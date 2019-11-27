import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:supply_chain_manager/appState/ProductChannelLoader.dart';

import 'package:supply_chain_manager/appState/ScmAppState.dart';
import 'package:supply_chain_manager/messages/Product.dart';
import 'package:supply_chain_manager/widgets/ProductChannelBody.dart';

/// Screen listing details of a product's meta-channel
class ProductDetailsScreen extends StatefulWidget {
  @override
  ProductDetailsScreenState createState() => ProductDetailsScreenState();
}

class ProductDetailsScreenState extends State {
  ProductChannelLoader productLoader;


  @override
  Widget build(BuildContext context) {
    return Consumer<ScmAppState>(builder: (context, appState, child) {
      if (productLoader == null) {
        Product product = ModalRoute
            .of(context)
            .settings
            .arguments;
        productLoader = appState.getProductChannelLoader(product);
      }

        return Scaffold(
            appBar: AppBar(title: Text('Product Details'), actions: [
              FlatButton(child: Text('as QR', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  onPressed: () =>
                      Navigator.pushNamed(context, '/ProductDetailsQR',
                          arguments: productLoader.product.root))
            ]),

            body: ProductChannelBody(productLoader));
      });

  }
}