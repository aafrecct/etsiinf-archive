package aed.recursion;

import es.upm.aedlib.Pair;
import es.upm.aedlib.Position;
import es.upm.aedlib.positionlist.PositionList;
import es.upm.aedlib.positionlist.NodePositionList;


public class Crypto {
  
  private static Integer encryptChar (PositionList<Character> key, Character character,
                                      Integer result, Position<Character> keyPos) {
    if (keyPos.element().equals(character)) {    // Character is found.
      return result;
    } else if (keyPos.element().compareTo(character) < 0) {    // Character is left of target.
      keyPos = key.next(keyPos);
      return encryptChar(key, character, result + 1, keyPos);
    } else {    // Character is right of target. 
      return encryptChar(key, character, result - 1, keyPos);
    }
  }
  
  private static PositionList<Integer> encrypt (PositionList<Character> key, PositionList<Character> text, 
                                                PositionList<Integer> result, Position<Character> characterPos,
                                                int prev_num) {
    if (characterPos == null) {    // Reached end of string.
      return result;
    } else {
      // Encrypt one character.
      Integer last_num = encryptChar(key, characterPos.element(), 0, key.first());
      result.addLast(last_num - prev_num);
      // Call function with next character.
      return encrypt(key, text, result, text.next(characterPos), last_num);
    }
  }
  
  public static PositionList<Integer> encrypt (PositionList<Character> key, PositionList<Character> text) {
    PositionList<Integer> result = new NodePositionList<Integer>();
    return encrypt(key, text, result, text.first(), 0);
  }
  
  public static Character get (PositionList<Character> key, int pos, Position<Character> keyPos) {
    if (pos == 0) {
      return keyPos.element();
    } else {
      keyPos = key.next(keyPos);
      return get(key, pos - 1, keyPos);
    }
  }
  
  
  public static PositionList<Character> decrypt (PositionList<Character> key, PositionList<Integer> encodedText,
                                                 PositionList<Character> result, Position<Integer> characterPos,
                                                 int last_pos) {
    if (characterPos == null) {
      return result;
    } else {
      int pos = last_pos + characterPos.element();
      result.addLast(get(key, pos, key.first()));
      return decrypt(key, encodedText, result, encodedText.next(characterPos), pos);
    }
  }
  
  public static PositionList<Character> decrypt (PositionList<Character> key, PositionList<Integer> encodedText) {
    PositionList<Character> result = new NodePositionList<Character>();
    return decrypt(key, encodedText, result, encodedText.first(), 0);
  }

}
