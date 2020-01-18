import 'package:commons/commons.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:jama/ui/models/time/time_model.dart';
import 'package:jama/ui/widgets/goal_stepper_widget.dart';
import 'package:jama/ui/widgets/time_selection_slider.dart';
import 'package:provider/provider.dart';

import '../app_styles.dart';

class TimeScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ChangeNotifierProvider(
            create: (_) => TimeModel(),
            child: Consumer<TimeModel>(
                builder: (_, model, __) => Container(
                    color: AppStyles.secondaryBackground,
                    child: SafeArea(
                      bottom: false,
                      child: Stack(
                        children: <Widget>[
                          Padding(
                            padding:
                                EdgeInsets.only(top: AppStyles.headerHeight),
                            child: Container(
                              color: AppStyles.primaryBackground,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: AppStyles.topMargin),
                            child: Row(
                              children: <Widget>[
                                BackButton(
                                  color: AppStyles.secondaryTextColor,
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                Text(
                                  "Add Time",
                                  style: AppStyles.heading1.copyWith(
                                      color: AppStyles.secondaryTextColor),
                                ),
                              ],
                            ),
                          ),
                          Container(
                              alignment: Alignment.bottomCenter,
                              height: AppStyles.headerHeight,
                              child: DatePickerTimeline(
                                model.time.formattedDate,
                                inactiveTextColor: AppStyles.lightGrey.withAlpha(80),
                                selectionColor: Colors.white,
                                onDateChange: (date) {
                                  model.setDate(date);
                                },
                              )),
                          Padding(
                            padding:
                                EdgeInsets.only(top: AppStyles.headerHeight),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: 20, left: 20, right: 20),
                                      child:
                                          TimeSelectionSlider(model: model),
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 20, bottom: 20),
                                          child: Text("Category",
                                              style: AppStyles.heading4),
                                        ),
                                        ConstrainedBox(
                                          constraints: BoxConstraints.expand(height: 100, width: MediaQuery.of(context).size.width - 190),
                                          child: GridView.count(
                                              crossAxisSpacing: 4,
                                              crossAxisCount: 2,
                                              children: model.categories
                                                  .map((category) => Container(
                                                    alignment: Alignment.topLeft,
                                                    child: ChoiceChip(
                                                          label: Text(
                                                            category.name,
                                                            style: AppStyles
                                                                .smallTextStyle
                                                                .copyWith(
                                                                    color: AppStyles
                                                                        .secondaryTextColor),
                                                          ),
                                                          backgroundColor:
                                                              category.color
                                                                  .withAlpha(80),
                                                          selectedColor:
                                                              category.color,
                                                          selected: model.time
                                                                  .category.id ==
                                                              category.id,
                                                          onSelected: (selected) {
                                                            if (selected) {
                                                              model.setCategory(category);
                                                            }
                                                          },
                                                        ),
                                                  ))
                                                  .toList()),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: AppStyles.leftMargin,
                                      vertical: 10),
                                  child: Text("Goals",
                                      style: AppStyles.heading4),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: AppStyles.leftMargin),
                                  child: Row(
                                    children: <Widget>[
                                      Selector<TimeModel, int>(
                                          selector: (_, m) =>
                                              m.time.placements,
                                          builder: (_, placements, __) =>
                                              GoalStepper(
                                                initialValue: placements,
                                                titleText: "placements",
                                                goalText:
                                                    model.placementsGoal,
                                                onChanged: (val) =>
                                                    model.setPlacements(val),
                                              )),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: AppStyles.leftMargin),
                                        child: Selector<TimeModel, int>(
                                            selector: (_, m) => m.time.videos,
                                            builder: (_, videos, __) =>
                                                GoalStepper(
                                                  initialValue: videos,
                                                  titleText: "videos",
                                                  goalText: model.videosGoal,
                                                  onChanged: (val) =>
                                                      model.setVideos(val),
                                                )),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: AppStyles.leftMargin, vertical: 10),
                                  child: Text("Notes",
                                      style: AppStyles.heading4),
                                ),
                                Padding(
                                    padding:
                                        EdgeInsets.all(AppStyles.leftMargin),
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        children: <Widget>[
                                          TextFormField(
                                            onSaved: (notes) =>
                                                model.setNotes(notes),
                                          ),
                                          Container(
                                            alignment: Alignment.bottomCenter,
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical:
                                                      AppStyles.leftMargin,
                                                  horizontal: 0),
                                              child: SizedBox(
                                                height: 40,
                                                width: double.infinity,
                                                child: FlatButton(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                  color: AppStyles.primaryColor,
                                                  child: Text(
                                                    "save",
                                                    style: AppStyles.heading2
                                                        .copyWith(
                                                            color: AppStyles
                                                                .secondaryTextColor),
                                                  ),
                                                  onPressed: () {
                                                    _formKey.currentState
                                                        .save();
                                                    if (model.time.category == null || model.time.category.id == -1) {
                                                      infoDialog(context,
                                                          "You must select a category for your new time.");
                                                      return;
                                                    }
                                                    model.saveOrUpdate();
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                          )
                        ],
                      ),
                    )))));
  }
}
