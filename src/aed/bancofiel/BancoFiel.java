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

  // ----------------------------------------------------------------------
  // Anadir metodos aqui ...
  
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
  
  private static void quickSort(IndexedList<Cuenta> list, int start, int end, Comparator<Cuenta> cmp){
    if (start < end) {
      int p = partition(list, start, end, cmp);
      quickSort(list, start, p - 1, cmp);
      quickSort(list, p + 1, end, cmp);
    }   
  }
  
  private static boolean isSorted(IndexedList<Cuenta> list, Comparator<Cuenta> cmp) {
    int i = 0;
    for ( ; i < list.size() - 1 && cmp.compare(list.get(i), list.get(i + 1)) < 0; i++) {}
      return i < list.size() - 1;
    }
  
  //Metodo que busca de manera binaria un elemento en la lista
  private static int binarySearch(IndexedList<Cuenta> list, int start, int end, String token) throws CuentaNoExisteExc {
    int med = (int) (start + (end - start) / 2);
    int comparison;
    	if(token.contains("/")) {
    		comparison = list.get(med).getId().compareTo(token);
    	} else {
    		comparison = list.get(med).getDNI().compareTo(token);
    	}
    
    if (comparison == 0) {
      return med;
    } else if(end - start < 1){
    	throw new CuentaNoExisteExc();
    } else if (comparison < 0) {
      return binarySearch(list, start, med - 1, token);
    } else {
      return binarySearch(list, med + 1, end, token);
    } 
  }
  
  private Cuenta getCuentaById(String id) throws CuentaNoExisteExc {
    return cuentas.get(binarySearch(cuentas, 0 , cuentas.size() , id));
  }
  
  @Override
  public IndexedList<Cuenta> getCuentasOrdenadas(Comparator<Cuenta> cmp) {
    if (isSorted(cuentas, cmp)) {
      return cuentas;
    } else {
      IndexedList<Cuenta> cuentas_new_sort = new ArrayIndexedList<Cuenta>((ArrayIndexedList<Cuenta>) cuentas);
      quickSort(cuentas_new_sort, 0, cuentas_new_sort.size() - 1, cmp);
      return cuentas_new_sort;
    }
    
  }

  @Override
  public String crearCuenta(String dni, int saldoIncial) {
    Cuenta nueva_cuenta = new Cuenta(dni, saldoIncial);
    int i = 0;
    for ( ; i < cuentas.size() && !(cuentas.get(i).getId().compareTo(nueva_cuenta.getId()) < 0); i++) {}
    cuentas.add(i, nueva_cuenta);
    System.out.println("Cuenta creada con el dni y saldo inicial : " + dni + " " + saldoIncial);
    for(Cuenta c : cuentas) {
    	System.out.println("id: " + c.getId());
    }
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
	  //Nuestro m�todo binary search nos busca un elemento aleatorio dentro de el "bloque" de cuentas con el mismo dni
	  int med = 0;
    try {
      med = binarySearch(cuentas, 0, cuentas.size(), dni);
    } catch (CuentaNoExisteExc e) {}
	  //Por ello hacemos una busqueda por debajo y por arriba para poder tener todas las cuentas con el mismo id
	  int i = med + 1;
	  int j = med - 1;
	  
	  while( i < cuentas.size() && cuentas.get(i).getDNI().equals(dni)) {
		  //a�ade a solucion por la parte de detras los elementos que van despues de med
		  sol.add(sol.size(), cuentas.get(i).getDNI());
		  i++;
	  }
	  while( j > 0 && cuentas.get(j).getDNI().equals(dni)) {
		  //a�ade por la perte de delante los elementos que van antes de med
		  sol.add(0, cuentas.get(j).getDNI());
		  j--;
	  }
	//Devuelve un array ordenado por id de las cuentas con el mismo dni  
    return sol;
  }

  @Override
  public int getSaldoCuentas(String dni) {
  	  IndexedList<String> list = new ArrayIndexedList<String>();
  	  if (list.size() == 0) {
  	    return 0;
  	  } else {
  	    list = getIdCuentas(dni);
  	    int primera_cuenta = 0;
  	    try {
  	      primera_cuenta = binarySearch(cuentas, 0, cuentas.size(), list.get(0));
  	    } catch (CuentaNoExisteExc e) {}
        int sum = 0;
        for(int i = primera_cuenta; i < primera_cuenta + list.size(); i++) {
          sum += cuentas.get(i).getSaldo();
        }
        return sum;
  	  }
  }

  // ----------------------------------------------------------------------
  // NOTAD. No se deberia cambiar este metodo.
  public String toString() {
    return "banco";
  }
  
}



