import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_tableview/flutter_tableview.dart';
import 'package:intl/intl.dart';
import 'package:jama/ui/models/time/time_collection.dart';
import 'package:jama/ui/models/time/time_model.dart';
import 'package:jama/ui/widgets/time_report_widget.dart';
import 'package:provider/provider.dart';

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
    return Scaffold(
        floatingActionButton: SpeedDial(
          foregroundColor: AppStyles.secondaryBackground,
          backgroundColor: Colors.white,
          animatedIcon: AnimatedIcons.menu_close,
          marginBottom:
              MediaQuery.of(context).size.height - AppStyles.headerHeight - 28,
          overlayColor: AppStyles.speedDialOverlayColor,
          overlayOpacity: 0.7,
          orientation: SpeedDialOrientation.Down,
          children: [
            SpeedDialChild(
                child: Icon(Icons.add),
                label: "add time",
                labelStyle: AppStyles.heading4,
                onTap: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => TimeScreen()));
                }),
            SpeedDialChild(
                child: Icon(Icons.clear_all),
                label: "add bulk time",
                labelStyle: AppStyles.heading4),
            SpeedDialChild(
                child: Icon(Icons.access_alarms),
                label: "record time",
                labelStyle: AppStyles.heading4),
          ],
        ),
        body: ChangeNotifierProvider<TimeCollectionModel>(
      create: (_) => TimeCollectionModel(startDate, endDate),
      child: Consumer<TimeCollectionModel>(
          builder: (_, model, __) => Container(
                color: AppStyles.primaryColor,
                child: SafeArea(
                  bottom: false,
                  child: Stack(children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                          top: AppStyles.headerHeight -
                              MediaQuery.of(context).padding.top),
                      child: Container(
                        color: AppStyles.primaryBackground,
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                            top: AppStyles.topMargin,
                            left: AppStyles.leftMargin),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Your Time",
                              style: AppStyles.heading1
                                  .copyWith(color: Colors.white),
                            ),
                            Text(DateFormat("MMMM y").format(DateTime.now()),
                                style: AppStyles.heading4
                                    .copyWith(color: Colors.white))
                          ],
                        )),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            top: AppStyles.headerHeight -
                                (AppStyles.timeHeaderBoxHeight / 2) -
                                MediaQuery.of(context).padding.top,
                          ),
                          child: Padding(
                            padding:
                                EdgeInsets.only(left: AppStyles.leftMargin),
                            child: TimeReportWidget(
                              allHours: model.allHours,
                              goalHours: model.goalHours,
                              placements: model.placements,
                              videos: model.videos,
                              returnVisits: model.returnVisits,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: AppStyles.leftMargin),
                        ),
                        Expanded(
                            child: model.items.length <= 0
                                ? Container()
                                : FlutterTableView(
                                    sectionCount: model.items.length,
                                    rowCountAtSection: (section) =>
                                        model.items[section].items.length,
                                    cellHeight: (context, section, row) => 91,
                                    sectionHeaderHeight: (context, section) =>
                                        35,
                                    sectionHeaderBuilder:
                                        (context, sectionIndex) {
                                      var section = model.items[sectionIndex];
                                      return Container(
                                          color: AppStyles.lightGrey,
                                          height: 35,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    AppStyles.leftMargin),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text(DateFormat.EEEE()
                                                    .format(section.date)),
                                                Text(DateFormat.yMMMd()
                                                    .format(section.date))
                                              ],
                                            ),
                                          ));
                                    },
                                    cellBuilder: (context, section, row) {
                                      var item =
                                          model.items[section].items[row];
                                      var last =
                                          model.items[section].items.last;

                                      return InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      TimeScreen(TimeModel(
                                                          timeModel:
                                                              item.time))));
                                        },
                                        child: Column(
                                          children: <Widget>[
                                            Container(
                                              alignment: Alignment.topLeft,
                                              height: 80,
                                              padding: EdgeInsets.only(
                                                  left: AppStyles.leftMargin,
                                                  top: AppStyles.leftMargin),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 4.0),
                                                    child: Container(
                                                      height: 18,
                                                      width: 18,
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              width: 1,
                                                              color: AppStyles
                                                                  .captionText),
                                                          color: item.time
                                                              .category.color),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        Text(
                                                          "9:30 AM - 12:30 PM",
                                                          style: AppStyles
                                                              .heading2,
                                                        ),
                                                        Text(
                                                          item.time.category
                                                              .name,
                                                          style: AppStyles
                                                              .smallTextStyle,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(child: Container()),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        right: AppStyles
                                                            .leftMargin),
                                                    child: Text(
                                                      item.time.duration
                                                          .toShortString(),
                                                      style: AppStyles.heading2,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: 35.0,
                                                  right: 35.0,
                                                  top: 10),
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                      border: item == last
                                                          ? null
                                                          : Border(
                                                              bottom: BorderSide(
                                                                  width: 1,
                                                                  color: Colors
                                                                          .grey[
                                                                      300])))),
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  ))
                      ],
                    ),
                  ]),
                ),
              )),
    ));
  }
}