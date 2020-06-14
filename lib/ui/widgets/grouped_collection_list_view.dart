import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:jama/ui/models/grouped_collection_base_model.dart';
import 'package:sticky_headers/sticky_headers.dart';

/// A list view that 
class GroupedCollectionListView<T> extends StatelessWidget {
  /// If [true] the headers will be sticky while scrolled.
  final bool useStickyHeaders;

  /// The [groups] for the collection list view.
  final List<GroupedCollection<T>> groups;

  /// The builder for the header of a group.
  /// [isLast] is true if this is the last header and [isFirst] is true if it's the first header.
  final Widget Function(BuildContext context, String header, bool isLast, bool isFirst) headerBuilder;

  /// The builder for each item of a group.
  /// [isLast] is true if this is the last item and [isFirst] is true if it's the first item.
  final Widget Function(BuildContext context, T item, bool isLast, bool isFirst) itemBuilder;

  const GroupedCollectionListView({Key key, @required this.groups, @required this.headerBuilder, @required this.itemBuilder, this.useStickyHeaders = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: groups == null || groups.isEmpty
        ? Container()
        : _buildGroups(),
    );
  }

  Widget _buildGroups() {
    return ListView.builder(
      itemCount: groups.length,
      itemBuilder: (context, index) => Column(children: useStickyHeaders
        ? _buildStickyGroup(
          context, 
          groups[index], 
          index == groups.length - 1, 
          index == 0)
        : <Widget>[
          headerBuilder(
            context, 
            groups[index].header, 
            index == groups.length - 1, 
            index == 0)
        ] +
          _buildItemListForGroup(groups[index].items, context)
      ),
    );
  }

  List<Widget> _buildItemListForGroup(UnmodifiableListView<T> items, BuildContext context) {
    return items
          .map((item) => itemBuilder(
            context,
            item, 
            items.last == item, 
            items.first == item))
          .toList();
  }

  List<Widget> _buildStickyGroup(BuildContext context, GroupedCollection<T> group, bool isLast, bool isFirst) {
    return <Widget>[StickyHeader(
      header: headerBuilder(context, group.header, isLast, isFirst),
      content: Column(children: 
        _buildItemListForGroup(group.items, context),),
    )];
  }
}