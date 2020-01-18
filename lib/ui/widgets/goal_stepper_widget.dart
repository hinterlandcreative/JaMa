import 'package:flutter/material.dart';
import 'package:jama/ui/widgets/stepper_widget.dart';

import '../app_styles.dart';

class GoalStepper extends StatelessWidget {

  /// the initial value
  final int initialValue;

  /// called when the value has changed.
  final void Function(int) onChanged;

  /// the title of the goal
  final String titleText;

  /// if [false] the bottom goal text will not be shown.
  final bool showGoal;

  /// the text to show for the goal.
  final String goalText;

  
  const GoalStepper({
    this.initialValue,
    this.onChanged,
    this.titleText, 
    this.showGoal = true, 
    this.goalText = "",
    Key key, 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Container(
        height: 135,
        width: 100,
        decoration: BoxDecoration(
            color: AppStyles.primaryColor.withAlpha(150),
            borderRadius: AppStyles.defaultBoxCorner),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(titleText,
                  style: AppStyles.smallTextStyle
                      .copyWith(color: AppStyles.secondaryTextColor)),
            ),
            SizedBox(
                height: 75,
                child: StepperTouch(
                  initialValue: initialValue,
                  minValue: 0,
                  direction: Axis.vertical,
                  onChanged: onChanged,
                ))
          ],
        ),
      ),
      Positioned(
          bottom: 0,
          child: !showGoal ? null : Container(
            height: 30,
            width: 100,
            decoration: BoxDecoration(
                color: AppStyles.primaryColor,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15))),
            child: Center(
                child: Text(goalText,
                    style: AppStyles.smallTextStyle
                        .copyWith(color: AppStyles.secondaryTextColor))),
          ))
    ]);
  }
}