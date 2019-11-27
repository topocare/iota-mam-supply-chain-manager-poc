import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:supply_chain_manager/appState/ScmAppState.dart';

/// Screen listing all managed manufacturer channels
class ManufacturerListScreen extends StatefulWidget {
  @override
  ManufacturerListScreenState createState() => ManufacturerListScreenState();
}

class ManufacturerListScreenState extends State {
  final List<int> colorCodes = <int>[500, 200];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Managed Manufacturer-IDs')),
        body: Consumer<ScmAppState>(builder: (context, appState, child) {
          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: appState.managedManufacturers.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                  height: 50,
                  color: Colors.blue[colorCodes[index % 2]],
                  child: FlatButton(
                    child: Center(
                        child:
                        Text(appState.managedManufacturers[index].description)),
                    onPressed: () {
                      Navigator.pushNamed(context, '/ManufacturerDetails', arguments: appState.managedManufacturers[index]);
                    },
                  ));
            },
            separatorBuilder: (BuildContext context, int index) =>
            const Divider(),
          );
        }));
  }
}
