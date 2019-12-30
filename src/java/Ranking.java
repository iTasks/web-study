public class Ranking {

    public static int LIMIT = 45; 
    
    public static void main(String []args) {
        
        int[] flag = new int[LIMIT + 1];
        
        int[] winningGameNumberArr = {1, 2, 9, 15, 31};
        
        int[] gameNumberArr1 = {2, 9, 29, 35, 41};
        int[] gameNumberArr2 = {1, 9, 20, 31, 44};
        
        for(int i=0; i<winningGameNumberArr.length; i++)
            flag[winningGameNumberArr[i]] = 1;
        
        int matchCount1 = 0;
        for(int i=0; i<gameNumberArr1.length; i++)
            if(flag[ gameNumberArr1[i] ] == 1)
                matchCount1++;
        
        int matchCount2 = 0;
        for(int i = 0; i< gameNumberArr2.length; i++)
            if(flag[ gameNumberArr2[i] ] == 1)
                matchCount2++;
        
        System.out.println("Found " + matchCount1 + " times in first Array");
        System.out.println("Found " + matchCount2 + " times in second Array");
        
     }
}
