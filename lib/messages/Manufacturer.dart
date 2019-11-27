import 'package:supply_chain_manager/mamHandler/MamFetchResponse.dart';
import 'package:supply_chain_manager/trytes/trytes.dart';

import 'ChannelOwnership.dart';
import 'MamMessageTypeHandler.dart';
import 'messageTypes.dart';

/// Object-Representation of a "Manufacturer" mam-message
///
/// It is the first (defining) message of a manufacturer channel,
/// it's root is used to identify the real-world manufacturer on the channel.
class Manufacturer extends ChannelDefiningObject {

  static get messageTypeId => MamMessageTypeHandler.getIdByType(Manufacturer);

  String description;

  Manufacturer(this.description, String root, String nextRoot, [ChannelOwnership ownership]) : super(root, nextRoot, ownership);

  Manufacturer.byTrytes(String tryteString, String root, String nextRoot, [ChannelOwnership ownership]) : super(root, nextRoot, ownership) {
    TryteReader tryteReader = new TryteReader(tryteString);
    this.description = tryteReader.string();
  }

  factory Manufacturer.byMamFetchResponse(MamFetchResponse response) {
    return Manufacturer.byTrytes(response.payload, response.root, response.nextRoot);
  }

  String toTrytes(){
    return buildTryteString(description);
  }

  static String buildTryteString(description) {
    TryteWriter writer = TryteWriter();
    writer.messageTypeId(messageTypeId);
    writer.string(description);
    return writer.returnTrytes();
  }

  static bool compareMessageTypeId(String messageAsTrytes) {
    return messageAsTrytes.startsWith(messageTypeId);
  }

  bool operator == (dynamic other) {
    if (other is Manufacturer) {
      if (other.root == this.root) {
        return true;
      }
    }
    return false;
  }

  int get hashCode => root.hashCode;
}