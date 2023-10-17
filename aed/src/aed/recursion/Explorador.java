package aed.recursion;

import java.util.Iterator;

import es.upm.aedlib.Pair;
import es.upm.aedlib.positionlist.*;


public class Explorador {
	
	private static Pair<Object,PositionList<Lugar>> explora (Lugar lugar, PositionList<Lugar> camino){
		if (lugar.tieneTesoro()) {
		  // Caso base, esta el tesoro.
			return new Pair<Object, PositionList<Lugar>>(lugar.getTesoro(), camino);		
			
		} else {
			// No esta el tesoro asi que tenemos que ir al siguiente que no este marcado con tiza.
			Lugar next = nextCamino(lugar);
			lugar.marcaSueloConTiza();
			
			if (next == null) { 
			  // No hay siguiente asi que tenemos que volver al anterior.
				camino.remove(camino.last());
				return explora(camino.last().element(), camino);	
				
			} else {
				// Metemos este lugar en la pila y llamamos a la funcion en el siguiente.
				camino.addLast(next);
				return explora(next,camino);
			}
		}
	}
		
	// Metodo que devuelve el siguiente lugar de la cueva que no esta marcado por tiza o null si no hay ninguno.
	private static Lugar nextCamino (Lugar lugar) {
	  Iterator<Lugar> caminos = lugar.caminos().iterator();
		Lugar next = null;
		
		while (caminos.hasNext() && next == null) {
		  Lugar l = caminos.next();
		  if (!l.sueloMarcadoConTiza()) {
        next = l;
		  }
		}
		
		return next;
	}
		
  
	public static Pair<Object,PositionList<Lugar>> explora (Lugar inicialLugar) {
		PositionList<Lugar> camino = new NodePositionList<Lugar>();
		camino.addLast(inicialLugar);
	  return explora(inicialLugar, camino);
	}
}
