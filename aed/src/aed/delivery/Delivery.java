package aed.delivery;

import es.upm.aedlib.positionlist.PositionList;
import es.upm.aedlib.Entry;
import es.upm.aedlib.Position;
import es.upm.aedlib.map.Map;
import es.upm.aedlib.positionlist.NodePositionList;
import es.upm.aedlib.graph.DirectedGraph;
import es.upm.aedlib.graph.DirectedAdjacencyListGraph;
import es.upm.aedlib.graph.Vertex;
import es.upm.aedlib.graph.Edge;
import es.upm.aedlib.map.HashTableMap;
import es.upm.aedlib.set.HashTableMapSet;
import es.upm.aedlib.set.Set;
import java.util.Iterator;

public class Delivery<V> {
  private DirectedGraph<V, Integer> towns;
  private PositionList<Vertex<V>> hamPath;
  private int numTowns;
  
  
  // Construct a graph out of a series of vertices and an adjacency matrix.
  // There are 'len' vertices. A negative number means no connection. A non-negative
  // number represents distance between nodes.
  public Delivery(V[] places, Integer[][] gmat) {
    towns = new DirectedAdjacencyListGraph<V, Integer>();
    hamPath = new NodePositionList<Vertex<V>>();
    numTowns = places.length;
    Vertex<V> [] vertices = new Vertex [numTowns];
    
    for (int i = 0; i < numTowns; i++) {
      vertices[i] = towns.insertVertex(places[i]);
    }
    
    for (int i = 0; i < numTowns; i++) {
      for (int j = 0; j < numTowns; j++) {
        if (gmat[i][j] != null) {
          towns.insertDirectedEdge(vertices[i], vertices[j], gmat[i][j]);
        }
      }
    }
  }
  
  
  // Just return the graph that was constructed
  public DirectedGraph<V, Integer> getGraph() {
    return towns;
  }
  
  
  // Return a Hamiltonian path for the stored graph, or null if there is noe.
  // The list containts a series of vertices, with no repetitions (even if the path
  // can be expanded to a cycle).
  public PositionList<Vertex<V>> tour() { 
    for(Vertex<V> v : towns.vertices()) {
      if (hamPath.size() != numTowns) {
        tourRec(hamPath, v);
      } else {
        break;
      }
    }
    
    if (hamPath.size() == 0) {
      return null;
    } else {
      return hamPath;
    }
  }
  
  
  //En la primera vuelta, por cada vertice en el grafo va a llamar a los hijos de esos vertices que 
  //a su vez van a llamar a sus hijos y etc etc, el metodo para cuando ya no tengan hijos los vertices,
  // cuando al añadir un hijo este ya dentro o cuando se encuentra
  private void tourRec(PositionList<Vertex<V>> path, Vertex<V> town) {
    if (!inPath(town, path)) {
      path.addLast(town);
      
      Iterable<Edge<Integer>> routes = towns.outgoingEdges(town);
      
      for (Edge<Integer> route : routes) {
        if (path.size() != numTowns) {
          Vertex<V> t = towns.endVertex(route);
          tourRec(path, t);
        } else {
          break;
        }
      } 
      
      if (path.size() != numTowns) {
        path.remove(path.last());
      }
    }
  }
  

  private boolean inPath(Vertex<V> town, PositionList<Vertex<V>> path) {
    boolean in = false;
    Position<Vertex<V>> p = path.first();
    while (!in && p != null) {
      in |= p.element().equals(town);
      p = path.next(p);
    }
    return in;
  }

  
  public int length(PositionList<Vertex<V>> path) {
    int total = 0;
    Position<Vertex<V>> p = path.first();
    Position<Vertex<V>> n = path.next(p);
    while (n != null) {
      for (Edge<Integer> e : towns.outgoingEdges(p.element())) {
        if (towns.endVertex(e).equals(n.element())) {
          total += e.element();
          p = n;
          n = path.next(p);
          break;
        }
      }
    }
    return total;
  }

  
  public String toString() {
    return "Delivery";
  }
}
