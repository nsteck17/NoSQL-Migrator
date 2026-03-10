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

public class DmlAnalysis {
    // Global array to store parsed SQL statements
    private static List<String> globalSqlStatements = new ArrayList<>();
    // Global array to store columns used in WHERE clauses (indexes needed)
    private static List<List<String>> globalWhereClauseColumns = new ArrayList<>();

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
        // Use regex to match JOIN as a word, case-insensitive
        return sql.matches("(?i).*\\bJOIN\\b.*");
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
    public static void displayCheckResults(Map<String, Predicate<String>> checks, BufferedWriter writer) throws IOException {
        List<Map<String, Boolean>> results = checkAllSql(checks);
        List<String> sqls = getGlobalSqlStatements();
        for (int i = 0; i < sqls.size(); i++) {
            writer.write("SQL Statement " + (i + 1) + ":\n");
            writer.write(sqls.get(i) + "\n");
            Map<String, Boolean> checkResult = results.get(i);
            for (Map.Entry<String, Boolean> entry : checkResult.entrySet()) {
                writer.write("  " + entry.getKey() + ": " + entry.getValue() + "\n");
            }
            // Output columns used in WHERE clause for this statement
            List<List<String>> whereColumns = getAllWhereClauseColumns();
            if (i < whereColumns.size()) {
                List<String> cols = whereColumns.get(i);
                writer.write("  Columns in WHERE clause: " + (cols.isEmpty() ? "None" : String.join(", ", cols)) + "\n");
            }
            writer.write("\n");
        }
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
            // Remove string literals to avoid confusion
            whereClause = whereClause.replaceAll("'[^']*'", "");
            whereClause = whereClause.replaceAll("\"[^\"]*\"", "");
            // Split by AND/OR (case-insensitive)
            String[] conditions = whereClause.split("(?i)\\bAND\\b|\\bOR\\b");
            for (String cond : conditions) {
                // Try to extract the column name (before =, <, >, <=, >=, <>, !=)
                Matcher colMatcher = Pattern.compile("([a-zA-Z_][a-zA-Z0-9_\\.]*)\\s*(?=[=<>!])").matcher(cond);
                if (colMatcher.find()) {
                    String col = colMatcher.group(1).trim();
                    columns.add(col);
                }
            }
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
}
