import 'dart:async';
import 'dart:collection';

import 'package:jama/ui/models/time/time_modification_model.dart';
import 'package:kiwi/kiwi\.dart';
import 'package:tuple/tuple.dart';

import 'package:jama/ui/models/collection_base_model.dart';
import 'package:jama/services/time_service.dart';
import 'package:jama/ui/models/time/time_category_model.dart';

import 'package:jama/ui/models/time/time_by_date_model.dart';
import 'package:jama/mixins/date_mixin.dart';

class TimeCollectionModel extends CollectionBaseModel<TimeByDateModel> {
  final DateTime startDate;
  final DateTime endDate;

  List<TimeByDateModel> _items = [];
  TimeService _timeService;
  List<TimeByCategory> _allHours = [];
  int _goalHours = 0;
  int _videos = 0;
  int _placements = 0;
  int _returnVisits = 0;

  StreamSubscription<Time> _subscription;

  List<TimeByCategory> get allHours => _allHours;
  int get goalHours => _goalHours;
  int get videos => _videos;
  int get placements => _placements;
  int get returnVisits => _returnVisits;

  TimeCollectionModel(this.startDate, this.endDate, [TimeService timeService]) {
    var container = KiwiContainer();

    _timeService = timeService ?? container.resolve<TimeService>();
    _subscription = _timeService.timeUpdatedStream.listen((time) {
      if (time == null ||
          (time.date.compareTo(startDate) >= 0 && time.date.compareTo(endDate) <= 0)) {
        loadChildren();
      }
    });
    loadChildren();
  }

  @override
  UnmodifiableListView<TimeByDateModel> get items => UnmodifiableListView(_items);

  @override
  Future loadChildren() async {
    var timeEntries = await _timeService.getTimeEntriesByDate(start: startDate, end: endDate);

    var dates = timeEntries.map((t) => t.date.dropTime()).toList();
    dates = dates.toSet().toList();
    _items = dates
        .map((date) => TimeByDateModel(
            timeEntries
                .where((t) => t.date.dropTime() == date)
                .map((t) => TimeModificationModel.edit(time: t))
                .toList(),
            date))
        .toList();

    var categories = await _timeService.getCategories();

    var totals = <Tuple2<TimeCategory, int>>[];

    for (var category in categories) {
      var entries = timeEntries.where((t) => t.category == category);
      if (entries.isNotEmpty) {
        totals.add(Tuple2<TimeCategory, int>(
            category, entries.map((t) => t.totalMinutes).reduce((a, b) => a + b)));
      }
    }

    _allHours = totals.map((t) => TimeByCategory(t.item1, t.item2 / 60.0)).toList();

    _goalHours = 0;

    if (timeEntries.isNotEmpty) {
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
