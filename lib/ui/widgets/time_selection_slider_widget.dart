import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:intl/intl.dart';
import 'package:jama/ui/app_styles.dart';
import '../../mixins/duration_mixin.dart';

class TimeSelectionSlider extends StatefulWidget {
  final Function(DateTime startTime, Duration duration) onTimeChanged;
  final DateTime startTime;
  final Duration duration;

  /// Create a widget for selecting a duration between two times.
  /// [onTimeChanged] is called when the time has been updated.
  /// [startTime] is the starting time.
  /// [duration] is the initial duration between the start time and end time.
  TimeSelectionSlider({@required this.onTimeChanged, this.startTime, this.duration});

  @override
  _TimeSelectionSliderState createState() => _TimeSelectionSliderState();
}

class _TimeSelectionSliderState extends State<TimeSelectionSlider> {
  static final int increment = 15;
  static final maxHours = 8;
  DateTime startTime;
  DateTime endTime;
  Duration duration = Duration.zero;

  int _totalIncrementCount = maxHours * (60 ~/ increment); // 15 min x 12 hours
  DateTime _baseTime;
  int _durationInIncrements;
  int _startInIncrements;

  @override
  void initState() {
    super.initState();
    startTime = widget.startTime;
    duration = widget.duration;
    endTime = startTime.add(duration);

    _setNewBaseValues(duration, startTime);
  }

  void _setNewBaseValues(Duration dur, DateTime date) {
    if (dur < Duration(hours: maxHours)) {
      var halfDuration = (dur.inMinutes / 2) ~/ increment;
      _startInIncrements = ((_totalIncrementCount ~/ 2) - halfDuration);
      _baseTime = date
          .subtract(Duration(minutes: _startInIncrements * increment));
      _durationInIncrements = dur.inMinutes ~/ increment;
    } else {
      _baseTime = date;
      _durationInIncrements = dur.inMinutes ~/ increment;
      _startInIncrements = 0;
      _totalIncrementCount = _durationInIncrements;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppStyles.leftMargin),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("START",
                        style: AppStyles.smallTextStyle
                            .copyWith(fontWeight: FontWeight.bold)),
                    Text(DateFormat.jm().format(startTime),
                        style: AppStyles.smallTextStyle)
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(40),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text("END",
                        style: AppStyles.smallTextStyle
                            .copyWith(fontWeight: FontWeight.bold)),
                    Text(DateFormat.jm().format(endTime),
                        style: AppStyles.smallTextStyle)
                  ],
                ),
              ],
            ),
          ),
          FlutterSlider(
            rangeSlider: true,
            min: 0,
            max: _totalIncrementCount.toDouble(),
            values: [
              _startInIncrements.toDouble(),
              (_startInIncrements + _durationInIncrements).toDouble()
            ],
            tooltip: FlutterSliderTooltip(disabled: true),
            onDragging: (_, s, e) {
              double start = s ?? 0.0;
              double end = e ?? 0.0;
              setState(() {
                _startInIncrements = start.toInt();
                _durationInIncrements = (end - start).toInt();
                startTime = _baseTime
                    .add(Duration(minutes: (start.toInt() * increment)));
                duration = Duration(minutes: increment * _durationInIncrements);
                endTime = startTime.add(duration);
              });
            },
            onDragCompleted: (_, __, ___) => widget.onTimeChanged(startTime, duration),
          ),
        ],
      ),
      Container(
        alignment: Alignment.topCenter,
        child: RawMaterialButton(
          shape: new CircleBorder(),
          elevation: 8.0,
          fillColor: Colors.white,
          padding: EdgeInsets.all(20.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: AutoSizeText(
              duration.toShortString(),
              style: AppStyles.heading2.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          onPressed: () {
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (dialogContext) {
                  var lastStart = startTime;
                  var lastStartInIncrements = _startInIncrements;
                  var lastDurationInIncrements = _durationInIncrements;
                  var lastDuration = duration;
                  var lastEnd = endTime;

                  var chosenStart = lastStart;
                  var chosenEnd = lastEnd;

                  return AlertDialog(
                      content: Stack(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical:30),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text("Choose Start & End",
                                    style: AppStyles.heading2),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text("START TIME"),
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 33),
                                      child: TimePickerSpinner(
                                        time: startTime,
                                        is24HourMode: false,
                                        minutesInterval: 15,
                                        spacing: 1,
                                        itemHeight: 25,
                                        alignment: Alignment.center,
                                        isForce2Digits: true,
                                        highlightedTextStyle: AppStyles.heading2
                                            .copyWith(
                                                fontWeight: FontWeight.bold),
                                        normalTextStyle: AppStyles.smallTextStyle
                                            .copyWith(color: AppStyles.lightGrey),
                                        onTimeChange: (newStart) => chosenStart = newStart,
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text("END TIME"),
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 33),
                                      child: TimePickerSpinner(
                                        time: endTime,
                                        is24HourMode: false,
                                        minutesInterval: 15,
                                        spacing: 1,
                                        itemHeight: 25,
                                        alignment: Alignment.center,
                                        isForce2Digits: true,
                                        highlightedTextStyle: AppStyles.heading2
                                            .copyWith(
                                                fontWeight: FontWeight.bold),
                                        normalTextStyle: AppStyles.smallTextStyle
                                            .copyWith(color: AppStyles.lightGrey),
                                        onTimeChange: (newEnd) => chosenEnd = newEnd,
                                      ),
                                    )
                                  ],
                                ),
                                Container(
                                  height: 40,
                                  width: MediaQuery.of(context).size.width,
                                  child: FlatButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20)),
                                    color: AppStyles.primaryColor,
                                    child: Text(
                                      "save",
                                      style: AppStyles.heading2.copyWith(
                                          color: AppStyles.secondaryTextColor),
                                    ),
                                    onPressed: () {
                                      if(chosenEnd.isBefore(chosenStart)) {
                                        chosenEnd = chosenStart;
                                      }

                                      widget.onTimeChanged(chosenStart, chosenEnd.difference(chosenStart));
                                      startTime = chosenStart;
                                      endTime = chosenEnd;
                                      duration = chosenEnd.difference(chosenStart);
                                      setState(() => _setNewBaseValues(duration, chosenStart));

                                      Navigator.of(dialogContext, rootNavigator: true).pop();
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                          Positioned(
                            top: 0, 
                            right: 0,
                            child: IconButton(
                              color: AppStyles.primaryColor,
                              icon: Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  startTime = lastStart;
                                  duration = lastDuration;
                                  endTime = lastEnd;
                                  _startInIncrements = lastStartInIncrements;
                                  _durationInIncrements = lastDurationInIncrements;
                                });

                                Navigator.of(dialogContext, rootNavigator: true).pop();
                              }
                            ,)),
                        ],
                      ),
                    );
                });
          },
        ),
      ),
    ]);
  }
}
