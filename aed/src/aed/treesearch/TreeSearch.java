package aed.treesearch;


import java.util.Iterator;

import es.upm.aedlib.Position;
import es.upm.aedlib.set.*;
import es.upm.aedlib.positionlist.*;
import es.upm.aedlib.tree.*;


public class TreeSearch {
  private static boolean match (String expr, Position<String> node) {
    if (expr.equals("*")) {
      return true;
    } else {
      return expr.equals(node.element());
    }
  }
  
  private static Set<Position<String>> search (Tree<String> t, PositionList<String> searchExprs, Position<String> expElem,
                                               Position<String> node, Set<Position<String>> result) {
    if (expElem != null && match(expElem.element(), node)) {
      if (expElem.equals(searchExprs.last())) {
        result.add(node);
      } else {
        for (Position<String> child : t.children(node)) {
          search(t, searchExprs, searchExprs.next(expElem), child, result);
        }
      }
    }
    return result;
  }
  
  public static Set<Position<String>> search(Tree<String> t, PositionList<String> searchExprs) {
    return search(t, searchExprs, searchExprs.first(), t.root(), new HashTableMapSet<Position<String>>());
  }
  
  private static <E> Set<E> copySet(Set<E> s) {
    Set<E> ns = new HashTableMapSet<E>();
    for (E item : s) {
      ns.add(item);
    }
    return ns;
  }
  
  public static Tree<String> constructDeterministicTree(Set<PositionList<String>> paths) {
		LinkedGeneralTree<String> t = new LinkedGeneralTree<String>();
		
		//hacemos una copia para no andar molestando
		Set<PositionList<String>> listOfPaths = copySet(paths);
		
		for(PositionList<String> path : listOfPaths) {
			
			  //primer caso con el arbol vacio para meter la root
			  if(t.isEmpty()) {
				  t.addRoot(path.first().element());
			  }
			  //Procedemos sabiendo que hay una root ya y quitamos el primer elemento(que es la root que ya tenemos)
			  path.remove(path.first());
			  Position<String> cursor = t.root();
			  //Miramos para cada elemento de la position list si es hijo, luego el cursor pasa a ser ese si o si
			  for(String name : path) {
				  if(isChild(t, cursor, name) == null) {
					  cursor = t.addChildLast(cursor, name);
				  }else {
					  cursor = isChild(t, cursor, name);
				  }
			  }
		}
	    return t;
	  }
  
  //Metodo que devuelve una posicion si hay un hijo con ese string o null si no lo hay
  private static Position<String> isChild(Tree<String> t, Position<String> father, String name) {
	  //Una simple busqueda con iteradores
	  Position<String> boy = null;
	  Iterator<Position<String>> it = t.children(father).iterator(); 
	  while(boy == null && it.hasNext()) {
		  Position<String> n = it.next();
		  if(n.element().equals(name)) {
			  boy = n;
		  }
	  }
	  return boy;
  }

}
