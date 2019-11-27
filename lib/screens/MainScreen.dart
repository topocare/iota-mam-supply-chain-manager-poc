import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:provider/provider.dart';

import 'package:supply_chain_manager/appState/ScmAppState.dart';
import 'package:supply_chain_manager/widgets/CustomButton.dart';
import 'package:supply_chain_manager/widgets/NavigationButton.dart';
import 'package:supply_chain_manager/widgets/CustomButtonStadium.dart';

/// The main-menu of the app.
///
/// Handles scanning of QR codes, before navigating to the appropriate screens
/// Also includes the [WebView] used by [MamQueue] to execute javascript (not visible).
class MainScreen extends StatefulWidget {
  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State {
  String scanResult = "";

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Consumer<ScmAppState>(builder: (context, appState, child) {
        return appState.mamQueue.getWidget(context);
      }),

      Scaffold(
          appBar: AppBar(title: Text('IOTA Supply Chain Manager'),
              actions: [
                IconButton(icon: Icon(Icons.add_box),
                    onPressed: () => Navigator.pushNamed(context, '/DevScreen'))
              ]),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Spacer(flex: 1),
                NavigationButton(
                    title: 'My Portfolio', route: '/PortfolioMenu'),
                Spacer(flex: 3),
                CustomButtonStadium(title: 'Buy', onPressed: () {
                  scanAndNavigate('/BuyScreen');
                }, color: Colors.green),
                Spacer(flex: 2),
                CustomButtonStadium(title: 'Sell',
                    onPressed: () => scanAndNavigate('/SellScreen'),
                    color: Colors.red),
                Spacer(flex: 3),
                CustomButton(title: 'Scan Product',
                    onPressed: () => scanAndNavigate('/ScanScreen')),
                Spacer(flex: 1),
              ],
            ),
          ))
    ]);
  }


  Future scanAndNavigate(String navigatorRoute) async {
    String scanResult = await scan();

    //TODO: replace with check trytes length 81
    if (scanResult != "") {
      Navigator.pushNamed(context, navigatorRoute, arguments: scanResult);
    }
  }

  Future<String> scan() async {
    String result = "";
    try {
      result = await BarcodeScanner.scan();
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        Scaffold.of(context).showSnackBar(
          SnackBar(content: Text('ERROR: camera permission denied')),
        );
      } else {
        SnackBar(content: Text('ERROR: Unknown'));
      }
    } on FormatException {} catch (e) {
      SnackBar(content: Text('ERROR: Unknown'));
    }
    return result;
  }

}
