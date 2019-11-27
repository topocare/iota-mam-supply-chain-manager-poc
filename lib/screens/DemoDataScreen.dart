import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:supply_chain_manager/appState/ScmAppState.dart';
import 'package:supply_chain_manager/controllers/DemoDataController.dart';
import 'package:supply_chain_manager/widgets/AlertAndLoadingScreen.dart';
import 'package:supply_chain_manager/widgets/CustomButton.dart';

/// screen providing access to functions of [DemoDataController] for creation of demo-data
class DemoDataScreen extends StatefulWidget {
  @override
  DevTestScreenState createState() => DevTestScreenState();
}

typedef FutureVoidCallback = Future<void> Function();

/// screen displaying options to generate / delete demo-data
class DevTestScreenState extends State {
  Future<void> busy;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: busy,
        builder: (context, AsyncSnapshot<void> busySnapshot) {
          if (busySnapshot.hasError) {
            busy.catchError((e) => {});
            return AlertAndLoadingScreen(appBarTitle: 'PoC Data Management', text: 'Error: \n${busySnapshot.error.toString()}', showIconProblem: true,);
          }
          if (busySnapshot.connectionState == ConnectionState.waiting) {
            return AlertAndLoadingScreen(appBarTitle: 'PoC Data Management', text: 'executing...', showCircularProgressIndicator: true,);
          }
          DemoDataController demoDataController =
              Provider.of<ScmAppState>(context, listen: false).demoDataController;
          return Scaffold(
              appBar: AppBar(title: Text('PoC Data Management')),
              body: SingleChildScrollView(
                  child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            makeButton(
                              text: 'newManufacturer',
                              todo: () => demoDataController.newManufacturer(),
                            ),
                            makeButton(
                              text: 'add new product to last manufacturer',
                              todo: () =>
                                  demoDataController.newProductToLastManufacturer(),
                            ),
                            makeButton(
                              text: 'add details to last product',
                              todo: () => demoDataController
                                  .addProductionDetailsToLastProduct(),
                            ),
                            makeButton(
                              text: "make manufacutrer of last product trusted",
                              todo: () => demoDataController
                                  .makeManufacturerOfLastProductTrusted(),
                            ),
                            makeButton(
                              text: "wipeData",
                              todo: () => demoDataController.wipeData(),
                            ),
                          ]))));
        });
  }

  ///helper to add setState to each button
  Widget makeButton({String text, FutureVoidCallback todo}) {
    return CustomButton(
        title: text,
        hight: 80,
        onPressed: () {
          setState(() {
            this.busy = todo();
          });
        });
  }
}
