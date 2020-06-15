import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:jama/data/models/time_model.dart';

import 'package:jama/ui/app_styles.dart';
import 'package:jama/ui/models/time/time_model.dart';
import 'package:jama/mixins/duration_mixin.dart';
import 'package:jama/ui/screens/time/add_time_screen.dart';

class TimeCard extends StatelessWidget {
  final TimeModel item;
  final bool isLast;
  final Function(Time) onItemDeleted;
  
  const TimeCard({
    Key key, 
    @required this.item, 
    @required this.isLast, 
    @required this.onItemDeleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
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
        child:  GestureDetector(
        onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      TimeScreen(TimeModel(timeModel: item.time.copy())))),
        child: Column(
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
        ),
      ),
    );
  }
}