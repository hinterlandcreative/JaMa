import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:jama/data/models/dto/visit_dto.dart';
import 'package:jama/services/app_settings_service.dart';
import 'package:jama/services/return_visit_service.dart';

import 'package:kiwi/kiwi.dart' as kiwi;
import 'package:quiver/time.dart';

import 'package:jama/services/time_service.dart';
import 'package:jama/mixins/date_mixin.dart';

class TimeModificationModel extends ChangeNotifier {
  final Time _time;
  final TimeService _timeService;
  final ReturnVisitService _rvService;
  final AppSettingsService _appSettingsService;

  int _currentPlacements = 0;
  int _goalPlacements = 0;
  int _currentVideos = 0;
  int _goalVideos = 0;

  List<TimeCategory> _categories = [];

  List<Time> _entriesForMonth;

  TimeModificationModel._(
      this._time, this._timeService, this._rvService, this._appSettingsService) {
    _loadData();
  }

  /// Creates a new [TimeModificationModel] that edits the supplied [time].
  factory TimeModificationModel.edit(
      {@required Time time,
      TimeService timeService,
      ReturnVisitService rvService,
      AppSettingsService appSettingsService}) {
    return TimeModificationModel._(
        time.copy(),
        timeService ?? kiwi.Container().resolve<TimeService>(),
        rvService ?? kiwi.Container().resolve<ReturnVisitService>(),
        appSettingsService ?? kiwi.Container().resolve<AppSettingsService>());
  }

  /// Creates a new [TimeModificationModel] that has not been saved yet.
  factory TimeModificationModel.create(
          [date,
          TimeService timeService,
          ReturnVisitService rvService,
          AppSettingsService appSettingsService]) =>
      TimeModificationModel._(
          Time.create(
              date: date ?? DateTime.now().toNearestIncrement().subtract(anHour),
              totalMinutes: anHour.inMinutes,
              category: null),
          timeService ?? kiwi.Container().resolve<TimeService>(),
          rvService ?? kiwi.Container().resolve<ReturnVisitService>(),
          appSettingsService ?? kiwi.Container().resolve<AppSettingsService>());

  /// The [duration] of the current time entry.
  Duration get duration => _time.duration;

  /// The [date] of the curent time entry.
  DateTime get date => _time.date;

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
  bool get shouldHideGoals => _time.category != null && !_time.category.isMinistry;

  /// The placements total from other days this month.
  int get previousPlacements => _currentPlacements;

  /// The goals value for monthly placements.
  int get goalsPlacements => _goalPlacements;

  /// The videos total from other days this month.
  int get previousVideos => _currentVideos;

  /// The goals value for monthly videos.
  int get goalsVideos => _goalVideos;

  String get placementsGoalMessage => _time.placements + _currentPlacements < _goalPlacements
      ? "You have ${_goalPlacements - (_time.placements + _currentPlacements)} left to meet your monthly goal of $_goalPlacements placements."
      : "Congratulations! You have already met your monthly goal of $_goalPlacements placements.";

  get videosGoalMessage => _time.videos + _currentVideos < _goalVideos
      ? "You have ${_goalVideos - (_time.videos + _currentVideos)} left to meet your monthly goal of $_goalVideos videos."
      : "Congratulations! You have already met your monthly goal of $_goalVideos videos shown.";

  /// The [date] of the curent time entry.
  set date(DateTime value) {
    if (_time.date != value) {
      _time.date = value;
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
    if (_time.videos != value) {
      _time.videos = value;
      notifyListeners();
    }
  }

  /// The [notes] of the time entry.
  set notes(String value) {
    if (_time.notes != value) {
      _time.notes = value;
      notifyListeners();
    }
  }

  /// Sets the time based on the [startTime] and the [totalMinutes] from that start time.
  void setTime(DateTime startTime, int totalMinutes) {
    _time.date = DateTime(
        _time.date.year, _time.date.month, _time.date.day, startTime.hour, startTime.minute);
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
    if (!_time.isSaved) return;

    await _timeService.deleteTime(_time);
  }

  Future _loadData() async {
    _categories = await _timeService.getCategories();
    if (_time.category == null) {
      _time.category = _categories[0];
    }

    _entriesForMonth = await _timeService.getTimeEntriesByDate(
        start: DateTime.now().toFirstDayOfMonth(), end: DateTime.now().toLastDayOfMonth());
    if (await _appSettingsService.getSettingBool(AppSettingsService.goals_enabled)) {
      _goalPlacements =
          await _appSettingsService.getSettingInt(AppSettingsService.goals_monthly_placements);
      _goalVideos =
          await _appSettingsService.getSettingInt(AppSettingsService.goals_monthly_videos);

      if (_goalPlacements > 0 || _goalVideos > 0) {
        var placements = await _rvService.getPlacementsFromDates(
            start: DateTime.now().toFirstDayOfMonth(), end: DateTime.now().toLastDayOfMonth());
        if (_goalPlacements > 0) {
          _currentPlacements = _entriesForMonth.fold(
                  0, (previousValue, element) => previousValue + element.placements) +
              placements
                  .where((p) => p.type != PlacementType.Video)
                  .fold(0, (previousValue, element) => previousValue + element.count);
        }

        if (_goalVideos > 0) {
          _currentVideos =
              _entriesForMonth.fold(0, (previousValue, element) => previousValue + element.videos) +
                  placements
                      .where((p) => p.type == PlacementType.Video)
                      .fold(0, (previousValue, element) => previousValue + element.count);
        }
      }
    }

    notifyListeners();
  }

  List<TimeCategory> isDateMarkedForPreviousEntry(DateTime date) {
    return _entriesForMonth == null
        ? <TimeCategory>[]
        : _entriesForMonth
            .where((time) => time.date.isSameDayAs(date))
            .map((e) => e.category)
            .toSet()
            .toList();
  }
}
