import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jama/ui/app_styles.dart';

class GoalDisplay extends StatelessWidget {
  /// The current [value] of the goal yet to be saved.
  final int value;

  /// The [text] to display.
  final String text;

  /// The [previous value] of items attributed to the goal.
  final int previousValue;

  /// The value of the [goal].
  final int goalValue;

  /// The function called when the widget is tapped.
  final Function onTap;
  
  const GoalDisplay({Key key, this.value, this.text, this.previousValue, this.goalValue, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap == null ? {} : onTap(),
      child: Container(
        height: 75.00,
        width: 135.00,
        decoration: BoxDecoration(
          color: AppStyles.primaryColor,
          borderRadius: BorderRadius.circular(20.00), 
        ), 
        child: Padding(
          padding: const EdgeInsets.all(7.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    height: 30.00,
                    width: 30.00,
                    decoration: BoxDecoration(
                      color: Color(0xffffffff),
                        shape: BoxShape.circle, 
                    ), 
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: AutoSizeText(
                          value.toString(),
                          minFontSize: 1,
                          style: AppStyles.heading1.copyWith(color: AppStyles.primaryColor),
                        ),
                      ),
                    ),
                  ),
                  if(previousValue != null && goalValue != null) Expanded(
                    child: value + previousValue < goalValue
                      ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Container(
                          color: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 2.0),
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.white,
                            valueColor: AlwaysStoppedAnimation<Color>(AppStyles.lightGrey),
                            value: (value + previousValue) / goalValue
                            ),
                        ),
                      )
                      : Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: FaIcon(FontAwesomeIcons.check, color: Colors.green,),
                          
                        ),
                      )
                  )
                ]
              ),
              Container(height: 5.0,),
              Text(
                text,
                style: AppStyles.smallTextStyle.copyWith(color: Colors.white))
            ]
          ),
        ),
      ),
    );
  }
}