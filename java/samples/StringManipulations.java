import java.util.ArrayList;
import java.util.List;

public class StringManipulations {

    public static String reverseString(String s) {
        return new StringBuilder(s).reverse().toString();
    }

    public static boolean isPalindrome(String s) {
        s = s.toLowerCase().replaceAll("[^a-z0-9]", "");
        int left = 0, right = s.length() - 1;
        while (left < right) {
            if (s.charAt(left++) != s.charAt(right--)) {
                return false;
            }
        }
        return true;
    }

    public static String compressString(String s) {
        StringBuilder compressed = new StringBuilder();
        int count = 0;
        for (int i = 0; i < s.length(); i++) {
            count++;
            if (i + 1 >= s.length() || s.charAt(i) != s.charAt(i + 1)) {
                compressed.append(s.charAt(i));
                if (count > 1) {
                    compressed.append(count);
                }
                count = 0;
            }
        }
        return compressed.length() < s.length() ? compressed.toString() : s;
    }

    public static boolean isAnagram(String s1, String s2) {
        if (s1.length() != s2.length()) return false;
        int[] count = new int[256];
        for (char c : s1.toCharArray()) count[c]++;
        for (char c : s2.toCharArray()) {
            if (--count[c] < 0) return false;
        }
        return true;
    }

    public static List<String> getPermutations(String str) {
        List<String> result = new ArrayList<>();
        permutations("", str, result);
        return result;
    }

    private static void permutations(String prefix, String str, List<String> result) {
        if (str.isEmpty()) {
            result.add(prefix);
        } else {
            for (int i = 0; i < str.length(); i++) {
                permutations(prefix + str.charAt(i), str.substring(0, i) + str.substring(i + 1), result);
            }
        }
    }

    public static String longestCommonPrefix(String[] strs) {
        if (strs == null || strs.length == 0) return "";
        String prefix = strs[0];
        for (int i = 1; i < strs.length; i++) {
            while (strs[i].indexOf(prefix) != 0) {
                prefix = prefix.substring(0, prefix.length() - 1);
                if (prefix.isEmpty()) return "";
            }
        }
        return prefix;
    }

    public static void main(String[] args) {
        String s1 = "hello";
        String s2 = "racecar";
        String s3 = "A man, a plan, a canal: Panama";
        String[] group = {"flower", "flow", "flight"};

        System.out.println("Reversed: " + reverseString(s1));
        System.out.println("Is Palindrome (racecar): " + isPalindrome(s2));
        System.out.println("Is Palindrome (A man, a plan, a canal: Panama): " + isPalindrome(s3));
        System.out.println("Compressed String (aabcccccaaa): " + compressString("aabcccccaaa"));
        System.out.println("Are Anagrams (silent & listen): " + isAnagram("silent", "listen"));
        System.out.println("Permutations of 'cat': " + getPermutations("cat"));
        System.out.println("Longest Common Prefix: " + longestCommonPrefix(group));
    }
}
