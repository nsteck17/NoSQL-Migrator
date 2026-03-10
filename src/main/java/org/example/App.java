package org.example;

import java.nio.file.Files;
import java.nio.file.Paths;
import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;

/**
 * Hello world!
 *
 */
public class App 
{
    public static void main( String[] args ){
        String outputFile = "output.txt";
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(outputFile))) {
            //Import Create-Only-DDL.sql and run DdlToNoSqlModel.java convertDdlToNoSqlDesign
            try {
                //String ddl = new String(Files.readAllBytes(Paths.get("src/main/java/org/example/Create-Only-DDL.sql")));
                String ddl = new String(Files.readAllBytes(Paths.get("src/main/java/org/example/DDL.sql")));
                String json = DdlToNoSqlModel.convertDdlToNoSqlDesign(ddl, "appdb");
                writer.write(json);
                writer.newLine();

                // Output tableToCollectionMap cleanly
                writer.write("\n--- DDL Table to NoSQL Collection Map ---\n");
                com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
                DdlToNoSqlModel.tableToCollectionMap.forEach((table, collectionObj) -> {
                    try {
                        String collectionJson = mapper.writerWithDefaultPrettyPrinter().writeValueAsString(collectionObj);
                        writer.write("Table: " + table + "\n");
                        writer.write(collectionJson + "\n");
                    } catch (Exception ex) {
                        try { writer.write("Error serializing collection for table: " + table + "\n"); } catch (IOException ignored) {}
                    }
                });

                // Load cleaned-DML.sql and analyze SQL statements
                String dml = new String(Files.readAllBytes(Paths.get("src/main/java/org/example/cleaned-DML.sql")));
                org.example.DmlAnalysis.parseSqlStatements(dml);
                java.util.Map<String, java.util.function.Predicate<String>> checks = new java.util.HashMap<>();
                checks.put("Contains JOIN", org.example.DmlAnalysis::containsJoin);
                writer.write("\n--- DML SQL Analysis ---\n");
                org.example.DmlAnalysis.displayCheckResults(checks, writer);

                // Output globalWhereClauseColumns as list of columns to index
                writer.write("\n--- Suggested Index Columns (from WHERE clauses) ---\n");
                java.util.Set<String> indexColumns = new java.util.HashSet<>();
                for (java.util.List<String> cols : org.example.DmlAnalysis.getGlobalWhereClauseColumns()) {
                    indexColumns.addAll(cols);
                }
                if (indexColumns.isEmpty()) {
                    writer.write("No columns found in WHERE clauses.\n");
                } else {
                    for (String col : indexColumns) {
                        writer.write(col + "\n");
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
