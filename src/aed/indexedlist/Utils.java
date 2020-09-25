package aed.indexedlist;
import es.upm.aedlib.indexedlist.*;

public class Utils {
  /**
   * Returns whether an equivalent of the element 'e' 
   * or the element 'e' itself is present in the list 'l'.
   * 
   * @param e The element.
   * @param l The list.
   * @return A boolean value indicating if the element is in the list.
   * */
  public static <E> boolean isIn(E e, IndexedList<E> l) {
    boolean found = false;    // 'found' variable used for readability.
    
    for (int i = 0; i < l.size() && !found; i++) {
      found |= l.get(i).equals(e);
    }
    
    return found;
  }
  
  /**
   * Returns the list representing the ordered set of a given list.
   * i.e. Returns a list without repeated elements.
   * 
   * @param l The list.
   * @return A list made from the given one without repeated elements.
   */
  public static <E> IndexedList<E> deleteRepeated(IndexedList<E> l) {
    IndexedList<E> result = new ArrayIndexedList<E>();    // The list to be returned.
    for (E e : l) {
      if (!isIn(e, result)) {
        result.add(result.size(), e);
      }
    }
    return result;
  }
}
