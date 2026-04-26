package org.example;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.function.Predicate;
import java.util.Map;
import java.util.HashMap;
import java.io.BufferedWriter;
import java.io.IOException;
import java.io.PrintWriter;
import net.sf.jsqlparser.parser.CCJSqlParserUtil;
import net.sf.jsqlparser.statement.select.Select;
import net.sf.jsqlparser.statement.Statement;
import net.sf.jsqlparser.statement.select.PlainSelect;
import net.sf.jsqlparser.expression.Expression;
import net.sf.jsqlparser.expression.ExpressionVisitorAdapter;
import net.sf.jsqlparser.schema.Column;

public class DmlAnalysis {
    // Global array to store parsed SQL statements
    private static final List<String> globalSqlStatements = new ArrayList<>();
    // Global array to store columns used in WHERE clauses (indexes needed)
    private static final List<List<String>> globalWhereClauseColumns = new ArrayList<>();

    /**
     * Parses the input SQL string and extracts individual SQL statements.
     * Stores them in the global array.
     * Handles semicolons inside strings and comments.
     * @param sqlContent The content of the SQL file as a string.
     * @return List of parsed SQL statements.
     */
    public static List<String> parseSqlStatements(String sqlContent) {
        List<String> statements = new ArrayList<>();
        StringBuilder sb = new StringBuilder();
        boolean inString = false;
        char stringChar = '\0';
        boolean inLineComment = false;
        boolean inBlockComment = false;
        for (int i = 0; i < sqlContent.length(); i++) {
            char c = sqlContent.charAt(i);
            char next = i + 1 < sqlContent.length() ? sqlContent.charAt(i + 1) : '\0';
            // Handle string literals
            if (!inLineComment && !inBlockComment) {
                if (!inString && (c == '\'' || c == '"')) {
                    inString = true;
                    stringChar = c;
                } else if (inString && c == stringChar) {
                    // Check for escaped quote
                    if (i + 1 < sqlContent.length() && sqlContent.charAt(i + 1) == stringChar) {
                        sb.append(c); // Escaped quote
                        i++; // Skip next
                        continue;
                    } else {
                        inString = false;
                        stringChar = '\0';
                    }
                }
            }
            // Handle comments
            if (!inString) {
                if (!inLineComment && !inBlockComment && c == '-' && next == '-') {
                    inLineComment = true;
                } else if (!inLineComment && !inBlockComment && c == '/' && next == '*') {
                    inBlockComment = true;
                } else if (inLineComment && c == '\n') {
                    inLineComment = false;
                } else if (inBlockComment && c == '*' && next == '/') {
                    inBlockComment = false;
                    i++; // Skip /
                    continue;
                }
            }
            sb.append(c);
            // Split on semicolon if not in string or comment
            if (!inString && !inLineComment && !inBlockComment && c == ';') {
                String stmt = sb.toString().trim();
                if (!stmt.isEmpty()) {
                    statements.add(stmt);
                }
                sb.setLength(0);
            }
        }
        // Add last statement if any
        String last = sb.toString().trim();
        if (!last.isEmpty()) {
            statements.add(last);
        }
        globalSqlStatements.clear();
        globalSqlStatements.addAll(statements);
        // Populate globalWhereClauseColumns
        globalWhereClauseColumns.clear();
        for (String sql : globalSqlStatements) {
            globalWhereClauseColumns.add(getWhereClauseColumns(sql));
        }
        return statements;
    }

    /**
     * Returns the global list of parsed SQL statements.
     * @return List of SQL statements.
     */
    public static List<String> getGlobalSqlStatements() {
        return globalSqlStatements;
    }

    /**
     * Returns the global list of columns used in WHERE clauses for all SQL statements.
     * Each inner list corresponds to a statement.
     */
    public static List<List<String>> getGlobalWhereClauseColumns() {
        return globalWhereClauseColumns;
    }

    /**
     * Checks if the given SQL string contains a JOIN clause (case-insensitive).
     * @param sql The SQL statement to check.
     * @return true if a JOIN clause is present, false otherwise.
     */
    public static boolean containsJoin(String sql) {
        if (sql == null) return false;
        // Use Pattern/Matcher to find JOIN as a word, case-insensitive, anywhere in the string
        Pattern joinPattern = Pattern.compile("\\bJOIN\\b", Pattern.CASE_INSENSITIVE);
        Matcher matcher = joinPattern.matcher(sql);
        return matcher.find();
    }

    /**
     * Extracts the table names involved in JOIN clauses from a SQL statement.
     * Uses JSqlParser to robustly handle various JOIN types and multiple JOINs.
     *
     * @param sql The SQL statement to analyze.
     * @return List of table names involved in JOINs. Empty if none or not a SELECT.
     */
    public static List<String> getJoinTables(String sql) {
        List<String> joinTables = new ArrayList<>();
        if (sql == null) return joinTables;
        try {
            Statement statement = CCJSqlParserUtil.parse(sql);
            if (statement instanceof Select) {
                Select select = (Select) statement;
                if (select.getSelectBody() instanceof PlainSelect) {
                    PlainSelect plainSelect = (PlainSelect) select.getSelectBody();
                    // Handle main FROM table if present
                    if (plainSelect.getFromItem() != null) {
                        String fromTable = plainSelect.getFromItem().toString();
                        // Only add if it's a table (not a subselect)
                        if (plainSelect.getFromItem() instanceof net.sf.jsqlparser.schema.Table) {
                            // Remove alias if present (take only first word)
                            String tableName = fromTable.split("\\s+")[0];
                            joinTables.add(tableName);
                        }
                    }
                    // Handle JOINs
                    if (plainSelect.getJoins() != null) {
                        for (net.sf.jsqlparser.statement.select.Join join : plainSelect.getJoins()) {
                            if (join.getRightItem() instanceof net.sf.jsqlparser.schema.Table) {
                                String joinTable = join.getRightItem().toString();
                                // Remove alias if present (take only first word)
                                String tableName = joinTable.split("\\s+")[0];
                                joinTables.add(tableName);
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            // Ignore parse errors for non-SELECT or malformed statements
        }
        return joinTables;
    }

    /**
     * Runs multiple checks (predicates) on each SQL statement in globalSqlStatements.
     * Returns a list of maps, each map contains check names and their boolean results for a SQL statement.
     * @param checks Map of check name to Predicate<String>.
     * @return List of Map<String, Boolean> for each SQL statement.
     */
    public static List<Map<String, Boolean>> checkAllSql(Map<String, Predicate<String>> checks) {
        List<Map<String, Boolean>> results = new ArrayList<>();
        for (String sql : globalSqlStatements) {
            Map<String, Boolean> checkResults = new HashMap<>();
            for (Map.Entry<String, Predicate<String>> entry : checks.entrySet()) {
                checkResults.put(entry.getKey(), entry.getValue().test(sql));
            }
            results.add(checkResults);
        }
        return results;
    }

    /**
     * Displays the check results for each SQL statement.
     * @param checks Map of check name to Predicate<String>.
     */
    public static void displayCheckResults(Map<String, Predicate<String>> checks, java.io.Writer writer) throws IOException {
        PrintWriter pw = (writer instanceof PrintWriter) ? (PrintWriter) writer : new PrintWriter(writer, true);
        List<Map<String, Boolean>> results = checkAllSql(checks);
        List<String> sqls = getGlobalSqlStatements();
        for (int i = 0; i < sqls.size(); i++) {
            pw.println("SQL Statement " + (i + 1) + ":");
            pw.println(sqls.get(i));
            Map<String, Boolean> checkResult = results.get(i);
            for (Map.Entry<String, Boolean> entry : checkResult.entrySet()) {
                pw.println("  " + entry.getKey() + ": " + entry.getValue());
            }
            // Output columns used in WHERE clause for this statement
            List<List<String>> whereColumns = getAllWhereClauseColumnsJSqlParser();
            if (i < whereColumns.size()) {
                List<String> cols = whereColumns.get(i);
                pw.println("  Columns in WHERE clause: " + (cols.isEmpty() ? "None" : String.join(", ", cols)));
            }
            pw.println();
            // Output the tabl
        }
        pw.flush();
    }

    /**
     * Extracts all column names used in the WHERE clause of a SQL statement.
     * Handles simple cases: WHERE col1 = 5 AND col2 > 3, etc.
     * Does not handle subqueries or complex expressions.
     * @param sql The SQL statement.
     * @return List of column names used in the WHERE clause.
     */
    public static List<String> getWhereClauseColumns(String sql) {
        List<String> columns = new ArrayList<>();
        if (sql == null) return columns;
        // Find the WHERE clause (case-insensitive)
        Pattern wherePattern = Pattern.compile("(?i)\\bWHERE\\b(.*?)(?:\\bGROUP\\b|\\bORDER\\b|\\bLIMIT\\b|;|$)");
        Matcher matcher = wherePattern.matcher(sql);
        if (matcher.find()) {
            String whereClause = matcher.group(1);
            // Remove string literals and quotes to avoid confusion
            whereClause = whereClause.replaceAll("'[^']*'", "");
            whereClause = whereClause.replaceAll("\"[^\"]*\"", "");
            whereClause = whereClause.replace("'", "");
            whereClause = whereClause.replace("\"", "");
            // Remove parentheses to simplify matching
            whereClause = whereClause.replaceAll("[()]", " ");
            // Normalize whitespace
            whereClause = whereClause.replaceAll("\\s+", " ");
            // Use a global matcher to find all column/operator pairs, including NOT IN/LIKE/BETWEEN
            Pattern colPattern = Pattern.compile(
                "([a-zA-Z_][a-zA-Z0-9_\\.]*)\\s*(NOT\\s+IN|NOT\\s+LIKE|NOT\\s+BETWEEN|>=|<=|<>|!=|=|<|>|IN|LIKE|IS|BETWEEN)",
                Pattern.CASE_INSENSITIVE
            );
            Matcher colMatcher = colPattern.matcher(whereClause);
            while (colMatcher.find()) {
                String col = colMatcher.group(1).trim();
                if (!columns.contains(col)) {
                    columns.add(col);
                }
            }
        }
        return columns;
    }

    /**
     * Uses JSqlParser to extract all column names used in the WHERE clause of a SQL statement.
     * Handles complex/nested conditions robustly.
     * @param sql The SQL statement.
     * @return List of column names used in the WHERE clause.
     */
    public static List<String> getWhereClauseColumnsJSqlParser(String sql) {
        List<String> columns = new ArrayList<>();
        try {
            Statement statement = CCJSqlParserUtil.parse(sql);
            if (statement instanceof Select) {
                Select select = (Select) statement;
                PlainSelect plainSelect = (PlainSelect) select.getSelectBody();
                Expression where = plainSelect.getWhere();
                if (where != null) {
                    where.accept(new ExpressionVisitorAdapter() {
                        @Override
                        public void visit(Column column) {
                            String colName = column.getFullyQualifiedName();
                            if (!columns.contains(colName)) {
                                columns.add(colName);
                            }
                        }
                    });
                }
            }
        } catch (Exception e) {
            // Ignore parse errors for non-SELECT statements
        }
        return columns;
    }

    /**
     * For each global SQL statement, finds columns used in WHERE clauses.
     * @return List of List<String>, each inner list is columns for a statement.
     */
    public static List<List<String>> getAllWhereClauseColumns() {
        List<List<String>> allColumns = new ArrayList<>();
        for (String sql : globalSqlStatements) {
            allColumns.add(getWhereClauseColumns(sql));
        }
        return allColumns;
    }

    /**
     * For each global SQL statement, finds columns used in WHERE clauses using JSqlParser.
     * @return List of List<String>, each inner list is columns for a statement.
     */
    public static List<List<String>> getAllWhereClauseColumnsJSqlParser() {
        List<List<String>> allColumns = new ArrayList<>();
        for (String sql : globalSqlStatements) {
            allColumns.add(getWhereClauseColumnsJSqlParser(sql));
        }
        return allColumns;
    }

    /**
     * For each global SQL statement, finds all comparison operators used in WHERE clauses using JSqlParser.
     * @return List of List<String>, each inner list is operators for a statement.
     */
    public static List<List<String>> getAllWhereClauseOperatorsJSqlParser() {
        List<List<String>> allOperators = new ArrayList<>();
        for (String sql : globalSqlStatements) {
            allOperators.add(getWhereClauseOperatorsJSqlParser(sql));
        }
        return allOperators;
    }

    /**
     * Uses JSqlParser to extract all comparison operators used in the WHERE clause of a SQL statement.
     * Handles complex/nested conditions robustly.
     * @param sql The SQL statement.
     * @return List of operators (e.g., '=', '<', '>', '<=', '>=', '<>', '!=') used in the WHERE clause.
     */
    public static List<String> getWhereClauseOperatorsJSqlParser(String sql) {
        List<String> operators = new ArrayList<>();
        try {
            Statement statement = CCJSqlParserUtil.parse(sql);
            if (statement instanceof Select) {
                Select select = (Select) statement;
                PlainSelect plainSelect = (PlainSelect) select.getSelectBody();
                Expression where = plainSelect.getWhere();
                if (where != null) {
                    where.accept(new ExpressionVisitorAdapter() {
                        @Override
                        public void visit(net.sf.jsqlparser.expression.operators.relational.EqualsTo expr) {
                            operators.add("=");
                        }
                        @Override
                        public void visit(net.sf.jsqlparser.expression.operators.relational.GreaterThan expr) {
                            operators.add(">");
                        }
                        @Override
                        public void visit(net.sf.jsqlparser.expression.operators.relational.MinorThan expr) {
                            operators.add("<");
                        }
                        @Override
                        public void visit(net.sf.jsqlparser.expression.operators.relational.GreaterThanEquals expr) {
                            operators.add(">=");
                        }
                        @Override
                        public void visit(net.sf.jsqlparser.expression.operators.relational.MinorThanEquals expr) {
                            operators.add("<=");
                        }
                        @Override
                        public void visit(net.sf.jsqlparser.expression.operators.relational.NotEqualsTo expr) {
                            operators.add("!=");
                        }
                    });
                }
            }
        } catch (Exception e) {
            // Ignore parse errors for non-SELECT statements
        }
        return operators;
    }
}
