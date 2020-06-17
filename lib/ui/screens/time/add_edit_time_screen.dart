import 'package:commons/commons.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:provider/provider.dart';

import 'package:jama/data/models/time_model.dart';
import 'package:jama/ui/models/time/time_model.dart';
import 'package:jama/ui/widgets/goal_stepper_widget.dart';
import 'package:jama/ui/widgets/time_selection_slider_widget.dart';
import 'package:jama/ui/app_styles.dart';
import 'package:jama/ui/screens/base_screen.dart';

class AddEditTimeScreen extends StatelessWidget {
  final TimeModel model;
  final _formKey = GlobalKey<FormState>();

  AddEditTimeScreen._([this.model]);

  factory AddEditTimeScreen(TimeModel model) {
    return AddEditTimeScreen._(TimeModel(timeModel: model.time));
  }

  factory AddEditTimeScreen.createNew() {
    return AddEditTimeScreen._();
  }

  @override
  Widget build(BuildContext context) {
    var categoryScrollListController = ItemScrollController();
    return BaseScreen(
        body: ChangeNotifierProvider(
            create: (_) => model ?? TimeModel(),
            child: Consumer<TimeModel>(
                builder: (_, model, __) => Stack(children: <Widget>[
                      // header
                      Positioned(
                        height: AppStyles.headerHeight -
                            MediaQuery.of(context).padding.top,
                        width: MediaQuery.of(context).size.width,
                        child: Container(
                          child: Padding(
                            padding: EdgeInsets.only(top: AppStyles.topMargin),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
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
                                DatePickerTimeline(
                                  model.time.formattedDate,
                                  inactiveTextColor:
                                      AppStyles.lightGrey.withAlpha(80),
                                  selectionColor: Colors.white,
                                  onDateChange: (date) {
                                    model.setDate(date);
                                  },
                                )
                              ],
                            ),
                          ),
                        ),
                      ),

                      // body - main add/edit time form
                      Positioned.fill(
                        top: AppStyles.headerHeight -
                            MediaQuery.of(context).padding.top,
                        child: Container(
                          color: AppStyles.primaryBackground,
                          child: Padding(
                            padding: EdgeInsets.only(
                                bottom:
                                    50 + MediaQuery.of(context).padding.bottom),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: AppStyles.leftMargin),
                                  ),
                                  Selector<TimeModel, Time>(
                                    selector: (_, m) => m.time,
                                    shouldRebuild: (a, b) =>
                                        (a.date != b.date) ||
                                        (a.totalMinutes != b.totalMinutes),
                                    builder: (BuildContext context, value,
                                        Widget child) {
                                      return TimeSelectionSlider(
                                        startTime: model.time.formattedDate,
                                        duration: model.time.duration,
                                        onTimeChanged: (newTime, newDuration) =>
                                            model.setTime(newTime, newDuration.inMinutes),
                                      );
                                    },
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        bottom: 10,
                                        left: AppStyles.leftMargin),
                                    child: Text("Category",
                                        style: AppStyles.heading4),
                                  ),
                                  Container(
                                    height: 30,
                                    width: MediaQuery.of(context).size.width,
                                    child: ScrollablePositionedList.builder(
                                        itemScrollController: categoryScrollListController,
                                        padding: EdgeInsets.only(left: AppStyles.leftMargin),
                                        scrollDirection: Axis.horizontal,
                                        itemCount: model.categories.length,
                                        initialScrollIndex: model.categories.length <= 0 ? 0 : model.categories.indexWhere((category) => category.id == model.time.category.id),
                                        itemBuilder: (_, index) {
                                          var category =
                                              model.categories[index];
                                          return ChoiceChip(
                                            avatar: CircleAvatar(
                                              backgroundColor: category.color,
                                            ),
                                            label: Text(
                                              category.name,
                                              style: AppStyles.smallTextStyle),
                                            backgroundColor:
                                                AppStyles.primaryBackground,
                                            selectedColor:
                                                AppStyles.lightGrey,
                                            selected:
                                                model.time.category.id == category.id,
                                            onSelected: (selected) {
                                              if (selected) {
                                                model.setCategory(category);
                                              }
                                            },
                                          );
                                        },
                                        ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: AppStyles.leftMargin,
                                        vertical: 0),
                                    child: model.shouldHideGoals
                                        ? null
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    top: 10, bottom: 10),
                                                child: Text("Goals",
                                                    style: AppStyles.heading4),
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  Selector<TimeModel, int>(
                                                      selector: (_, m) =>
                                                          m.time.placements,
                                                      builder:
                                                          (_, placements, __) =>
                                                              GoalStepper(
                                                                initialValue:
                                                                    placements,
                                                                titleText:
                                                                    "placements",
                                                                goalText: model
                                                                    .placementsGoal,
                                                                onChanged:
                                                                    (val) => model
                                                                        .setPlacements(
                                                                            val),
                                                              )),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: AppStyles
                                                            .leftMargin),
                                                    child: Selector<TimeModel,
                                                            int>(
                                                        selector: (_, m) =>
                                                            m.time.videos,
                                                        builder:
                                                            (_, videos, __) =>
                                                                GoalStepper(
                                                                  initialValue:
                                                                      videos,
                                                                  titleText:
                                                                      "videos",
                                                                  goalText: model
                                                                      .videosGoal,
                                                                  onChanged: (val) =>
                                                                      model.setVideos(
                                                                          val),
                                                                )),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: AppStyles.leftMargin).add(
                                          EdgeInsets.only(top: 10.0)
                                        ),
                                    child: Text("Notes",
                                        style: AppStyles.heading4),
                                  ),
                                  Padding(
                                      padding:
                                          EdgeInsets.only(left: AppStyles.leftMargin, right: AppStyles.leftMargin, bottom: AppStyles.leftMargin),
                                      child: Form(
                                        key: _formKey,
                                        child: Column(
                                          children: <Widget>[
                                            TextFormField(
                                              keyboardType: TextInputType.multiline,
                                              minLines: 1,
                                              maxLines: 5,
                                              onSaved: (notes) =>
                                                  model.setNotes(notes),
                                            ),
                                          ],
                                        ),
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // body - save button
                      Positioned(
                        left: AppStyles.leftMargin,
                        bottom: 10,
                        height: 40,
                        width: MediaQuery.of(context).size.width -
                            (AppStyles.leftMargin * 2),
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          color: AppStyles.primaryColor,
                          child: Text(
                            "save",
                            style: AppStyles.heading2
                                .copyWith(color: AppStyles.secondaryTextColor),
                          ),
                          onPressed: () {
                            _formKey.currentState.save();
                            if (model.time.totalMinutes <= 0) {
                              infoDialog(
                                  context, "You must add time before saving.");
                              return;
                            }
                            if (model.time.category == null ||
                                model.time.category.id == -1) {
                              infoDialog(context,
                                  "You must select a category for your new time.");
                              return;
                            }
                            model.saveOrUpdate();
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ]))));
  }
}
