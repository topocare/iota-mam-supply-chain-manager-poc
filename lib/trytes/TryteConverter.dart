import "dart:math";

import "defines.dart";

/// helper class for tryte en-/decoding
///
/// int <-> tryte
/// String <-> tryte
class TryteConverter {

  static String stringToTryte(String str) {
    String erg = "";
    for (int i = 0; i < str.length; i++) {
      int asciiValue = str.codeUnitAt(i);
      String upperChar = tryteAlphabet[asciiValue ~/ 27];
      String lowerChar = tryteAlphabet[asciiValue % 27];

      erg += lowerChar + upperChar;
    }
    return erg;
  }

  static String tryteToString(String trytes) {
    String result = "";
    for (int i = 0; i < trytes.length / 2; i++) {
      int charCode = (
          27 * tryteAlphabet.indexOf(trytes[2 * i + 1]) +
              tryteAlphabet.indexOf(trytes[2 * i]));
      //stop if field is only filled up with 99 = null
      if (charCode == 0)
        break;
      result += String.fromCharCode(charCode);
    }
    return result;
  }

  static int tryteToInt(String trytes) {
    int result = 0;
    for (int trytePosition = 0; trytePosition < trytes.length; trytePosition++) {
      result += pow(27, trytePosition) * (tryteAlphabetByValue.indexOf(trytes[trytePosition])-tryteAlphabetByValueOffset);
    }
    return result;
  }

  static String intToTryte(int intIn) {
    List<int> stepResults = List<int>();
    List<int> stepOverlows = List<int>();
    int residuum = intIn;

    int requiredTrytes=1;
    int intAbs = intIn.abs();

    //find number of nessessery steps
    while(true) {
      if (pow(27,requiredTrytes) >= intAbs) {
        break;
      }
      requiredTrytes++;
    }

    //calculate each single step
    for (int i = requiredTrytes-1; i >= 0; i--) {
      int powI = pow(27,i);
      int stepResult = 0;
      int overflow = 0;
      if (residuum >= powI){
        stepResult = residuum ~/ powI;
      }
      if (residuum <= -powI) {
        stepResult = residuum ~/ powI;
      }
      residuum -= (stepResult*powI);
      if (stepResult > 13) {
        stepResult-=27;
        overflow=1;
      }
      if (stepResult < -13) {
        stepResult+=27;
        overflow=-1;
      }
      stepResults.add(stepResult);
      stepOverlows.add(overflow);
    }

    //apply overflows
    //  add overflows to the relevant values
    for (int i = 0; i< stepResults.length-1; i++) {
      stepResults[i] += stepOverlows[i+1];
    }
    if (stepOverlows[0] != 0) {
      stepResults.insert(0, stepOverlows[0]);
    }
    //  replace -14 and 14 by equivalent values
    for (int i = stepResults.length-1; i>=0 ; i--) {
      if (stepResults[i] == -14) {
        stepResults[i] = 13;
        if (i - 1 < 0)
          stepResults.insert(0, -1);
        else
          stepResults[i - 1] -= 1;
      }
      if (stepResults[i] == 14) {
        stepResults[i] = -13;
        if (i - 1 < 0)
          stepResults.insert(0, 1);
        else
          stepResults[i - 1] += 1;
      }
    }
    //as list<values> to trytes
    String result = "";
    for (int i = stepResults.length-1; i>=0 ; i--) {
      result += tryteAlphabetByValue[stepResults[i]+13];
    }
    return result;
  }
}