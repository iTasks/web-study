/**
 * CollectionOperations.groovy
 * Demonstrates Groovy's powerful collection operations
 */

class CollectionOperations {

    /**
     * Filter even numbers from a list
     */
    static List<Integer> filterEvens(List<Integer> numbers) {
        return numbers.findAll { it % 2 == 0 }
    }

    /**
     * Map each element to its square
     */
    static List<Integer> squareAll(List<Integer> numbers) {
        return numbers.collect { it * it }
    }

    /**
     * Find the sum of all elements
     */
    static Integer sumAll(List<Integer> numbers) {
        return numbers.sum() ?: 0
    }

    /**
     * Group elements by a condition (even/odd)
     */
    static Map<String, List<Integer>> groupByParity(List<Integer> numbers) {
        return numbers.groupBy { it % 2 == 0 ? 'even' : 'odd' }
    }

    /**
     * Find the maximum element in a list
     */
    static Integer findMax(List<Integer> numbers) {
        return numbers.max()
    }

    /**
     * Remove duplicates from a list
     */
    static List<Integer> removeDuplicates(List<Integer> numbers) {
        return numbers.unique()
    }

    /**
     * Flatten a nested list
     */
    static List flattenList(List nestedList) {
        return nestedList.flatten()
    }

    /**
     * Zip two lists together
     */
    static List<List> zipLists(List list1, List list2) {
        return [list1, list2].transpose()
    }

    /**
     * Count occurrences of each element
     */
    static Map<Integer, Integer> countOccurrences(List<Integer> numbers) {
        return numbers.countBy { it }
    }

    /**
     * Partition a list based on a condition
     */
    static Map<String, List<Integer>> partitionList(List<Integer> numbers, int threshold) {
        def partitioned = numbers.split { it >= threshold }
        return [above: partitioned[0], below: partitioned[1]]
    }

    /**
     * Map operations
     */
    static void demonstrateMapOperations() {
        println "=== Map Operations ==="
        
        def person = [name: 'John', age: 30, city: 'New York']
        println "Original map: $person"
        
        // Filter map entries
        def filtered = person.findAll { key, value -> value instanceof String }
        println "Filtered (strings only): $filtered"
        
        // Transform map values
        def transformed = person.collectEntries { key, value ->
            [key.toUpperCase(), value]
        }
        println "Transformed keys: $transformed"
        
        // Check if key exists
        println "Has 'name' key: ${person.containsKey('name')}"
        
        // Get with default value
        println "Country (with default): ${person.get('country', 'USA')}"
        println()
    }

    /**
     * Set operations
     */
    static void demonstrateSetOperations() {
        println "=== Set Operations ==="
        
        def set1 = [1, 2, 3, 4, 5] as Set
        def set2 = [4, 5, 6, 7, 8] as Set
        
        println "Set 1: $set1"
        println "Set 2: $set2"
        
        // Union
        println "Union: ${set1 + set2}"
        
        // Intersection
        println "Intersection: ${set1.intersect(set2)}"
        
        // Difference
        println "Difference (set1 - set2): ${set1 - set2}"
        
        // Symmetric difference
        def symDiff = (set1 + set2) - set1.intersect(set2)
        println "Symmetric Difference: $symDiff"
        println()
    }

    /**
     * Range operations
     */
    static void demonstrateRangeOperations() {
        println "=== Range Operations ==="
        
        def range = 1..10
        println "Range: $range"
        println "Range contains 5: ${range.contains(5)}"
        println "Range size: ${range.size()}"
        
        // Iterate over range
        print "Range elements: "
        range.each { print "$it " }
        println()
        
        // Step through range
        print "Every other element: "
        range.step(2) { print "$it " }
        println()
        println()
    }

    static void main(String[] args) {
        println "=== Collection Operations in Groovy ==="
        println()
        
        def numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        println "Original list: $numbers"
        println()
        
        // Filter evens
        println "Even numbers: ${filterEvens(numbers)}"
        println()
        
        // Square all
        println "Squared: ${squareAll(numbers)}"
        println()
        
        // Sum all
        println "Sum: ${sumAll(numbers)}"
        println()
        
        // Group by parity
        println "Grouped by parity: ${groupByParity(numbers)}"
        println()
        
        // Find max
        println "Maximum: ${findMax(numbers)}"
        println()
        
        // Remove duplicates
        def withDuplicates = [1, 2, 2, 3, 3, 3, 4, 4, 5]
        println "With duplicates: $withDuplicates"
        println "Without duplicates: ${removeDuplicates(withDuplicates)}"
        println()
        
        // Flatten list
        def nestedList = [[1, 2], [3, 4], [5, 6]]
        println "Nested list: $nestedList"
        println "Flattened: ${flattenList(nestedList)}"
        println()
        
        // Zip lists
        def list1 = ['a', 'b', 'c']
        def list2 = [1, 2, 3]
        println "List 1: $list1"
        println "List 2: $list2"
        println "Zipped: ${zipLists(list1, list2)}"
        println()
        
        // Count occurrences
        def repeated = [1, 1, 2, 2, 2, 3, 3, 3, 3]
        println "List: $repeated"
        println "Occurrences: ${countOccurrences(repeated)}"
        println()
        
        // Partition list
        println "Partition at 5: ${partitionList(numbers, 5)}"
        println()
        
        // Map operations
        demonstrateMapOperations()
        
        // Set operations
        demonstrateSetOperations()
        
        // Range operations
        demonstrateRangeOperations()
    }
}
