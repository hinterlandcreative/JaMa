import 'package:flutter/material.dart';
import '../app_styles.dart';

class TimelineTitle extends StatelessWidget {
  final bool isFirst;
  final String title;
  final String subtitle;
  
  const TimelineTitle({
    Key key, @required this.title, this.subtitle, this.isFirst = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 18.5),
      child: Container(
        height: 37,
        decoration: BoxDecoration(
          border: Border(left: isFirst
          ? BorderSide.none
          : BorderSide(width: 3.0, color: AppStyles.lightGrey))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              title, 
              style: AppStyles.smallTextStyle.copyWith(
                color: AppStyles.captionText,
                fontWeight: FontWeight.bold)),
            if(subtitle != null && subtitle.isNotEmpty) Padding(padding: EdgeInsets.only(left: 2.0),),
            if(subtitle != null && subtitle.isNotEmpty) Text(subtitle, style: AppStyles.smallTextStyle.copyWith(color: AppStyles.captionText)),
          ],
        ),
      ),
    );
  }
}