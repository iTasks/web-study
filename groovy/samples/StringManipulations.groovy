/**
 * StringManipulations.groovy
 * Demonstrates various string manipulation operations in Groovy
 */

class StringManipulations {

    /**
     * Reverse a string
     */
    static String reverseString(String s) {
        return s.reverse()
    }

    /**
     * Check if a string is a palindrome
     */
    static boolean isPalindrome(String s) {
        s = s.toLowerCase().replaceAll('[^a-z0-9]', '')
        return s == s.reverse()
    }

    /**
     * Compress a string by counting consecutive characters
     * Example: "aabcccccaaa" -> "a2bc5a3"
     */
    static String compressString(String s) {
        if (!s) return s
        
        def compressed = new StringBuilder()
        int count = 1
        
        for (int i = 0; i < s.length(); i++) {
            if (i + 1 < s.length() && s[i] == s[i + 1]) {
                count++
            } else {
                compressed.append(s[i])
                if (count > 1) {
                    compressed.append(count)
                }
                count = 1
            }
        }
        
        return compressed.length() < s.length() ? compressed.toString() : s
    }

    /**
     * Check if two strings are anagrams
     */
    static boolean isAnagram(String s1, String s2) {
        if (s1.length() != s2.length()) return false
        
        def count = [:].withDefault { 0 }
        s1.each { count[it]++ }
        s2.each { count[it]-- }
        
        return count.values().every { it == 0 }
    }

    /**
     * Get all permutations of a string
     */
    static List<String> getPermutations(String str) {
        if (str.length() <= 1) return [str]
        
        def result = []
        for (int i = 0; i < str.length(); i++) {
            def ch = str[i]
            def remaining = str.substring(0, i) + str.substring(i + 1)
            getPermutations(remaining).each { perm ->
                result << ch + perm
            }
        }
        
        return result.unique()
    }

    /**
     * Find the longest common prefix among an array of strings
     */
    static String longestCommonPrefix(String[] strs) {
        if (!strs || strs.length == 0) return ""
        
        def prefix = strs[0]
        for (int i = 1; i < strs.length; i++) {
            while (!strs[i].startsWith(prefix)) {
                prefix = prefix.substring(0, prefix.length() - 1)
                if (!prefix) return ""
            }
        }
        
        return prefix
    }

    /**
     * Count occurrences of each word in a string
     */
    static Map<String, Integer> wordFrequency(String text) {
        def words = text.toLowerCase().split(/\W+/)
        def frequency = [:].withDefault { 0 }
        words.each { word ->
            if (word) frequency[word]++
        }
        return frequency
    }

    /**
     * Capitalize the first letter of each word
     */
    static String titleCase(String s) {
        return s.split(/\s+/).collect { it.capitalize() }.join(' ')
    }

    static void main(String[] args) {
        println "=== String Manipulations in Groovy ==="
        println()
        
        // Reverse string
        def str1 = "hello"
        println "Original: $str1"
        println "Reversed: ${reverseString(str1)}"
        println()
        
        // Palindrome check
        def str2 = "racecar"
        def str3 = "A man, a plan, a canal: Panama"
        println "Is Palindrome ('$str2'): ${isPalindrome(str2)}"
        println "Is Palindrome ('$str3'): ${isPalindrome(str3)}"
        println()
        
        // String compression
        def str4 = "aabcccccaaa"
        println "Original: $str4"
        println "Compressed: ${compressString(str4)}"
        println()
        
        // Anagram check
        def s1 = "silent"
        def s2 = "listen"
        println "Are Anagrams ('$s1' & '$s2'): ${isAnagram(s1, s2)}"
        println()
        
        // Permutations
        def str5 = "abc"
        println "Permutations of '$str5': ${getPermutations(str5)}"
        println()
        
        // Longest common prefix
        def group = ["flower", "flow", "flight"] as String[]
        println "Longest Common Prefix: ${longestCommonPrefix(group)}"
        println()
        
        // Word frequency
        def text = "hello world hello groovy world"
        println "Word Frequency in '$text':"
        wordFrequency(text).each { word, count ->
            println "  $word: $count"
        }
        println()
        
        // Title case
        def str6 = "hello world from groovy"
        println "Original: $str6"
        println "Title Case: ${titleCase(str6)}"
    }
}
