import java.net.InetSocketAddress;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.List;

/**
 * Java 18 Features Demonstration
 * Released in March 2022
 * 
 * Key Features:
 * 1. UTF-8 by Default
 * 2. Simple Web Server (jwebserver)
 * 3. Code Snippets in Java API Documentation (@snippet)
 * 4. Vector API (Second Incubator)
 * 5. Pattern Matching for switch (Second Preview)
 */
public class Java18Features {

    public static void main(String[] args) {
        demonstrateUTF8Default();
        demonstrateSimpleWebServer();
        demonstratePatternMatchingSwitch();
        demonstrateCodeSnippets();
    }

    /**
     * UTF-8 is now the default charset in Java 18
     */
    private static void demonstrateUTF8Default() {
        System.out.println("=== Java 18: UTF-8 by Default ===");
        
        // Default charset is now UTF-8
        Charset defaultCharset = Charset.defaultCharset();
        System.out.println("Default Charset: " + defaultCharset);
        System.out.println("Is UTF-8: " + defaultCharset.name().equals("UTF-8"));
        System.out.println();
    }

    /**
     * Simple Web Server (available via jwebserver command)
     * Note: This demonstrates the API, actual server runs via command line
     */
    private static void demonstrateSimpleWebServer() {
        System.out.println("=== Java 18: Simple Web Server ===");
        System.out.println("Simple Web Server can be started using:");
        System.out.println("  jwebserver");
        System.out.println("  jwebserver -p 9000");
        System.out.println("  jwebserver -b 0.0.0.0 -p 8080 -d /path/to/dir");
        System.out.println();
        System.out.println("Programmatically:");
        
        try {
            // This would start a simple file server
            // var server = SimpleFileServer.createFileServer(
            //     new InetSocketAddress(8080),
            //     Path.of("/tmp"),
            //     SimpleFileServer.OutputLevel.VERBOSE
            // );
            // server.start();
            System.out.println("Server would be created at localhost:8080");
        } catch (Exception e) {
            System.out.println("Note: SimpleFileServer requires com.sun.net.httpserver");
        }
        System.out.println();
    }

    /**
     * Pattern Matching for switch (Preview in Java 18)
     * Demonstrates enhanced switch expressions with patterns
     */
    private static void demonstratePatternMatchingSwitch() {
        System.out.println("=== Java 18: Pattern Matching for switch (Preview) ===");
        
        Object[] objects = {
            "Hello",
            42,
            3.14,
            new ArrayList<String>(),
            null
        };
        
        for (Object obj : objects) {
            String description = describeObject(obj);
            System.out.println(obj + " -> " + description);
        }
        System.out.println();
    }

    /**
     * Pattern matching switch (requires --enable-preview in Java 18)
     */
    private static String describeObject(Object obj) {
        // Note: This is preview feature syntax
        // In actual use, would require --enable-preview flag
        
        // Traditional approach (without pattern matching)
        if (obj == null) {
            return "null object";
        } else if (obj instanceof String s) {
            return "String of length " + s.length();
        } else if (obj instanceof Integer i) {
            return "Integer with value " + i;
        } else if (obj instanceof Double d) {
            return "Double with value " + d;
        } else if (obj instanceof List<?> list) {
            return "List with " + list.size() + " elements";
        } else {
            return "Unknown type: " + obj.getClass().getSimpleName();
        }
        
        // With pattern matching for switch (preview):
        /*
        return switch (obj) {
            case null -> "null object";
            case String s -> "String of length " + s.length();
            case Integer i -> "Integer with value " + i;
            case Double d -> "Double with value " + d;
            case List<?> list -> "List with " + list.size() + " elements";
            default -> "Unknown type: " + obj.getClass().getSimpleName();
        };
        */
    }

    /**
     * Code Snippets in JavaDoc (@snippet tag)
     * This is a documentation feature
     */
    private static void demonstrateCodeSnippets() {
        System.out.println("=== Java 18: Code Snippets in JavaDoc ===");
        System.out.println("Java 18 introduces @snippet tag for better code examples in JavaDoc:");
        System.out.println();
        System.out.println("Example usage in JavaDoc:");
        System.out.println("/**");
        System.out.println(" * {@snippet :");
        System.out.println(" * List<String> list = new ArrayList<>();");
        System.out.println(" * list.add(\"Hello\");");
        System.out.println(" * list.add(\"World\");");
        System.out.println(" * }");
        System.out.println(" */");
        System.out.println();
        System.out.println("This provides better formatting and syntax highlighting in generated docs.");
        System.out.println();
    }

    /**
     * Example method with @snippet JavaDoc (for demonstration)
     * 
     * This method demonstrates the new @snippet tag introduced in Java 18.
     * 
     * Example usage:
     * {@snippet :
     * Java18Features demo = new Java18Features();
     * // Call the method
     * demo.sampleMethod();
     * }
     */
    public void sampleMethod() {
        System.out.println("Sample method with @snippet JavaDoc");
    }
}
