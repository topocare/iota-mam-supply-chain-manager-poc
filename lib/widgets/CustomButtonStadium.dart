import 'package:flutter/material.dart';

// custom oval button
class CustomButtonStadium extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final Color color;
  final TextStyle textStyle;
  final double hight;

  CustomButtonStadium({
    this.title = "",
    @required this.onPressed,
    this.color = Colors.blueAccent,
    this.textStyle,
    this.hight = 100,
  });

  Widget build(BuildContext context) {
    TextStyle buildTextStyle;
    if (textStyle == null) {
      buildTextStyle = TextStyle(fontSize: 20, color: Colors.white);
    } else {
      buildTextStyle = textStyle;
    }

    return Container(
        height: hight,
        padding: EdgeInsets.all(10.0),
        child: RaisedButton(
            color: color,
            shape: StadiumBorder(),
            onPressed: onPressed,
            child: Center(
              child: Text(title, style: buildTextStyle),
            )));
  }
}