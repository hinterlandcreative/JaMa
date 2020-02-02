import 'package:flutter/material.dart';
import 'package:flutter_circular_slider/flutter_circular_slider.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:jama/ui/models/time/time_model.dart';

import '../app_styles.dart';
import '../../mixins/num_mixin.dart';
import '../../mixins/duration_mixin.dart';

class TimeSelectionSlider extends StatelessWidget {
  final TimeModel model;
  final double width;
  final double height;
  final DateTime baseTime;
  final _divisions = 8 * (60 ~/ 15);

  const TimeSelectionSlider({
    @required this.model,
    this.width = 140,
    this.height = 140,
    Key key,
    this.baseTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        InkWell(
          onTap: () {
            DatePicker.showTimePicker(context,
                showSecondsColumn: false,
                currentTime: model.time.formattedDate, onConfirm: (time) {
              time = DateTime(time.year, time.month, time.day, time.hour,
                  time.minute.roundTo(15));
              model.setTime(
                  time, model.time.formattedDate.difference(time).inMinutes);
            });
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                DateFormat.jm().format(model.time.formattedDate),
                style: AppStyles.smallTextStyle
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                "START TIME", 
                style: TextStyle(
                    fontFamily: "Avenir", fontSize: 12, color: Colors.grey),
                )
              ],
            ),
          ),
        SingleCircularSlider(
          _divisions,
          model.time.totalMinutes ~/ model.increment,
          height: height,
          width: width,
          selectionColor: AppStyles.primaryColor.withAlpha(150),
          baseColor: AppStyles.lightGrey,
          handlerColor: AppStyles.primaryColor,
          handlerOutterRadius: 10,
          shouldCountLaps: false,
          onSelectionChange: (a, b, c) => _setTime(a, b, c),
          child: Center(child: Text(model.time.duration.toShortString(), style: AppStyles.heading2)),
        ),
        InkWell(
          onTap: () {
            DatePicker.showTimePicker(context,
                showSecondsColumn: false,
                currentTime: model.time.formattedDate
                    .add(Duration(minutes: model.time.totalMinutes)),
                onConfirm: (time) {
              time = DateTime(time.year, time.month, time.day, time.hour,
                  time.minute.roundTo(15));
              var diff = model.time.formattedDate.difference(time);
              var start = model.time.formattedDate.add(diff);
              var date = start.toString();
              model.setTime(start, diff.inMinutes);
            });
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                DateFormat.jm()
                    .format(model.time.formattedDate.add(model.time.duration)),
                style: AppStyles.smallTextStyle
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                "START TIME",
                style: TextStyle(
                    fontFamily: "Avenir", fontSize: 12, color: Colors.grey),
              )
            ],
          ),
        ),
      ],
    );
  }

  void _setTime(int start, int end, int laps) {
    int timeInMinutes = end > start
        ? ((end - start) * model.increment) + (laps * 72)
        : ((48 - start + end) * model.increment) + (laps * 720);

    model.setTime(model.baseTime.subtract(Duration(minutes: timeInMinutes)),
        timeInMinutes);
  }
}
