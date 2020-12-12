package aed.airport;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;
import es.upm.aedlib.positionlist.*;


public class Tests {
  
  @Test
  public void property1 () {
    IncomingFlightsRegistry fr = new IncomingFlightsRegistry();
    fr.arrivesAt("avion", 1050);
    fr.arrivesAt("avion", 1200);
    assertEquals(fr.arrivalTime("avion"), 1200);
  }
  
  @Test
  public void property2 () {
    IncomingFlightsRegistry fr = new IncomingFlightsRegistry();
    fr.arrivesAt("avion1", 20);
    fr.arrivesAt("avion2", 10);
    FlightArrival a[] = {new FlightArrival("avion2", 10), new FlightArrival("avion1", 20)};  
    PositionList<FlightArrival> pa = new NodePositionList<FlightArrival>(a);
    assertEquals(fr.arriving(0), pa);
  }
  
}

