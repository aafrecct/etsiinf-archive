package aed.individual3;

import es.upm.aedlib.Position;
import es.upm.aedlib.positionlist.NodePositionList;
import es.upm.aedlib.positionlist.PositionList;

public class OperacionCompactar {
	
  /**
   * Compares two nullable elements.
   * @param <E> A nullable element.
   * @param elem1
   * @param elem2
   * @return Whether elem1 is equivalent to elem2.
   */
  private static <E> boolean equals (E elem1, E elem2) {
    if (elem1 == null) {
      return elem2 == null;
    } else {
      return elem1.equals(elem2);
    }
  }
  
	/**
	 * Metodo que reduce los elementos iguales consecutivos de una lista a una 
	 * unica repeticion
	 * @param lista Lista de entrada
	 * @return Lista nueva compactada sin elementos iguales consecutivos
	 */
	public static <E> PositionList<E> compactar (Iterable<E> lista) {
	  NodePositionList<E> lista_compact = new NodePositionList<E>();
	  E last_element = null;
	  for (E e : lista) {
	    if (!equals(e, last_element) || lista_compact.isEmpty()) {
        lista_compact.addLast(e);
        last_element = e;
	    }
	  }
		return lista_compact;
	}
	

}
