import 'dart:collection';

import 'package:intl/intl.dart';
import 'package:jama/ui/models/grouped_collection_base_model.dart';
import 'package:jama/ui/models/time/time_model.dart';

class TimeByDateModel extends GroupedCollection<TimeModel> {

  final List<TimeModel> _items;
  final DateTime date;

  TimeByDateModel(this._items, this.date) : super(DateFormat.yMMMMd(Intl.defaultLocale).format(date), UnmodifiableListView(_items));

  @override
  UnmodifiableListView<TimeModel> get items => UnmodifiableListView(_items);

  @override
  Future loadChildren() {
    return Future.value(0);
  }

}