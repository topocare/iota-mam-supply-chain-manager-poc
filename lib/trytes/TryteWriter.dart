import 'defines.dart' as defines;
import 'TryteConverter.dart';

/// helper for writing data to a tryte-encoded string
///
/// usage:
/// construct for each usage, call the message-specific
/// writing methods in order of the data.
/// get result with [returnTrytes]
class TryteWriter {
  String trytes = "";

  TryteWriter();

  void messageTypeId(String str) {
    addAsTrytes(str, defines.messageTypeIdLength);
  }

  void id(int intIn) {
    dynInt(intIn);
  }

  void root(String str) {
    addAsTrytes(str, defines.rootLength);
  }

  String returnTrytes() {
    return trytes;
  }

  void addAsTrytes(String str, [int length]) {
    if (length != null) {
      String strMod = str;
      if (str.length < length) {
        strMod = strMod.padRight(length, '9');
      } else if (str.length > length) {
        strMod = strMod.substring(0, length);
      }
      trytes += strMod;
    } else {
      trytes += str;
    }
  }

  void dynInt(int intIn) {
    String asTrytes = TryteConverter.intToTryte(intIn);
    trytes += _dynamicLengthDescriptor(asTrytes);
    trytes += asTrytes;
  }

  void string(String string) {
    String asTrytes = TryteConverter.stringToTryte(string);
    trytes += _dynamicLengthDescriptor(asTrytes);
    trytes += asTrytes;
  }

  //a dynamic length descriptor defining the length of the following field.
  //for length 0..13 a single trytes is used.
  //fir larger fields the first trytes contains the negativ count of following trytes, containing the length
  String _dynamicLengthDescriptor(String dynLengthPayload) {
    String result = "";
    String length = TryteConverter.intToTryte(dynLengthPayload.length);
    if (length.length > 1) {
      String nagativLengthOfLength = TryteConverter.intToTryte(-length.length);
      result += nagativLengthOfLength;
    }
    result += length;
    return result;
  }
}
