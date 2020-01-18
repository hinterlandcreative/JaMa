import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:jama/data/models/time_category_model.dart';
import 'package:jama/data/models/time_model.dart';
import 'package:jama/services/time_service.dart';
import 'package:kiwi/kiwi.dart' as kiwi;

class TimeModel extends ChangeNotifier {
  int _currentPlacements = 0;
  int _placementsGoal = 0;
  int _videosGoal = 0;
  int _currentVideos = 0;
  Time time;
  int increment = 15;
  String get placementsGoal => _getGoalText(_placementsGoal, _currentPlacements, time.placements);
  String get videosGoal => _getGoalText(_videosGoal, _currentVideos, time.videos);

  List<TimeCategory> _categories = [];

  UnmodifiableListView<TimeCategory> get categories =>
      UnmodifiableListView(_categories);

  TimeService _timeService;

  TimeModel({Time timeModel, TimeService timeService}) {
    time = timeModel ??
        Time(
            date: DateTime.now().millisecondsSinceEpoch,
            totalMinutes: 15,
            category: null);
    final container = kiwi.Container();
    _timeService = timeService ?? container.resolve<TimeService>();

    _currentPlacements = 6;
    _placementsGoal = 20;
    _currentVideos = 1;
    _videosGoal = 4;

    _loadData();
  }

  Future _loadData() async {
    _categories = await _timeService.getCategories();
    _categories.add(TimeCategory(name: "local design construction", color: Colors.yellow));
    if(time.category == null) {
      time.category = _categories[0];
    }
    notifyListeners();
  }

  Future saveOrUpdate() async {
    await _timeService.saveOrAddTime(time);
  }

  void setDate(DateTime date) {
    if (time.date != date.millisecondsSinceEpoch) {
      time.date = date.millisecondsSinceEpoch;
      notifyListeners();
    }
  }

  void setTime(int totalMinutes) {
    if (time.totalMinutes != totalMinutes) {
      time.totalMinutes = totalMinutes;
      notifyListeners();
    }
  }

  void setCategory(TimeCategory category) {
    if (time.category != category) {
      time.category = category;
      notifyListeners();
    }
  }

  void setPlacements(int value) {
    if (time.placements != value) {
      time.placements = value;
      notifyListeners();
    }
  }

  void setVideos(int value) {
    if(time.videos != value) {
      time.videos = value;
      notifyListeners();
    }
  }

  void setNotes(String value) {
    if(time.notes != value && value.isNotEmpty) {
      time.notes = value;
      notifyListeners();
    }
  }

  String _getGoalText(int goal, int currentState, int addedState) {
    final goalValue = goal - currentState - addedState;
    if(goalValue == 0) {
      return "goal met";
    } else if(goalValue < 0) {
      return "${-(goalValue)} extra";
    } else {
      return "$goalValue left";
    }
  }
}
