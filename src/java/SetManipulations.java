import java.util.HashSet;
import java.util.Set;

public class SetManipulations {

    public static <T> Set<T> union(Set<T> set1, Set<T> set2) {
        Set<T> result = new HashSet<>(set1);
        result.addAll(set2);
        return result;
    }

    public static <T> Set<T> intersection(Set<T> set1, Set<T> set2) {
        Set<T> result = new HashSet<>(set1);
        result.retainAll(set2);
        return result;
    }

    public static <T> Set<T> difference(Set<T> set1, Set<T> set2) {
        Set<T> result = new HashSet<>(set1);
        result.removeAll(set2);
        return result;
    }

    public static <T> Set<T> symmetricDifference(Set<T> set1, Set<T> set2) {
        Set<T> result = union(set1, set2);
        Set<T> intersect = intersection(set1, set2);
        result.removeAll(intersect);
        return result;
    }

    public static <T> boolean isSubset(Set<T> subset, Set<T> superset) {
        return superset.containsAll(subset);
    }

    public static void main(String[] args) {
        Set<Integer> set1 = new HashSet<>();
        Set<Integer> set2 = new HashSet<>();
        // Adding elements
        set1.add(1);
        set1.add(2);
        set1.add(3);
        set2.add(2);
        set2.add(3);
        set2.add(4);

        System.out.println("Set1: " + set1);
        System.out.println("Set2: " + set2);
        System.out.println("Union: " + union(set1, set2));
        System.out.println("Intersection: " + intersection(set1, set2));
        System.out.println("Difference (Set1 - Set2): " + difference(set1, set2));
        System.out.println("Symmetric Difference: " + symmetricDifference(set1, set2));
        System.out.println("Is Set2 a subset of Set1? " + isSubset(set2, set1));
        System.out.println("Is {2, 3} a subset of Set1? " + isSubset(new HashSet<>(Set.of(2, 3)), set1));
    }
}
