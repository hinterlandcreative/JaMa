import 'package:flutter/material.dart';

class HorizontalSpace extends StatelessWidget {
  final double width;
  const HorizontalSpace(this.width, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
    );
  }
} 

class VerticalSpace extends StatelessWidget {
  final double height;
  const VerticalSpace(this.height, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
    );
  }
}