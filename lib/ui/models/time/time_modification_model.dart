import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:jama/data/models/time_category_model.dart';

import 'package:kiwi/kiwi.dart' as kiwi;
import 'package:quiver/time.dart';

import 'package:jama/data/models/time_model.dart';
import 'package:jama/services/time_service.dart';
import 'package:jama/mixins/date_mixin.dart';

class TimeModificationModel extends ChangeNotifier {
  final Time _time;
  final TimeService _timeService;
  int _currentPlacements = 0;
  int _goalPlacements = 25;
  int _currentVideos = 0;
  int _goalVideos = 4;

  List<TimeCategory> _categories = [];

  List<Time> _entriesForMonth;

  TimeModificationModel._(this._time, this._timeService) {
    _loadData();
  }

  /// Creates a new [TimeModificationModel] that edits the supplied [time].
  factory TimeModificationModel.edit({@required Time time, TimeService timeService}) {
    return TimeModificationModel._(time.copy(), timeService ?? kiwi.Container().resolve<TimeService>());
  }
  
  /// Creates a new [TimeModificationModel] that has not been saved yet.
  factory TimeModificationModel.create([TimeService timeService]) {
    var now = DateTime.now();

    return TimeModificationModel._(
      Time(
        date: DateTime.now().toNearestIncrement().subtract(anHour).millisecondsSinceEpoch,
        totalMinutes: anHour.inMinutes,
        category: null),
      timeService ?? kiwi.Container().resolve<TimeService>()
    );
  }

  /// The [duration] of the current time entry.
  Duration get duration => _time.duration;

  /// The [date] of the curent time entry.
  DateTime get date => DateTime.fromMillisecondsSinceEpoch(_time.date);

  /// The list of available [categories].
  UnmodifiableListView<TimeCategory> get categories => UnmodifiableListView(_categories);
  
  /// The [notes] of the time entry.
  String get notes => _time.notes;

  /// The number of [placements] of the time entry.
  int get placements => _time.placements;

  /// The number of [videos] of the time entry.
  int get videos => _time.videos;

  /// The [category] of the time entry.
  TimeCategory get category => _time.category;

  /// Gets a value indicating whether goals should be hidden.
  bool get shouldHideGoals => _time.category != null  && _time.category.id != 1;

  /// The placements total from other days this month.
  int get previousPlacements => _currentPlacements;

  /// The goals value for monthly placements.
  int get goalsPlacements => _goalPlacements;

  /// The videos total from other days this month.
  int get previousVideos => _currentVideos;

  /// The goals value for monthly videos.
  int get goalsVideos => _goalVideos;

  /// The [date] of the curent time entry.
  set date(DateTime value) {
    if (_time.date != value.millisecondsSinceEpoch) {
      _time.date = value.millisecondsSinceEpoch;
      notifyListeners();
    }
  }

  /// The [category] of the time entry.
  set category(TimeCategory value) {
    if (_time.category != value) {
      _time.category = value;
      notifyListeners();
    }
  }

  /// The number of [placements] of the time entry.
  set placements(int value) {
    if (_time.placements != value) {
      _time.placements = value;
      notifyListeners();
    }
  }

  /// The number of [videos] of the time entry.
  set videos(int value) {
    if(_time.videos != value) {
      _time.videos = value;
      notifyListeners();
    }
  }

  /// The [notes] of the time entry.
  set notes(String value) {
    if(_time.notes != value) {
      _time.notes = value;
      notifyListeners();
    }
  }

  /// Sets the time based on the [startTime] and the [totalMinutes] from that start time.
  void setTime(DateTime startTime, int totalMinutes) {
    _time.date = DateTime(_time.formattedDate.year, _time.formattedDate.month, _time.formattedDate.day, startTime.hour, startTime.minute).millisecondsSinceEpoch;
    if (_time.totalMinutes != totalMinutes) {
      _time.totalMinutes = totalMinutes;
      notifyListeners();
    }
  }

  /// [save] or update the current time entry.
  Future save() async {
    await _timeService.saveOrAddTime(_time);
  }

  TimeModificationModel copy() {
    return TimeModificationModel.edit(time: _time);
  }
  
  /// [Deletes] this time entry.
  Future delete() async {
    if(_time.id == -1) return;

    await _timeService.deleteTime(_time);
  }

  Future _loadData() async {
    _categories = await _timeService.getCategories();
    if(_time.category == null) {
      _time.category = _categories[0];
    }


    _entriesForMonth = await _timeService.getTimeEntriesByDate(
      startTime: DateTime.now().toFirstDayOfMonth(),
      endTime: DateTime.now().toLastDayOfMonth()
    );

    notifyListeners();
  }

  List<TimeCategory> isDateMarkedForPreviousEntry(DateTime date) {
    return _entriesForMonth
      .where((time) => time.formattedDate.isSameDayAs(date))
      .map((e) => e.category)
      .toSet()
      .toList();
  }
}