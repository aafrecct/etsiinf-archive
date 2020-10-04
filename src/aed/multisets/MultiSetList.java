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


    @Override
    public void add(Element elem, int n) {
      // TODO Auto-generated method stub
      
    }


    @Override
    public void remove(Element elem, int n) {
      // TODO Auto-generated method stub
      
    }


    @Override
    public int count(Element elem) {
      // TODO Auto-generated method stub
      return 0;
    }


    @Override
    public int size() {
      // TODO Auto-generated method stub
      return 0;
    }


    @Override
    public boolean isEmpty() {
      // TODO Auto-generated method stub
      return false;
    }


    @Override
    public PositionList<Element> allElements() {
      // TODO Auto-generated method stub
      return null;
    }


    @Override
    public MultiSet<Element> intersection(MultiSet<Element> s) {
      // TODO Auto-generated method stub
      return null;
    }


    @Override
    public MultiSet<Element> sum(MultiSet<Element> s) {
      // TODO Auto-generated method stub
      return null;
    }


    @Override
    public MultiSet<Element> minus(MultiSet<Element> s) {
      // TODO Auto-generated method stub
      return null;
    }
}
