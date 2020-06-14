import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:jama/ui/app_styles.dart';
import 'package:jama/ui/models/time/time_model.dart';
import 'package:jama/mixins/duration_mixin.dart';

class TimeCard extends StatelessWidget {
  final TimeModel item;
  final bool isLast;
  
  const TimeCard({
    Key key, 
    this.item, 
    this.isLast,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          alignment: Alignment.topLeft,
          height: 80,
          padding: EdgeInsets.only(
              left: AppStyles.leftMargin, top: AppStyles.leftMargin),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: Container(
                  height: 18,
                  width: 18,
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: 1, color: AppStyles.captionText),
                      color: item.time.category.color),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "${DateFormat.jm().format(item.time.formattedDate)} - ${DateFormat.jm().format(item.time.formattedDate.add(item.time.duration))}",
                      style: AppStyles.heading2,
                    ),
                    Text(
                      item.time.category.name,
                      style: AppStyles.smallTextStyle,
                    ),
                  ],
                ),
              ),
              Expanded(child: Container()),
              Padding(
                padding: EdgeInsets.only(right: AppStyles.leftMargin),
                child: Text(
                  item.time.duration.toShortString(),
                  style: AppStyles.heading2,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 35.0, right: 35.0, top: 10),
          child: Container(
              decoration: BoxDecoration(
                  border: isLast
                      ? null
                      : Border(
                          bottom: BorderSide(
                              width: 1, color: Colors.grey[300])))),
        )
      ],
    );
  }
}