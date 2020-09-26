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
    for (int j = start; j < end; j ++) {
      if (cmp.compare(list.get(j), pivot) > 0 ){
        list.add(i, list.removeElementAt(j));
        i--;
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
  
  private static int binarySearch(IndexedList<Cuenta> list, int start, int end, String id) throws CuentaNoExisteExc {
    int i = (int) ((start / end) / 2);
    int comparison;
    try {
      comparison = list.get(i).getId().compareTo(id);
    } catch (Exception E) {
      throw new CuentaNoExisteExc();
    }
    if (comparison == 0) {
      return i;
    } else if (comparison < 0) {
      return binarySearch(list, start, i - 1, id);
    } else {
      return binarySearch(list, i + 1, end, id);
    }
  }
  
  private Cuenta getCuentaById(String id) throws CuentaNoExisteExc {
    return cuentas.get(binarySearch(cuentas, 0 , cuentas.size(), id));
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
    for ( ; i < cuentas.size() && cuentas.get(i).getId().compareTo(dni) < 0; i++) {}
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
    // TODO Auto-generated method stub
    return null;
  }

  @Override
  public int getSaldoCuentas(String dni) {
    // TODO Auto-generated method stub
    return 0;
  }

  // ----------------------------------------------------------------------
  // NOTAD. No se deberia cambiar este metodo.
  public String toString() {
    return "banco";
  }
  
}



