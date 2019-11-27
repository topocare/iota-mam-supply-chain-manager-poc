import 'package:supply_chain_manager/mamHandler/MamFetchResponse.dart';
import 'package:supply_chain_manager/trytes/trytes.dart';

import 'ChannelOwnership.dart';
import 'MamMessageTypeHandler.dart';
import 'messageTypes.dart';
import 'ProductionDetail.dart';

/// Object-Representation of a "Product" mam-message
///
/// It is the first (defining) message of a product (meta-)channel,
/// acting as a digital twin of a real-world product.
/// Contains basic product information and links the manufacturer's root for validation.
class Product extends ChannelDefiningObject{

  static get messageTypeId => MamMessageTypeHandler.getIdByType(Product);

  String manufacturerRoot;
  int productId;
  String typeId;
  String description;

  Product(this.manufacturerRoot, this.productId, this.typeId, this.description, String root, String nextRoot, [ChannelOwnership ownership]) : super(root, nextRoot, ownership);

  Product.byTrytes(String tryteString, String root, String nextRoot, [ChannelOwnership ownership]) : super(root, nextRoot, ownership) {
    TryteReader tryteReader = new TryteReader(tryteString);
    this.productId = tryteReader.id();
    this.manufacturerRoot = tryteReader.root();
    this.typeId = tryteReader.string();
    this.description = tryteReader.string();
  }

  factory Product.byMamFetchResponse(MamFetchResponse response) {
    return Product.byTrytes(response.payload, response.root, response.nextRoot);
  }

  String toTrytes(){
    return buildTryteString(productId, manufacturerRoot, typeId, description);
  }

  static String buildTryteString(int productId, String manufacturerRoot, String typeId, String description) {
    TryteWriter writer = TryteWriter();
    writer.messageTypeId(messageTypeId);
    writer.id(productId);
    writer.root(manufacturerRoot);
    writer.string(typeId);
    writer.string(description);
    return writer.returnTrytes();
  }

  static bool compareMessageTypeId(String messageAsTrytes) {
    return messageAsTrytes.startsWith(messageTypeId);
  }

  bool operator == (dynamic other) {
    if (other is Product) {
      if (other.root == this.root) {
        return true;
      }
    }
    return false;
  }

  int get hashCode => root.hashCode;
}

