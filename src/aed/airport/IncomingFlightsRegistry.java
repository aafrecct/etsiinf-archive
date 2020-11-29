package aed.airport;


import java.util.Iterator;
import es.upm.aedlib.Entry;
import es.upm.aedlib.Pair;
import es.upm.aedlib.Position;
import es.upm.aedlib.indexedlist.ArrayIndexedList;
import es.upm.aedlib.indexedlist.IndexedList;
import es.upm.aedlib.priorityqueue.*;
import es.upm.aedlib.map.*;
import es.upm.aedlib.positionlist.*;


/**
 * A registry which organizes information on airplane arrivals.
 */
public class IncomingFlightsRegistry {
	static private PositionList<Pair<String,Long>> flightsList = new NodePositionList<Pair<String,Long>>(); 
  /**
   * Constructs an class instance.
   */
  public IncomingFlightsRegistry() {
  }

  /**
   * A flight is predicted to arrive at an arrival time (in seconds).
   */
  public void arrivesAt(String flight, long time) {
	  Position<Pair<String,Long>> elem = search(flight);
	  if(elem == null) {
		  flightsList.addLast(new Pair<String,Long>(flight,time));
	  }else {
		  elem.element().setRight(time);
	  }
  }
  
  //Method that returns the element searched or null if it isnt on the list
  private Position<Pair<String,Long>> search (String name){
	  Position<Pair<String,Long>> cursor = flightsList.first();
	  while(cursor != null && cursor.element().getLeft() != name) {
			  cursor = flightsList.next(cursor);
	  }
	  return cursor;
	  
  }
  

  /**
   * A flight has been diverted, i.e., will not arrive at the airport.
   */
  public void flightDiverted(String flight) {
	  if(search(flight) != null)
		  flightsList.remove(search(flight));
  }

  /**
   * Returns the arrival time of the flight.
   * @return the arrival time for the flight, or null if the flight is not predicted
   * to arrive.
   */
  public Long arrivalTime(String flight) {
    return search(flight) == null? null : search(flight).element().getRight();
  }

  /**
   * Returns a list of "soon" arriving flights, i.e., if any 
   * is predicted to arrive at the airport within nowTime+180
   * then adds the predicted earliest arriving flight to the list to return, 
   * and removes it from the registry.
   * Moreover, also adds to the returned list, in order of arrival time, 
   * any other flights arriving withinfirstArrivalTime+120; these flights are 
   * also removed from the queue of incoming flights.
   * @return a list of soon arriving flights.
   */
  public PositionList<FlightArrival> arriving(long nowTime) {
    return null;
  }
  
}
