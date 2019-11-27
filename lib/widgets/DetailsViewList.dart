import "package:flutter/material.dart";

import 'package:supply_chain_manager/widgets/DetailsViewItem.dart';

/// A list of [DetailsViewitem], shown as a column.
/// Can be generated from a Map<String,String>
class DetailsViewList extends StatelessWidget {
  final List<Widget> children;
  final WidgetBuilder separatorBuilder;
  final bool separated;
  final bool separatorAtEnd;

  DetailsViewList({@required this.children, this.separatorBuilder = buildDefaultDivider, this.separated = true, this.separatorAtEnd = false});

  factory DetailsViewList.buildByMap({@required Map<String,String> titleAndValue, bool reverseKeyAndValue = false, WidgetBuilder separatorBuilder = buildDefaultDivider, bool separated = true, bool separatorAtEnd = false}) {
    List<Widget> children = List<Widget>();
    if (reverseKeyAndValue) {
      titleAndValue.forEach((String key, String value) => {children.add(DetailsViewItem(title: value, value: key))});
    } else {
      titleAndValue.forEach((String key, String value) => {children.add(DetailsViewItem(title: key, value: value))});
    }
    return DetailsViewList(children: children, separatorBuilder: separatorBuilder, separated: separated, separatorAtEnd: separatorAtEnd);
  }



  @override
  build(BuildContext context) {
    List<Widget> buildList;
    if (separated) {
      buildList = _separate(context, children);
    } else {
      buildList = children;
    }

    if (separatorAtEnd) {
      buildList.add(separatorBuilder(context));
    }

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: buildList);
  }

  List<Widget> _separate(BuildContext context, List<Widget> widgetListToSeparate) {
    List<Widget> separatedList = new List<Widget>();

    for (int i = 0; i < widgetListToSeparate.length-1; i++) {
      separatedList.add(widgetListToSeparate[i]);
      separatedList.add(separatorBuilder(context));
    }
    separatedList.add(widgetListToSeparate.last);
    return separatedList;
  }

  static Widget buildDefaultDivider(BuildContext context) {
    return Divider();
  }
}