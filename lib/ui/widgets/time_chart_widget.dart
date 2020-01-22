import 'dart:ui';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:jama/mixins/color_mixin.dart';
import 'package:jama/ui/models/home_model.dart';
import 'package:jama/ui/models/time/time_category_model.dart';
import 'package:jama/ui/widgets/donut_chart_widget.dart';
import 'package:quiver/iterables.dart';

import '../../mixins/duration_mixin.dart';

class TimeChartWidget extends DonutChartWidget {
  TimeChartWidget(List<charts.Series> seriesList,
      {bool animate,
      String text,
      TextStyle textStyle,
      @required double width,
      @required double height})
      : super(seriesList,
            animate: animate,
            text: text,
            textStyle: textStyle,
            width: width,
            height: height);

  factory TimeChartWidget.fromTimeSeries(
      List<TimeByCategoryModel> values, int goal,
      {bool animate,
      @required double width,
      @required double height,
      TextStyle textStyle}) {
    List<_HoursPerCategorySeries> data = [];
    for (int i in range(0, values.length)) {
      data.add(_HoursPerCategorySeries(
          values[i].category.name, values[i].time, values[i].category.color));
    }

    final valuesTotal = values.length > 0
        ? values.map((x) => x.time).reduce((a, b) => a + b)
        : 0;

    if (goal > 0 && (valuesTotal == 0 || valuesTotal < goal)) {
      data.add(_HoursPerCategorySeries("amount left",
          (goal - valuesTotal).toDouble(), HexColor.fromHex("#CEEDF2")));
    }

    var series = [
      charts.Series<_HoursPerCategorySeries, String>(
          id: "time",
          data: data,
          domainFn: (_HoursPerCategorySeries series, _) => series.category,
          measureFn: (_HoursPerCategorySeries series, _) => series.timeInHours,
          colorFn: (_HoursPerCategorySeries series, _) =>
              charts.ColorUtil.fromDartColor(series.color))
    ];

    return TimeChartWidget(series,
        animate: animate,
        text: Duration(minutes: (valuesTotal * 60.0).toInt()).toShortString(),
        textStyle: textStyle,
        width: width,
        height: height);
  }
}

class _HoursPerCategorySeries {
  final String category;
  final double timeInHours;
  final Color color;

  _HoursPerCategorySeries(this.category, this.timeInHours, this.color);
}
