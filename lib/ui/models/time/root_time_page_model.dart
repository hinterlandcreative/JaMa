import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jama/services/time_service.dart';
import 'package:jama/mixins/date_mixin.dart';
import 'package:jama/mixins/duration_mixin.dart';
import 'package:jama/ui/models/navigatable.dart';
import 'package:jama/ui/models/time/time_modification_model.dart';
import 'package:jama/ui/screens/time/add_edit_time_screen.dart';
import 'package:kiwi/kiwi.dart' as kiwi;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class RootTimePageModel extends ChangeNotifier {
  final TimeService timeService;
  bool _isLoading = true;
  List<TimeEntry> _entries;

  DateTime _start;
  DateTime _end;

  StreamSubscription<Time> _timeServiceSubscription;

  RootTimePageModel._(this.timeService) {
    _timeServiceSubscription = timeService.timeUpdatedStream.listen((event) {
      if (_start != null && _end != null) {
        if (event == null || (event.date.isAfter(_start) && event.date.isBefore(_end))) {
          _loadData();
        }
      }
    });
  }

  @override
  void dispose() {
    _timeServiceSubscription.cancel();
    super.dispose();
  }

  factory RootTimePageModel([TimeService timeService]) =>
      RootTimePageModel._(timeService ?? kiwi.Container().resolve<TimeService>());

  /// Loads the time entries between a given [start] and [end] date.
  Future loadEntries(DateTime start, DateTime end) async {
    if (start == null || end == null) {
      throw ArgumentError.notNull("Start and end can't be null.");
    }
    if (start.compareTo(end) > 0) {
      throw ArgumentError.value("start can't be greater than end.");
    }

    if (!_isLoading) {
      _isLoading = true;
      notifyListeners();
    }

    _start = start.dropTime();
    _end = end.dropTime();

    await _loadData();
  }

  Future _loadData() async {
    var entries = await timeService.getTimeEntriesByDate(start: _start, end: _end);

    _entries = entries
        .map((e) => TimeEntry(
              e,
              category: e.category,
              startTime: e.date,
              endTime: e.date.add(e.duration),
              hours: e.duration,
              placements: e.placements,
              videos: e.videos,
              onDelete: (t) async => timeService.deleteTime(t),
            ))
        .toList();

    _isLoading = false;
    notifyListeners();
  }

  /// Gets the entries that occur on this date.
  List<TimeEntry> getEntriesForDate(DateTime date) => _entries == null
      ? []
      : _entries.where((element) => element.startTime.isSameDayAs(date)).toList();
}

class TimeEntry extends Navigatable {
  final Time _time;

  /// The category of the thime entry.
  final TimeCategory category;

  /// The [startTime] of the time entry.
  final DateTime startTime;

  /// The [endTime] of the time entry.
  final DateTime endTime;

  /// The [hours] of the time entry.
  final Duration hours;

  /// The count of [placements] of the time entry.
  final int placements;

  /// The count of [videos] of the time entry.
  final int videos;

  /// Called when this time entry is deleted.
  final Function(Time) onDelete;

  TimeEntry(this._time,
      {@required this.category,
      @required this.startTime,
      @required this.endTime,
      @required this.hours,
      @required this.placements,
      @required this.videos,
      @required this.onDelete});

  /// The [startTime] and [endTime] as a formatted string.
  String get startAndEndTimeString =>
      "${DateFormat.jm().format(startTime)} - ${DateFormat.jm().format(endTime)}";

  ///
  String get hoursString => hours.toShortString();

  @override
  Future navigate(BuildContext context) {
    return showBarModalBottomSheet(
        context: context,
        builder: (_, __) => AddEditTimeScreen.edit(TimeModificationModel.edit(time: _time)));
  }

  void delete() => onDelete(_time);
}
