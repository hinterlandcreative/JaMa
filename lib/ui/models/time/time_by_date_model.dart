import 'dart:collection';

import 'package:jama/ui/models/collection_base_model.dart';
import 'package:jama/ui/models/time/time_model.dart';

class TimeByDateModel extends CollectionBaseModel<TimeModel> {

  final List<TimeModel> _items;
  final DateTime date;

  TimeByDateModel(this._items, this.date);

  @override
  UnmodifiableListView<TimeModel> get items => UnmodifiableListView(_items);

  @override
  Future loadChildren() {
    return Future.value(0);
  }

}