public class Main {

  public static void sum(int[][] g, int pos, int r, int c) 	{
	  int rs = 0;
    for(int j = pos; j <= pos+c; j++){
      for(int i = pos; i <= pos+r; i++){
    	  rs = rs + g[j][i];
      }
    }
    System.out.println("Sum: "+ rs);
  }
  
  public static void main(String[] args) {
  	int[][] grid = {
			{2, 3, 4, 6},
          		{5, 8, 6, 1},
			{8, 7, 6, 4},
			{4, 5, 6, 9}
				};
    int rows = 4;
    int cols = 4;
    sum(grid, 0, 1, 1);
    sum(grid, 0, 2, 2);
  }
}
