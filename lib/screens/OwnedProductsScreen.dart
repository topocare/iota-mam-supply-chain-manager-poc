import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:supply_chain_manager/appState/ScmAppState.dart';

/// Screen listing all owned products
class OwnedProductsScreen extends StatefulWidget {
  @override
  OwnedProductsScreenState createState() => OwnedProductsScreenState();
}

class OwnedProductsScreenState extends State {
  final List<int> colorCodes = <int>[500, 200];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Owned Products')),
        body: Consumer<ScmAppState>(builder: (context, appState, child) {
          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: appState.ownedProducts.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                  height: 50,
                  color: Colors.blue[colorCodes[index % 2]],
                  child: FlatButton(
                    child: Center(
                        child: Text('${appState.ownedProducts[index].productId}')),
                    onPressed: () {
                      //appState.selectedProduct = appState.ownedProducts[index];
                      Navigator.pushNamed(context, '/ProductDetails', arguments: appState.ownedProducts[index]);
                    },
                  ));
            },
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(),
          );
        }));
  }
}
