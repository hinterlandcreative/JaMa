import 'dart:collection';

import 'package:jama/data/models/time_model.dart';
import 'package:jama/ui/models/collection_base_model.dart';
import 'package:jama/services/time_service.dart';
import 'package:kiwi/kiwi.dart';

class TimeCollectionModel extends CollectionBaseModel<Time> {
  List<Time> _items = [];

  TimeService _timeService;

  TimeCollectionModel([TimeService timeService]) {
    Container container = Container();
  
    _timeService = timeService ?? container.resolve<TimeService>();
  }

  @override
  UnmodifiableListView<Time> get items => UnmodifiableListView(_items);

  @override
  Future loadChildren() {
    return loadChildrenByDate();
  }
  
  /// load children items based on a start and end date.
  Future loadChildrenByDate({DateTime start, DateTime end}) async {
    _items = await _timeService.getTimeEntriesByDate(startTime: start, endTime: end);
    
    notifyListeners();
  }

  Future saveOrUpdate(Time model) async {
    model = await _timeService.saveOrAddTime(model);
    var i = _items.indexWhere((t) => t.id == model.id);
    if(i == -1) {
      // item not found
      // find where to insert new time based on date.
      i = _items.indexWhere((t) => t.date > model.date);
      if(i == -1) {
        _items.add(model);
      } else {
        _items.insert(i, model);
      }
    } else {
      // item found. replace it.
      _items[i] = model;
    }

    notifyListeners();
  }
}