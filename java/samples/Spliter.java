import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.Spliterators;
import java.util.stream.Stream;
import java.util.stream.StreamSupport;

public class Spliter {
    interface Generation<T> extends Iterable<T> {
        Stream<T> stream();
    }

    class CombinationIterator<T> implements Iterator<List<T>> {

        private final CombinationGenerator<T> generator;
        private List<T> currentSimpleCombination = null;

        private long currentIndex = 0;
        private final int lengthN;
        private final int lengthK;

        // Internal array
        private int[] bitVector = null;

        // Criteria to stop iterating
        private int endIndex = 0;

        CombinationIterator(CombinationGenerator<T> generator) {
            this.generator = generator;
            lengthN = generator.originalVector.size();
            lengthK = generator.combinationLength;
            currentSimpleCombination = new ArrayList<T>();
            bitVector = new int[lengthK + 1];
            for (int i = 0; i <= lengthK; i++) {
                bitVector[i] = i;
            }
            if (lengthN > 0) {
                endIndex = 1;
            }
            currentIndex = 0;
        }

        /**
         * Returns true if all combinations were iterated, otherwise false
         */
        @Override
        public boolean hasNext() {
            return !((endIndex == 0) || (lengthK > lengthN));
        }

        /**
         * Moves to the next combination
         */
        @Override
        public List<T> next() {
            currentIndex++;

            for (int i = 1; i <= lengthK; i++) {
                int index = bitVector[i] - 1;
                if (generator.originalVector.size() > 0) {
                    setValue(currentSimpleCombination, i - 1, generator.originalVector.get(index));
                }
            }

            endIndex = lengthK;

            while (bitVector[endIndex] == lengthN - lengthK + endIndex) {
                endIndex--;
                if (endIndex == 0)
                    break;
            }
            bitVector[endIndex]++;
            for (int i = endIndex + 1; i <= lengthK; i++) {
                bitVector[i] = bitVector[i - 1] + 1;
            }

            // return the current combination
            return new ArrayList<>(currentSimpleCombination);
        }

        @Override
        public void remove() {
            throw new UnsupportedOperationException();
        }

        @Override
        public String toString() {
            return "Combination=[#" + currentIndex + ", " + currentSimpleCombination + "]";
        }

        private void setValue(List<T> list, int index, T value) {
            if (index < list.size()) {
                list.set(index, value);
            } else {
                list.add(index, value);
            }
        }
    }

    class CombinationGenerator<T> implements Generation<List<T>> {

        final List<T> originalVector;
        final int combinationLength;

        CombinationGenerator(Collection<T> originalVector, int combinationsLength) {
            this.originalVector = new ArrayList<>(originalVector);
            this.combinationLength = combinationsLength;
        }

        @Override
        public Iterator<List<T>> iterator() {
            return new CombinationIterator<T>(this);
        }

        @Override
        public Stream<List<T>> stream() {
            return StreamSupport.stream(Spliterators.spliteratorUnknownSize(iterator(), 0), false);
        }

    }

    class Generator<T> {

        final Collection<T> originalVector;

        Generator(Collection<T> originalVector) {
            this.originalVector = originalVector;
        }

        public Generation<List<T>> simple(int length) {
            return new CombinationGenerator<>(originalVector, length);
        }

    }

    public <T> Generator<T> combination(T... args) {
        return new Generator<>(Arrays.asList(args));
    }

    public static void main(String[] args) {
        Spliter spliter = new Spliter();
        spliter.combination(14, 17, 23, 33, 41)
        .simple(4)
        .forEach(numbers -> System.out.println(numbers));

    }

}
