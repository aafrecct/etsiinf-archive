package aed.bancofiel;

import java.util.Comparator;
import es.upm.aedlib.indexedlist.IndexedList;
import es.upm.aedlib.indexedlist.ArrayIndexedList;


/**
 * Implements the code for the bank application.
 * Implements the client and the "gestor" interfaces.
 */
public class BancoFiel implements ClienteBanco, GestorBanco {

  // NOTAD. No se deberia cambiar esta declaracion.
  public IndexedList<Cuenta> cuentas;

  // NOTAD. No se deberia cambiar esta constructor.
  public BancoFiel() {
    this.cuentas = new ArrayIndexedList<Cuenta>();
  }
  // ============================================================================================================
  // ------------------METODOS PRIVADOS Y AUXILIARES -------------------------------------------
  // serie de Metodos privados que usamos para poder resolver los problemas
  
  //Metodo auxiliar del metodo quickSort
  private static int partition(IndexedList<Cuenta> list, int start, int end, Comparator<Cuenta> cmp) {
    Cuenta pivot = list.get(end);  
    int i = end;
    
    for(int j = start; j < i;) {
      if (cmp.compare(list.get(j), pivot) > 0 ){
        list.add(i, list.removeElementAt(j));
        i--;
      } else {
        j++;
      }
    }
    return i; 
  }
  
  /**
   * Metodo quicksort que reordena una lista de una manera recursiva 
   * @param list lista que se le introduce
   * @param start inicio (requerido para la recursivvidad)
   * @param end final (requerido para la recursivvidad)
   * @param cmp comparador por el cual se quiere ordenar
   * @return una lista ordenada segun cmp
   */ 
  private static void quickSort(IndexedList<Cuenta> list, int start, int end, Comparator<Cuenta> cmp){
    if (start < end) {
      int p = partition(list, start, end, cmp);
      quickSort(list, start, p - 1, cmp);
      quickSort(list, p + 1, end, cmp);
    }   
  }
  
  /**
   * Metodo que busca de manera binaria un elemento en la lista tiene como precondicion que la lista este ordenada
   * @param list lista donde buscar
   * @param start inicio (requerido para la recursivvidad)
   * @param end final (requerido para la recursivvidad)
   * @param id  ID del elemento que se quiere buscar
   * @return la posicion en el array de ese elemento
   * @throws CuentaNoExisteExc
   */
  private static int binarySearchId(IndexedList<Cuenta> list, int start, int end, String id) throws CuentaNoExisteExc {
	
	if (list.size() <= 0) {
      throw new CuentaNoExisteExc();  
    } else {
    	//Cogemos el elemento del medio y en base a el vemos si está por encima o por debajo el que queremos	
      int med = start + (int)((end - start) / 2);
      int comparison = list.get(med).getId().compareTo(id);
      if (comparison == 0) {
    	  return med;
      } else if((end - start) < 1){
    	  throw new CuentaNoExisteExc();
      } else if (comparison > 0) {
    	  return binarySearchId(list, start, med - 1, id);
      } else {
    	  return binarySearchId(list, med + 1, end, id);
      } 
    }
  }
  
  
  /**
   * Metodo que busca de manera binaria un elemento en la lista tiene como precondicion que la lista este ordenada
   * @param list lista donde buscar
   * @param start inicio (requerido para la recursivvidad)
   * @param end final (requerido para la recursivvidad)
   * @param dni DNI del elemento que se quiere buscar
   * @return la posicion en el array de ese elemento
   * @throws CuentaNoExisteExc
   */
  private static int binarySearchDNI(IndexedList<Cuenta> list, int start, int end, String dni) throws CuentaNoExisteExc {
	  if (list.size() <= 0) {
	      throw new CuentaNoExisteExc();  
	  } else {  
		  //Cogemos el elemento del medio y en base a el vemos si está por encima o por debajo el que queremos
		int med = start + (int)((end - start) / 2);
	    int comparison = list.get(med).getDNI().compareTo(dni);
	    if (comparison == 0) {
	      return med;
	    } else if(end - start < 1){
	    	throw new CuentaNoExisteExc();
	    } else if (comparison > 0) {
	      return binarySearchDNI(list, start, med - 1, dni);
	    } else {
	      return binarySearchDNI(list, med + 1, end, dni);
	    } 
	  }
  }
  
  /**
   *  Metodo que busca por id un elemento
   * @param id
   * @return el elemento
   * @throws CuentaNoExisteExc
   */
  private Cuenta getCuentaById(String id) throws CuentaNoExisteExc {
    return cuentas.get(binarySearchId(cuentas, 0 , cuentas.size() - 1, id));
  }
  
  /**
   *  Metodo que busca por DNI un elemento
   * @param dni
   * @return array con las cuentas asociadas al mismo dni
   * @throws CuentaNoExisteExc
   */
  
  private  IndexedList<Cuenta> getCuentasByDNI(String dni) throws CuentaNoExisteExc {
    IndexedList<Cuenta> sol = new ArrayIndexedList<Cuenta>();
    //Nuestro método binary search nos busca un elemento aleatorio dentro de el "bloque" de cuentas con el mismo dni
    int med = 0;
    med = binarySearchDNI(cuentas, 0, cuentas.size() - 1, dni);
    sol.add(0, cuentas.get(med));
    getAccDni(med + 1, 1, dni, sol);
    getAccDni(med - 1, -1, dni, sol);  
    //Devuelve un array ordenado por id de las cuentas con el mismo dni  
    return sol;
  }
  
  /**
   *  Metodo que busca en una direccion cuentas que tengan un dni y las añade a la lista 
   * @param i 
   * @param dir la direccion
   * @param dni el dni 
   * @param list
   */
  private void getAccDni(int i, int dir, String dni, IndexedList<Cuenta> list) {
	    while(i < cuentas.size() && i >= 0 && cuentas.get(i).getDNI().equals(dni)) {
	      int pos = dir > 0 ? list.size() : 0;
	      list.add(pos, cuentas.get(i));
	      i += dir;
	    }
	  }
  
  // ------------------METODOS A IMPLEMENTAR-------------------------------------------
  
  @Override
  public IndexedList<Cuenta> getCuentasOrdenadas(Comparator<Cuenta> cmp) {
    IndexedList<Cuenta> cuentas_new_sort = new ArrayIndexedList<Cuenta>((ArrayIndexedList<Cuenta>) cuentas);
    quickSort(cuentas_new_sort, 0, cuentas_new_sort.size() - 1, cmp);
    return cuentas_new_sort;
  }

  @Override
  public String crearCuenta(String dni, int saldoIncial) {
    Cuenta nueva_cuenta = new Cuenta(dni, saldoIncial);
    int i = 0;
    for ( ; i < cuentas.size() && !(cuentas.get(i).getId().compareTo(nueva_cuenta.getId()) > 0); i++){}
    cuentas.add(i, nueva_cuenta);
    return nueva_cuenta.getId();
  }

  @Override
  public void borrarCuenta(String id) throws CuentaNoExisteExc, CuentaNoVaciaExc {
    Cuenta cuenta = getCuentaById(id);
    if (cuenta.getSaldo() > 0){
      throw new CuentaNoVaciaExc();
    }
    cuentas.remove(cuenta);
  }

  @Override
  public int ingresarDinero(String id, int cantidad) throws CuentaNoExisteExc {
    Cuenta cuenta = getCuentaById(id);
    return cuenta.ingresar(cantidad);
  }

  @Override
  public int retirarDinero(String id, int cantidad) throws CuentaNoExisteExc, InsuficienteSaldoExc {
    Cuenta cuenta = getCuentaById(id);
    return cuenta.retirar(cantidad);
  }

  @Override
  public int consultarSaldo(String id) throws CuentaNoExisteExc { 
    Cuenta cuenta = getCuentaById(id);
    return cuenta.getSaldo();
  }

  @Override
  public void hacerTransferencia(String idFrom, String idTo, int cantidad)
      throws CuentaNoExisteExc, InsuficienteSaldoExc {
    Cuenta origen = getCuentaById(idFrom);
    Cuenta destino = getCuentaById(idTo);
    origen.retirar(cantidad);
    destino.ingresar(cantidad);
  }
  
  
  @Override
  public IndexedList<String> getIdCuentas(String dni) {
    IndexedList<String> sol = new ArrayIndexedList<String>();
    try {
      for (Cuenta c : getCuentasByDNI(dni)) {
        sol.add(sol.size(), c.getId());
      }
    } catch (CuentaNoExisteExc e) {}
   
    return sol;  
  }

  @Override
  public int getSaldoCuentas(String dni) {
    int sum = 0;
    try {
      for (Cuenta c : getCuentasByDNI(dni)) {
        sum += c.getSaldo();
      }
    } catch (CuentaNoExisteExc e) {}
  
    return sum;
  }

  // ===========================================================================================================
  // NOTAD. No se deberia cambiar este metodo.
  public String toString() {
    return "banco";
  }
}



