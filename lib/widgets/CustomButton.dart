import 'package:flutter/material.dart';

/// default design for buttons used in the app
class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final Color color;
  final double hight;

  CustomButton({@required this.title, @required this.onPressed, this.color, this.hight = 60});

  CustomButton.list(this.title, this.onPressed, [this.color, this.hight = 60]);

  Widget build(BuildContext context) {
    Color buildColor;
    if (color == null) {
      buildColor = Colors.blue;
    } else {
      buildColor = color;
    }
    return Container(
        height: hight,
        padding: EdgeInsets.all(10.0),
        width: double.infinity,
        child: FlatButton(
            onPressed: onPressed,
            color: buildColor,
            child: Text(title, style: TextStyle(fontSize: 20, color: Colors.white), textAlign: TextAlign.center,)));
  }
}
