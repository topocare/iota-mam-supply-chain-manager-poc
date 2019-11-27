import "package:flutter/material.dart";

import 'package:supply_chain_manager/widgets/DetailsViewItem.dart';

/// as [DetailsViewItem], but contains a Future
/// shows a [CircularProgressIndicator] while waiting
class DetailsViewFutureItem extends StatelessWidget {
  final String title;
  final Future future;

  DetailsViewFutureItem({@required this.title, @required this.future});

  @override
  build(BuildContext context) {
    return FutureBuilder(
        future: future,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return DetailsViewItem(title: "Name:", value: '${snapshot.data}');
          }
          return Icon(
            Icons.report_problem,
            color: Colors.red,
          );
        });
  }
}
