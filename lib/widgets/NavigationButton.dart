import 'package:flutter/material.dart';

import "CustomButton.dart";

// button using the app's default design and containing a Navigator route
class NavigationButton extends StatelessWidget {
  final String title;
  final String route;

  NavigationButton({this.title = "", this.route = "/"});

  NavigationButton.list([this.title = "", this.route = "/"]);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
        title: title,
        onPressed: () {
          Navigator.pushNamed(context, route);
        });
  }
}