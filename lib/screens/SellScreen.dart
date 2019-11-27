import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:supply_chain_manager/appState/ScmAppState.dart';
import 'package:supply_chain_manager/controllers/SellController.dart';
import 'package:supply_chain_manager/widgets/AlertAndLoadingScreen.dart';
import 'package:supply_chain_manager/widgets/CustomButton.dart';
import 'package:supply_chain_manager/widgets/ProductChannelBody.dart';

/// Screen handling the Sell-part of a transfer of ownership
///
/// uses [SellController] and represents the information available at it's  different states
class SellScreen extends StatefulWidget {
  @override
  SellScreenState createState() => SellScreenState();
}

class SellScreenState extends State {
  SellController sellHandler;
  static const String _appBarTitle = 'Sell Product';

  @override
  Widget build(BuildContext context) {
    return Consumer<ScmAppState>(builder: (context, appState, child) {
      if (sellHandler == null) {
        String offeredBuyRoot = ModalRoute.of(context).settings.arguments;
        sellHandler = SellController(appState, offeredBuyRoot);
        //offeredBuy = appState.mamHandler.getBuyByRoot(offeredBuyRoot);
      }

      return ChangeNotifierProvider.value(
          value: sellHandler, child: _SellScreenContent(_appBarTitle));
    });
  }


}

class _SellScreenContent extends StatelessWidget {
  final String _appBarTitle;

  _SellScreenContent(this._appBarTitle);

  Widget build(BuildContext context) {
    SellController sellHandler = Provider.of<SellController>(context, listen: true);
    switch (sellHandler.state) {
      case SellControllerState.loadingBuyAndProduct:
        return AlertAndLoadingScreen(
            appBarTitle: _appBarTitle,
            text: 'loading IOTA-MAM data',
            showCircularProgressIndicator: true);
      case SellControllerState.buyAndProductReady:
        return Scaffold(
            appBar: AppBar(title: Text(_appBarTitle)),
            body: Column(children: [
              CustomButton(
                  title: "Confirm Sell",
                  onPressed: () {
                    sellHandler.sellProduct();
                  },
                  color: Colors.red),
              Expanded(
                  child: ProductChannelBody(
                      Provider.of<ScmAppState>(context, listen: true)
                          .getProductChannelLoader(sellHandler.product))),
            ]));
      case SellControllerState.sendingSell:
        return AlertAndLoadingScreen(
            appBarTitle: _appBarTitle,
            text: 'uploading Sell confirmation',
            showCircularProgressIndicator: true);
      case SellControllerState.sellDone:
        return AlertAndLoadingScreen(
            appBarTitle: _appBarTitle,
            text: 'Product sold!',
            showIconDone: true);
      case SellControllerState.errorMamFetch:
        return AlertAndLoadingScreen(
            appBarTitle: _appBarTitle,
            text: 'Error: MAM-fetch failed',
            showIconProblem: true);
      case SellControllerState.errorProductNotOwned:
        return AlertAndLoadingScreen(
            appBarTitle: _appBarTitle,
            text: 'Error: Product not owned',
            showIconProblem: true);
      case SellControllerState.errorMamSend:
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
