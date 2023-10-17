package aed.individual5;

import es.upm.aedlib.tree.Tree;

import java.util.Iterator;

import es.upm.aedlib.Position;


public class Find {
  
  private static void find(String fileName, Tree<String> directory, Position<String> node, String path) {
    String dirName = node.element();
    path += "/" + dirName;
    if (dirName.equals(fileName)) {
      Printer.println(path);
    } else {
      if (directory.isInternal(node)) {
        for (Position<String> child : directory.children(node)) {
          find(fileName, directory, child, path);
        }
      }
    }
  }
  
  /**
   * Busca ficheros con nombre igual que fileName dentro el arbol directory,
   * y devuelve un PositionList con el nombre completo de los ficheros
   * (incluyendo el camino).
   */
  public static void find(String fileName, Tree<String> directory) {
    Printer.enableOutput();
    find(fileName, directory, directory.root(), "");
  }
}
