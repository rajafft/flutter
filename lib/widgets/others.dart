import 'package:flutter/material.dart';
import 'package:group_button/group_button.dart';
import 'package:wean_app/common/screenConfig.dart';

class DividerGrey extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(2, 8, 2, 8),
      width: SizeConfig.screenWidth,
      height: 0.6,
      color: Colors.grey,
    );
  }
}

class ScrollIjector extends StatelessWidget {
  const ScrollIjector({
    required this.child,
    required this.groupingType,
  });

  final Widget child;
  final GroupingType groupingType;

  @override
  Widget build(BuildContext context) {
    if (groupingType == GroupingType.row) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: child,
      );
    }
    return child;
  }
}
