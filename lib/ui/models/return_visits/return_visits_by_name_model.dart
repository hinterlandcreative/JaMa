import 'dart:collection';

import 'package:jama/ui/models/grouped_collection_base_model.dart';
import 'package:jama/ui/models/return_visits/return_visit_list_item_model.dart';

class ReturnVisitsByNameModel extends GroupedCollection<ReturnVisitListItemModel> {
  ReturnVisitsByNameModel({String header, UnmodifiableListView<ReturnVisitListItemModel> items}) : super(header, items);
}