import 'package:supply_chain_manager/appState/ScmAppState.dart';
import 'package:supply_chain_manager/mamHandler/MamQueue.dart';
import 'package:supply_chain_manager/messages/ChannelOwnership.dart';
import 'package:supply_chain_manager/messages/IndexEntry.dart';
import 'package:supply_chain_manager/messages/Manufacturer.dart';
import 'package:supply_chain_manager/messages/Product.dart';
import 'package:supply_chain_manager/messages/ProductionDetail.dart';

/// An extension to ScmAppState, providing additional functionality
///
/// Allows creation of Manufacturers / products including the Index-Structure
class ScmAppStateDemoExtension {
  final ScmAppState appState;

  ScmAppStateDemoExtension(this.appState);

  //extended functionality for Demo-Data creation
  Future<Manufacturer> createManufacturer(String description) async {
    String payload = Manufacturer.buildTryteString(description);
    ChannelOwnership ownership = ChannelOwnership.generate();
    MamSendResponse mamSendResponse =
        await appState.sendMessageByChannelOwnership(ownership, payload, false);
    Manufacturer manufacturer = Manufacturer(
        description, mamSendResponse.root, mamSendResponse.nextRoot, ownership);
    appState.addOwnedManufacturer(manufacturer, manufacturer.ownership);
    return manufacturer;
  }

  Future<void> _addProductToManufacturer(
      Manufacturer manufacturer, int linkedId, String linkedRoot) async {
    //create payload
    String payload = IndexEntry.buildTryteString(linkedId, linkedRoot);

    //send message
    MamSendResponse mamSendResponse = await appState
        .sendMessageByChannelDefiningObject(manufacturer, payload);

    return IndexEntry(
        mamSendResponse.root, mamSendResponse.nextRoot, linkedId, linkedRoot);
  }

  Future<Product> createProduct(Manufacturer manufacturer, int productId,
      String typeId, String description,
      [String seed]) async {
    String productPayload = Product.buildTryteString(
        productId, manufacturer.root, typeId, description);

    ChannelOwnership ownership;
    //create data for new channel
    if (seed == null) {
      ownership = ChannelOwnership.generate();
    } else {
      ownership = ChannelOwnership(seed);
    }

    MamSendResponse productSendResponse = await appState
        .sendMessageByChannelOwnership(ownership, productPayload, false);

    //create Index entry
    await _addProductToManufacturer(
        manufacturer, productId, productSendResponse.root);

    Product product = Product(manufacturer.root, productId, typeId, description,
        productSendResponse.root, productSendResponse.nextRoot, ownership);

    await appState.addOwnedProduct(product, product.ownership);
    return product;
  }

  Future<ProductionDetail> addProductionDetail(Product product,
      String timeStamp, String batchNumber, String productionLine) async {
    String payload = ProductionDetail.buildTryteString(
        timeStamp, batchNumber, productionLine);

    MamSendResponse mamSendResponse =
        await appState.sendMessageByChannelDefiningObject(product, payload);

    return ProductionDetail(timeStamp, batchNumber, productionLine,
        mamSendResponse.root, mamSendResponse.nextRoot);
  }
}
