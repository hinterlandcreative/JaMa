import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class DonutChartWidget extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;
  final TextStyle textStyle;
  final String text;
  final double width;
  final double height;
  final int margin;

  DonutChartWidget(this.seriesList,
      {this.animate, this.textStyle, this.text, this.width = 100.0, this.height = 100.0, this.margin = 0});

  @override
  Widget build(BuildContext context) {
    final w = width ?? 100.0;
    final h = height ?? 100.0;

    return SizedBox(
      width: w,
      height: h,
      child: Stack(
        children: <Widget>[
          charts.PieChart(
            seriesList,
            layoutConfig: charts.LayoutConfig(
              leftMarginSpec: charts.MarginSpec.fixedPixel(margin),
              rightMarginSpec: charts.MarginSpec.fixedPixel(margin),
              topMarginSpec: charts.MarginSpec.fixedPixel(margin),
              bottomMarginSpec: charts.MarginSpec.fixedPixel(margin)),
            animate: animate,
            defaultRenderer: new charts.ArcRendererConfig(arcWidth: 8)),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: AutoSizeText(
                text,
                minFontSize: 1,
                style: textStyle,
                maxLines: 1,
              ),
            ),
          )
        ],
      ),
    );
  }
}
