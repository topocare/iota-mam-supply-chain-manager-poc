

import 'package:flutter/material.dart';

import 'package:supply_chain_manager/widgets/QRAndWidgetBelow.dart';

/// Screen showing the QR code of a specific product-roots
class ProductDetailsQRScreen extends StatefulWidget {
  ProductDetailsQRScreenState createState() => ProductDetailsQRScreenState();
}

class ProductDetailsQRScreenState extends State<ProductDetailsQRScreen> {
  String _qrData;

  Widget build(BuildContext context) {
    if (_qrData == null) {
      _qrData = ModalRoute.of(context).settings.arguments;
    }
    return QRAndWidgetBelow(appBarTitle: 'Product Details', qrData: _qrData, child: Text('$_qrData', textAlign: TextAlign.center,));
  }
}