import 'package:flutter/material.dart';
import 'package:jama/mixins/color_mixin.dart';

class AppStyles {
  // Colors
  static Color get primaryColor => HexColor.fromHex("#5385E5");
  static Color get primaryBackground => HexColor.fromHex("#F7FBFB");
  static Color get secondaryBackground => HexColor.fromHex("#5385E5");
  static Color get lightGrey => HexColor.fromHex("#DBDBDB");
  static Color get captionText => HexColor.fromHex("#707070");
  static Color get primaryTextColor => Colors.black;
  static Color get secondaryTextColor => Colors.white;
  static Color get shadowColor => HexColor.fromHex("#20000000");
  static Color get speedDialOverlayColor => HexColor.fromHex("#9F9F9F");

  // Text Styles
  static TextStyle get heading1 => TextStyle(
      fontFamily: "Avenir", fontWeight: FontWeight.w700, fontSize: 34);
  static TextStyle get heading2 =>
      TextStyle(fontFamily: "Avenir", fontSize: 20);
  static TextStyle get heading4 => TextStyle(
      fontFamily: "Avenir", fontWeight: FontWeight.w100, fontSize: 16);
  static TextStyle get smallTextStyle =>
      TextStyle(fontFamily: "Avenir", fontSize: 14);

  // constants
  static double get leftMargin => 24.0;
  static double get topMargin => 37.0;
  static double get headerHeight => 250.0;
  static double get timeHeaderBoxHeight => 165.0;
  static double get timeHeaderBoxWidth => 211.0;

  // boxes
  static BorderRadiusGeometry get defaultBoxCorner => BorderRadius.all(Radius.circular(15));
  static BoxShadow get defaultBoxShadow => BoxShadow(
      blurRadius: 15,
      color: AppStyles.shadowColor,
      offset: Offset.fromDirection(1.178097, 5));

  // charts
  static double get defaultChartHeight => 100.0;
  static double get defaultChartWidth => 100.0;
}
