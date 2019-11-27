import 'package:flutter/foundation.dart';

import 'package:supply_chain_manager/appState/ProductChannelLoader.dart';
import 'package:supply_chain_manager/appState/ScmAppState.dart';
import 'package:supply_chain_manager/mamHandler/MamQueue.dart';
import 'package:supply_chain_manager/messages/Buy.dart';
import 'package:supply_chain_manager/messages/ChannelOwnership.dart';

/// possible states of a [BuyController]
enum BuyControllerState {
  loadingProduct,
  productReady,
  sendingBuy,
  unconfirmed,
  checkingConfirmation,
  transactionConfirmed,
  errorMamFetch,
  errorRootIsNoProduct,
  errorMamSend,
}

/// Controller for the "buy" part of a transfer of ownership.
class BuyController extends ChangeNotifier {
  final ScmAppState _appState;
  final String productRoot;

  ChannelOwnership _channelOwnership;

  BuyControllerState _state;

  BuyControllerState get state => _state;

  void setState(BuyControllerState state) {
    _state = state;
    notifyListeners();
  }

  Buy _buy;

  Buy get buy => _buy;

  ProductChannelLoader _productChannelLoader;

  ProductChannelLoader get productChannelLoader => _productChannelLoader;

  BuyController(this._appState, this.productRoot) {
    _loadProduct();
  }

  // loads the [Product] and [ProductChannelLoader],
  // state transition: loadingProduct -> productReady
  // sets [productChannelLoader] when done
  // run in constructor
  void _loadProduct() async {
    try {
      setState(BuyControllerState.loadingProduct);
      _productChannelLoader =
          await _appState.getProductChannelLoaderByRoot(productRoot);
      if (_productChannelLoader == null) {
        setState(BuyControllerState.errorRootIsNoProduct);
      } else {
        setState(BuyControllerState.productReady);
      }
    } catch (e) {
      setState(BuyControllerState.errorMamFetch);
    }
  }

  // publishes the [Buy] message
  // state transition: productReady -> sendingBuy -> unconfirmed
  // sets [Buy] when done
  void makeBuyRequest(String buyerDescription) async {
    try {
      setState(BuyControllerState.sendingBuy);
      _buy = await _publishBuyRequest(buyerDescription);
      setState(BuyControllerState.unconfirmed);
    } catch (e) {
      setState(BuyControllerState.errorMamSend);
    }
  }

  // checks if product was sold ([Sell] message) to the [Buy], and as such to this app-instance
  // state transition: unconfirmed -> checkingConfirmation -> transactionConfirmed
  // result is the new state: either still unconfirmed or transitionConfirmed
  void checkIfSold() async {
    setState(BuyControllerState.checkingConfirmation);
    if (await _checkForSell()) {
      setState(BuyControllerState.transactionConfirmed);
    } else {
      setState(BuyControllerState.unconfirmed);
    }
  }

  // checks if product is sold to the [Buy], leaving state determination to checkIfSold
  // adds product to _appState.ownedproducts if buy was successfull
  Future<bool> _checkForSell() async {
    await productChannelLoader.startLoadingProductionDetails();
    bool result = productChannelLoader.containsProductUpdate(buy.root);

    if (result) {
      productChannelLoader.product.ownership = _channelOwnership;
      await _appState.addOwnedProduct(
          productChannelLoader.product, productChannelLoader.product.ownership);
    }
    return result;
  }

  // publishes the [Buy], leaving state-changes to [makeBuyRequest]
  Future<Buy> _publishBuyRequest(String buyerDescription) async {
    //create payload
    String productRoot = _productChannelLoader.product.root;
    String payload = Buy.buildTryteString(productRoot, buyerDescription);

    //create data for new channel
    _channelOwnership = ChannelOwnership.generate();

    //send message
    MamSendResponse mamSendResponse = await _appState
        .sendMessageByChannelOwnership(_channelOwnership, payload, false);

    return Buy(productRoot, buyerDescription, mamSendResponse.root,
        mamSendResponse.nextRoot);
  }
}
