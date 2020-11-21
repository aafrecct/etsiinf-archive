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
    return null;
  }
}
