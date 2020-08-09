import 'dart:collection';

import 'package:intl/intl.dart';
import 'package:jama/ui/models/grouped_collection_base_model.dart';
import 'package:jama/ui/models/time/time_modification_model.dart';

class TimeByDateModel extends GroupedCollection<TimeModificationModel> {

  final List<TimeModificationModel> _items;
  final DateTime date;
  
  TimeByDateModel(this._items, this.date) : super(DateFormat.MMMMEEEEd(Intl.defaultLocale).format(date), UnmodifiableListView(_items));

  @override
  UnmodifiableListView<TimeModificationModel> get items => UnmodifiableListView(_items);

  Future loadChildren() {
    return Future.value(0);
  }

}