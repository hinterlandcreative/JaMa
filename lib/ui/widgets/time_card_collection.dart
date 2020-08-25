import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:jama/ui/models/time/time_modification_model.dart';
import 'package:sticky_headers/sticky_headers.dart';

import 'package:jama/ui/models/time/time_by_date_model.dart';
import 'package:jama/ui/widgets/time_card.dart';
import 'package:jama/ui/app_styles.dart';

class TimeCardCollection extends StatelessWidget {
  final UnmodifiableListView<TimeByDateModel> items;
  final Function(TimeModificationModel) onItemDeleted;

  const TimeCardCollection({Key key, @required this.items, @required this.onItemDeleted})
      : super(key: key);

  Widget _createCollectionCell(
      BuildContext context, TimeModificationModel item, bool shouldAddBottomBorder) {
    return TimeCard(
        item: item, isLast: shouldAddBottomBorder, onItemDeleted: () => onItemDeleted(item));
  }

  Widget _createCollectionHeader(TimeByDateModel section) {
    return Container(
        color: AppStyles.lightGrey,
        height: 35,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppStyles.leftMargin),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(DateFormat.EEEE().format(section.date)),
              Text(DateFormat.yMMMd().format(section.date))
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[];
    for (var section in items) {
      children.add(StickyHeader(
        header: _createCollectionHeader(section),
        content: Column(
            children: section.items
                .map((item) => _createCollectionCell(context, item, item == section.items.last))
                .toList()),
      ));
    }
    return Column(children: children);
  }
}
