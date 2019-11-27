import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:supply_chain_manager/appState/ScmAppState.dart';
import 'package:supply_chain_manager/widgets/DetailsViewList.dart';

// screen listing all trusted manufacturers
class TrustedManufacturerListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Trusted Manufacturer-IDs')),
        body: Consumer<ScmAppState>(builder: (context, appState, child) {
          return Padding(
              padding: EdgeInsets.all(8.0),
              child: DetailsViewList.buildByMap(titleAndValue: appState.trustedManufacturers, reverseKeyAndValue: true),
          );
        }));
  }
}