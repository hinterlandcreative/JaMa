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

  DonutChartWidget(this.seriesList,
      {this.animate, this.textStyle, this.text, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    final w = width == 0 ? 100 : width;
    final h = height == 0 ? 100 : height;

    return SizedBox(
      width: w,
      height: h,
      child: Stack(
        children: <Widget>[
          charts.PieChart(seriesList,
              animate: animate,
              defaultRenderer: new charts.ArcRendererConfig(arcWidth: 8)),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: AutoSizeText(
                text,
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
