import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:supply_chain_manager/appState/ScmAppState.dart';
import 'package:supply_chain_manager/appState/ScmAppStateDemoExtension.dart';
import 'package:supply_chain_manager/messages/Manufacturer.dart';
import 'package:supply_chain_manager/messages/Product.dart';

/// Controller enabling the generation of demo data for the app.
///
/// Generates random values for messages created by [ScmAppStateDemoExtension].
/// Functions are available by the [DemoDataScreen]
class DemoDataController {
  ScmAppState appState;

  DemoDataController(this.appState);

  Future<void> newManufacturer() async {
    int randomId = Random().nextInt(4294967296); //max for random
    Manufacturer index =
        await appState.demoExtension.createManufacturer("TestIndex_$randomId");
    debugPrint('newManufacturer: index.root ${index.root}');
    return null;
  }

  Future<void> newProductToLastManufacturer() async {
    if (appState.managedManufacturers.isNotEmpty) {
      Manufacturer index = appState.managedManufacturers.last;
      debugPrint('newProduct: index.root ${index.root}');
      int randomId = Random().nextInt(4294967296); //max for random
      Product product = await appState.demoExtension.createProduct(index,
          randomId, "testType_$randomId", "TestProduct_${randomId}description");
      debugPrint('newProduct: product.root ${product.root}');
    } else {
      throw "Create a manufacturer first!";
    }
  }

  Future<void> addProductionDetailsToLastProduct() async {
    if (appState.ownedProducts.isNotEmpty) {
      Product product = appState.ownedProducts.last;
      await appState.demoExtension
          .addProductionDetail(product, "2019-10-30 14:31:22", "435", "Line 4");
    } else {
      throw "Create a product first!";
    }
  }

  Future<void> makeManufacturerOfLastProductTrusted() async {
    if (appState.ownedProducts.isNotEmpty) {
      appState.addTrustedManufacturer(
          appState.ownedProducts.first.manufacturerRoot, "trusted_example");
    } else {
      throw "Have a Product first";
    }
  }

  Future<void> wipeData() {
    appState.deleteAll();
    return null;
  }
}
