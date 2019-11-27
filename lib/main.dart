import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

import 'package:supply_chain_manager/appState/ScmAppState.dart';
import 'package:supply_chain_manager/screens/DemoDataScreen.dart';
import 'package:supply_chain_manager/screens/ProductDetailsQRScreen.dart';
import 'package:supply_chain_manager/screens/ScanScreen.dart';

//screens for routes
import 'screens/MainScreen.dart';
import 'screens/OwnedProductsScreen.dart';
import 'screens/BuyScreen.dart';
import 'screens/SellScreen.dart';
import 'screens/ProductDetailsScreen.dart';
import 'screens/PortfolioMenuScreen.dart';
import 'screens/ManufacturerListScreen.dart';
import 'screens/ManufacturerDetailsScreen.dart';
import 'screens/TrustedManufacturerListScreen.dart';


void main() => runApp(SupplyChainManager());


/// Entrypoint of the App.
///
/// Defines routes to screens and global app state
class SupplyChainManager extends StatefulWidget {

  @override
  SupplyChainManagerState createState() => SupplyChainManagerState();
}

class SupplyChainManagerState extends State<SupplyChainManager> {
  ScmAppState appState;

  @override
  void initState() {
    appState = ScmAppState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return FutureBuilder(
        future: appState.init(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ChangeNotifierProvider.value(
                value: appState,
                child: MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: 'topocare X IOTA Supply Chain Manager PoC',
                  initialRoute: '/',
                  routes: {
                    //menus
                    '/': (context) => MainScreen(),
                    '/PortfolioMenu': (context) => PortfolioMenuScreen(),
                    //by scan
                    '/ScanScreen': (context) => ScanScreen(),
                    '/BuyScreen': (context) => BuyScreen(),
                    '/SellScreen': (context) => SellScreen(),

                    //BaseDataManagement
                    //  Products
                    '/OwnedProducts': (context) => OwnedProductsScreen(),
                    '/ProductDetails': (context) => ProductDetailsScreen(),
                    '/ProductDetailsQR': (context) => ProductDetailsQRScreen(),
                    //  managed Manufacturer-IDs
                    '/ManufacturerList': (context) => ManufacturerListScreen(),
                    '/ManufacturerDetails': (context) =>
                        ManufacturerDetailsScreen(),
                    //  trusted Manufacturer-IDs
                    '/TrustedManufacturers': (context) => TrustedManufacturerListScreen(),

                    //DemoDataManagement
                    '/DevScreen': (context) => DemoDataScreen(),
                  },
                ));
          } else if (snapshot.hasError){
            debugPrint("ERROR");
            debugPrint(snapshot.error.toString());
            return Center(child: Text("Error", textDirection: TextDirection.ltr));
          } else return Container();
        });
  }
}
