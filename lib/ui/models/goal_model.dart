import 'package:flutter/material.dart';

class GoalModel {
  final String text;
  final Widget Function() navigationWidget;
  final String iconPath;

  GoalModel({@required this.text, this.navigationWidget, @required this.iconPath});
}