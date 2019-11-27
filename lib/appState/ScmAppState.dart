import 'package:flutter/foundation.dart';
import 'package:supply_chain_manager/mamHandler/MamQueue.dart';

import 'package:supply_chain_manager/appState/DatabaseAdapter.dart';
import 'package:supply_chain_manager/appState/ProductChannelLoader.dart';
import 'package:supply_chain_manager/appState/ScmAppStateDemoExtension.dart';
import 'package:supply_chain_manager/controllers/DemoDataController.dart';
import 'package:supply_chain_manager/mamHandler/MamBuffer.dart';
import 'package:supply_chain_manager/messages/ChannelOwnership.dart';
import 'package:supply_chain_manager/messages/Product.dart';
import 'package:supply_chain_manager/messages/Manufacturer.dart';
import 'package:supply_chain_manager/messages/messageTypes.dart';

/// The 'global state' of the app, containing all the data.
/// Encapsulates:
///   access to MAM
///   DatabaseAdapter
/// Directly handles:
///   lists of owned objects
///    -owned Products
///    -managed Manufacturer-IDs
///    -trusted Manufacturers
/// Acts as factory for ProductChannelLoader-Instances
/// Also makes the ScmAppStateDemoExtension available
class ScmAppState extends ChangeNotifier {
  MamQueue mamQueue = MamQueue();
  MamBuffer mamBuffer;
  DemoDataController demoDataController;
  ScmAppStateDemoExtension demoExtension;
  DatabaseAdapter databaseAdapter = DatabaseAdapter();

  List<Product> ownedProducts = List<Product>();
  List<Manufacturer> managedManufacturers = List<Manufacturer>();

  void notifyListenersCallbackTarget() {
    notifyListeners();
  }

  //Data of ProductChannelLoader factory
  Map<Product, ProductChannelLoader> _productChannelLoaders =
      Map<Product, ProductChannelLoader>();

  // part of the ProductChannelLoader factory,
  // gets the ProductChannelLoader for a specific Product
  ProductChannelLoader getProductChannelLoader(Product product) {
    if (!_productChannelLoaders.containsKey(product)) {
      _productChannelLoaders[product] = ProductChannelLoader(
          mamBuffer, product, notifyListenersCallbackTarget);
    }
    return _productChannelLoaders[product];
  }

  // Part of the ProductChannelLoader factory,
  // gets the ProductChannelLoader for a product specified by its root.
  // Is a Future, since it's possible that the product message needs to be fetched first.
  Future<ProductChannelLoader> getProductChannelLoaderByRoot(
      String root) async {
    ProductChannelLoader foundLoader;

    //if loader already exists
    _productChannelLoaders
        .forEach((Product product, ProductChannelLoader loader) {
      if (product.root == root) {
        foundLoader = loader;
      }
    });
    if (foundLoader != null) {
      return foundLoader;
    }

    //if new loader is needed
    foundLoader = await ProductChannelLoader.futureFactoryByRoot(
        root, mamBuffer, notifyListenersCallbackTarget);
    _productChannelLoaders[foundLoader.product] = foundLoader;
    return foundLoader;
  }

  //Init of the ScmAppState, async as it needs to wait for the database
  Future<void> init() async {
    await databaseAdapter.init();
    await loadListFromDatabase();
    mamBuffer = MamBuffer(mamQueue);

    demoDataController = DemoDataController(this);
    demoExtension = ScmAppStateDemoExtension(this);

    return null;
  }

  // Used to load persistent data after reboot.
  // Fills the following Lists/Map from the Database:
  // [ownedProducts]
  // [managedManufacturers]
  // [trustedManufacturers]
  Future<void> loadListFromDatabase() async {
    List<Map<String, dynamic>> entries =
        await databaseAdapter.ownedChannelsAsList();
    entries.forEach((Map<String, dynamic> entry) {
      String data = entry['data'];
      if (data.startsWith(Product.messageTypeId)) {
        Product product = Product.byTrytes(
            data,
            entry['firstRoot'],
            entry['nextRoot'],
            ChannelOwnership(
                entry['seed'], entry['mamStartIndex'], entry['id']));

        if (!ownedProducts.contains(product)) {
          ownedProducts.add(product);
        }
      }
      if (data.startsWith(Manufacturer.messageTypeId)) {
        Manufacturer manufacturer = Manufacturer.byTrytes(
            data,
            entry['firstRoot'],
            entry['nextRoot'],
            ChannelOwnership(
                entry['seed'], entry['mamStartIndex'], entry['id']));

        if (!managedManufacturers.contains(manufacturer)) {
          managedManufacturers.add(manufacturer);
        }
      }
    });

    List<Map<String, dynamic>> entries2 =
        await databaseAdapter.trustedManufacturersAsList();
    entries2.forEach((Map<String, dynamic> entry) {
      trustedManufacturers[entry['firstRoot']] = entry["description"];
    });
    return null;
  }

  // listFunctions
  Future<void> _addToList<t>(t listEntry, List<t> list) async {
    list.add(listEntry);
    notifyListenersCallbackTarget();
    return null;
  }

  Future<void> _removeFromList<t>(t listEntry, List<t> list) async {
    if (list.contains(listEntry)) {
      list.remove(listEntry);
    }
    notifyListenersCallbackTarget();
    return null;
  }

  //ownedProducts
  // adds owned product to ownedProducts and database
  Future<void> addOwnedProduct(
      Product product, ChannelOwnership ownership) async {
    if (ownedProducts.contains(product)) {
      return null;
    }
    ownership.databaseId = await databaseAdapter.addOwnedChannel(
        product.root,
        product.nextRoot,
        ownership.seed,
        ownership.mamStartIndex,
        product.toTrytes());
    return _addToList(product, this.ownedProducts);
  }

  // removes owned product from ownedProducts and database
  Future<void> deleteOwnedProduct(Product product) async {
    if (!ownedProducts.contains(product)) {
      return null;
    }
    await databaseAdapter.deleteOwnedChannel(product.ownership.databaseId);
    await _removeFromList(product, this.ownedProducts);
    return null;
  }

  bool isOwnedProduct(String root) {
    bool found = false;
    ownedProducts.forEach((Product ownedProduct) {
      if (ownedProduct.root == root) {
        found = true;
      }
    });
    return found;
  }

  Product getOwnedProductByRoot(String root) {
    Product product;
    ownedProducts.forEach((Product ownedProduct) {
      if (ownedProduct.root == root) {
        product = ownedProduct;
      }
    });
    return product;
  }

  //managedManufacturers
  // adds manufacturer to managedManufacturers and database
  Future<void> addOwnedManufacturer(
      Manufacturer manufacturer, ChannelOwnership ownership) async {
    if (managedManufacturers.contains(manufacturer)) {
      return null;
    }
    ownership.databaseId = await databaseAdapter.addOwnedChannel(
        manufacturer.root,
        manufacturer.nextRoot,
        ownership.seed,
        ownership.mamStartIndex,
        manufacturer.toTrytes());
    return _addToList(manufacturer, managedManufacturers);
  }

  // deletes manufacturer from managedManufacturers and database
  Future<void> deleteOwnedManufacturer(Manufacturer manufacturer) {
    if (!managedManufacturers.contains(manufacturer)) {
      return null;
    }
    return _removeFromList(manufacturer, managedManufacturers);
  }

  //trustedManufacturers
  Map<String, String> trustedManufacturers = Map<String, String>();

  // adds manufacturer-root and description to [trustedManufacturers] and database
  Future<void> addTrustedManufacturer(String root, String description) {
    if (!trustedManufacturers.containsKey(root)) {
      return null;
    }
    databaseAdapter.addTrustedManufacturer(root, description);
    trustedManufacturers[root] = description;
    notifyListeners();
    return null;
  }

  // removes manufacturer-root and description from [trustedManufacturers] and database
  Future<void> deleteTrustedManufacturer(root) {
    if (!trustedManufacturers.containsKey(root)) {
      return null;
    }
    databaseAdapter.deleteTrustedManufacturer(root);
    trustedManufacturers.remove(root);
    notifyListeners();
    return null;
  }

  bool isTrustedManufacturer(root) {
    return trustedManufacturers.containsKey(root);
  }

  //general data management
  Future<void> deleteAll() async {
    await databaseAdapter.deleteAll();
    ownedProducts.clear();
    managedManufacturers.clear();
    trustedManufacturers.clear();
    notifyListeners();
  }

  // Sending MAM messages by specific [ChannelOwnership],
  // automatically handling metadata.

  // [updateDatabase] needs to be false for ownerships not yet part of the database
  // (like a buy-message before the product is owned)
  Future<MamSendResponse> sendMessageByChannelOwnership(
      ChannelOwnership ownership, String payload,
      [bool updateDatabase = true]) async {
    MamSendResponse mamSendResponse = await mamQueue.sendMessage(
        ownership.seed, ownership.mamStartIndex, payload);
    ownership.mamStartIndex++;
    if (updateDatabase) {
      await databaseAdapter.updateOwnedChannel(
          ownership.databaseId, ownership.mamStartIndex);
    }
    return mamSendResponse;
  }

  //Sending MAM messages using the [ChannelOwnership] of a [ChannelDefiningObject]
  Future<MamSendResponse> sendMessageByChannelDefiningObject(
      ChannelDefiningObject channelDefiningObject, String payload) async {
    MamSendResponse mamSendResponse = await sendMessageByChannelOwnership(
        channelDefiningObject.ownership, payload);
    //channelDefiningObject.nextRoot = mamSendResponse.nextRoot;
    return mamSendResponse;
  }
}
