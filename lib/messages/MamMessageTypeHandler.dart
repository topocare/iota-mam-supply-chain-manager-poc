
import 'package:supply_chain_manager/mamHandler/MamFetchResponse.dart';
import 'package:supply_chain_manager/trytes/defines.dart';

import 'Buy.dart';
import 'IndexEntry.dart';
import 'Manufacturer.dart';
import 'messageTypes.dart';
import 'Product.dart';
import 'ProductionDetail.dart';
import 'Sell.dart';

/// Manages the messageTypeIDs identifying of [MamMessage] subtypes.
/// Serves as factory for [MamMessage] if exact type is unknown.
class MamMessageTypeHandler {
  static Map<String, Type> typeById = {
    //Manufacturer
    "99": Manufacturer,
    "9A": IndexEntry,
    //Product
    "A9": Product,
    "AA": ProductionDetail,
    "AB": Buy,
    "AC": Sell,
  };

  static Map<Type, String> idByType = Map.fromEntries(typeById.entries.map((e) => MapEntry(e.value, e.key)));

  static Type getTypeById(String messageTypeId) {
    if (typeById.containsKey(messageTypeId))
      return typeById[messageTypeId];
    return null;
  }

  static String getIdByType(Type type) {
    if (idByType.containsKey(type)) {
      return idByType[type];
    }
    return null;
  }

  static MamMessage messageFactoryByResponse(MamFetchResponse response) {
    return messageFactoryByTryte(response.payload, response.root, response.nextRoot);
  }

  static MamMessage messageFactoryByTryte(String payload, String root, String nextRoot) {
    String messageTypeId = payload.substring(0, messageTypeIdLength);
    switch (messageTypeId) {
      case "99":
        return Manufacturer.byTrytes(payload, root, nextRoot);
      case "9A":
        return IndexEntry.byTrytes(payload, root, nextRoot);
      case "A9":
        return Product.byTrytes(payload, root, nextRoot);
      case "AA":
        return ProductionDetail.byTrytes(payload, root, nextRoot);
      case "AB":
        return Buy.byTrytes(payload, root, nextRoot);
      case "AC":
        return Sell.byTrytes(payload, root, nextRoot);
      default:
        return null;
    }
  }
}