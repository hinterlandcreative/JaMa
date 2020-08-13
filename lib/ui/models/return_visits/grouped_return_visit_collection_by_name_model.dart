import 'dart:collection';
import 'dart:math';

import 'package:jama/data/models/dto/return_visit_dto.dart';
import 'package:jama/ui/models/return_visits/return_visits_by_name_model.dart';
import 'package:jama/ui/models/grouped_collection_base_model.dart';
import 'package:jama/ui/models/return_visits/grouped_return_visit_collection_model.dart';
import 'package:jama/ui/models/return_visits/return_visit_list_item_model.dart';

class GroupedReturnVisitByNameCollection
    extends GroupedReturnVisitCollection<ReturnVisitListItemModel> {
  static const List<String> _women = [
    "🙋‍♀️",
    "🙋🏻‍♀️",
    "🙋🏼‍♀️",
    "🙋🏽‍♀️",
    "🙋🏾‍♀️",
    "🙋🏿‍♀️"
  ];

  static const List<String> _men = [
    "🙋‍♂️",
    "🙋🏻‍♂️",
    "🙋🏼‍♂️",
    "🙋🏽‍♂️",
    "🙋🏾‍♂️",
    "🙋🏿‍♂️",
  ];

  final List<ReturnVisitListItemModel> returnVisitModels;
  final List<GroupedCollection<ReturnVisitListItemModel>> _items = [];

  GroupedReturnVisitByNameCollection._(this.returnVisitModels) {
    loadChildren();
  }

  factory GroupedReturnVisitByNameCollection({List<ReturnVisitListItemModel> models}) {
    return GroupedReturnVisitByNameCollection._(models);
  }

  @override
  UnmodifiableListView<GroupedCollection<ReturnVisitListItemModel>> get items =>
      UnmodifiableListView(_items);

  @override
  Future loadChildren() async {
    Map<String, ReturnVisitsByNameModel> items = {};
    items[Gender.Male.toString()] =
        ReturnVisitsByNameModel(header: _getRandomManEmoji(), items: UnmodifiableListView([]));
    items[Gender.Female.toString()] =
        ReturnVisitsByNameModel(header: _getRandomGirlEmoji(), items: UnmodifiableListView([]));

    for (var rvModel in returnVisitModels) {
      if (rvModel.hasEmptyName) {
        items[rvModel.gender.toString()] = ReturnVisitsByNameModel(
            header: items[rvModel.gender.toString()].header,
            items:
                UnmodifiableListView(items[rvModel.gender.toString()].items.toList() + [rvModel]));
      } else {
        var letter = rvModel.nameOrDescription.substring(0, 1).toUpperCase();
        if (items.containsKey(letter)) {
          items[letter] = ReturnVisitsByNameModel(
              header: letter,
              items: UnmodifiableListView(items[letter].items.toList() + [rvModel]));
        } else {
          items[letter] =
              ReturnVisitsByNameModel(header: letter, items: UnmodifiableListView([rvModel]));
        }
      }
    }

    _items.addAll(items.entries.where((i) => i.value.items.isNotEmpty).map((e) => e.value));
    notifyListeners();
  }

  String _getRandomManEmoji() {
    var rand = Random();
    return _men[rand.nextInt(_men.length)];
  }

  String _getRandomGirlEmoji() {
    var rand = Random();
    return _women[rand.nextInt(_women.length)];
  }
}
