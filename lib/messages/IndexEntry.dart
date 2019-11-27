import 'package:supply_chain_manager/mamHandler/MamFetchResponse.dart';
import 'package:supply_chain_manager/trytes/trytes.dart';

import 'MamMessageTypeHandler.dart';
import 'messageTypes.dart';
import 'Product.dart';

/// Object-Representation of a "IndexEntry" mam-message
/// is part of a manufacturer channel and declares that
/// the linked product(-message) was published by the manufacturer.
class IndexEntry extends MamMessage{

  static get messageTypeId => MamMessageTypeHandler.getIdByType(IndexEntry);

  int linkedId;
  String linkedRoot;

  IndexEntry(String root, String nextRoot, this.linkedId, this.linkedRoot) : super(root, nextRoot);

  IndexEntry.byTrytes(String tryteString, String root, String nextRoot) : super(root, nextRoot) {
    TryteReader tryteReader = new TryteReader(tryteString);
    this.linkedRoot = tryteReader.root();
    this.linkedId = tryteReader.id();
  }

  factory IndexEntry.byMamFetchResponse(MamFetchResponse response) {
    return IndexEntry.byTrytes(response.payload, response.root, response.nextRoot);
  }

  String toTrytes(){
    return buildTryteString(linkedId, linkedRoot);
  }

  static String buildTryteString(int linkedId, String linkedRoot) {
    TryteWriter writer = TryteWriter();
    writer.messageTypeId(messageTypeId);
    writer.root(linkedRoot);
    writer.id(linkedId);
    return writer.returnTrytes();
  }

  static bool compareMessageTypeId(String messageAsTrytes) {
    return messageAsTrytes.startsWith(messageTypeId);
  }

  bool isLinking (Product product) {
    return (linkedId == product.productId && linkedRoot == product.root);
  }
}