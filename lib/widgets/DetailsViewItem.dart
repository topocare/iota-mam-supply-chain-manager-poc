import "package:flutter/material.dart";


/// Item to list information.
///
/// The title of the value is shown in first row, the value below.
class DetailsViewItem extends StatelessWidget {

  final String title;
  final String value;

  DetailsViewItem ({this.title, this.value});


  @override
  build(BuildContext context) {
    String buildTitle = _undefinedIfNull(title);
    String buildValue = _undefinedIfNull(value);

    TextStyle customStyle = TextStyle(fontSize: 16);

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(buildTitle, style: customStyle, textAlign: TextAlign.left,),
          Padding(
            padding: EdgeInsets.fromLTRB(10.0, 2, 0, 2.0),
            child: Text(buildValue, style: customStyle),
          )
        ]
    );
  }

  String _undefinedIfNull(String value) {
    if (value != null) {
      return value;
    } else {
      return '[undefined]';
    }
  }
}