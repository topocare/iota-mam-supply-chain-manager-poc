import 'package:flutter/material.dart';

/// Used for ordering [NavigationButton]s in a column
class NavigationList extends StatelessWidget {
  final String title;
  final List<Widget> children;

  NavigationList({this.title = "", this.children});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: children)));
  }
}



