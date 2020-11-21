package aed.treesearch;


import es.upm.aedlib.Position;
import es.upm.aedlib.set.*;
import es.upm.aedlib.positionlist.*;
import es.upm.aedlib.tree.*;


public class TreeSearch {
  
  private static boolean match (Position<String> expr, Position<String> node) {
    if (expr.element().equals("*")) {
      return true;
    } else {
      return expr.element().equals(node.element());
    }
  }
  
  private static Set<Position<String>> search (Tree<String> t, PositionList<String> searchExprs, Position<String> node,
                                               Set<Position<String>> result, PositionList<String> streak, Position<String> searchPos) {
    if (t.isInternal(node)) {
      if (match(searchPos, node)) {
        if (streak.size() + 1 == searchExprs.size()) {
          result.add(node);
          streak = new NodePositionList<String>();
          searchPos = searchExprs.first();
        } else {
          streak.addLast(node.element());
          searchPos = searchExprs.next(searchPos);
        }
      } else {
        streak = new NodePositionList<String>();
        searchPos = searchExprs.first();
        if (match(searchPos, node)) {
          streak.addLast(node.element());
          searchPos = searchExprs.next(searchPos);
        }
      }
      for (Position<String> child : t.children(node)) {
        result = search(t, searchExprs, child, result, streak, searchPos);
      }
      return search(t, searchExprs, node, result, streak, searchPos);
    } else {
      if (streak.size() + 1 == searchExprs.size()) {
        if (match(searchExprs.last(), node)) {
          result.add(node);
        }
      }
    }
    return result;
  }
  
  public static Set<Position<String>> search(Tree<String> t,
                                             PositionList<String> searchExprs) {
    return null;
  }

  public static Tree<String> constructDeterministicTree(Set<PositionList<String>> paths) {
	LinkedGeneralTree<String> sol = new LinkedGeneralTree<String>();
	//de verdad que no se como pasar del set a algo mas iterable asi que lo paso a una lista
	PositionList<PositionList<String>> ls = new NodePositionList<PositionList<String>>();
	for(PositionList<String> e : paths) {
		ls.addLast(e);
	}
	sol = constructDeterministicTreeRec(ls, sol);
    return sol;
  }
  
  private static LinkedGeneralTree<String> constructDeterministicTreeRec(PositionList<PositionList<String>> ls, LinkedGeneralTree<String> t){
	  if(ls.isEmpty()) {
		  return t;
	  }
	  PositionList<String> PList = ls.first().element();
	  String PrimeraPalabra = PList.first().element();
	  
	  //si el arbol esta vacio introducimos el primer elemento de la lista (PList)
	  if(t.isEmpty()) {
		  t.addRoot(PrimeraPalabra);
	  }
	  //comprobamos si el primer elemento del PositionList es la root
	  if(t.root().element() != PrimeraPalabra) {
			  ls.remove(ls.first());
			  return constructDeterministicTreeRec(ls, t);
	  }
		  
	  //Procedemos sabiendo que hay una root ya y quitamos el primer elemento(que es la root que ya tenemos)
	  PList.remove(PList.first());
	  Position<String> cursor = t.root();
	  //Miramos para cada elemento de la position list si es hijo, luego el cursor pasa a ser ese si o si
	  for(String e : PList) {
		  cursor = isSon(t, cursor, e);
		  if(cursor == null) {
			  cursor = t.addChildLast(cursor, e);
		  }
	  }
	  //En este momento ya hemos recorrido toda la positionList y metido los elementos, es momento de llamar al siguiente
	  
	  ls.remove(ls.first());
	  return constructDeterministicTreeRec(ls, t);
	  }
	  
  
  
  //Metodo que devuelve una posicion si hay un hijo con ese string o null si no lo hay
  private static Position<String> isSon(Tree<String> t, Position<String> a, String b) {
	  Position<String> boy = null;
	  for(Position<String> e : t.children(a)) {
		  if(e.element() == b) {
			  boy = e;
		  }
	  }
	  return boy;
  }
}
