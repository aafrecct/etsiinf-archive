package aed.recursion;

import java.util.Iterator;

import es.upm.aedlib.Pair;
import es.upm.aedlib.Position;
import es.upm.aedlib.positionlist.*;


public class Explorador {
	
	private static Pair<Object,PositionList<Lugar>> exploraR(Lugar lugar, PositionList<Lugar> camino){
		//Caso base, esta el tesoro
		if(lugar.tieneTesoro()){
			return new Pair<Object, PositionList<Lugar>>(lugar.getTesoro(), camino);
			
		} else {
			//No esta el tesoro asi que tenemos que ir al siguiente que no este marcado con tiza
			Lugar next = nextCamino(lugar);

			if(next == null) { //No hay siguiente asi que tenemos que volver al anterior
				
				if(lugar.sueloMarcadoConTiza()) { //si este estaba marcado es que habiamos pasado asi que hay que quitarlo de la pila
					
					camino.remove(camino.last());
				} else { //si no estaba marcado, no hace falta sacarlo de la pila porque no esta en un principio
					lugar.marcaSueloConTiza();
				}
				return exploraR(camino.last().element(), camino);
				
			} else {
				//metemos este lugar en la pila y llamamos a la unfion en el siguiente
				camino.addLast(lugar);
				lugar.marcaSueloConTiza();
				return exploraR(next,camino);
			}
		}
	}
		
	//Metodo que devuelve el siguiente lugar de la cueva que no esta marcado por tiza o null si no hay ninguno
	private static Lugar nextCamino(Lugar lugar) {
		Iterator<Lugar> it = lugar.caminos().iterator();
		boolean found = false;
		Lugar current = null;
		
		while(it.hasNext() && !found) {
			current  = it.next();
			if(!current.sueloMarcadoConTiza()) {
				found = true;
			}
		}
		return current;
	}
		
  
	public static Pair<Object,PositionList<Lugar>> explora(Lugar inicialLugar) {
		PositionList<Lugar> camino = new NodePositionList<Lugar>();
		camino.addLast(inicialLugar);
	  
	  return exploraR(inicialLugar, camino);
	}
}
