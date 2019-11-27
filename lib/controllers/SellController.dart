import 'package:flutter/foundation.dart';

import 'package:supply_chain_manager/appState/ProductChannelLoader.dart';
import 'package:supply_chain_manager/appState/ScmAppState.dart';
import 'package:supply_chain_manager/mamHandler/MamQueue.dart';
import 'package:supply_chain_manager/messages/Buy.dart';
import 'package:supply_chain_manager/messages/Product.dart';
import 'package:supply_chain_manager/messages/Sell.dart';

/// possible states of a [SellController]
enum SellControllerState {
  loadingBuyAndProduct,
  buyAndProductReady,
  sendingSell,
  sellDone,
  errorMamFetch,
  errorProductNotOwned,
  errorMamSend,
}

/// Controller for the "sell" part of a transfer of ownership.
class SellController extends ChangeNotifier{
  final ScmAppState _appState;
  final String buyRoot;

  SellControllerState _state;
  SellControllerState get state => _state;
  void setState(SellControllerState state) {
    _state = state;
    notifyListeners();
  }

  Buy _buyOffer;
  String _productRoot;
  Product _product;
  ProductChannelLoader _productChannelLoader;

  Buy get buyOffer => _buyOffer;
  String get productRoot => _productRoot;
  Product get product => _product;
  ProductChannelLoader get productChannelLoader => _productChannelLoader;


  SellController(this._appState, this.buyRoot) {
     _getBuyAndProduct();
  }

  // fetches the buy and loads the product of owned
  // state-changes: loadingBuyAndProduct -> buyAndProductReady
  void _getBuyAndProduct() async{
    setState(SellControllerState.loadingBuyAndProduct);
    Buy buy = await _appState.mamBuffer.getTypedMessage<Buy>(buyRoot);
    if (buy == null) {
      setState(SellControllerState.errorMamFetch);
      return null;
    }
    _productRoot = buy.rootOfProduct;

    _product = _appState.getOwnedProductByRoot(_productRoot);
    if (product == null) {
      setState(SellControllerState.errorProductNotOwned);
      return null;
    }

    _productChannelLoader = _appState.getProductChannelLoader(_product);
    _buyOffer = buy;
    setState(SellControllerState.buyAndProductReady);
  }

  // sells the product to the publisher of the 'Buy' message
  // state-changes: buyAndProductReady -> sendingSell -> sellDone
  void sellProduct() async{
    setState(SellControllerState.sendingSell);
    try {
      await _sellProduct(_buyOffer);
      setState(SellControllerState.sellDone);
    } catch(e) {
      setState(SellControllerState.errorMamSend);
    }
  }

  // inner function for [sellProduct], handling the sell excluding state-changes
  Future<void> _sellProduct(Buy buy) async {
    //send sell and delete entry
    if (_appState.isOwnedProduct(buy.rootOfProduct)) {
      Product product = _appState.getOwnedProductByRoot(buy.rootOfProduct);

      _appState.getProductChannelLoader(product).addProductUpdate(await _publishSellMessage(product, buy));
      await _appState.deleteOwnedProduct(product);
      return null;
    }
  }

  // creates and publishes the sell message
  Future<Sell> _publishSellMessage(Product product, Buy buy) async{
    String payload = Sell.buildTryteStringNow(buy.root);
    MamSendResponse mamSendResponse = await _appState.sendMessageByChannelOwnership(product.ownership, payload);
    return Sell(buy.root, mamSendResponse.root, mamSendResponse.nextRoot);
  }
}