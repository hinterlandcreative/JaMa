import 'package:flutter/material.dart';
import 'package:flutter_circular_slider/flutter_circular_slider.dart';
import 'package:jama/ui/models/time/time_model.dart';

import '../app_styles.dart';

class TimeSelectionSlider extends StatelessWidget {
  final TimeModel model;
  final double width;
  final double height;
  
  const TimeSelectionSlider({
    @required
    this.model,
    this.width = 140,
    this.height = 140,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleCircularSlider(
      12 * (60 ~/ model.increment),
      model.time.totalMinutes ~/ model.increment,
      height: height,
      width: width,
      selectionColor: AppStyles.primaryColor.withAlpha(150),
      baseColor: AppStyles.lightGrey,
      handlerColor: AppStyles.primaryColor,
      handlerOutterRadius: 10,
      onSelectionChange: (a, b, c) => _setTime(a,b,c),
      child: Center(child: Text(_formatTime(), style: AppStyles.heading2)),
    );
  }

  void _setTime(int start, int end, int laps) {
    int timeInMinutes = end > start
        ? ((end - start) * model.increment) + (laps * 72)
        : ((48 - start + end) * model.increment) + (laps * 720);
    model.setTime(timeInMinutes);
  }

  String _formatTime() {
    final hours = model.time.totalMinutes ~/ 60;
    final minutes = model.time.totalMinutes % 60;
    return "${hours}h${minutes}m";
  }
}