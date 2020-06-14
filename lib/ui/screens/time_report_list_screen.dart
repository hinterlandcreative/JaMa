import 'dart:collection';

import 'package:flutter/material.dart';

import 'package:jama/services/time_service.dart';
import 'package:jama/ui/models/collection_base_model.dart';
import 'package:jama/ui/models/time/time_model.dart';
import 'package:jama/ui/screens/generic_collection_screen.dart';
import 'package:jama/ui/widgets/time_card.dart';
import 'package:kiwi/kiwi.dart' as kiwi;
import 'package:provider/provider.dart';

class TimeReportListScreen extends StatelessWidget {
  /// The [start] date for the report.
  final DateTime start;

  /// The [end] date for the report.
  final DateTime end;

  const TimeReportListScreen
({Key key, this.start, this.end}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider<TimeReport>(
        create: (_) => TimeReport(start, end),
        child: Consumer<TimeReport>(
          builder: (context, model, _) => ListView.builder(
            itemCount: model.items.length,
            itemBuilder: (context, index) => TimeCard(
              item: model.items[index],
              isLast: index == model.items.length - 1
            ),
          )
        )
      ),
    );
  }
}

class TimeReport extends CollectionBaseModel<TimeModel> {
  /// The [start] date for the report.
  final DateTime start;

  /// The [end] date for the report.
  final DateTime end;

  final TimeService _timeService;

  List<TimeModel> _items = [];

  TimeReport._(this.start, this.end, this._timeService) {
    loadChildren();
  }

  factory TimeReport(@required DateTime start, @required DateTime end, [TimeService timeService]) {
    var container = kiwi.Container();
    return TimeReport._(start, end, timeService ?? container.resolve<TimeService>());
  }

  @override
  // TODO: implement items
  UnmodifiableListView<TimeModel> get items => UnmodifiableListView(_items);

  @override
  Future loadChildren() async {
    var items = await _timeService.getTimeEntriesByDate(startTime: start, endTime: end);
    if(items.isNotEmpty) {
      _items = items.map((e) => TimeModel(timeModel: e)).toList();
      notifyListeners();
    }
  }
}