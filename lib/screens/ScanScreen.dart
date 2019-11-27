import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:supply_chain_manager/appState/ProductChannelLoader.dart';
import 'package:supply_chain_manager/appState/ScmAppState.dart';
import 'package:supply_chain_manager/controllers/SellController.dart';
import 'package:supply_chain_manager/widgets/ProductChannelBody.dart';

/// screen listing details of a scanned product
class ScanScreen extends StatefulWidget {
  @override
  ScanScreenState createState() => ScanScreenState();
}

class ScanScreenState extends State {
  Future<ProductChannelLoader> productLoader;

  @override
  Widget build(BuildContext context) {
    return Consumer<ScmAppState>(builder: (context, appState, child) {
      if (productLoader == null) {
        String scannedString = ModalRoute.of(context).settings.arguments;
        productLoader = appState.getProductChannelLoaderByRoot(scannedString);
      }
      return FutureBuilder(
          future: productLoader,
          builder: (context, AsyncSnapshot<ProductChannelLoader> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Scaffold(
                  appBar: AppBar(title: Text('Scanned Product')),
                  body: Column(children: [
                    Expanded(
                      child: ProductChannelBody(snapshot.data),
                    ),
                  ]));
            } else {
              return Scaffold(
                  appBar: AppBar(title: Text('Scanned Product')),
                  body: Center(child: CircularProgressIndicator()));
            }
          });
    });
  }
}
