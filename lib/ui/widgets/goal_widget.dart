import 'package:flutter/material.dart';
import 'package:jama/ui/models/goal_model.dart';

import '../app_styles.dart';

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