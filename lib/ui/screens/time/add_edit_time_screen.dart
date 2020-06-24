import 'package:calendar_strip/calendar_strip.dart';
import 'package:commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fluid_slider/flutter_fluid_slider.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jama/ui/models/time/time_modification_model.dart';
import 'package:jama/ui/widgets/goal_display_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

import 'package:jama/ui/widgets/time_selection_slider_widget.dart';
import 'package:jama/ui/app_styles.dart';
import 'package:jama/ui/screens/base_screen.dart';
import 'package:tuple/tuple.dart';

class AddEditTimeScreen extends StatefulWidget {
  final TimeModificationModel model;

  AddEditTimeScreen._({Key key, this.model}) : super(key: key);

  /// Creates a [AddEditTimeScreen] to edit the supplied time.
  factory AddEditTimeScreen.edit(TimeModificationModel time) {
    return AddEditTimeScreen._(model:time.copy());
  }

  /// Creates a [AddEditTimeScreen] to create a new time entry.
  factory AddEditTimeScreen.create() {
    return AddEditTimeScreen._(model: TimeModificationModel.create());
  }

  @override
  _AddEditTimeScreenState createState() => _AddEditTimeScreenState();
}

class _AddEditTimeScreenState extends State<AddEditTimeScreen> {
  final _formKey = GlobalKey<FormState>();
  final categoryScrollListController = ItemScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      body: ChangeNotifierProvider<TimeModificationModel>.value(
        value: widget.model,
        child: Consumer<TimeModificationModel>(
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
                      CalendarStrip(
                        startDate: DateTime(0),
                        endDate: DateTime(9999),
                        selectedDate: model.date,
                        addSwipeGesture: true,
                        onDateSelected: (date) => model.date = date,
                        monthNameWidget: (_) => Container(),
                        iconColor: AppStyles.lightGrey,
                        dateTileBuilder: (date, selectedDate, _, __, ___, ____) => dateTileBuilder(model, date, selectedDate),
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
                        buildTime(context, model),
                        buildCategories(context, model),
                        buildGoals(context, model),
                        buildNotes(context, model),
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
                  if (model.duration <= Duration.zero) {
                    infoDialog(
                        context, "You must add time before saving.");
                    return;
                  }
                  if (model.category == null ||
                      model.category.id == -1) {
                    infoDialog(context,
                        "You must select a category for your new time.");
                    return;
                  }
                  model.save();
                  Navigator.pop(context);
                },
              ),
            ),
          ]
        )
      )
    )
  );
  }

  Widget buildTime(BuildContext context, TimeModificationModel model) => Selector<TimeModificationModel, Tuple2<DateTime, Duration>>(
      selector: (_, m) => Tuple2(m.date, m.duration),
      shouldRebuild: (a, b) =>
          (a.item1 != b.item1) ||
          (a.item2 != b.item2),
      builder: (BuildContext context, value,
          Widget child) {
        return TimeSelectionSlider(
          startTime: model.date,
          duration: model.duration,
          onTimeChanged: (newTime, newDuration) =>
              model.setTime(newTime, newDuration.inMinutes),
        );
      },
    );

  Widget buildCategories(BuildContext context, TimeModificationModel model) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
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
          scrollDirection: Axis.horizontal,
          itemCount: model.categories.length,
          initialScrollIndex: model.categories.length <= 0 ? 0 : model.categories.indexWhere((category) => category.id == model.category.id),
          itemBuilder: (_, index) {
            var category =
                model.categories[index];
            bool isFirst = index == 0;
            bool isLast = index + 1 == model.categories.length;
            return ChipTheme(
              data: ChipTheme.of(context).copyWith(
                secondaryLabelStyle: AppStyles.smallTextStyle.copyWith(color: Colors.black)
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: isFirst ? AppStyles.leftMargin : 0.0,
                  right: isLast ? AppStyles.leftMargin : 0.0),
                child: ChoiceChip(
                  avatar: Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: CircleAvatar(
                      backgroundColor: category.color,
                    ),
                  ),
                  label: Text(
                    category.name,
                    style: AppStyles.smallTextStyle),
                  backgroundColor:
                      AppStyles.primaryBackground,
                  selectedColor:
                      AppStyles.lightGrey,
                  selected:
                      model.category.id == category.id,
                  onSelected: (selected) {
                    if (selected) {
                      categoryScrollListController.scrollTo(index: index, duration: Duration(milliseconds: 300));
                      model.category = category;
                    }
                  },
                ),
              ),
            );
              },
            ),
          ),
        ]
      );

  Widget buildNotes(BuildContext context, TimeModificationModel model) => Padding(
      padding:
          EdgeInsets.only(left: AppStyles.leftMargin, right: AppStyles.leftMargin, bottom: AppStyles.leftMargin),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Text("Notes",
        style: AppStyles.heading4),
            ),
            TextFormField(
              keyboardType: TextInputType.multiline,
              minLines: 1,
              maxLines: 5,
              onSaved: (notes) => model.notes = notes,
            ),
          ],
        ),
      ));

  Widget buildGoals(BuildContext context, TimeModificationModel model) => Padding(
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
                    Selector<TimeModificationModel, int>(
                      selector: (_, m) =>
                        m.placements,
                      builder:
                        (_, placements, __) => GoalDisplay(
                          text: "Placements",
                          value: model.placements,
                          previousValue: model.previousPlacements,
                          goalValue: model.goalsPlacements,
                          onTap: () => showMaterialModalBottomSheet(
                            expand: false,
                            context: context, 
                            builder: (context, _) => Padding(
                              padding: const EdgeInsets.all(22.0),
                              child: _EditGoalModal(
                                title: "Placements",
                                message: "You have ${model.goalsPlacements - (model.placements + model.previousPlacements)} left to meet your monthly goal of ${model.goalsPlacements} placements.",
                                value: model.placements,
                                onSave: (x) => model.placements = x,
                              ),
                            )
                            ),
                        )

                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: AppStyles
                              .leftMargin),
                      child: Selector<TimeModificationModel, int>(
                        selector: (_, m) =>m.videos,
                        builder: (_, videos, __) =>
                          GoalDisplay(
                            text: "Videos",
                            value: model.videos,
                            previousValue: model.previousVideos,
                            goalValue: model.goalsVideos,
                            onTap: () => showMaterialModalBottomSheet(
                            expand: false,
                            context: context, 
                            builder: (context, _) => Padding(
                              padding: const EdgeInsets.all(22.0),
                              child: _EditGoalModal(
                                title: "Videos",
                                message: "You have ${model.goalsVideos - (model.videos + model.previousVideos)} left to meet your monthly goal of ${model.goalsVideos} videos.",
                                value: model.videos,
                                onSave: (x) => model.videos = x,
                              ),
                            )
                            ),
                          ),
                      )
                    ),
                  ],
                ),
              ],
            ),
    );

  Widget dateTileBuilder(TimeModificationModel model, DateTime date, DateTime selectedDate,) {
    final marks = model.isDateMarkedForPreviousEntry(date);
    final isSelected = date.compareTo(selectedDate) == 0;
    var style = isSelected 
      ? AppStyles.smallTextStyle.copyWith(fontWeight: FontWeight.bold) 
      : AppStyles.smallTextStyle.copyWith(fontWeight: FontWeight.bold, color: AppStyles.lightGrey);
    
    var dateWidget = Column(children: <Widget>[
      Text(DateFormat.MMM().format(date).toUpperCase(), style: style),
      Text(date.day.toString(), style: style.copyWith(fontSize: 22)),
      Text(DateFormat.E().format(date).toUpperCase().substring(0,3), style: style),
      marks.isNotEmpty 
        ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: marks
            .take(3)
            .map((category) => Container(
              width: 7.0,
              height: 7.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: category.id == 1 && !isSelected ? Colors.white : category.color,
                ),
              )
            ).toList(),
          )
        : Container(height: 7.0,)
    ],);

    if(isSelected) {
      return Container(
        padding: EdgeInsets.all(5.0),
        child: dateWidget,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0)
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(5.0),
        child: dateWidget,
      );
    }
  }
}

class _EditGoalModal extends StatefulWidget {
  final String title;
  final String message;
  final int value;
  final Function(int) onSave;
  
  const _EditGoalModal({
    Key key, 
    this.title, 
    this.message, 
    @required this.value, 
    @required this.onSave,
  }) : super(key: key);

  @override
  __EditGoalModalState createState() => __EditGoalModalState();
}

class __EditGoalModalState extends State<_EditGoalModal> {
  double value;

  @override
  void initState() {
    value = widget.value.toDouble();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
      Text(widget.title, style: AppStyles.heading2),
      Container(height: 15),
      Text(widget.message),
      Container(height: 50),
      FluidSlider(
        value: value,
        onChanged: (double newValue) => setState(() => value = newValue),
        sliderColor: AppStyles.primaryColor,
        min: 0.0,
        max: 50.0,
        ),
        Container(height: 50),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: FaIcon(FontAwesomeIcons.check, color: Colors.green,),
              onPressed: () {
                widget.onSave(value.toInt());
                Navigator.of(context).pop();
              },),
            IconButton(
              icon: Icon(Icons.close, color: Colors.red, size: 35),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        ),
        Container(height: MediaQuery.of(context).padding.bottom,)
    ],);
  }
}
