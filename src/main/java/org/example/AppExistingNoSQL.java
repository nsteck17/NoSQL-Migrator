package org.example;

import org.json.JSONObject;
import org.json.XML;

public class AppExistingNoSQL {
    public static void main( String[] args ){
        System.out.println( "Hello NoSQL World!" );
        //Read XML file with NoSQL and convert to JSON
        try {
            String xml = new String(java.nio.file.Files.readAllBytes(java.nio.file.Paths.get("src/main/java/org/example/bulk-train-release-request-cache-1_0_6.xsd")));
            // Convert XML to JSON
            JSONObject jsonObj = XML.toJSONObject(xml);
            String jsonPretty = jsonObj.toString(4); // Pretty print with 4-space indent
            System.out.println(jsonPretty);
        } catch (java.io.IOException e) {
            e.printStackTrace();
        }
    }
}
