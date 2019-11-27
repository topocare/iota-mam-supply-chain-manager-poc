import "package:flutter/material.dart";

/// Pre-formatted Title, used for grouping items in a [DetailsViewList]
class DetailsViewTitle extends StatelessWidget {
  final String title;

  DetailsViewTitle({this.title});

  @override
  build(BuildContext context) {

    String buildTitle = _undefinedIfNull(title);

    TextStyle customStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        buildTitle,
        style: customStyle,
        textAlign: TextAlign.left,
      )
    ]);
  }

  String _undefinedIfNull(String value) {
    if (value != null) {
      return value;
    } else {
      return '[undefined]';
    }
  }
}
