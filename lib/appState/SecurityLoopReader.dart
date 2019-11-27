import 'package:supply_chain_manager/messages/Manufacturer.dart';
import 'package:supply_chain_manager/messages/IndexEntry.dart';
import 'package:supply_chain_manager/messages/Product.dart';

import '../mamHandler/MamBuffer.dart';


/// Implements the security-loop
/// to confirm if a product is included in its manufacturer's channel
class SecurityLoopReader {
  MamBuffer mamBuffer;


  SecurityLoopReader(this.mamBuffer);


  // as confirmProductManufacturer, but by product-root
  Future<ConfirmationResponse> confirmProductManufacturerByRoot(String productRoot) async {
    Product product = await mamBuffer.getTypedMessage<Product>(productRoot);
    if (product != null) {
      return confirmProductManufacturer(product);
    } else {
      return ConfirmationResponse(
          false, null, "provided root does not lead to a Product-Message,");
    }
  }


  // checks if root and id of product are linked by manufacturer's channel,
  // expects that the message itself was already read from the root
  Future<ConfirmationResponse> confirmProductManufacturer(Product product,
      [reloadAndConfirmProduct = false]) async {
    //product -> firstIndex -> first

    Manufacturer manufacturer = await mamBuffer.getTypedMessage<Manufacturer>(product.manufacturerRoot);
    if (manufacturer == null)
      return ConfirmationResponse(
          false, null, "product.manufacturerRoot is not a manufacturer-definition");

    String manufacturerDescription = manufacturer.description;

    String root = manufacturer.nextRoot;
    while (true) {
      //runs until channel ended or confirmation is clear
      IndexEntry indexEntry = await mamBuffer.getTypedMessage<IndexEntry>(root);

      if (indexEntry == null) {
        return ConfirmationResponse(
            false, manufacturerDescription, "Index channel ended without confirming the product.");
      }

      if (indexEntry.isLinking(product)) {
        return ConfirmationResponse(true, manufacturerDescription);
      }

      root = indexEntry.nextRoot;
    }
  }
}

/// Response of SecurityLoopReader
class ConfirmationResponse {
  final bool confirmed;
  final String failMessage;
  final String manufacturerDescription;

  ConfirmationResponse(this.confirmed, this.manufacturerDescription, [this.failMessage]);
}
