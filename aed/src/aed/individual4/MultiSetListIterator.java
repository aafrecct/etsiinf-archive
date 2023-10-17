package aed.individual4;

import java.util.Iterator;
import java.util.NoSuchElementException;

import es.upm.aedlib.Pair;
import es.upm.aedlib.Position;
import es.upm.aedlib.positionlist.PositionList;

public class MultiSetListIterator<E> implements Iterator<E> {
  PositionList<Pair<E,Integer>> list;
  
  Position<Pair<E,Integer>> cursor;
  int counter;
  Position<Pair<E,Integer>> prevCursor;
  boolean canRemove;

  public MultiSetListIterator(PositionList<Pair<E,Integer>> list) {
    this.list = list;
    this.cursor = list.first();
    this.counter = 1;
    this.canRemove = false;
  }

  public boolean hasNext() {
    return cursor != null;
  }

  public E next() {
    // Most times there will be a next.
    if (hasNext()) {
      E next = cursor.element().getLeft();
      // When next() is executed, remove() can be use again.
      canRemove |= true;
      
      if (counter < cursor.element().getRight()) {
        counter ++;
      } else {
        counter = 1;
        prevCursor = cursor;
        // Cursor is null when there are no more elements.
        try {
          cursor = list.next(cursor);
        } catch (IllegalArgumentException e) {
          cursor = null;
        }
      }
      return next;
    } else {
      throw new NoSuchElementException();
    }
  }
  
  /*
   * To make remove() more readable.
   * It removes one from the amount of elements stored in position.
   * It assumes this position exists and the amount is >1.
   */
  private void removeOneFromSet(Position<Pair<E,Integer>> position) {
    position.element().setRight(position.element().getRight() - 1);
  }
  
  public void remove() {
    if (!canRemove) {
      throw new IllegalStateException();
    } else if (counter == 1) {  
      if (prevCursor.element().getRight() <= 1) {
        list.remove(prevCursor);    // Position is removed. N. of elements is 0.
      } else {
        removeOneFromSet(prevCursor);
      }
    } else {
      removeOneFromSet(cursor);
      counter --;
    }
    canRemove = false;
  }
}
