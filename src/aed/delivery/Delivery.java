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
		Map<Vertex<V>, V> path = new HashTableMap<Vertex<V>,V>();
		PositionList<Vertex<V>> sol = new NodePositionList<Vertex<V>>();
		for(Entry<Vertex<V>, V> x : tourRec(towns.vertices(), path).entries()) {
			sol.addLast(x.getKey());
		}
	    return sol;
	  }
	  
	  //En la primera vuelta, por cada vertice en el grafo va a llamar a los hijos de esos vertices que 
	  //a su vez van a llamar a sus hijos y etc etc, el metodo para cuando ya no tengan hijos los vertices,
	  // cuando al añadir un hijo este ya dentro o cuando se encuentra
	  
	  private boolean foundTourRec = false;
	  private Map<Vertex<V>,V> tourRec(Iterable<Vertex<V>> iter, Map<Vertex<V>,V> path) {
		  
		  //Si ya esta encontrado no entramos en el metodo
		  if(foundTourRec) {
			  return path;
		  }
		  //Comprobacion de que estan todos dentro del camino y lo ha encontrado
		  if(path.size() == towns.numVertices()) {
			  this.foundTourRec = true;
			  return path;
		  }
		  // Comprobacion de que no hay mas hijos que visitar
		  if(!iter.iterator().hasNext()) {
				return null;
		  }
		  Map<Vertex<V>,V> sol = new HashTableMap<Vertex<V>, V>();
		  Map<Vertex<V>,V> copy = new HashTableMap<Vertex<V>, V>(path);
		  for( Vertex<V> vertex : iter) {
			//Si el put devuelve null es que no estaba en el camino y seguimos por ahi
			//En otro caso seguimos 
			if(path.put(vertex, vertex.element()) == null && !foundTourRec) {
				sol = tourRec(iterableVertex(vertex), path);
				path = copy;
				
			}
		  }
		   /*Si ha pasado que no esta vacio, es distinto el numero de elementos en el camino y el grafo,
		   * Todavia no esta encontrado, y por cada elemento estan repetidos eso significa que no hay camino posible
		   * asi que devolvemos null*/
		  return sol;
		
	}
	  //Método que devuelve un iterable de todos los nodos hijos de dado un cierto nodo padre
	  private Iterable<Vertex<V>> iterableVertex (Vertex<V> vertex){
		  PositionList<Vertex<V>> list = new NodePositionList<Vertex<V>>();
		  for(Edge<Integer> edge : towns.outgoingEdges(vertex)) {
			  list.addLast(towns.endVertex(edge));
		  }
		  return list;
	  }

  public int length(PositionList<Vertex<V>> path) {
    return 0;
  }

  public String toString() {
    return "Delivery";
  }
}
