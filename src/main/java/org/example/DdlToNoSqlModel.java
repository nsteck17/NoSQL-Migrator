package org.example;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import net.sf.jsqlparser.parser.CCJSqlParserUtil;
import net.sf.jsqlparser.statement.Statements;
import net.sf.jsqlparser.statement.create.table.*;

import java.util.*;
import java.util.stream.Collectors;

/**
 * Converts relational DDL to a NoSQL document model JSON (collections, documents, indexes, relationships).
 * Heuristics:
 *  - Each table -> collection
 *  - PK -> _id
 *  - FK: if table name suggests child-of (e.g., user_addresses), embed; else reference
 *  - Junction tables (composite PK of 2+ FKs or table name like users_roles) -> denormalize to array of scalar refs, or keep separate edge collection
 */
public class DdlToNoSqlModel {

    // Global map: DDL table name -> NoSQL collection object
    public static final Map<String, ObjectNode> tableToCollectionMap = new LinkedHashMap<>();


    // Overload for backward compatibility (no explicit embedding)
    public static String convertDdlToNoSqlDesign(String ddl, String databaseName) throws Exception {
        return convertDdlToNoSqlDesign(ddl, databaseName, null);
    }

    /**
     * Converts DDL to NoSQL design, with optional explicit parent-child embedding map.
     * @param ddl SQL DDL string
     * @param databaseName logical DB name
     * @param embedMap map of parent table name (lowercase) to list of child table names (lowercase) to embed
     * @return JSON string
     * @throws Exception on parse error
     */
    public static String convertDdlToNoSqlDesign(String ddl, String databaseName, Map<String, List<String>> embedMap) throws Exception {
        // Clear global map before conversion
        tableToCollectionMap.clear();

        // Remove TABLESPACE, PCTFREE, and STORAGE clauses from DDL
        ddl = ddl.replaceAll("(?i)TABLESPACE\\s+\\w+;?", "");
        ddl = ddl.replaceAll("(?i)PCTFREE\\s+\\d+;?", "");
        ddl = ddl.replaceAll("(?i)INITRANS\\s+\\d+;?", "");
        ddl = ddl.replaceAll("(?i)MAXTRANS\\s+\\d+;?", "");
        ddl = ddl.replaceAll("(?is)STORAGE\\s*\\(.*?\\)", "");
        Statements statements = CCJSqlParserUtil.parseStatements(ddl);
        List<CreateTable> creates = statements.getStatements().stream()
                .filter(s -> s instanceof CreateTable)
                .map(s -> (CreateTable) s)
                .collect(Collectors.toList());

        // Collect table metadata
        Map<String, TableMeta> tables = new LinkedHashMap<>();
        for (CreateTable ct : creates) {
            TableMeta meta = TableMeta.from(ct);
            tables.put(meta.qualifiedNameLower(), meta);
        }

        // Process ALTER TABLE ... ADD CONSTRAINT ... FOREIGN KEY ... statements
        for (Object stmt : statements.getStatements()) {
            if (stmt instanceof net.sf.jsqlparser.statement.alter.Alter) {
                net.sf.jsqlparser.statement.alter.Alter alter = (net.sf.jsqlparser.statement.alter.Alter) stmt;
                String tableName = alter.getTable().getName().toLowerCase(Locale.ROOT);
                TableMeta t = tables.get(tableName);
                if (t == null) continue;
                List<net.sf.jsqlparser.statement.alter.AlterExpression> exprs = alter.getAlterExpressions();
                if (exprs == null) continue;
                for (net.sf.jsqlparser.statement.alter.AlterExpression expr : exprs) {
                    if (expr.getOperation() == net.sf.jsqlparser.statement.alter.AlterOperation.ADD && expr.getFkColumns() != null && !expr.getFkColumns().isEmpty()) {
                        List<String> srcCols = expr.getFkColumns();
                        String refTable = null;
                        // Fallback: extract referenced table from expr.toString()
                        String exprStr = expr.toString().toUpperCase(Locale.ROOT);
                        int fkIdx = exprStr.indexOf("REFERENCES ");
                        if (fkIdx != -1) {
                            int start = fkIdx + "REFERENCES ".length();
                            int end = exprStr.indexOf(" ", start);
                            if (end == -1) end = exprStr.length();
                            refTable = exprStr.substring(start, end).replaceAll("[\"']", "").toLowerCase(Locale.ROOT);
                        }
                        List<String> refCols = expr.getFkSourceColumns();
                        if (srcCols != null && refTable != null) {
                            for (int i = 0; i < srcCols.size(); i++) {
                                String srcCol = srcCols.get(i).toLowerCase(Locale.ROOT);
                                String refCol = (refCols != null && i < refCols.size()) ? refCols.get(i).toLowerCase(Locale.ROOT) : "id";
                                ColumnMeta cm = t.columns.get(srcCol);
                                if (cm != null) {
                                    cm.references = new Ref(refTable, refCol);
                                }
                            }
                        }
                    }
                }
            }
        }

        // Build NoSQL design with true recursive embedding
        ObjectMapper mapper = new ObjectMapper();
        ObjectNode root = mapper.createObjectNode();
        root.put("database", databaseName);
        ArrayNode collections = root.putArray("collections");
        ArrayNode notes = root.putArray("notes");

        String defaultPartitionKey = guessPartitionKey(tables.keySet());
        Set<String> junctions = detectJunctionTables(tables);

        // Build parent-child map from FKs for embedding (child table as array in parent)
        Map<String, List<TableMeta>> parentToChildren = new HashMap<>();
        for (TableMeta t : tables.values()) {
            for (ColumnMeta c : t.columns.values()) {
                if (c.references != null) {
                    String parent = c.references.table;
                    parentToChildren.computeIfAbsent(parent, k -> new ArrayList<>()).add(t);
                }
            }
        }
        if (embedMap != null) {
            for (Map.Entry<String, List<String>> entry : embedMap.entrySet()) {
                String parent = entry.getKey().toLowerCase(Locale.ROOT);
                for (String child : entry.getValue()) {
                    String childLower = child.toLowerCase(Locale.ROOT);
                    TableMeta parentMeta = tables.get(parent);
                    TableMeta childMeta = tables.get(childLower);
                    if (parentMeta != null && childMeta != null) {
                        parentToChildren.computeIfAbsent(parent, k -> new ArrayList<>()).add(childMeta);
                    }
                }
            }
        }

        // Track which tables are embedded so we can skip them as top-level collections
        Set<String> embeddedChildren = new HashSet<>();
        for (Map.Entry<String, List<TableMeta>> entry : parentToChildren.entrySet()) {
            for (TableMeta child : entry.getValue()) {
                embeddedChildren.add(child.nameLower);
            }
        }

        // Recursive helper to build document fields and recursively embed children
        java.util.function.BiConsumer<ObjectNode, TableMeta> addFieldsAndEmbeddedChildren = new java.util.function.BiConsumer<>() {
            @Override
            public void accept(ObjectNode doc, TableMeta t) {
                Set<String> required = new LinkedHashSet<>();
                // _id
                String idField = "_id";
                addField(doc, idField, t.primaryKey.size() == 1 ? mapType(t.columns.get(t.primaryKey.get(0)).type) : "object");
                required.add(idField);
                // Other columns
                for (ColumnMeta c : t.columns.values()) {
                    if (t.primaryKey.contains(c.nameLower)) continue; // already mapped to _id
                    String fieldName = toCamel(c.name);
                    addField(doc, fieldName, mapType(c.type));
                    if (!c.nullable) required.add(fieldName);
                }
                // Embed children recursively
                List<TableMeta> children = parentToChildren.getOrDefault(t.nameLower, Collections.emptyList());
                for (TableMeta child : children) {
                    String arrayField = pluralize(toCamel(child.baseNameFromParent(t.nameLower)));
                    // Add array of child documents
                    ObjectNode arrayNode = doc.putArray(arrayField).addObject();
                    arrayNode.put("originalTable", child.name); // <-- Add originalTable field
                    accept(arrayNode, child);
                    notes.add("Embedded '" + child.name + "' into '" + t.name + "' as '" + arrayField + "'.");
                }
                // Store required fields for this doc (if at top level)
                ArrayNode reqArr = doc.putArray("_requiredFields");
                for (String req : required) reqArr.add(req);
            }
        };

        // Output only top-level collections (not embedded as children)
        for (TableMeta t : tables.values()) {
            if (junctions.contains(t.nameLower)) {
                notes.add("Junction table '" + t.name + "' detected; consider denormalizing into parent.");
                continue;
            }
            if (embeddedChildren.contains(t.nameLower)) {
                notes.add("Table '" + t.name + "' embedded in parent; not output as top-level collection.");
                continue;
            }
            ObjectNode coll = collections.addObject();
            coll.put("name", toCollectionName(t.name));
            tableToCollectionMap.put(t.nameLower, coll);
            ObjectNode doc = coll.putObject("document");
            addFieldsAndEmbeddedChildren.accept(doc, t);
            // Required
            ArrayNode req = coll.putArray("required");
            // Copy required fields from doc
            if (doc.has("_requiredFields")) {
                for (com.fasterxml.jackson.databind.JsonNode n : doc.get("_requiredFields")) req.add(n.asText());
                doc.remove("_requiredFields");
            }
            // Indexes
            ArrayNode idxs = coll.putArray("indexes");
            t.columns.values().stream().filter(c -> c.isUnique).forEach(c -> {
                ObjectNode ix = idxs.addObject();
                ix.put("name", "ux_" + t.nameLower + "_" + c.nameLower);
                ObjectNode keys = ix.putObject("keys");
                keys.put(toCamel(c.name), 1);
                ix.put("unique", true);
            });
            // FK reference relationships (non-embedded)
            ArrayNode rels = coll.putArray("relationships");
            for (ColumnMeta c : t.columns.values()) {
                if (c.references != null) {
                    boolean thisTableIsEmbedded = false;
                    List<TableMeta> parentChildren = parentToChildren.getOrDefault(c.references.table, Collections.emptyList());
                    for (TableMeta child : parentChildren) {
                        if (child.nameLower.equals(t.nameLower)) {
                            thisTableIsEmbedded = true;
                            break;
                        }
                    }
                    if (!thisTableIsEmbedded) {
                        ObjectNode r = rels.addObject();
                        r.put("type", "reference");
                        r.put("field", toCamel(c.name));
                        ObjectNode to = r.putObject("to");
                        to.put("collection", toCollectionName(c.references.table));
                        to.put("field", "_id");
                    }
                }
            }
            coll.put("partitionKey", choosePartitionKey(t, defaultPartitionKey));
        }

        return mapper.writerWithDefaultPrettyPrinter().writeValueAsString(root);
    }

    // ===== Helpers & Model =====

    static String toCollectionName(String tableName) {
        return tableName.toLowerCase(Locale.ROOT);
    }

    static String toCamel(String s) {
        String[] parts = s.split("_");
        StringBuilder out = new StringBuilder(parts[0].toLowerCase(Locale.ROOT));
        for (int i = 1; i < parts.length; i++) {
            if (parts[i].isEmpty()) continue;
            out.append(parts[i].substring(0,1).toUpperCase(Locale.ROOT)).append(parts[i].substring(1).toLowerCase(Locale.ROOT));
        }
        return out.toString();
    }

    static String pluralize(String s) {
        if (s.endsWith("s")) return s;
        return s + "s";
    }

    static void addField(ObjectNode node, String name, String type) {
        node.put(name, type);
    }

    static String mapType(String sqlType) {
        String t = sqlType.toUpperCase(Locale.ROOT);
        if (t.contains("CHAR") || t.contains("TEXT") || t.contains("UUID")) return "string";
        if (t.contains("INT") || t.contains("DECIMAL") || t.contains("NUMERIC") || t.contains("FLOAT") || t.contains("DOUBLE") || t.contains("REAL")) return "number";
        if (t.contains("BOOL")) return "boolean";
        if (t.contains("DATE") || t.contains("TIME")) return "date";
        if (t.contains("JSON")) return "object";
        return "string"; // safe default
    }
    static String guessPartitionKey(Set<String> tableNames) {
        // Very simple heuristic: org, tenant, account preference
        for (String n : tableNames) {
            if (n.contains("org")) return "orgId";
            if (n.contains("tenant")) return "tenantId";
            if (n.contains("account")) return "accountId";
        }
        return "_id";
    }
    static String choosePartitionKey(TableMeta t, String defaultPk) {
        // Prefer an FK like org_id or tenant_id if present
        for (String pref : List.of("org_id", "tenant_id", "account_id")) {
            if (t.columns.containsKey(pref)) return toCamel(pref);
        }
        return defaultPk;
    }

    static Set<String> detectJunctionTables(Map<String, TableMeta> tables) {
        Set<String> out = new HashSet<>();
        for (TableMeta t : tables.values()) {
            long fkCount = t.columns.values().stream().filter(c -> c.references != null).count();
            boolean compositePk = t.primaryKey.size() >= 2;
            boolean nameLooksLike = t.nameLower.contains("_") && t.nameLower.split("_").length >= 2;
            if (compositePk && fkCount >= 2) out.add(t.nameLower);
            else if (nameLooksLike && fkCount >= 2) out.add(t.nameLower);
        }
        return out;
    }

    static Map<String, List<TableMeta>> detectChildTables(Map<String, TableMeta> tables) {
        Map<String, List<TableMeta>> res = new HashMap<>();
        for (TableMeta t : tables.values()) {
            for (ColumnMeta c : t.columns.values()) {
                if (c.references != null) {
                    String parent = c.references.table;
                    // Name-based rule: a table named {parent}_* or singular child suggests embedding
                    if (t.nameLower.startsWith(parent + "_") || t.nameLower.endsWith("_" + parent)) {
                        res.computeIfAbsent(parent, k -> new ArrayList<>()).add(t);
                    }
                }
            }
        }
        return res;
    }

    static class TableMeta {
        String schema;
        String name;
        String nameLower;
        Map<String, ColumnMeta> columns = new LinkedHashMap<>();
        List<String> primaryKey = new ArrayList<>();

        static TableMeta from(CreateTable ct) {
            TableMeta t = new TableMeta();
            t.schema = (ct.getTable().getSchemaName() != null) ? ct.getTable().getSchemaName() : "";
            t.name = ct.getTable().getName();
            t.nameLower = t.name.toLowerCase(Locale.ROOT);

            // Ignore tablespace and other table options
            if (ct.getTableOptionsStrings() != null) {
                // Remove any table options containing 'TABLESPACE'
                ct.setTableOptionsStrings(ct.getTableOptionsStrings().stream()
                        .filter(opt -> !opt.toUpperCase(Locale.ROOT).contains("TABLESPACE"))
                        .collect(Collectors.toList()));
            }

            if (ct.getColumnDefinitions() != null) {
                for (ColumnDefinition cd : ct.getColumnDefinitions()) {
                    ColumnMeta c = ColumnMeta.from(cd);
                    t.columns.put(c.nameLower, c);
                }
            }
            if (ct.getIndexes() != null) {
                for (Index idx : ct.getIndexes()) {
                    String type = idx.getType() != null ? idx.getType().toUpperCase(Locale.ROOT) : "";
                    List<String> cols = new ArrayList<>();
                    if (idx.getColumnsNames() != null) {
                        for (String cn : idx.getColumnsNames()) cols.add(cn.toLowerCase(Locale.ROOT).replace("\"",""));
                    }
                    if ("PRIMARY KEY".equals(type)) {
                        t.primaryKey.addAll(cols);
                    } else if ("UNIQUE".equals(type)) {
                        for (String cn : cols) {
                            ColumnMeta cm = t.columns.get(cn);
                            if (cm != null) cm.isUnique = true;
                        }
                    } else if ("FOREIGN KEY".equals(type) && idx instanceof ForeignKeyIndex) {
                        ForeignKeyIndex fk = (ForeignKeyIndex) idx;
                        List<String> srcs = fk.getColumnsNames().stream().map(s -> s.toLowerCase(Locale.ROOT)).collect(Collectors.toList());
                        String refTable = fk.getTable().getName().toLowerCase(Locale.ROOT);
                        List<String> refs = fk.getReferencedColumnNames() != null
                                ? fk.getReferencedColumnNames().stream().map(s -> s.toLowerCase(Locale.ROOT)).collect(Collectors.toList())
                                : Collections.emptyList();
                        for (int i = 0; i < srcs.size(); i++) {
                            String col = srcs.get(i);
                            ColumnMeta cm = t.columns.get(col);
                            if (cm != null) {
                                cm.references = new Ref(refTable, refs.isEmpty() ? "id" : refs.get(i));
                            }
                        }
                    }
                }
            }
            // Column-level PK/Unique/Nullable inference
            for (ColumnMeta c : t.columns.values()) {
                if (c.colSpecsUpper.contains("PRIMARY KEY")) t.primaryKey.add(c.nameLower);
                if (c.colSpecsUpper.contains("UNIQUE")) c.isUnique = true;
            }
            // Default PK if missing
            if (t.primaryKey.isEmpty()) {
                if (t.columns.containsKey("id")) t.primaryKey.add("id");
            }
            return t;
        }

        String qualifiedNameLower() {
            return nameLower;
        }

        String baseNameFromParent(String parentLower) {
            if (nameLower.startsWith(parentLower + "_")) return nameLower.substring((parentLower + "_").length());
            if (nameLower.endsWith("_" + parentLower)) return nameLower.substring(0, nameLower.length() - ("_" + parentLower).length());
            return nameLower;
        }
    }

    static class ColumnMeta {
        String name;
        String nameLower;
        String type;
        boolean nullable = true;
        boolean isUnique = false;
        Ref references;
        String colSpecsUpper;

        static ColumnMeta from(ColumnDefinition cd) {
            ColumnMeta c = new ColumnMeta();
            c.name = cd.getColumnName();
            c.nameLower = c.name.toLowerCase(Locale.ROOT);
            c.type = cd.getColDataType() != null ? cd.getColDataType().getDataType() : "UNKNOWN";
            List<String> specs = cd.getColumnSpecs();
            String joined = specs != null ? String.join(" ", specs) : "";
            c.colSpecsUpper = joined.toUpperCase(Locale.ROOT);
            if (c.colSpecsUpper.contains("NOT NULL")) c.nullable = false;
            if (c.colSpecsUpper.contains("UNIQUE")) c.isUnique = true;
            // Heuristic FK if named like *_id and a table exists (filled later if using Indexes)
            // Detect inline REFERENCES clause
            if (specs != null) {
                for (int i = 0; i < specs.size(); i++) {
                    String s = specs.get(i).toUpperCase(Locale.ROOT);
                    if (s.equals("REFERENCES") && i + 1 < specs.size()) {
                        String refTable = specs.get(i + 1).replaceAll("[\"']", "").toLowerCase(Locale.ROOT);
                        String refCol = "id";
                        if (i + 2 < specs.size() && specs.get(i + 2).startsWith("(")) {
                            refCol = specs.get(i + 2).replaceAll("[()\"']", "").toLowerCase(Locale.ROOT);
                        }
                        c.references = new Ref(refTable, refCol);
                    }
                }
            }
            return c;
        }
    }

    static class Ref {
        String table;
        String column;
        Ref(String table, String column) { this.table = table; this.column = column; }
    }

    public static void main(String[] args) throws Exception {
        // No demo logic here. Use App.java to invoke this class with desired embedding.
    }
}
