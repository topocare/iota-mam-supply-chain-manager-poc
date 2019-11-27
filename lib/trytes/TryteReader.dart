import 'defines.dart' as defines;
import 'TryteConverter.dart';

/// helper for reading tryte-encoded data from a tryte-string
///
/// usage:
/// construct with the tryte-string, then call the message-specific
/// reading methods in order of the contained data
class TryteReader {
  String trytes;
  int _counter = defines.messageTypeIdLength;

  TryteReader(this.trytes);

  String messageTypeId() {
    return trytes.substring(0, defines.messageTypeIdLength);
  }

  int id() {
    return dynInt();
  }

  String root() {
    return asTrytes(defines.rootLength);
  }

  String asTrytes(int length) {
    String result = trytes.substring(_counter, _counter + length);
    _counter += length;
    return result;
  }

  int _dynamicLength() {
    int result = TryteConverter.tryteToInt(asTrytes(1));
    if (result < 0) {
      result = TryteConverter.tryteToInt(asTrytes(-result));
    }
    return result;
  }

  int dynInt() {
    int length = _dynamicLength();
    return TryteConverter.tryteToInt(asTrytes(length));
  }

  String string() {
    int length = _dynamicLength();
    return TryteConverter.tryteToString(asTrytes(length));
  }
}
