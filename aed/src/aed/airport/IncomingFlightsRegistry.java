package aed.airport;


import java.util.Iterator;
import es.upm.aedlib.Pair;
import es.upm.aedlib.Position;
import es.upm.aedlib.map.Map;
import es.upm.aedlib.map.HashTableMap;
import es.upm.aedlib.positionlist.*;
import es.upm.aedlib.Entry;
import es.upm.aedlib.priorityqueue.HeapPriorityQueue;
import es.upm.aedlib.priorityqueue.PriorityQueue;


/**
 * A registry which organizes information on airplane arrivals.
 */
public class IncomingFlightsRegistry {
  private Map<String, Entry<Long, String>> flightMap;
  private PriorityQueue<Long, String> timeQueue;
  
	/**
   * Constructs an class instance.
   */
  public IncomingFlightsRegistry() {
    flightMap = new HashTableMap<String, Entry<Long, String>>();
    timeQueue = new HeapPriorityQueue<Long, String>();
  }
  
  private FlightArrival entryToArrival (Entry<Long, String> entry) {
    return new FlightArrival(entry.getValue(), entry.getKey());
  }
  
  /**
   * A flight is predicted to arrive at an arrival time (in seconds).
   */
  public void arrivesAt(String flight, long time) {
    Entry<Long, String> entry = flightMap.get(flight);
    if (entry == null) {
      flightMap.put(flight, timeQueue.enqueue(time, flight));
    } else {
      timeQueue.replaceKey(entry, time);
    }
  }
  

  /**
   * A flight has been diverted, i.e., will not arrive at the airport.
   */
  public void flightDiverted (String flight) {
    Entry<Long, String> entry = flightMap.get(flight);
    if (entry != null) {
      timeQueue.remove(entry);
      flightMap.remove(flight);
    }
  }

  /**
   * Returns the arrival time of the flight.
   * @return the arrival time for the flight, or null if the flight is not predicted
   * to arrive.
   */
  public Long arrivalTime(String flight) {
    Entry<Long, String> f = flightMap.get(flight);
    return f != null ? f.getKey() : null;
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
    PositionList<FlightArrival> res = new NodePositionList<FlightArrival>();
    if (!timeQueue.isEmpty() && timeQueue.first().getKey() <= nowTime + 180) {
      Long firstArrivalTime = timeQueue.first().getKey();
      do {
        res.addLast(entryToArrival(timeQueue.dequeue()));
        flightMap.remove(res.last().element().flight());
      } while (!timeQueue.isEmpty() && timeQueue.first().getKey() <= firstArrivalTime + 120);
    }
    return res;
  }
  
}
