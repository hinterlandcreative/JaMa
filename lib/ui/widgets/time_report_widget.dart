import 'package:flutter/material.dart';
import 'package:jama/ui/models/time/time_category_model.dart';

import '../widgets/time_chart_widget.dart';
import '../app_styles.dart';

class TimeReportWidget extends StatelessWidget {
  final List<TimeByCategoryModel> allHours;
  final int goalHours, placements, videos, returnVisits;
  const TimeReportWidget({
    Key key, 
    this.allHours, 
    this.goalHours, 
    this.placements, 
    this.videos, 
    this.returnVisits}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppStyles.timeHeaderBoxHeight,
      width: AppStyles.timeHeaderBoxWidth,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppStyles.defaultBoxCorner,
          boxShadow: [AppStyles.defaultBoxShadow]),
      child: Row(
        children: <Widget>[
          TimeChartWidget.fromTimeSeries(
              allHours, goalHours,
              width: AppStyles.defaultChartHeight,
              height: AppStyles.defaultChartWidth,
              textStyle: AppStyles.heading2),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 11.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(placements.toString(),
                    style: AppStyles.heading2),
                Text(
                  "placements",
                  style: AppStyles.smallTextStyle,
                ),
                Text(videos.toString(),
                    style: AppStyles.heading2),
                Text(
                  "videos",
                  style: AppStyles.smallTextStyle,
                ),
                Text(returnVisits.toString(),
                    style: AppStyles.heading2),
                Text(
                  "return visits",
                  style: AppStyles.smallTextStyle,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}