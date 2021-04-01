import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:jama/services/image_service.dart';
import 'package:jama/services/location_service.dart';
import 'package:jama/services/return_visit_service.dart';
import 'package:jama/ui/models/return_visits/grouped_return_visit_collection_by_name_model.dart';
import 'package:jama/ui/models/return_visits/return_visit_list_item_model.dart';
import 'package:kiwi/kiwi\.dart';

import 'grouped_return_visit_collection_model.dart';

class AllReturnVisitsListModel extends ChangeNotifier {
  final ReturnVisitService rvService;
  final LocationService _locationService;

  List<ReturnVisitListItemModel> _returnVisits = [];
  RvGroupedBy _currentGroupedBy = RvGroupedBy.Name;
  GroupedReturnVisitCollection<ReturnVisitListItemModel> _currentGroupedCollection;

  StreamSubscription _rvUpdatesSubscription;

  AllReturnVisitsListModel._(this._locationService, this.rvService) {
    _loadData();
    _rvUpdatesSubscription = rvService.returnVisitUpdates.listen((_) => _loadData());
  }

  factory AllReturnVisitsListModel(
      [ReturnVisitService rvService, LocationService locationService, ImageService imageService]) {
    var container = KiwiContainer();
    return AllReturnVisitsListModel._(locationService ?? container.resolve<LocationService>(),
        rvService ?? container.resolve<ReturnVisitService>());
  }

  UnmodifiableListView<ReturnVisitListItemModel> get returnVisits =>
      UnmodifiableListView(_returnVisits);

  UnmodifiableListView<ReturnVisitListItemModel> get pinnedReturnVisits =>
      UnmodifiableListView(_returnVisits.where((rv) => rv.isPinned));

  bool get hasItems =>
      _currentGroupedCollection != null && _currentGroupedCollection.items.length > 0;

  GroupedReturnVisitCollection<ReturnVisitListItemModel> get groupedCollection =>
      _currentGroupedCollection;

  @override
  void dispose() {
    _rvUpdatesSubscription.cancel();
    super.dispose();
  }

  List<ReturnVisitListItemModel> search(String query) {
    var results = returnVisits
        .where((rv) => rv.searchString.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return results;
  }

  Future _loadData() async {
    var position = await _locationService.getCurrentOrLastKnownPosition();
    var entries = await rvService.getAllReturnVisits();

    _returnVisits = entries
        .map((rv) => ReturnVisitListItemModel(
              returnVisit: rv,
              currentLatitude: position.latitude,
              currentLongitude: position.longitude,
            ))
        .toList();

    _currentGroupedCollection = GroupedReturnVisitByNameCollection(models: _returnVisits);
    notifyListeners();
  }
}

enum RvGroupedBy { Name, City, Street, Distance }
