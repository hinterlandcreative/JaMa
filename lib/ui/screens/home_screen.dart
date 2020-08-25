import 'package:commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:jama/ui/app_styles.dart';
import 'package:jama/ui/models/home_model.dart';
import 'package:jama/ui/models/reports/send_current_report_model.dart';
import 'package:jama/ui/screens/return_visits/add_return_visit_screen.dart';
import 'package:jama/ui/screens/scrollable_base_screen.dart';
import 'package:jama/ui/screens/time/add_edit_time_screen.dart';
import 'package:jama/ui/widgets/goal_widget.dart';
import 'package:jama/ui/widgets/time_report_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:slider_button/slider_button.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeModel>(
        create: (_) => HomeModel(),
        child: Consumer<HomeModel>(
            builder: (_, model, __) => ScrollableBaseScreen(
                  speedDialIcon: AnimatedIcons.menu_close,
                  speedDialActions: [
                    SpeedDialChild(
                        child: Icon(Icons.add),
                        label: "add time",
                        labelStyle: AppStyles.heading4,
                        onTap: () {
                          showBarModalBottomSheet(
                              context: context,
                              builder: (context, _) => AddEditTimeScreen.create());
                        }),
                    SpeedDialChild(
                        child: Icon(Icons.access_alarms),
                        label: "record time",
                        labelStyle: AppStyles.heading4),
                    SpeedDialChild(
                        child: Icon(Icons.group_add),
                        label: "add return visit",
                        labelStyle: AppStyles.heading4,
                        onTap: () {
                          showBarModalBottomSheet(
                              context: context, builder: (context, _) => AddReturnVisitScreen());
                        }),
                  ],
                  headerWidget: PreferredSize(
                    preferredSize: Size.fromHeight(66.0),
                    child: Padding(
                      padding:
                          EdgeInsets.only(top: AppStyles.topMargin, left: AppStyles.leftMargin),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Home",
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
                    preferredSize:
                        Size(MediaQuery.of(context).size.width, AppStyles.timeHeaderBoxHeight),
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
                    padding: EdgeInsets.only(
                        top: 35.0, left: AppStyles.leftMargin, right: AppStyles.leftMargin),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ChangeNotifierProvider<SendCurrentReportModel>(
                          create: (_) => SendCurrentReportModel(),
                          child: Consumer<SendCurrentReportModel>(
                            builder: (_, sendReportModel, __) => SliderButton(
                              backgroundColor: AppStyles.secondaryBackground,
                              shimmer: false,
                              dismissible: false,
                              buttonColor: Colors.white,
                              highlightedColor: Colors.white,
                              baseColor: Colors.white,
                              width: MediaQuery.of(context).size.width - (AppStyles.leftMargin * 2),
                              action: sendReportModel.sendReport,
                              label: Text(sendReportModel.lastReportString,
                                  style: AppStyles.heading2.copyWith(color: Colors.white)),
                              icon: Center(
                                child: Icon(
                                  Icons.send,
                                  color: AppStyles.secondaryBackground,
                                ),
                              ),
                            ),
                          ),
                        ),
                        model.goals.length > 0
                            ? ListView.builder(
                                shrinkWrap: true,
                                itemCount: model.goals.length,
                                itemBuilder: (context, index) {
                                  return GoalWidget(goal: model.goals[index]);
                                },
                              )
                            : Center(
                                heightFactor: 2.0,
                                child: FlatButton(
                                  color: AppStyles.lightGrey,
                                  child: Text(
                                    "add some goals",
                                    style: AppStyles.heading4.copyWith(color: Colors.black),
                                  ),
                                  onPressed: () {
                                    // TODO: how to enable goals?
                                  },
                                ))
                      ],
                    ),
                  ),
                )));
  }
}
