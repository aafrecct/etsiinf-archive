package aed.recursion;

import es.upm.aedlib.Pair;
import es.upm.aedlib.Position;
import es.upm.aedlib.positionlist.PositionList;
import es.upm.aedlib.positionlist.NodePositionList;


public class Crypto {
  
  private static Integer encryptChar (PositionList<Character> key, Character character,
                                      Integer result, Position<Character> keyPos) {
    if (keyPos.element().equals(character)) {
      return result;
    } else if (keyPos.element().compareTo(character) < 0) {
      keyPos = key.next(keyPos);
      return encryptChar(key, character, result + 1, keyPos);
    } else {
      
      return encryptChar(key, character, result - 1, keyPos);
    }
  }
  
  private static PositionList<Integer> encrypt (PositionList<Character> key, PositionList<Character> text, 
                                                PositionList<Integer> result, Position<Character> keyPos, 
                                                Position<Character> characterPos, Position<Integer> resultPos) {
    if (characterPos == null) {
      return result;
    } else {    
      result.set(resultPos, encryptChar(key, characterPos.element(), 0, keyPos));
      return encrypt(key, text, result, keyPos, text.next(characterPos), result.next(resultPos));
    }
  }
  
  public static PositionList<Integer> encrypt (PositionList<Character> key, PositionList<Character> text) {
    PositionList<Integer> result = new NodePositionList<Integer>();
    return encrypt(key, text, result, key.first(), text.first(), result.first());
  }
  
  public static PositionList<Character> decrypt (PositionList<Character> key, PositionList<Integer> encodedText,
                                                 PositionList<Character> result, Position<Character> keyPos) {
    return null;
  }
  
  public static PositionList<Character> decrypt (PositionList<Character> key, PositionList<Integer> encodedText) {
    return null;
  }

}
