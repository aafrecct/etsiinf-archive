package aed.delivery;

import es.upm.aedlib.positionlist.PositionList;
import es.upm.aedlib.Position;
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
  DirectedGraph<V, Integer> towns = new DirectedAdjacencyListGraph<V, Integer>();
  
  // Construct a graph out of a series of vertices and an adjacency matrix.
  // There are 'len' vertices. A negative number means no connection. A non-negative
  // number represents distance between nodes.
  public Delivery(V[] places, Integer[][] gmat) {
    Vertex<V> [] vertices = new Vertex [places.length];
    for (int i = 0; i < places.length; i++) {
      vertices[i] = towns.insertVertex(places[i]);
    }
    for (int i = 0; i < places.length; i++) {
      for (int j = 0; i < places.length; j++) {
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
  public PositionList <Vertex<V>> tour() {
    return null;
  }

  public int length(PositionList<Vertex<V>> path) {
    return 0;
  }

  public String toString() {
    return "Delivery";
  }
}
