import 'package:flutter/cupertino.dart';

import 'package:supply_chain_manager/mamHandler/MamBuffer.dart';
import 'package:supply_chain_manager/appState/SecurityLoopReader.dart';
import 'package:supply_chain_manager/messages/Product.dart';
import 'package:supply_chain_manager/messages/Sell.dart';
import 'package:supply_chain_manager/messages/messageTypes.dart';

/// Reader for Product-(meta)Channels
/// - validates if Product is Part of the Manufacturer Index
/// - loads all messages of the (meta)Channel
class ProductChannelLoader {
  Product product;
  VoidCallback _callback;
  String _nextRoot;
  bool stopReadingSignal = false;
  bool _isLoadingNow = false;
  MamBuffer mamBuffer;

  Future<String> manufacturerDescription;
  Future<bool> manufacturerConfirmed;

  Future<ConfirmationResponse> _manufacturerDetails;

  /// loads [manufacturerDescription] and [manufacturerConfirmed]
  /// loads [_manufacturerDetails] first, then uses the result to offer the individual values
  void getManufacturerDetails() async{
    if (_manufacturerDetails == null) {
      _manufacturerDetails = _getManufacturerDetails();
      manufacturerDescription = _getManufacturerDescription();
      manufacturerConfirmed = _getManufacturerConfirmed();
    }
  }

  //part of [getManufacturerDetails]
  Future<String> _getManufacturerDescription() async {
    ConfirmationResponse manufacturerDetails = await _manufacturerDetails;
    return manufacturerDetails.manufacturerDescription;
  }

  //part of [getManufacturerDetails]
  Future<bool> _getManufacturerConfirmed() async {
    ConfirmationResponse manufacturerDetails = await _manufacturerDetails;
    return manufacturerDetails.confirmed;
  }

  //part of [getManufacturerDetails]
  Future<ConfirmationResponse> _getManufacturerDetails() {
    SecurityLoopReader securityLoopReader = SecurityLoopReader(mamBuffer);
    return securityLoopReader.confirmProductManufacturer(product);
  }

  List<ProductUpdate> productionDetailsList = List<ProductUpdate>();

  void addProductUpdate(ProductUpdate productUpdate) {
    productionDetailsList.add(productUpdate);
    _callback();
  }

  bool get isLoading => _isLoadingNow;

  set isLoading(bool value) {
    _isLoadingNow = value;
    _callback();
  }

  /// creates a ProductChannelLoader as soon as the product-message was loaded from MAM
  static Future<ProductChannelLoader> futureFactoryByRoot(String root, MamBuffer mamBuffer, VoidCallback callback) async{
    Product product = await mamBuffer.getTypedMessage<Product>(root);
    if (product != null) {
      return ProductChannelLoader(mamBuffer, product, callback);
    }
    return null;
  }

  ProductChannelLoader(this.mamBuffer, this.product, this._callback, [this._nextRoot]) {
    if (_nextRoot == null) {
      _nextRoot = product.nextRoot;
    }
  }

  /// Starts loading data from on the product-channel,
  /// can be stopped by before finished by [stopLoadingProductUpdate]
  Future<void> startLoadingProductionDetails() async {
    isLoading = true;
    stopReadingSignal = false;
     while(!stopReadingSignal) {
       ProductUpdate productUpdate = await mamBuffer.getTypedMessage<ProductUpdate>(_nextRoot);
       if (productUpdate == null) {
         break;
       }
       addProductUpdate(productUpdate);
       if (productUpdate is Sell) {
         _nextRoot = productUpdate.rootOfBuyer;
       } else {
         _nextRoot = productUpdate.nextRoot;
       }


    }
    isLoading = false;
    return null;
  }

  /// Stops loading of further updates, the current MAM-request will be finished
  void stopLoadingProductUpdate() {
    stopReadingSignal = true;
  }

  bool containsProductUpdate(String root) {
    bool productLinksToUpdate = false;

    productionDetailsList.forEach((ProductUpdate productUpdate) {
      if (productUpdate.root == root) {
        productLinksToUpdate = true;
      }
    });
    return productLinksToUpdate;
  }

}
