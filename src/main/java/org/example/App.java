package org.example;

import java.nio.file.Files;
import java.nio.file.Paths;
import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;

/**
 * Hello world!
 *
 */
public class App 
{


    /**
     * Writer that writes to two destinations: a file and System.out (no duplicate output)
     */
    static class DualWriter extends java.io.Writer {
        private final java.io.Writer fileWriter;
        private final java.io.PrintStream console;
        public DualWriter(java.io.Writer fileWriter, java.io.PrintStream console) {
            this.fileWriter = fileWriter;
            this.console = console;
        }
        @Override
        public void write(char[] cbuf, int off, int len) throws IOException {
            fileWriter.write(cbuf, off, len);
            console.print(new String(cbuf, off, len));
        }
        @Override
        public void flush() throws IOException {
            fileWriter.flush();
            console.flush();
        }
        @Override
        public void close() throws IOException {
            fileWriter.close();
            // Do not close System.out
        }
    }


    /**
     * Infers parent-child embedding relationships from DDL using ONLY FK relationships (not naming).
     * Supports multi-level (recursive) embedding.
     * Returns a map: parent table (lowercase) -> list of child tables (lowercase) to embed.
     */
    public static java.util.Map<String, java.util.List<String>> inferEmbedMapFromDdl(String ddl) {
        java.util.Map<String, java.util.List<String>> embedMap = new java.util.HashMap<>();
        // Find all FKs: alter table <child> add constraint ... foreign key (...) references <parent> (...)
        java.util.regex.Pattern fkPattern = java.util.regex.Pattern.compile(
            "(?i)alter table\\s+([A-Za-z0-9_\\.]+)\\s+add constraint\\s+(\\w+)\\s+foreign key\\s*\\(([^)]+)\\)\\s+references\\s+([A-Za-z0-9_\\.]+)\\s*\\(([^)]+)\\)");
        java.util.regex.Matcher matcher = fkPattern.matcher(ddl);
        java.util.Map<String, java.util.List<String>> parentToChildren = new java.util.HashMap<>();
        while (matcher.find()) {
            String childTable = matcher.group(1).replaceAll("^[A-Za-z0-9_]*\\.", "").toLowerCase();
            String parentTable = matcher.group(4).replaceAll("^[A-Za-z0-9_]*\\.", "").toLowerCase();
            parentToChildren.computeIfAbsent(parentTable, k -> new java.util.ArrayList<>()).add(childTable);
        }
        // Recursively build embedMap for multi-level embedding
        java.util.Set<String> visited = new java.util.HashSet<>();
        for (String parent : parentToChildren.keySet()) {
            buildEmbedMapRecursive(parent, parentToChildren, embedMap, visited);
        }
        // Debug: Print embedMap to verify relationships
        System.out.println("Embed Map: " + embedMap);
        return embedMap;
    }

    private static void buildEmbedMapRecursive(String parent, java.util.Map<String, java.util.List<String>> parentToChildren,
                                               java.util.Map<String, java.util.List<String>> embedMap, java.util.Set<String> visited) {
        if (visited.contains(parent)) return;
        visited.add(parent);
        java.util.List<String> children = parentToChildren.get(parent);
        if (children != null) {
            for (String child : children) {
                embedMap.computeIfAbsent(parent, k -> new java.util.ArrayList<>()).add(child);
                buildEmbedMapRecursive(child, parentToChildren, embedMap, visited);
            }
        }
    }

    public static void main( String[] args ){
        //===================================================
        // Generate a timestamped output folder and filename
        //===================================================
        String timestamp = new java.text.SimpleDateFormat("yyyyMMdd_HHmmss").format(new java.util.Date());
        String outputDir = "output_" + timestamp;
        java.nio.file.Path outputDirPath = java.nio.file.Paths.get(outputDir);
        try {
            java.nio.file.Files.createDirectories(outputDirPath);
        } catch (IOException e) {
            System.err.println("Failed to create output directory: " + outputDir);
            e.printStackTrace();
            return;
        }
        String outputFile = outputDir + "/output_" + timestamp + ".txt";
        String tableToCollectionsFile = outputDir + "/table_to_collections.json";

        try (
            FileWriter fileWriter = new FileWriter(outputFile);
            DualWriter dualWriter = new DualWriter(fileWriter, System.out);
            PrintWriter printDualWriter = new PrintWriter(dualWriter, true)
        ) {
            //===========================================================================================================
            //Import Create-Only-DDL.sql and run DdlToNoSqlModel.java convertDdlToNoSqlDesign
            //===========================================================================================================
            try {
                // Read DDL from file
                String ddl = new String(Files.readAllBytes(Paths.get("src/main/java/ref/DDL.sql")));
                // Build embedding map automatically
                java.util.Map<String, java.util.List<String>> embedMap = inferEmbedMapFromDdl(ddl);
                String json = DdlToNoSqlModel.convertDdlToNoSqlDesign(ddl, "appdb", embedMap);
                // Use dualWriter for all output
                printDualWriter.write(json + "\n");
                printDualWriter.write("\n--- DDL Table to NoSQL Collection Map ---\n");
                com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
                // Remove 'indexes' and 'relationships' from each collection object using Jackson's ObjectNode
                java.util.Map<String, com.fasterxml.jackson.databind.JsonNode> sanitizedMap = new java.util.HashMap<>();
                DdlToNoSqlModel.tableToCollectionMap.forEach((table, collectionObj) -> {
                    com.fasterxml.jackson.databind.JsonNode node = mapper.valueToTree(collectionObj);
                    if (node.isObject()) {
                        com.fasterxml.jackson.databind.node.ObjectNode objNode = (com.fasterxml.jackson.databind.node.ObjectNode) node;
                        objNode.remove("indexes");
                        objNode.remove("relationships");
                    }
                    sanitizedMap.put(table, node);
                });
                try {
                    mapper.writerWithDefaultPrettyPrinter().writeValue(new java.io.File(tableToCollectionsFile), sanitizedMap);
                    printDualWriter.write("All table-to-collection mappings written to: " + tableToCollectionsFile + " (without indexes/relationships)\n");
                } catch (Exception ex) {
                    printDualWriter.write("Error writing table-to-collections JSON file: " + ex.getMessage() + "\n");
                }

                //===========================================================================================================
                // Extract and print FK relationships from DDL
                //===========================================================================================================
                printDualWriter.write("\n--- Foreign Key Relationships ---\n");
                java.util.regex.Pattern fkPattern = java.util.regex.Pattern.compile(
                    "(?i)CONSTRAINT\\s+(\\w+)\\s+FOREIGN KEY\\s*\\(([^)]+)\\)\\s+REFERENCES\\s+([^(\\s]+)\\s*\\(([^)]+)\\)");
                java.util.regex.Matcher matcher = fkPattern.matcher(ddl);
                boolean foundFk = false;
                while (matcher.find()) {
                    foundFk = true;
                    String constraintName = matcher.group(1);
                    String fkCols = matcher.group(2).replaceAll("\\s", "");
                    String refTable = matcher.group(3);
                    String refCols = matcher.group(4).replaceAll("\\s", "");
                    printDualWriter.write(String.format(
                        "Constraint: %s\n  Foreign Key: (%s)\n  References: %s(%s)\n",
                        constraintName, fkCols, refTable, refCols));
                }
                if (!foundFk) {
                    printDualWriter.write("No foreign key relationships found.\n");
                }

                //===========================================================================================================
                // Load cleaned-DML.sql and analyze SQL statements
                //===========================================================================================================
                String dml = new String(Files.readAllBytes(Paths.get("src/main/java/ref/cleaned-DML.sql")));
                org.example.DmlAnalysis.parseSqlStatements(dml);
                java.util.Map<String, java.util.function.Predicate<String>> checks = new java.util.HashMap<>();
                checks.put("Contains JOIN", org.example.DmlAnalysis::containsJoin);
                // Boolean check: true if there are tables in JOINs
                checks.put("Has JOIN tables", sql -> !org.example.DmlAnalysis.getJoinTables(sql).isEmpty());

                // Build a set of all valid JSON names (top-level and embedded) and a map for embedded property to parent collection
                java.util.Set<String> allJsonNames = new java.util.HashSet<>();
                java.util.Set<String> embeddedJsonNames = new java.util.HashSet<>();
                java.util.Map<String, String> embeddedToParent = new java.util.HashMap<>();
                // Helper to recursively collect embedded property names
                java.util.function.BiConsumer<com.fasterxml.jackson.databind.JsonNode, String> collectNames = new java.util.function.BiConsumer<com.fasterxml.jackson.databind.JsonNode, String>() {
                    @Override
                    public void accept(com.fasterxml.jackson.databind.JsonNode node, String parent) {
                        if (node == null || !node.isObject()) return;
                        node.fieldNames().forEachRemaining(field -> {
                            allJsonNames.add(field.toLowerCase());
                            if (parent != null) {
                                embeddedJsonNames.add(field.toLowerCase());
                                embeddedToParent.put(field.toLowerCase(), parent);
                            }
                            com.fasterxml.jackson.databind.JsonNode child = node.get(field);
                            if (child.isArray() && child.size() > 0 && child.get(0).isObject()) {
                                // For arrays of objects, recurse into the first element
                                accept(child.get(0), field.toLowerCase());
                            } else if (child.isObject()) {
                                accept(child, field.toLowerCase());
                            }
                        });
                    }
                };
                // Traverse all collections
                sanitizedMap.values().forEach(jsonNode -> {
                    if (jsonNode.has("name")) allJsonNames.add(jsonNode.get("name").asText().toLowerCase());
                    if (jsonNode.has("document")) collectNames.accept(jsonNode.get("document"), jsonNode.has("name") ? jsonNode.get("name").asText().toLowerCase() : null);
                });

                // Build a map from table name to all its NoSQL representations (top-level and embedded)
                java.util.Map<String, java.util.Set<String>> tableToAllNoSqlNames = new java.util.HashMap<>();
                // Add top-level collection names
                DdlToNoSqlModel.tableToCollectionMap.forEach((table, collectionObj) -> {
                    String tableName = table.toLowerCase();
                    tableToAllNoSqlNames.computeIfAbsent(tableName, k -> new java.util.HashSet<>());
                    if (collectionObj instanceof java.util.Map) {
                        Object nameObj = ((java.util.Map<?, ?>) collectionObj).get("name");
                        if (nameObj != null) tableToAllNoSqlNames.get(tableName).add(nameObj.toString().toLowerCase());
                    }
                });
                // Add embedded property names for each table
                sanitizedMap.forEach((table, jsonNode) -> {
                    String tableName = table.toLowerCase();
                    if (jsonNode.has("document")) {
                        java.util.function.BiConsumer<com.fasterxml.jackson.databind.JsonNode, String> collectEmbedded = new java.util.function.BiConsumer<com.fasterxml.jackson.databind.JsonNode, String>() {
                            @Override
                            public void accept(com.fasterxml.jackson.databind.JsonNode node, String parent) {
                                if (node == null || !node.isObject()) return;
                                node.fieldNames().forEachRemaining(field -> {
                                    if (!field.equals("_id") && !field.equals("_requiredFields") && !field.equals("partitionKey")) {
                                        tableToAllNoSqlNames.computeIfAbsent(tableName, k -> new java.util.HashSet<>()).add(field.toLowerCase());
                                    }
                                    com.fasterxml.jackson.databind.JsonNode child = node.get(field);
                                    if (child.isArray() && child.size() > 0 && child.get(0).isObject()) {
                                        accept(child.get(0), field.toLowerCase());
                                    } else if (child.isObject()) {
                                        accept(child, field.toLowerCase());
                                    }
                                });
                            }
                        };
                        collectEmbedded.accept(jsonNode.get("document"), null);
                    }
                });

                // Build a map: original table name -> set of all property names (top-level and embedded) it is represented as
                // Build a map: original table name -> set of all property names (top-level and embedded) it is represented as
                // Build a map: table name -> set of all property names (top-level and embedded) it is represented as
                java.util.Map<String, java.util.Set<String>> tableToAllProperties = new java.util.HashMap<>();
                // Map: table name (lowercase) -> list of (parentCollection, propertyName) pairs where it is embedded
                java.util.Map<String, java.util.List<String[]>> tableToParentAndProperty = new java.util.HashMap<>();
                // Add top-level collection names
                DdlToNoSqlModel.tableToCollectionMap.forEach((table, collectionObj) -> {
                    String tableName = table.toLowerCase();
                    tableToAllProperties.computeIfAbsent(tableName, k -> new java.util.HashSet<>()).add(tableName);
                    if (collectionObj instanceof java.util.Map) {
                        Object nameObj = ((java.util.Map<?, ?>) collectionObj).get("name");
                        if (nameObj != null) {
                            String jsonName = nameObj.toString().toLowerCase();
                            tableToAllProperties.get(tableName).add(jsonName);
                            tableToParentAndProperty.computeIfAbsent(tableName, k -> new java.util.ArrayList<>()).add(new String[]{jsonName, jsonName});
                        }
                    }
                });
                // Recursively add embedded property names for each table, using 'originalTable' field
                sanitizedMap.forEach((table, jsonNode) -> {
                    String parentCollection = null;
                    if (jsonNode.has("name")) parentCollection = jsonNode.get("name").asText().toLowerCase();
                    if (jsonNode.has("document")) {
                        java.util.function.BiConsumer<com.fasterxml.jackson.databind.JsonNode, String> collectEmbedded = new java.util.function.BiConsumer<com.fasterxml.jackson.databind.JsonNode, String>() {
                            @Override
                            public void accept(com.fasterxml.jackson.databind.JsonNode node, String parentColl) {
                                if (node == null || !node.isObject()) return;
                                node.fieldNames().forEachRemaining(field -> {
                                    com.fasterxml.jackson.databind.JsonNode child = node.get(field);
                                    // If this is an embedded array/object with 'originalTable', record the mapping
                                    if (child.isArray() && child.size() > 0 && child.get(0).isObject() && child.get(0).has("originalTable")) {
                                        String origTable = child.get(0).get("originalTable").asText().toLowerCase();
                                        tableToParentAndProperty.computeIfAbsent(origTable, k -> new java.util.ArrayList<>()).add(new String[]{parentColl, field.toLowerCase()});
                                        tableToAllProperties.computeIfAbsent(origTable, k -> new java.util.HashSet<>()).add(field.toLowerCase());
                                        // Recurse into the embedded object
                                        accept(child.get(0), parentColl);
                                    } else if (child.isObject()) {
                                        accept(child, parentColl);
                                    }
                                });
                            }
                        };
                        collectEmbedded.accept(jsonNode.get("document"), parentCollection);
                    }
                });

                // Build a map of lowercased table names to lowercased JSON collection names
                java.util.Map<String, String> tableAndJsonNames = new java.util.HashMap<>();
                DdlToNoSqlModel.tableToCollectionMap.forEach((table, collectionObj) -> {
                    String tableName = table.toLowerCase();
                    String jsonName = "";
                    if (collectionObj instanceof java.util.Map) {
                        Object nameObj = ((java.util.Map<?, ?>) collectionObj).get("name");
                        if (nameObj != null) jsonName = nameObj.toString().toLowerCase();
                    }
                    tableAndJsonNames.put(tableName, jsonName);
                });

                // Add check if all the tables in the Join are found in the DDL (i.e. they are real tables, not views or temp tables)
                // Track missing JOIN tables and match diagnostics for each SQL statement
                java.util.Map<Integer, java.util.List<String>> missingJoinTablesPerStatement = new java.util.HashMap<>();
                java.util.Map<Integer, java.util.List<String>> joinTableMatchDiagnostics = new java.util.HashMap<>();
                checks.put("All JOIN tables in DDL", sql -> {
                    java.util.List<String> joinTables = org.example.DmlAnalysis.getJoinTables(sql);
                    java.util.List<String> missing = new java.util.ArrayList<>();
                    java.util.List<String> diagnostics = new java.util.ArrayList<>();
                    for (String table : joinTables) {
                        String tableLc = table.toLowerCase();
                        boolean found = false;
                        String foundAs = null;
                        // Direct match: table name or mapped property
                        if (tableToAllProperties.containsKey(tableLc)) {
                            found = true;
                            foundAs = "direct match as table or mapped property";
                        } else {
                            // Try semantic mapping: does this JOIN table match a table that is mapped to a property with a different name?
                            java.util.List<String[]> parentAndPropList = tableToParentAndProperty.get(tableLc);
                            if (parentAndPropList != null && !parentAndPropList.isEmpty()) {
                                found = true;
                                StringBuilder sb = new StringBuilder();
                                for (String[] pair : parentAndPropList) {
                                    sb.append("table '").append(tableLc).append("' is mapped as property '").append(pair[1]).append("' under collection '").append(pair[0]).append("', ");
                                }
                                foundAs = sb.substring(0, sb.length() - 2);
                            }
                        }
                        if (!found) {
                            missing.add(table + " (not found as table or embedded property in NoSQL schema)");
                        } else if (foundAs != null) {
                            diagnostics.add(table + " (" + foundAs + ")");
                        }
                    }
                    // Store missing tables and diagnostics for this statement index
                    int idx = org.example.DmlAnalysis.getGlobalSqlStatements().indexOf(sql);
                    if (!missing.isEmpty()) {
                        missingJoinTablesPerStatement.put(idx, missing);
                    } else {
                        missingJoinTablesPerStatement.remove(idx);
                    }
                    if (!diagnostics.isEmpty()) {
                        joinTableMatchDiagnostics.put(idx, diagnostics);
                    } else {
                        joinTableMatchDiagnostics.remove(idx);
                    }
                    return missing.isEmpty();
                });

                printDualWriter.write("\n--- DML SQL Analysis ---\n");
                // Custom display logic to show missing JOIN tables if any
                java.util.List<java.util.Map<String, Boolean>> results = org.example.DmlAnalysis.checkAllSql(checks);
                java.util.List<String> sqls = org.example.DmlAnalysis.getGlobalSqlStatements();
                for (int i = 0; i < sqls.size(); i++) {
                    printDualWriter.write("SQL Statement " + (i + 1) + ":\n");
                    printDualWriter.write(sqls.get(i) + "\n");
                    java.util.Map<String, Boolean> checkResult = results.get(i);
                    for (java.util.Map.Entry<String, Boolean> entry : checkResult.entrySet()) {
                        printDualWriter.write("  " + entry.getKey() + ": " + entry.getValue() + "\n");
                        if ("All JOIN tables in DDL".equals(entry.getKey())) {
                            java.util.List<String> missing = missingJoinTablesPerStatement.get(i);
                            java.util.List<String> diagnostics = joinTableMatchDiagnostics.get(i);
                            if (missing != null && !missing.isEmpty()) {
                                printDualWriter.write("    Reason: Missing tables in DDL: " + String.join(", ", missing) + "\n");
                            }
                            if (diagnostics != null && !diagnostics.isEmpty()) {
                                printDualWriter.write("    JOIN table match details: " + String.join(", ", diagnostics) + "\n");
                            }
                        }
                    }
                    //Heuristic check for embedded property WHERE clause usage
                    // Heuristic: Check for WHERE clause comparisons on columns in embedded list properties
                    // If a column in WHERE is of the form embeddedProperty.column, and embeddedProperty is an embedded property,
                    // check if the original table for that property is present in the SQL statement. If not, flag as a potential issue.
                    java.util.List<java.util.List<String>> whereColumns = org.example.DmlAnalysis.getAllWhereClauseColumnsJSqlParser();
                    java.util.List<java.util.List<String>> whereOperators = org.example.DmlAnalysis.getAllWhereClauseOperatorsJSqlParser();
                    if (i < whereColumns.size()) {
                        java.util.List<String> cols = whereColumns.get(i);
                        for (String col : cols) {
                            // Check for dot notation: embeddedProperty.column
                            int dotIdx = col.indexOf('.');
                            if (dotIdx > 0) {
                                String embeddedProp = col.substring(0, dotIdx).toLowerCase();
                                // Is this an embedded property?
                                if (embeddedToParent.containsKey(embeddedProp)) {
                                    // Try to find the original table for this embedded property
                                    // We'll use tableToParentAndProperty to map property to original table
                                    // Reverse lookup: find which table has this property as an embedded property
                                    String origTable = null;
                                    for (java.util.Map.Entry<String, java.util.List<String[]>> entry : tableToParentAndProperty.entrySet()) {
                                        for (String[] pair : entry.getValue()) {
                                            if (pair[1].equals(embeddedProp)) {
                                                origTable = entry.getKey();
                                                break;
                                            }
                                        }
                                        if (origTable != null) break;
                                    }
                                    if (origTable != null) {
                                        // Check if original table is present in the SQL statement (case-insensitive)
                                        String sqlLower = sqls.get(i).toLowerCase();
                                        if (!sqlLower.contains(origTable)) {
                                            printDualWriter.write("  WARNING: WHERE clause compares column '" + col + "' (from embedded property '" + embeddedProp + "', original table '" + origTable + "'), but the original table is not present in the SQL statement. This may not be supported in NoSQL.\n");
                                        }
                                    }
                                }
                            }
                        }
                    }
                    // Additional check: If the main table in FROM clause is not a root-level collection, warn if query filters on its columns
                    java.util.List<String> mainTables = org.example.DmlAnalysis.getJoinTables(sqls.get(i));
                    for (String mainTable : mainTables) {
                        String mainTableLc = mainTable.toLowerCase();
                        // Only warn if this is not a root-level collection (i.e., not in tableToCollectionMap)
                        if (!DdlToNoSqlModel.tableToCollectionMap.containsKey(mainTableLc)) {
                            // Only warn if WHERE clause contains a '<' operator (not for '=')
                            if (i < whereOperators.size() && whereOperators.get(i).contains("<")) {
                                printDualWriter.write("  WARNING: Query filters on columns of table '" + mainTable + "' using '<', which is not a root-level collection in NoSQL. Such queries are not supported.\n");
                            }
                        }
                    }
                    // Output columns used in WHERE clause for this statement
                    if (i < whereColumns.size()) {
                        java.util.List<String> cols = whereColumns.get(i);
                        printDualWriter.write("  Columns in WHERE clause: " + (cols.isEmpty() ? "None" : String.join(", ", cols)) + "\n");
                        // Also output operators for debugging
                        if (i < whereOperators.size()) {
                            java.util.List<String> ops = whereOperators.get(i);
                            printDualWriter.write("  Operators in WHERE clause: " + (ops.isEmpty() ? "None" : String.join(", ", ops)) + "\n");
                        }
                    }
                    printDualWriter.write("\n");
                }
                printDualWriter.flush();

                //===========================================================================================================
                // Suggest parent-child embedding for NoSQL based on FK relationships
                //===========================================================================================================
                printDualWriter.write("\n--- Suggested Parent-Child Embedding for NoSQL ---\n");
                matcher.reset(); // reuse matcher on same DDL
                java.util.List<String[]> parentChildPairs = new java.util.ArrayList<>();
                while (matcher.find()) {
                    String childTable = null;
                    String parentTable = null;
                    // Find the table name preceding the constraint
                    int constraintStart = matcher.start();
                    int tableNameEnd = ddl.lastIndexOf("create table", constraintStart);
                    if (tableNameEnd != -1) {
                        // Extract table name after 'create table'
                        int nameStart = tableNameEnd + "create table".length();
                        int nameEnd = ddl.indexOf("(", nameStart);
                        if (nameEnd != -1) {
                            String tableName = ddl.substring(nameStart, nameEnd).trim().replaceAll("\\s+", "");
                            childTable = tableName;
                        }
                    }
                    parentTable = matcher.group(3).replaceAll("\\s", "");
                    if (childTable != null && parentTable != null) {
                        parentChildPairs.add(new String[]{parentTable, childTable});
                        printDualWriter.write(String.format("Parent: %s, Child: %s  =>  Suggest: Embed %s as a list in %s\n", parentTable, childTable, childTable, parentTable));
                    }
                }
                if (parentChildPairs.isEmpty()) {
                    printDualWriter.write("No parent-child relationships found for embedding.\n");
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
