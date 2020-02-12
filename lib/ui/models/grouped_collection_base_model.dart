import 'dart:collection';

abstract class GroupedCollection<TModel> {

  /// The [header] string to display for the group.
  final String header;

  /// The [items] of the group in type [TModel]
  final UnmodifiableListView<TModel> items;

  GroupedCollection(this.header, this.items);
}