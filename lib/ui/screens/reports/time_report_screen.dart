import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kiwi/kiwi.dart' as kiwi;
import 'package:provider/provider.dart';

import 'package:jama/services/time_service.dart';
import 'package:jama/mixins/date_mixin.dart';
import 'package:jama/ui/app_styles.dart';
import 'package:jama/ui/models/time/time_by_date_model.dart';
import 'package:jama/ui/models/time/time_modification_model.dart';
import 'package:jama/ui/widgets/grouped_collection_list_view.dart';
import 'package:jama/ui/widgets/time_card.dart';

class TimeReportScreen extends StatelessWidget {
  /// The [start] date for the report.
  final DateTime start;

  /// The [end] date for the report.
  final DateTime end;

  const TimeReportScreen
({Key key, this.start, this.end}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        title: Text(
          DateFormat.MMMMEEEEd(Intl.defaultLocale).format(start) + " - " + DateFormat.MMMMEEEEd(Intl.defaultLocale).format(end),
          style: AppStyles.heading2,),
        backgroundColor: AppStyles.primaryColor,),
      body: ChangeNotifierProvider<TimeGroupedByDateCollectionModel>(
        create: (_) => TimeGroupedByDateCollectionModel(start:start, end:end),
        child: Consumer<TimeGroupedByDateCollectionModel>(
          builder: (context, model, _) => GroupedCollectionListView<TimeModificationModel>(
            groups: model.items,
            headerBuilder: (_, header, __, ___) => _createCollectionHeader(header),
            itemBuilder: (_, item, isLast, __) => TimeCard(
              item: item, 
              isLast: isLast,
              onItemDeleted: () => model.onItemDeleted(item),),
          )
        )
      ),
    );
  }

  Widget _createCollectionHeader(String header) {
    return Container(
      color: AppStyles.lightGrey,
      height: 35,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppStyles.leftMargin),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(header)
          ],
        ),
      )
    );
  }
}

class TimeGroupedByDateCollectionModel extends ChangeNotifier {
  List<TimeByDateModel> _items = [];

  StreamSubscription<Time> _subscription;

  TimeService _timeService;

  TimeGroupedByDateCollectionModel({@required DateTime start, @required DateTime end, TimeService timeService}) {
    _timeService = timeService ?? kiwi.Container().resolve<TimeService>();
    _loadData(start, end);

    _subscription = _timeService.timeUpdatedStream.listen((_) => _loadData(start, end));
  }

  List<TimeByDateModel> get items => _items;

  Future _loadData(DateTime start, DateTime end) async {
    var timeEntries = await _timeService.getTimeEntriesByDate(
      startTime: start, 
      endTime: end);

    var dates = timeEntries.map((t) => t.date.dropTime()).toList();
    dates = dates.toSet().toList();
    
    _items = dates.map((date) => TimeByDateModel(
      timeEntries
        .where((t) => t.date.dropTime() == date)
        .map((t) => TimeModificationModel.edit(time: t))
        .toList(),
      date)
    ).toList();

    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future onItemDeleted(TimeModificationModel item) async {
    await item.delete();
  }
}