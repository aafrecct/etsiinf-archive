package aed.cache;

import es.upm.aedlib.Entry;
import es.upm.aedlib.Position;
import es.upm.aedlib.map.*;
import es.upm.aedlib.positionlist.*;


public class Cache<Key,Value> {
  

  // Tamano de la cache
  private int maxCacheSize;

  // NO MODIFICA ESTOS ATTRIBUTOS, NI CAMBIA SUS NOMBRES: mainMemory, cacheContents, keyListLRU

  // Para acceder a la memoria M
  private Storage<Key,Value> mainMemory;
  // Un 'map' que asocia una clave con un ``CacheCell''
  private Map<Key,CacheCell<Key,Value>> cacheContents;
  // Una PositionList que guarda las claves en orden de
  // uso -- la clave mas recientemente usado sera el keyListLRU.first()
  private PositionList<Key> keyListLRU;
 

  // Constructor de la cache. Especifica el tamano maximo 
  // y la memoria que se va a utilizar
  public Cache(int maxCacheSize, Storage<Key,Value> mainMemory) {
    this.maxCacheSize = maxCacheSize;

    // NO CAMBIA
    this.mainMemory = mainMemory;
    this.cacheContents = new HashTableMap<Key,CacheCell<Key,Value>>();
    this.keyListLRU = new NodePositionList<Key>();
  }

  /*
   * Sets a given key as the most used,
   * removing it from the previous position.
   * Returns the first position of the LRU list.
   */
  private Position<Key> setMostRU(Key key) {
    keyListLRU.addFirst(key);
    return keyListLRU.first();
  }
  
  /*
   * Sets a given key as the most used,
   * removing it from the previous position.
   * Returns the first position of the LRU list.
   */
  private Position<Key> setMostRU(Key key, CacheCell<Key,Value> cell) {
    keyListLRU.addFirst(key);
    try {
      keyListLRU.remove(cell.getPos());
    } catch (Exception E) {
      // Key is likely not on list.
    }
    cell.setPos(keyListLRU.first());
    return keyListLRU.first();
  }
  
  /*
   * Unloads the least used key from cacheContents and
   * removes the position from the LRU list.
   * If the unloaded key is marked 'dirty', it rewrites it to mainMemory.
   */
  private void unload() {
    Position<Key> leastUsed = keyListLRU.last();
    CacheCell<Key, Value> leastUsedKey = cacheContents.get(leastUsed.element());
    if (leastUsedKey.getDirty()) {
      mainMemory.write(leastUsed.element(), leastUsedKey.getValue());
    }
    cacheContents.remove(leastUsed.element());
    keyListLRU.remove(leastUsed);
  }
  
  /*
   * Loads the key from mainMemory into cacheContents,
   * if cache is full, it unloads least used element.
   */
  private boolean load(Key key) {
    Value value = mainMemory.read(key);
    if (value != null) {
      if (cacheContents.size() >= maxCacheSize) {
        unload();
      }
      cacheContents.put(key, new CacheCell<Key,Value>(value, false, setMostRU(key)));
    }
    return value != null;
  }
  
  
  // Devuelve el valor que corresponde a una clave "Key"
  public Value get(Key key) {
    Value value = null;
    if (!cacheContents.containsKey(key)) {
      load(key);
    } else {
      setMostRU(key, cacheContents.get(key));
    }
    value =  cacheContents.containsKey(key) ? cacheContents.get(key).getValue() : null;
    return value;
  }

  
  // Establece un valor nuevo para la clave en la memoria cache
  public void put(Key key, Value value) {
    if (!cacheContents.containsKey(key)){
      if (!load(key)) {
        if (cacheContents.size() >= maxCacheSize) {
          unload();
        }
        cacheContents.put(key, new CacheCell<Key,Value>(value, true, setMostRU(key)));
      }
    }
    CacheCell<Key,Value> cell = cacheContents.get(key);
    cell.setDirty(true);
    cell.setValue(value);
    setMostRU(key, cell);
  }


  // NO CAMBIA  
  public String toString() {
    return "cache";
  }
}


