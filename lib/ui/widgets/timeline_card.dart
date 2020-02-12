import 'package:flutter/material.dart';

import '../app_styles.dart';

class TimelineCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Icon icon;
  final Color iconColor;
  final bool isFirst;
  final bool isLast;
  const TimelineCard({
    Key key, 
    this.title, 
    this.children, 
    this.icon, 
    this.iconColor, 
    this.isFirst = false, 
    this.isLast = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 135, minHeight: 64),
      child: Row(children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
          if(children != null) Flexible(
            flex: 1,
            child: Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Container(width: isFirst ? 0.0 : 3.0, color: AppStyles.lightGrey,),
          ),),
           Container(
            height: 40.0,
            width: 40.0,
            decoration: BoxDecoration(
              color: iconColor ?? AppStyles.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(child: icon ?? Icon(Icons.star, color: Colors.white),)
          ),
          if(children != null) Flexible(
            flex: 1,
            child: Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Container(width: isLast ? 0.0 : 3.0, color: AppStyles.lightGrey,),
          ),),
        ],),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: AppStyles.leftMargin),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if(title != null) Padding(
                  padding: EdgeInsets.only(bottom: children == null ? 0.0 : 6.0),
                  child: Text(
                    title ?? "",    
                    style: AppStyles.smallTextStyle.copyWith(color: AppStyles.captionText),
                  ),
                ),
                if(children != null) Container(
                    decoration: BoxDecoration(
                      color: Color(0xffffffff),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(1.00,1.00),
                          color: Color(0xff000000).withOpacity(0.16),
                          blurRadius: 15,
                        ),
                      ], 
                      borderRadius: BorderRadius.circular(10.00),),
                    child: Padding(
                      padding: EdgeInsets.all(13.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: children),
                    ), 
                  ),
                  if(title != null && children != null) Padding(padding: EdgeInsets.only(bottom: 25.0),)
              ],
            ),
          ),
        ),
      ],),
    );
  }
}