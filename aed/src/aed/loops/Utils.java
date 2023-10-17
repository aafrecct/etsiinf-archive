package aed.loops;

public class Utils {
  /**
   * Returns the maximum number of equivalent, consecutive Integers
   * matching the one given in an array of Integers.
   * 
   * @param a An array of Integers.
   * @param elem An Integer to compare them to.
   * @return The maximum number con consecutive repetitions of 'elem'.
   * */
  public static int maxNumRepeated(Integer[] a, Integer elem)  {
	  int max_reps = 0;    // This counter updates when a larger chain is found.
	  int reps = 0;        // This counter resets every time a chain is broken.
	  
	  for (int i = 0; i < a.length; i++) {
		  reps = a[i].compareTo(elem) == 0 ? reps + 1 : 0;
		  max_reps = reps > max_reps ? reps : max_reps;
	  }
	  
	  return max_reps;  
  }
}
