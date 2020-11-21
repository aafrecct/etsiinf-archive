package aed.treesearch;


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

  public static Tree<String> constructDeterministicTree(Set<PositionList<String>> paths) {
    return null;
  }
}
