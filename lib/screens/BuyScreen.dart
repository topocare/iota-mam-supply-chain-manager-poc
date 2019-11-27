import 'package:flutter/material.dart';

import 'package:provider/provider.dart';


import 'package:supply_chain_manager/appState/ScmAppState.dart';
import 'package:supply_chain_manager/controllers/BuyController.dart';
import 'package:supply_chain_manager/widgets/AlertAndLoadingScreen.dart';
import 'package:supply_chain_manager/widgets/CustomButton.dart';
import 'package:supply_chain_manager/widgets/ProductChannelBody.dart';
import 'package:supply_chain_manager/widgets/QRAndWidgetBelow.dart';

/// Screen handling the Buy-part of a transfer of ownership
///
/// uses [BuyController] and represents the information available at it's  different states
class BuyScreen extends StatefulWidget {
  @override
  BuyScreenState createState() => BuyScreenState();
}

class BuyScreenState extends State {
  BuyController buyHandler;
  static const String _appBarTitle = 'Buy Product';

  @override
  Widget build(BuildContext context) {
    return Consumer<ScmAppState>(builder: (context, appState, child) {
      if (buyHandler == null) {
        String offeredBuyRoot = ModalRoute.of(context).settings.arguments;
        buyHandler = BuyController(appState, offeredBuyRoot);
        //offeredBuy = appState.mamHandler.getBuyByRoot(offeredBuyRoot);
      }

      return ChangeNotifierProvider.value(
          value: buyHandler, child: _BuyScreenContent(_appBarTitle));
    });
  }
}

/// helper-widget to enable [ChangeNotifierProvider] to update it
class _BuyScreenContent extends StatelessWidget {
  final String _appBarTitle;

  _BuyScreenContent(this._appBarTitle);

  Widget build(BuildContext context) {
    BuyController buyHandler = Provider.of<BuyController>(context, listen: true);
    switch (buyHandler.state) {
      case BuyControllerState.loadingProduct:
        return AlertAndLoadingScreen(
            appBarTitle: _appBarTitle,
            text: 'loading MAM data',
            showCircularProgressIndicator: true);
      case BuyControllerState.productReady:
        return Scaffold(
            appBar: AppBar(title: Text(_appBarTitle)),
            body: Column(children: [
              CustomButton(
                  title: "Buy",
                  onPressed: () {
                    buyHandler.makeBuyRequest("ExampleBuyer");
                  },
                  color: Colors.green),
              Expanded(
                child: ProductChannelBody(buyHandler.productChannelLoader),
              ),
            ]));
      case BuyControllerState.sendingBuy:
        return AlertAndLoadingScreen(
            appBarTitle: _appBarTitle,
            text: 'uploading Buy-Request',
            showCircularProgressIndicator: true);

      case BuyControllerState.unconfirmed:
        return QRAndWidgetBelow(
            appBarTitle: _appBarTitle,
            qrData: buyHandler.buy.root,
            child: RaisedButton(
                color: Colors.blue,
                child: const Text('Request Confirmation',
                    style: TextStyle(fontSize: 20, color: Colors.white)),
                onPressed: () {
                  buyHandler.checkIfSold();
                }));
      case BuyControllerState.checkingConfirmation:
        return QRAndWidgetBelow(
            appBarTitle: _appBarTitle,
            qrData: buyHandler.buy.root,
            child: Container(
              color: Colors.yellow,
              child: const Text('Confirming Transaction',
                  style: TextStyle(fontSize: 20, color: Colors.white)),
            ));
      case BuyControllerState.transactionConfirmed:
        return QRAndWidgetBelow(
            appBarTitle: _appBarTitle,
            qrData: buyHandler.buy.root,
                child: Container(
                  color: Colors.green,
                  child: const Text('Transaction Completed',
                      style: TextStyle(fontSize: 20, color: Colors.white)),
                ));
      case BuyControllerState.errorMamFetch:
        return AlertAndLoadingScreen(
            appBarTitle: _appBarTitle,
            text: 'Error: MAM-fetch failed',
            showIconProblem: true);
      case BuyControllerState.errorRootIsNoProduct:
        return AlertAndLoadingScreen(
            appBarTitle: _appBarTitle,
            text: 'is not a product-root',
            showCircularProgressIndicator: true);
      case BuyControllerState.errorMamSend:
        return AlertAndLoadingScreen(
            appBarTitle: _appBarTitle,
            text: 'Error: MAM-send failed',
            showIconProblem: true);
      default:
        return AlertAndLoadingScreen(
            appBarTitle: _appBarTitle,
            text: 'unspecified error',
            showIconProblem: true);
    }
  }
}
