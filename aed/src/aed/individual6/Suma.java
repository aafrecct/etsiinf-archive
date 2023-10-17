package aed.individual6;

import es.upm.aedlib.graph.Edge;
import es.upm.aedlib.graph.Vertex;
import es.upm.aedlib.graph.DirectedGraph;
import es.upm.aedlib.map.Map;
import es.upm.aedlib.map.HashTableMap;


public class Suma {

  private static <E> Map<Vertex<Integer>,Integer> reachableVertices(DirectedGraph<Integer,E> g,
                                                                    Vertex<Integer> v, 
                                                                    Map<Vertex<Integer>,Integer> reachable){
    reachable.put(v, 0);
    for (Edge<E> e : g.outgoingEdges(v)) {
      Vertex<Integer> ev = g.endVertex(e);
      if (!reachable.containsKey(ev)) {
        Map<Vertex<Integer>,Integer> rm = reachableVertices(g, ev, reachable);
        for (Vertex<Integer> rv : rm.keys()) {
          if (!reachable.containsKey(rv)) {
            reachable.put(rv, 0);
          }
        }
      }
    }
    return reachable;
  }
  
  public static <E> Map<Vertex<Integer>,Integer> sumVertices(DirectedGraph<Integer,E> g) {
    Map<Vertex<Integer>,Integer> m = new HashTableMap<Vertex<Integer>, Integer>();
    for (Vertex<Integer> v : g.vertices()) {
      int sum = 0;
      Map<Vertex<Integer>,Integer> reachable = reachableVertices(g, v, new HashTableMap<Vertex<Integer>,Integer>());
      for (Vertex<Integer> rv : reachable.keys()) {
        sum += rv.element();
      }
      m.put(v, sum);
    }
    return m;
  }
}
