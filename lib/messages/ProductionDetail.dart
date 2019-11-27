import 'package:supply_chain_manager/mamHandler/MamFetchResponse.dart';
import 'package:supply_chain_manager/trytes/trytes.dart';

import 'MamMessageTypeHandler.dart';
import 'messageTypes.dart';

/// Object-Representation of a "ProductionDetail" mam-message
///
/// adds additional exemplary information to the product.
class ProductionDetail extends ProductUpdate{

  static get messageTypeId => MamMessageTypeHandler.getIdByType(ProductionDetail);

  String timeStamp;
  String batchNumber;
  String productionLine;

  ProductionDetail(String root, String nextRoot, this.timeStamp, this.batchNumber, this.productionLine) : super(root, nextRoot);

  ProductionDetail.byTrytes(String tryteString, String root, String nextRoot) : super(root, nextRoot){
    TryteReader tryteReader = new TryteReader(tryteString);
    this.timeStamp = tryteReader.string();
    this.batchNumber = tryteReader.string();
    this.productionLine = tryteReader.string();
  }

  factory ProductionDetail.byMamFetchResponse(MamFetchResponse response) {
    return ProductionDetail.byTrytes(response.payload, response.root, response.nextRoot);
  }

  String toTrytes(){
    return buildTryteString(timeStamp, batchNumber, productionLine);
  }

  static String buildTryteString(String timeStamp, String batchNumber, String productionLine) {
    TryteWriter writer = TryteWriter();
    writer.messageTypeId(messageTypeId);
    writer.string(timeStamp);
    writer.string(batchNumber);
    writer.string(productionLine);
    return writer.returnTrytes();
  }

  static bool compareMessageTypeId(String messageAsTrytes) {
    return messageAsTrytes.startsWith(messageTypeId);
  }
}