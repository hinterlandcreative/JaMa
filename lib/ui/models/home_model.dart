import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jama/data/models/time_category_model.dart';
import 'package:jama/data/models/time_model.dart';
import 'package:jama/services/time_service.dart';
import 'package:jama/ui/models/goal_model.dart';
import 'package:jama/ui/screens/reports/time_report_screen.dart';
import 'package:kiwi/kiwi.dart' as kiwi;
import 'package:tuple/tuple.dart';

import 'time/time_category_model.dart';

class HomeModel extends ChangeNotifier {
  TimeService _timeService;

  List<TimeByCategoryModel> _allHours = [];
  int _goalHours = 0;
  int _placements = 0;
  int _videos = 0;
  int _returnVisits = 0;
  List<GoalModel> _goals = [];

  StreamSubscription<Time> _subscription;

  
  UnmodifiableListView<TimeByCategoryModel> get allHours => UnmodifiableListView(_allHours);
  UnmodifiableListView<GoalModel> get goals => UnmodifiableListView(_goals);
  int get goalHours => _goalHours;
  int get placements => _placements;
  int get videos => _videos;
  int get returnVisits => _returnVisits;

  HomeModel([TimeService timeService]) {
    final container = kiwi.Container();
    _timeService = timeService ?? container.resolve<TimeService>();

    _subscription = _timeService.timeUpdatedStream.listen((_) => _loadData());

    _loadData();
  }

  Future _loadData() async {
    var now = DateTime.now();
    var timeEntries = await _timeService.getTimeEntriesByDate(
      startTime: DateTime(now.year, now.month, 1), 
      endTime: DateTime(now.year, now.month+1,1).subtract(Duration(milliseconds: 1)));
    
    var categories = await _timeService.getCategories();

    var totals = <Tuple2<TimeCategory, int>>[];    

    for(var category in categories) {
      var entries = timeEntries.where((t) => t.category.id == category.id);
      if(entries.isNotEmpty) {
        totals.add(Tuple2<TimeCategory,int>(category, entries.map((t) => t.totalMinutes).reduce((a, b) => a + b)));
      }
    }

    _allHours = totals.map((t) => TimeByCategoryModel(t.item1, t.item2 / 60.0)).toList();

    _goalHours = 0;

    if(timeEntries.isNotEmpty) {
      _videos = timeEntries.map((t) => t.videos).reduce((a, b) => a + b);
      _placements = timeEntries.map((t) => t.placements).reduce((a, b) => a + b);
    }
    _returnVisits = 0;

    _goals.clear();
    _goals.add(
      GoalModel(
        text: "${DateFormat.MMM().format(DateTime(now.year, now.month - 1))} was a great month! Let's look at how your ministry went.",
        iconPath: "graphics/confetti.png",
        navigationWidget: () => TimeReportScreen(
          start: DateTime(now.year, now.month -1, 1),
          end: DateTime(now.year, now.month, 1).subtract(Duration(milliseconds: 1))
        )
      )); 
    // _goals.add(
    //   GoalModel(
    //     "You’ve averaged 14 ministry days per month, 4 hours per day and 72 hours per month.",
    //     null,
    //     "graphics/confetti.png"
    //   )); 
    // _goals.add(
    //   GoalModel(
    //     "You’ve set the goal of showing videos this month. You’ve shown 6 videos so far. Keep it up!",
    //     null,
    //     "graphics/diamond.png"
    //   )); 
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
  }
}