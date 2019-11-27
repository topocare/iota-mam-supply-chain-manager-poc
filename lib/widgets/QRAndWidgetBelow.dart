import 'package:flutter/material.dart';

import 'package:qr_flutter/qr_flutter.dart';

/// Arrangement of a QR code with a widget below.
class QRAndWidgetBelow extends StatelessWidget {
  final String appBarTitle;
  final String qrData;
  final Widget child;

  QRAndWidgetBelow({@required this.appBarTitle, @required this.qrData, @required this.child});

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(appBarTitle)),
        body: Center(
            child:
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              QrImage(
                data: qrData,
                version: QrVersions.auto,
                size: 300,
              ),
              child,
            ])));
  }
}