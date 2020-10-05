package aed.multisets;

import es.upm.aedlib.Pair;
import es.upm.aedlib.Position;
import es.upm.aedlib.positionlist.PositionList;
import es.upm.aedlib.positionlist.NodePositionList;


/**
 * An implementation of a multiset using a positionlist.
 */
public class MultiSetList<Element> implements MultiSet<Element> {

    /**
     * Datastructure for storing the multiset.
     */
    private PositionList<Pair<Element,Integer>> elements;

    private int size;


    /**
     * Constructs an empty multiset.
     */
    public MultiSetList() {
      this.elements = new NodePositionList<Pair<Element,Integer>>();
    }
    
    /**
     * Constructor that creates a MuliSetList copying the one passed
     * @param ms the list to copy
     */
    public MultiSetList(MultiSetList<Element> ms) {
      this.elements = new NodePositionList<Pair<Element,Integer>>();
      for (Pair<Element,Integer> e : ms.elements) {
        this.elements.addLast(new Pair<Element,Integer>(e));
      }
    }
    
    /**
     * Meethod that compares two elements
     * @param elem1
     * @param elem2
     * @return true if are equals
     */
    private boolean equals(Element elem1, Element elem2) {
      if (elem1 == null) {
        return elem2 == null;
      } else {
        return elem1.equals(elem2);
      }
    }
    
    /**
     * Method that returns the objet Position given an element
     * @param elem the element element
     * @return the position object
     */
    private Position<Pair<Element, Integer>> getPosition(Element elem){
      if (this.elements.size() == 0) {
        // If the size of the list is 0, return a null object.
        return null;
      } else {
        Position<Pair<Element,Integer>> pos = this.elements.first();
        boolean found = false;
        while (!found && pos != this.elements.last()) {
          if (equals(pos.element().getLeft(), elem)) {
            found = true;
          } else {
            pos = this.elements.next(pos);
          }
        }
        return equals(pos.element().getLeft(), elem) ? pos : null;
      }
    }
    
    @Override
    public void add(Element elem, int n) {
      Position<Pair<Element, Integer>> pos = getPosition(elem);
      if (n > 0) {
        if (pos != null) {
          pos.element().setRight(pos.element().getRight() + n);
        } else {
          this.elements.addLast(new Pair<Element, Integer>(elem, n));
        }
        size += n;
      } else if (n == 0) {
        // Do nothing.
      } else {
        throw new IllegalArgumentException("El numero de elementos especificado esta fuera del rango de valores esperados.");
      }
    }


    @Override
    public void remove(Element elem, int n) {
      Position<Pair<Element, Integer>> pos = getPosition(elem);
      if (n == 0) {
        //Do nothing.
      } else if (pos == null || n < 0 || n > pos.element().getRight()) {
        throw new IllegalArgumentException("El numero de elementos especificado esta fuera del rango de valores esperados.");
      } else {
        pos.element().setRight(pos.element().getRight() - n);
        if (pos.element().getRight() == 0) {
          elements.remove(pos);
        }
        size -= n;
      }
    }


    @Override
    public int count(Element elem) {
      Position<Pair<Element, Integer>> pos = getPosition(elem);
      return pos == null ? 0 : pos.element().getRight();
    }


    @Override
    public int size() {
      return size;
    }


    @Override
    public boolean isEmpty() {
      return size == 0;
    }


    @Override
    public PositionList<Element> allElements() {
      PositionList<Element> list = new NodePositionList<Element>();
      for (Pair<Element,Integer> e : elements) {
        for (int i = 0; i < e.getRight(); i++) {
          list.addLast(e.getLeft());
        }
      }
      return list;
    }


    @Override
    public MultiSet<Element> intersection(MultiSet<Element> s) {
      MultiSet<Element> intsect = new MultiSetList<Element>();
      for (Pair<Element,Integer> e : elements) {
        //Checks if e is in s 
    	if (s.count(e.getLeft()) > 0){
          int n_elem = Math.min(e.getRight(), s.count(e.getLeft()));
          intsect.add(e.getLeft(), n_elem);
        }
      }
      return intsect;
    }


    @Override
    public MultiSet<Element> sum(MultiSet<Element> s) {
      MultiSet<Element> sum = new MultiSetList<Element>((MultiSetList<Element>) s);
      for (Pair<Element,Integer> e : elements) {
        sum.add(e.getLeft(), e.getRight());
      }
      return sum;
    }


    @Override
    public MultiSet<Element> minus(MultiSet<Element> s) {
      MultiSet<Element> sub = new MultiSetList<Element>(this);
      MultiSet<Element> intsect = intersection(s);
      for (Element e : intsect.allElements()) {
        sub.remove(e, 1);
      }
      return sub;
    }
}
