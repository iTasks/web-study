public class Ranking {

    public static final int LIMIT = 45;

    public static void main(String[] args) {

        int[] flag = new int[LIMIT + 1];

        int[] drawNumbers = { 1, 2, 9, 15, 31 };

        int[] gameNumbers01 = { 2, 9, 29, 35, 41 };
        int[] gameNumbers02 = { 1, 9, 20, 31, 44 };

        int matchCount1 = extracted(flag, drawNumbers, gameNumbers01);
        int matchCount2 = extracted(flag, drawNumbers, gameNumbers02);

        System.out.println("Found " + matchCount1 + " times in first Array");
        System.out.println("Found " + matchCount2 + " times in second Array");

    }

    private static int extracted(int[] flag, int[] winningGameNumberArr, int[] gameNumberArr1) {
        for (int i = 0; i < winningGameNumberArr.length; i++) {

            flag[winningGameNumberArr[i]] = 1;
        }

        int matchCount1 = 0;
        for (int i = 0; i < gameNumberArr1.length; i++) {
            if (flag[gameNumberArr1[i]] == 1) {
                matchCount1++;
            }
        }
        return matchCount1;
    }
}
