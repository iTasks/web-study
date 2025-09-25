import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class Combination {
    // refer: https://www.baeldung.com/java-combinations-algorithm
    // recursive: C(n, r) = C(n-1, r-1) + C(n-1, r)

    private void helper(List<Integer[]> combinations, Integer data[], Integer start, Integer end, Integer index) {
        if (index == data.length) {
            Integer[] combination = data.clone();
            combinations.add(combination);
        } else if (start <= end) {
            data[index] = start;
            helper(combinations, data, start + 1, end, index + 1);
            helper(combinations, data, start + 1, end, index);
        }
    }

    public List<Integer[]> generate(Integer n, Integer r) {
        List<Integer[]> combinations = new ArrayList<>();
        helper(combinations, new Integer[r], 0, n - 1, 0);
        return combinations;
    }

    public static void main(String[] args) {
        Combination combination = new Combination();
        List<String> generated = combination.generate(45, 5).stream()
                .map(numbers -> Stream.of(numbers).map(String::valueOf).collect(Collectors.joining("|")))
                .collect(Collectors.toList());
        System.out.println(generated);
    }

}
