import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:jama/mixins/color_mixin.dart';
import 'package:jama/ui/app_styles.dart';
import 'package:jama/ui/models/goal_model.dart';
import 'package:jama/ui/models/home_model.dart';
import 'package:jama/ui/screens/time_screen.dart';
import 'package:jama/ui/widgets/time_chart_widget.dart';
import 'package:provider/provider.dart';
import 'package:slider_button/slider_button.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: SpeedDial(
        foregroundColor: AppStyles.secondaryBackground,
        backgroundColor: Colors.white,
        animatedIcon: AnimatedIcons.menu_close,
        marginBottom:
            MediaQuery.of(context).size.height - AppStyles.headerHeight - 28,
        overlayColor: HexColor.fromHex("#9F9F9F"),
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
              child: Icon(Icons.access_alarms),
              label: "record time",
              labelStyle: AppStyles.heading4),
          SpeedDialChild(
              child: Icon(Icons.group_add),
              label: "add return visit",
              labelStyle: AppStyles.heading4),
        ],
      ),
      body: ChangeNotifierProvider<HomeModel>(
        create: (_) => HomeModel(),
        child: Consumer<HomeModel>(
          builder: (_, model, __) => Container(
            color: AppStyles.secondaryBackground,
            child: SafeArea(
              bottom: false,
              child: Stack(
                children: <Widget>[
                  Container(
                    height: AppStyles.headerHeight,
                    color: AppStyles.secondaryBackground,
                  ),
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            top: AppStyles.topMargin,
                            left: AppStyles.leftMargin),
                        child: Column(
                          children: <Widget>[
                            Text(
                              "Home",
                              style: AppStyles.heading1
                                  .copyWith(color: Colors.white),
                            ),
                            Text(DateFormat("MMMM y").format(DateTime.now()),
                                style: AppStyles.heading4
                                    .copyWith(color: Colors.white))
                          ],
                        ),
                      )
                    ],
                  ),
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
                        top: AppStyles.headerHeight -
                            (AppStyles.timeHeaderBoxHeight / 2) -
                            MediaQuery.of(context).padding.top,
                        left: AppStyles.leftMargin),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          height: AppStyles.timeHeaderBoxHeight,
                          width: AppStyles.timeHeaderBoxWidth,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: AppStyles.defaultBoxCorner,
                              boxShadow: [AppStyles.defaultBoxShadow]),
                          child: Row(
                            children: <Widget>[
                              TimeChartWidget.fromTimeSeries(
                                  model.allHours, model.goalHours,
                                  width: AppStyles.defaultChartHeight,
                                  height: AppStyles.defaultChartWidth,
                                  textStyle: AppStyles.heading2),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                verticalDirection: VerticalDirection.down,
                                children: <Widget>[
                                  Text(model.placements.toString(),
                                      style: AppStyles.heading2),
                                  Text(
                                    "placements",
                                    style: AppStyles.smallTextStyle,
                                  ),
                                  Text(model.videos.toString(),
                                      style: AppStyles.heading2),
                                  Text(
                                    "videos",
                                    style: AppStyles.smallTextStyle,
                                  ),
                                  Text(model.returnVisits.toString(),
                                      style: AppStyles.heading2),
                                  Text(
                                    "return visits",
                                    style: AppStyles.smallTextStyle,
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: AppStyles.leftMargin,
                        right: AppStyles.leftMargin,
                        top: (AppStyles.headerHeight -
                                MediaQuery.of(context).padding.top) +
                            (AppStyles.timeHeaderBoxHeight / 2) +
                            35),
                    child: Column(
                      children: <Widget>[
                        SliderButton(
                          backgroundColor: AppStyles.secondaryBackground,
                          shimmer: false,
                          buttonColor: Colors.white,
                          highlightedColor: Colors.white,
                          baseColor: Colors.white,
                          width: MediaQuery.of(context).size.width -
                              (AppStyles.leftMargin * 2),
                          action: () {
                            // TODO: implement send report
                          },
                          label: Text(
                              "Send " +
                                  DateFormat("MMMM").format(DateTime.now()) +
                                  " Report",
                              style: AppStyles.heading2
                                  .copyWith(color: Colors.white)),
                          icon: Center(
                            child: Icon(
                              Icons.send,
                              color: AppStyles.secondaryBackground,
                            ),
                          ),
                        ),
                        Expanded(
                          child: model.goals.length > 0
                              ? ListView.builder(
                                  itemCount: model.goals.length,
                                  itemBuilder: (context, index) {
                                    return GoalWidget(goal: model.goals[index]);
                                  },
                                )
                              : Center(
                                  child: FlatButton(
                                  color: AppStyles.lightGrey,
                                  child: Text(
                                    "add some goals",
                                    style: AppStyles.heading4
                                        .copyWith(color: Colors.black),
                                  ),
                                  onPressed: () {},
                                )),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GoalWidget extends StatelessWidget {
  const GoalWidget({
    Key key,
    @required this.goal,
  }) : super(key: key);

  final GoalModel goal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 27),
      child: Container(
        height: 95,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppStyles.defaultBoxCorner,
            boxShadow: [AppStyles.defaultBoxShadow]),
        child: Padding(
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 16),
          child: Stack(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Image(
                    width: 26,
                    height: 26,
                    fit: BoxFit.contain,
                    image: AssetImage(goal.iconPath),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image(
                        width: 15,
                        height: 30,
                        image: AssetImage("graphics/arrow.png"),
                      ),
                    ],
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: 40, right: 32),
                child: Text(
                  goal.text,
                  style: AppStyles.heading4,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
