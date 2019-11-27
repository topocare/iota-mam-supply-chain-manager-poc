import 'package:flutter/material.dart';

/// basic widget for loading screens and alerts like errors or completion of a transaction
///
/// consists of a an icon or [CircularProgressIndicator] and a text
class AlertAndLoadingScreen extends StatelessWidget {
  final String appBarTitle;
  final String text;
  final bool showCircularProgressIndicator;
  final bool showIconDone;
  final bool showIconProblem;

  AlertAndLoadingScreen(
      {@required this.appBarTitle,
        @required this.text,
        this.showCircularProgressIndicator = false,
        this.showIconDone = false,
        this.showIconProblem = false
      }
    );


  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(appBarTitle)),
        body: Center(
            child:
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Visibility(
                visible: showIconDone,
                child: Icon(
                  Icons.done,
                  color: Colors.green,
                  size: 80.0,
                  semanticLabel: 'Text to announce in accessibility modes',
                ),
              ),
              Visibility(
                visible: showIconProblem,
                child: Icon(
                  Icons.report_problem,
                  color: Colors.red,
                  size: 80.0,
                  semanticLabel: 'Text to announce in accessibility modes',
                ),
              ),
              Text(
                text,
                style: TextStyle(fontSize: 16),
              ),
              Visibility(
                visible: showCircularProgressIndicator,
                child: CircularProgressIndicator(),
              ),
            ])));
  }
}

