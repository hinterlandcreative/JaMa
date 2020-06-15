import 'dart:async';
import 'dart:collection';

import 'package:jama/data/models/time_category_model.dart';
import 'package:jama/data/models/time_model.dart';
import 'package:jama/ui/models/collection_base_model.dart';
import 'package:jama/services/time_service.dart';
import 'package:jama/ui/models/time/time_category_model.dart';
import 'package:kiwi/kiwi.dart';
import 'package:tuple/tuple.dart';

import 'time_by_date_model.dart';
import 'time_model.dart';
import '../../../mixins/date_mixin.dart';

class TimeCollectionModel extends CollectionBaseModel<TimeByDateModel> {
  final DateTime startDate;
  final DateTime endDate;

  List<TimeByDateModel> _items = [];
  TimeService _timeService;
  List<TimeByCategoryModel> _allHours = [];
  int _goalHours = 0;
  int _videos = 0;
  int _placements = 0;
  int _returnVisits = 0;

  StreamSubscription<Time> _subscription;

  List<TimeByCategoryModel> get allHours => _allHours;
  int get goalHours => _goalHours;
  int get videos => _videos;
  int get placements => _placements;
  int get returnVisits => _returnVisits;

  TimeCollectionModel(this.startDate, this.endDate, [TimeService timeService]) {
    Container container = Container();
  
    _timeService = timeService ?? container.resolve<TimeService>();
    _subscription = _timeService.timeUpdatedStream.listen((time) {
      if(time == null || (time.formattedDate.compareTo(startDate) >= 0 && time.formattedDate.compareTo(endDate) <= 0)) {
        loadChildren();
      }
    });
  loadChildren();
  }

  @override
  UnmodifiableListView<TimeByDateModel> get items => UnmodifiableListView(_items);

  @override
  Future loadChildren() async {
    var timeEntries = await _timeService.getTimeEntriesByDate(
      startTime: startDate, 
      endTime: endDate);
    
    var dates = timeEntries.map((t) => DateTime.fromMillisecondsSinceEpoch(t.date).dropTime()).toList();
    dates = dates.toSet().toList();
    _items = dates.map((date) => TimeByDateModel(
      timeEntries
        .where((t) => DateTime.fromMillisecondsSinceEpoch(t.date).dropTime() == date)
        .map((t) => TimeModel(timeModel: t))
        .toList(), 
      date)
    ).toList();
    
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

    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
  }

  Future deleteTime(Time time) async {
    await _timeService.deleteTime(time);

    notifyListeners();
  }
}