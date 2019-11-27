import 'package:supply_chain_manager/mamHandler/MamQueue.dart';
import 'package:supply_chain_manager/messages/MamMessageTypeHandler.dart';
import 'package:supply_chain_manager/messages/messageTypes.dart';
import 'package:supply_chain_manager/trytes/trytes.dart';

/// Object-Representation of a "Buy" mam-message
///
/// declares intend to buy a product.
/// It is the first message on the buyers part of the products meta-channel
/// and must be linked by a [Sell]
class Buy extends ProductUpdate{
  String rootOfProduct;
  String buyerDescription;

  static get messageTypeId => MamMessageTypeHandler.getIdByType(Buy);

  Buy(this.rootOfProduct, this.buyerDescription, String root, String nextRoot) : super(root, nextRoot);

  Buy.byTrytes(String tryteString, String root, String nextRoot) : super(root, nextRoot) {
    TryteReader tryteReader = new TryteReader(tryteString);
    this.rootOfProduct = tryteReader.root();
    this.buyerDescription = tryteReader.string();
  }

  String toTrytes(){
    return buildTryteString(rootOfProduct, buyerDescription);
  }

  factory Buy.byMamFetchResponse(MamFetchResponse response) {
    return Buy.byTrytes(response.payload, response.root, response.nextRoot);
  }

  static String buildTryteString(String rootOfProduct, String buyerDescription) {
    TryteWriter writer = TryteWriter();
    writer.messageTypeId(messageTypeId);
    writer.root(rootOfProduct);
    writer.string(buyerDescription);
    return writer.returnTrytes();
  }

  static bool compareMessageTypeId(String messageAsTrytes) {
    return messageAsTrytes.startsWith(messageTypeId);
  }
}
