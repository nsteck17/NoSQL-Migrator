package org.example;

import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;

public class DmlAnalysisTestRunner {
    public static void main(String[] args) throws Exception {
        String sql = new String(Files.readAllBytes(Paths.get("src/main/java/org/example/cleaned-DML.sql")));
        List<String> stmts = DmlAnalysis.parseSqlStatements(sql);
        int i = 1;
        for (String stmt : stmts) {
            System.out.println("Statement " + i + ":\n" + stmt);
            String whereClause = null;
            java.util.regex.Matcher m = java.util.regex.Pattern.compile("(?i)\\bWHERE\\b(.*?)(?:\\bGROUP\\b|\\bORDER\\b|\\bLIMIT\\b|;|$)").matcher(stmt);
            if (m.find()) {
                whereClause = m.group(1);
                whereClause = whereClause.replaceAll("'[^']*'", "");
                whereClause = whereClause.replaceAll("\"[^\"]*\"", "");
                whereClause = whereClause.replaceAll("[()]", " ");
                whereClause = whereClause.replaceAll("\\s+", " ");
            }
            if (whereClause != null) {
                System.out.println("  Normalized WHERE clause: " + whereClause);
            }
            List<String> cols = DmlAnalysis.getWhereClauseColumns(stmt);
            System.out.println("  WHERE columns (regex): " + cols);
            List<String> colsJsql = DmlAnalysis.getWhereClauseColumnsJSqlParser(stmt);
            System.out.println("  WHERE columns (JSqlParser): " + colsJsql);
            i++;
        }
    }
}
