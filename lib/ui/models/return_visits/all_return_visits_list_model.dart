import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:jama/services/location_service.dart';
import 'package:jama/services/return_visit_service.dart';
import 'package:jama/ui/models/return_visits/grouped_return_visit_collection_by_name_model.dart';
import 'package:jama/ui/models/return_visits/return_visit_list_item_model.dart';
import 'package:kiwi/kiwi.dart' as kiwi;

import 'grouped_return_visit_collection_model.dart';

class AllReturnVisitsListModel extends ChangeNotifier {
  final ReturnVisitService rvService;
  final LocationService locationService;

  List<ReturnVisitListItemModel> _returnVisits = [];
  RvGroupedBy _currentGroupedBy = RvGroupedBy.Name;
  GroupedReturnVisitCollection<ReturnVisitListItemModel> _currentGroupedCollection;

  AllReturnVisitsListModel._({this.locationService, this.rvService}) {
    _loadData();
  }

  factory AllReturnVisitsListModel([ReturnVisitService rvService, LocationService locationService]) {
    var container = kiwi.Container();
    return AllReturnVisitsListModel._(
      rvService: rvService ?? container.resolve<ReturnVisitService>(),
      locationService: locationService ?? container.resolve<LocationService>());
  }

  UnmodifiableListView<ReturnVisitListItemModel> get returnVisits => UnmodifiableListView(_returnVisits);

  UnmodifiableListView<ReturnVisitListItemModel> get pinnedReturnVisits => UnmodifiableListView(_returnVisits.where((rv) => rv.isPinned));

  bool get hasItems => _currentGroupedCollection != null && _currentGroupedCollection.items.length > 0;

  GroupedReturnVisitCollection<ReturnVisitListItemModel> get groupedCollection => _currentGroupedCollection;

  List<ReturnVisitListItemModel> search(String query) {
    var results = returnVisits.where((rv) => rv.searchString.toLowerCase().contains(query.toLowerCase())).toList();
    return results;
  }

  Future _loadData() async {
    var position = await locationService.getCurrentOrLastKnownPosition();
    var entries = await rvService.getAllReturnVisits();
    _returnVisits = entries.map((rv) => ReturnVisitListItemModel(
      returnVisit: rv,
      currentLatitude: position.latitude,
      currentLongitude: position.longitude
    )).toList();

    _currentGroupedCollection = GroupedReturnVisitByNameCollection(models: _returnVisits);
    notifyListeners();
  }
}

enum RvGroupedBy {
  Name,
  City,
  Street,
  Distance
}