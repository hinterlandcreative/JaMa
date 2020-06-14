import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:jama/data/models/time_model.dart';
import 'package:jama/ui/models/time/time_by_date_model.dart';
import 'package:jama/ui/models/time/time_collection.dart';
import 'package:jama/ui/models/time/time_model.dart';
import 'package:jama/ui/screens/scrollable_base_screen.dart';
import 'package:jama/ui/widgets/time_card.dart';
import 'package:jama/ui/widgets/time_report_widget.dart';
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers.dart';

import '../app_styles.dart';
import '../../mixins/duration_mixin.dart';
import 'time_screen.dart';

class TimeListScreen extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;

  const TimeListScreen({Key key, this.startDate, this.endDate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TimeCollectionModel>(
        create: (_) => TimeCollectionModel(startDate, endDate),
        child: Consumer<TimeCollectionModel>(
            builder: (_, model, __) => ScrollableBaseScreen(
                speedDialIcon: AnimatedIcons.menu_close,
                speedDialActions: [
                  SpeedDialChild(
                      child: Icon(Icons.add),
                      label: "add time",
                      labelStyle: AppStyles.heading4,
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TimeScreen.createNew()));
                      }),
                  SpeedDialChild(
                      child: Icon(Icons.clear_all),
                      label: "add bulk time",
                      labelStyle: AppStyles.heading4),
                  SpeedDialChild(
                      child: Icon(Icons.access_alarms),
                      label: "record time",
                      labelStyle: AppStyles.heading4),
                  SpeedDialChild(
                      child: Icon(Icons.show_chart),
                      label: "last month's report",
                      labelStyle: AppStyles.heading4,
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Scaffold(
                                      body: ChangeNotifierProvider<TimeCollectionModel>(
                                          create: (_) {
                                            var now = DateTime.now();
                                            DateTime startDate = DateTime(
                                                now.year, now.month - 1, 1);
                                            DateTime endDate = DateTime(
                                                    now.year, now.month, 1)
                                                .subtract(
                                                    Duration(milliseconds: 1));
                                            return TimeCollectionModel(
                                                startDate, endDate);
                                          },
                                          child: Consumer<TimeCollectionModel>(
                                              builder: (_, model, __) =>
                                                  TimeCardCollection(
                                                    items: model.items,
                                                    onItemDeleted: (t) =>
                                                        model.deleteTime(t),
                                                  ))),
                                    )));
                      }),
                ],
                headerWidget: PreferredSize(
                  preferredSize: Size.fromHeight(66.0),
                  child: Padding(
                      padding: EdgeInsets.only(
                        top: AppStyles.topMargin,
                        left: AppStyles.leftMargin),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Your Time",
                          style: AppStyles.heading1.copyWith(color: Colors.white),
                        ),
                        Text(DateFormat("MMMM y").format(DateTime.now()),
                            style: AppStyles.heading4.copyWith(color: Colors.white))
                      ],
                    ),
                  ),
                ),
                hideFloatingWidgetOnScroll: true,
                floatingWidget: PreferredSize(
                  preferredSize: Size(MediaQuery.of(context).size.width, AppStyles.timeHeaderBoxHeight),
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: AppStyles.leftMargin, 
                        right: MediaQuery.of(context).size.width - 211.0 - AppStyles.leftMargin),
                      child: TimeReportWidget(
                      allHours: model.allHours,
                      goalHours: model.goalHours,
                      placements: model.placements,
                      videos: model.videos,
                      returnVisits: model.returnVisits,
                    ),
                  ),
                ),
                body: Padding(
                  padding: EdgeInsets.only(top: 17.0),
                  child: TimeCardCollection(
                        items: model.items,
                        onItemDeleted: (t) => model.deleteTime(t),
                      ),
                ))));
  }
}

class TimeCardCollection extends StatelessWidget {
  final UnmodifiableListView<TimeByDateModel> items;
  final Function(Time) onItemDeleted;

  const TimeCardCollection(
      {Key key, @required this.items, @required this.onItemDeleted})
      : super(key: key);

  Widget _createCollectionCell(
      BuildContext context, TimeModel item, bool shouldAddBottomBorder) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    TimeScreen(TimeModel(timeModel: item.time.copy()))));
      },
      child: Slidable(
        closeOnScroll: true,
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        secondaryActions: <Widget>[
          IconSlideAction(
            icon: Icons.delete_outline,
            color: Colors.red,
            caption: "delete",
            onTap: () => onItemDeleted(item.time),
          )
        ],
        child: TimeCard(item: item, isLast: shouldAddBottomBorder,),
      ),
    );
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
    for(var section in items) {
      children.add(StickyHeader(
        header: _createCollectionHeader(section),
        content: Column(children: section.items
        .map((item) => _createCollectionCell(
          context, 
          item, 
          item == section.items.last)).toList()),));
    }
    return Column(children: children);
  }
}
