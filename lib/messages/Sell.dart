import 'package:supply_chain_manager/mamHandler/MamFetchResponse.dart';
import 'package:supply_chain_manager/trytes/trytes.dart';

import 'MamMessageTypeHandler.dart';
import 'messageTypes.dart';

/// Object-Representation of a "Sell" mam-message
///
/// Gives ownership of the product it's meta-channel to the owner of the [Buy] message,
/// specified by [rootOfBuyer].
/// It is the last message of current owner's part of the meta-channel,
/// which continues at [rootOfBuyer], not [nextRoot].
class Sell extends ProductUpdate {
  String rootOfBuyer;
  String timeStamp;

  static get messageTypeId => MamMessageTypeHandler.getIdByType(Sell);

  Sell(this.rootOfBuyer, String root, String nextRoot) : super(root, nextRoot) {
    timeStamp = getTime();
  }

  factory Sell.byMamFetchResponse(MamFetchResponse response) {
    return Sell.byTrytes(response.payload, response.root, response.nextRoot);
  }

  Sell.byTrytes(String tryteString, String root, String nextRoot)
      : super(root, nextRoot) {
    TryteReader tryteReader = new TryteReader(tryteString);
    this.rootOfBuyer = tryteReader.root();
    this.timeStamp = tryteReader.string();
  }

  String toTrytes() {
    return buildTryteString(rootOfBuyer, timeStamp);
  }

  static String buildTryteString(String rootOfBuyer, String timeStamp) {
    TryteWriter writer = TryteWriter();
    writer.messageTypeId(messageTypeId);
    writer.root(rootOfBuyer);
    writer.string(timeStamp);
    return writer.returnTrytes();
  }

  static bool compareMessageTypeId(String messageAsTrytes) {
    return messageAsTrytes.startsWith(messageTypeId);
  }

  static String buildTryteStringNow(String rootOfBuyer) {
    return buildTryteString(rootOfBuyer, getTime());
  }

  static getTime() {
    DateTime dateTime = DateTime.now();
    return '${dateTime.year.toString().padLeft(4, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }
}
