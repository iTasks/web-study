import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Java 11 Features Demonstration
 * Released in September 2018 (LTS)
 * 
 * Key Features:
 * 1. Local Variable Syntax for Lambda Parameters (var)
 * 2. HTTP Client (Standard)
 * 3. String Methods (isBlank, lines, strip, repeat)
 * 4. Files.readString() and Files.writeString()
 * 5. Collection.toArray(IntFunction)
 */
public class Java11Features {

    public static void main(String[] args) {
        demonstrateVarInLambda();
        demonstrateStringMethods();
        demonstrateHttpClient();
        demonstrateFileMethods();
        demonstrateCollectionToArray();
    }

    /**
     * Java 11 allows 'var' in lambda parameters
     */
    private static void demonstrateVarInLambda() {
        System.out.println("=== Java 11: var in Lambda ===");
        List<String> list = List.of("Apple", "Banana", "Cherry");
        
        // Using var in lambda parameters
        list.forEach((var item) -> System.out.println(item.toUpperCase()));
        
        // Can add annotations with var
        var result = list.stream()
            .map((var s) -> s.toLowerCase())
            .collect(Collectors.toList());
        System.out.println("Lowercase: " + result);
        System.out.println();
    }

    /**
     * New String methods in Java 11
     */
    private static void demonstrateStringMethods() {
        System.out.println("=== Java 11: String Methods ===");
        
        // isBlank() - checks if string is empty or contains only whitespace
        String blank = "   ";
        System.out.println("'   '.isBlank(): " + blank.isBlank());
        
        // lines() - returns stream of lines
        String multiline = "Line 1\nLine 2\nLine 3";
        System.out.println("Lines count: " + multiline.lines().count());
        
        // strip() - removes leading and trailing whitespace (Unicode-aware)
        String padded = "  Hello World  ";
        System.out.println("Stripped: '" + padded.strip() + "'");
        
        // repeat() - repeats string n times
        System.out.println("Repeat 3 times: " + "Java ".repeat(3));
        System.out.println();
    }

    /**
     * Standard HTTP Client introduced in Java 11
     */
    private static void demonstrateHttpClient() {
        System.out.println("=== Java 11: HTTP Client ===");
        
        try {
            // Create HTTP client
            HttpClient client = HttpClient.newHttpClient();
            
            // Build request
            HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create("https://api.github.com/zen"))
                .GET()
                .build();
            
            // Send request and get response
            HttpResponse<String> response = client.send(request, 
                HttpResponse.BodyHandlers.ofString());
            
            System.out.println("Status Code: " + response.statusCode());
            System.out.println("Response: " + response.body());
        } catch (Exception e) {
            System.out.println("HTTP request demonstration (would require network): " + e.getMessage());
        }
        System.out.println();
    }

    /**
     * Files.readString() and Files.writeString() in Java 11
     */
    private static void demonstrateFileMethods() {
        System.out.println("=== Java 11: File Methods ===");
        
        try {
            Path tempFile = Files.createTempFile("java11", ".txt");
            
            // Write string to file
            String content = "Hello from Java 11!";
            Files.writeString(tempFile, content);
            System.out.println("Written to file: " + content);
            
            // Read string from file
            String read = Files.readString(tempFile);
            System.out.println("Read from file: " + read);
            
            // Clean up
            Files.delete(tempFile);
        } catch (Exception e) {
            System.out.println("File operation error: " + e.getMessage());
        }
        System.out.println();
    }

    /**
     * Collection.toArray(IntFunction) in Java 11
     */
    private static void demonstrateCollectionToArray() {
        System.out.println("=== Java 11: Collection.toArray ===");
        
        List<String> list = List.of("Java", "Python", "JavaScript");
        
        // New way - more concise
        String[] array = list.toArray(String[]::new);
        System.out.println("Array: " + String.join(", ", array));
        System.out.println();
    }
}
