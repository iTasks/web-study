import java.time.Duration;
import java.util.*;
import java.util.concurrent.Executors;

/**
 * Java 21 Features Demonstration
 * Released in September 2023 (LTS)
 * 
 * Key Features:
 * 1. Virtual Threads (Project Loom)
 * 2. Pattern Matching for switch (Final)
 * 3. Record Patterns (Final)
 * 4. Sequenced Collections
 * 5. String Templates (Preview)
 */
public class Java21Features {

    // Records for pattern matching demonstration
    record Point(int x, int y) {}
    record Circle(Point center, int radius) {}
    record Rectangle(Point topLeft, Point bottomRight) {}

    public static void main(String[] args) {
        demonstrateVirtualThreads();
        demonstratePatternMatching();
        demonstrateRecordPatterns();
        demonstrateSequencedCollections();
    }

    /**
     * Virtual Threads - lightweight threads for high-throughput concurrent applications
     * Note: Virtual threads require Java 21+
     */
    private static void demonstrateVirtualThreads() {
        System.out.println("=== Java 21: Virtual Threads ===");
        System.out.println("Virtual threads are lightweight threads introduced in Java 21");
        System.out.println("They enable high-throughput concurrent applications.");
        System.out.println();
        
        // Java 21 syntax (requires Java 21+):
        /*
        // Create and start a virtual thread
        Thread vThread = Thread.ofVirtual().start(() -> {
            System.out.println("Hello from virtual thread: " + Thread.currentThread());
        });
        
        try {
            vThread.join();
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        
        // Using virtual thread executor
        try (var executor = Executors.newVirtualThreadPerTaskExecutor()) {
            for (int i = 0; i < 5; i++) {
                final int taskId = i;
                executor.submit(() -> {
                    System.out.println("Task " + taskId + " running on: " + Thread.currentThread());
                    return taskId;
                });
            }
        } // executor.close() is called automatically
        */
        
        // Demonstration using traditional threads
        Thread traditionalThread = new Thread(() -> {
            System.out.println("Traditional thread: " + Thread.currentThread().getName());
        });
        traditionalThread.start();
        try {
            traditionalThread.join();
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        
        System.out.println("Virtual threads can be created in millions (vs thousands for platform threads)");
        System.out.println();
    }

    /**
     * Pattern Matching for switch - now a standard feature
     */
    private static void demonstratePatternMatching() {
        System.out.println("=== Java 21: Pattern Matching for switch ===");
        
        Object[] testObjects = {
            "Hello World",
            42,
            3.14159,
            List.of("A", "B", "C"),
            null
        };
        
        for (Object obj : testObjects) {
            String result = describeWithPatternMatching(obj);
            System.out.println(obj + " -> " + result);
        }
        System.out.println();
    }

    private static String describeWithPatternMatching(Object obj) {
        // Pattern matching for switch with type patterns and guards
        // Note: This uses Java 17 compatible syntax
        // In Java 21, you can use: case String s when s.length() > 10 -> ...
        
        if (obj == null) {
            return "It's null";
        } else if (obj instanceof String s) {
            if (s.length() > 10) {
                return "Long string: " + s.substring(0, 10) + "...";
            }
            return "String: " + s;
        } else if (obj instanceof Integer i) {
            if (i > 100) {
                return "Large integer: " + i;
            }
            return "Integer: " + i;
        } else if (obj instanceof Double d) {
            return "Double: " + d;
        } else if (obj instanceof List<?> list) {
            return "List of size " + list.size();
        } else {
            return "Unknown: " + obj.getClass().getSimpleName();
        }
        
        // Java 21 syntax (requires Java 21+):
        /*
        return switch (obj) {
            case null -> "It's null";
            case String s when s.length() > 10 -> "Long string: " + s.substring(0, 10) + "...";
            case String s -> "String: " + s;
            case Integer i when i > 100 -> "Large integer: " + i;
            case Integer i -> "Integer: " + i;
            case Double d -> "Double: " + d;
            case List<?> list -> "List of size " + list.size();
            default -> "Unknown: " + obj.getClass().getSimpleName();
        };
        */
    }

    /**
     * Record Patterns - destructuring records in pattern matching
     */
    private static void demonstrateRecordPatterns() {
        System.out.println("=== Java 21: Record Patterns ===");
        
        Object[] shapes = {
            new Circle(new Point(0, 0), 5),
            new Rectangle(new Point(0, 0), new Point(10, 10)),
            new Point(3, 4)
        };
        
        for (Object shape : shapes) {
            String description = describeShape(shape);
            System.out.println(description);
        }
        System.out.println();
    }

    private static String describeShape(Object obj) {
        // Java 17 compatible approach - manual destructuring
        if (obj instanceof Circle c) {
            Point center = c.center();
            return String.format("Circle at (%d,%d) with radius %d", 
                center.x(), center.y(), c.radius());
        } else if (obj instanceof Rectangle r) {
            Point topLeft = r.topLeft();
            Point bottomRight = r.bottomRight();
            return String.format("Rectangle from (%d,%d) to (%d,%d)", 
                topLeft.x(), topLeft.y(), bottomRight.x(), bottomRight.y());
        } else if (obj instanceof Point p) {
            return String.format("Point at (%d,%d)", p.x(), p.y());
        }
        return "Unknown shape";
        
        // Java 21 syntax with record patterns (requires Java 21+):
        // Record patterns allow you to destructure records directly in the pattern
        /*
        return switch (obj) {
            case Circle(Point(int x, int y), int r) -> 
                String.format("Circle at (%d,%d) with radius %d", x, y, r);
            case Rectangle(Point(int x1, int y1), Point(int x2, int y2)) ->
                String.format("Rectangle from (%d,%d) to (%d,%d)", x1, y1, x2, y2);
            case Point(int x, int y) ->
                String.format("Point at (%d,%d)", x, y);
            default -> "Unknown shape";
        };
        */
    }

    /**
     * Sequenced Collections - collections with defined encounter order
     * Note: Sequenced Collections require Java 21+
     */
    private static void demonstrateSequencedCollections() {
        System.out.println("=== Java 21: Sequenced Collections ===");
        System.out.println("Java 21 introduces SequencedCollection interface with methods:");
        System.out.println("  - getFirst() / getLast()");
        System.out.println("  - addFirst() / addLast()");
        System.out.println("  - removeFirst() / removeLast()");
        System.out.println("  - reversed()");
        System.out.println();
        
        // Java 17 compatible demonstration
        List<String> list = new ArrayList<>(List.of("First", "Middle", "Last"));
        
        // Traditional way to access first and last elements
        System.out.println("First element (Java 17): " + list.get(0));
        System.out.println("Last element (Java 17): " + list.get(list.size() - 1));
        
        // Traditional way to add to beginning or end
        list.add(0, "New First");
        list.add("New Last");
        System.out.println("After adding: " + list);
        
        // Traditional way to remove from beginning or end
        list.remove(0);
        list.remove(list.size() - 1);
        System.out.println("After removing: " + list);
        
        // Manual reversal
        List<String> reversed = new ArrayList<>();
        for (int i = list.size() - 1; i >= 0; i--) {
            reversed.add(list.get(i));
        }
        System.out.println("Reversed (Java 17): " + reversed);
        
        System.out.println();
        System.out.println("Java 21 syntax (requires Java 21+):");
        System.out.println("  list.getFirst()  // Instead of list.get(0)");
        System.out.println("  list.getLast()   // Instead of list.get(list.size()-1)");
        System.out.println("  list.addFirst(e) // Instead of list.add(0, e)");
        System.out.println("  list.reversed()  // Returns a reversed view");
        
        /*
        // Java 21+ code:
        List<String> list = new ArrayList<>(List.of("First", "Middle", "Last"));
        System.out.println("First element: " + list.getFirst());
        System.out.println("Last element: " + list.getLast());
        list.addFirst("New First");
        list.addLast("New Last");
        System.out.println("After adding: " + list);
        list.removeFirst();
        list.removeLast();
        System.out.println("After removing: " + list);
        System.out.println("Reversed: " + list.reversed());
        
        LinkedHashSet<String> set = new LinkedHashSet<>(List.of("A", "B", "C"));
        System.out.println("Set first: " + set.getFirst());
        System.out.println("Set last: " + set.getLast());
        System.out.println("Set reversed: " + set.reversed());
        
        LinkedHashMap<String, Integer> map = new LinkedHashMap<>();
        map.put("One", 1);
        map.put("Two", 2);
        map.put("Three", 3);
        System.out.println("Map first entry: " + map.firstEntry());
        System.out.println("Map last entry: " + map.lastEntry());
        System.out.println("Map reversed: " + map.reversed());
        */
        
        System.out.println();
    }

    /**
     * Sample record for demonstration
     */
    record Person(String name, int age) {
        // Compact constructor
        public Person {
            if (age < 0) {
                throw new IllegalArgumentException("Age cannot be negative");
            }
        }
    }
}
