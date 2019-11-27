import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:supply_chain_manager/appState/ScmAppState.dart';
import 'package:supply_chain_manager/messages/Manufacturer.dart';
import 'package:supply_chain_manager/widgets/DetailsViewItem.dart';
import 'package:supply_chain_manager/widgets/DetailsViewList.dart';

/// Screen listing details of a managed manufacturer channel
class ManufacturerDetailsScreen extends StatefulWidget {
  @override
  ManufacturerDetailsScreenState createState() =>
      ManufacturerDetailsScreenState();
}

class ManufacturerDetailsScreenState extends State {
  Manufacturer manufacturer;

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Manufacturer Details')),
        body: Padding(
            padding: EdgeInsets.all(8.0),
            child: Consumer<ScmAppState>(builder: (context, appState, child) {
              if (manufacturer == null) {
                manufacturer = ModalRoute.of(context).settings.arguments;
              }
              return DetailsViewList(children: [
                DetailsViewItem(
                    title: "Name:", value: manufacturer.description),
                DetailsViewItem(
                    title: "Root:", value: manufacturer.root),
                DetailsViewItem(
                    title: "nextRoot:", value: manufacturer.nextRoot),
              ]);
            })));
  }
}
