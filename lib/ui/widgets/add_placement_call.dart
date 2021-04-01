import 'package:flutter/material.dart';

import 'package:commons/commons.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gradual_stepper/gradual_stepper.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:supercharged/supercharged.dart';
import 'package:geocoding/geocoding.dart';

import 'package:jama/mixins/color_mixin.dart';
import 'package:jama/services/return_visit_service.dart';
import 'package:jama/ui/translation.dart';
import 'package:jama/ui/widgets/spacer.dart';
import 'package:jama/ui/app_styles.dart';
import 'package:jama/ui/models/node.dart';
import 'package:jama/ui/transitions/slide_and_fade_transition.dart';
import 'package:jama/ui/widgets/tree_select.dart';
import 'package:jama/data/models/dto/visit_dto.dart';

/// Shows a modal for editting or creating a new visit.
/// To edit a current visit, supply a [visit].
/// To create a visit, supply the [parent] rv.
/// Once the visit is saved [onVisitSaved] be called.
Future showAddEditVisitModal(BuildContext context,
    {VisitType type,
    Visit visit,
    ReturnVisit parent,
    Function(Visit visit) onVisitSaved,
    Function(Visit visit) onVisitDeleted,
    bool isDeletable = false}) async {
  if (visit == null && parent == null) {
    throw ArgumentError.notNull(
        "`visit` and `parent` cannot be null. \\r\\nTo create a new visit, supply a parent. To edit an existing visit supply a visit.");
  } else if (visit == null && parent != null) {
    visit = Visit.create(parent: parent, date: DateTime.now(), type: type ?? VisitType.ReturnVisit);
    isDeletable = false;
  }

  return await showMaterialModalBottomSheet(
      expand: false,
      context: context,
      builder: (context) => SingleChildScrollView(
              child: _AddEditVisit(
            visit: visit,
            isDeleteable: isDeletable,
            onVisitDeleted: onVisitDeleted,
            onVisitSaved: onVisitSaved,
          )));
}

Future editNotAtHomeVisit(BuildContext context,
    {Visit visit, Function(Visit visit) onSaved, Function(Visit visit) onDeleted}) async {
  assert(visit.isSaved);
  var newDate = visit.date;
  return await showMaterialModalBottomSheet(
      context: context,
      expand: false,
      builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              VerticalSpace(30),
              Padding(
                padding: EdgeInsets.all(AppStyles.leftMargin),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Edit Not At Home", style: AppStyles.heading2),
                    IconButton(
                      icon: Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        confirmationDialog(context, "Are you sure you want to delete this visit?",
                            positiveText: "Yes", positiveAction: () {
                          onDeleted(visit);
                          Navigator.of(context).pop();
                        }, negativeText: "No");
                      },
                    )
                  ],
                ),
              ),
              DateTimePickerWidget(
                maxDateTime: DateTime.now(),
                dateFormat: "EEEE MMMM d|hh|mm|a",
                initDateTime: visit.date,
                onChange: (d, _) => newDate = d,
                pickerTheme: DateTimePickerTheme(
                  backgroundColor: Colors.transparent,
                  pickerHeight: 90.0,
                  showTitle: false,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  SlideAndFadeTransition(
                    id: "placements_ok",
                    delay: 300,
                    curve: Curves.ease,
                    child: IconButton(
                      icon: FaIcon(
                        FontAwesomeIcons.check,
                        color: Colors.green,
                      ),
                      onPressed: () {
                        visit.date = newDate;
                        onSaved(visit);
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  SlideAndFadeTransition(
                    id: "placements_back",
                    delay: 400,
                    curve: Curves.ease,
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.red, size: 35),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  )
                ],
              ),
              Container(
                height: MediaQuery.of(context).padding.bottom,
              )
            ],
          ));
}

/// Shows a modal for adding a single placement.
Future showAddSinglePlacementModal(BuildContext context,
    Function(int count, PlacementType type, String description) onPlacementChanged) async {
  int count = 1;
  PlacementType type;
  String description = "";

  return await showMaterialModalBottomSheet(
      expand: false,
      context: context,
      builder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: AppStyles.leftMargin),
                  child: Text("Add A Placement", style: AppStyles.heading2),
                ),
                _AddPlacement(
                  onPlacementChanged: (c, t, d) {
                    count = c;
                    type = t;
                    description = d;
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    SlideAndFadeTransition(
                      id: "placements_ok",
                      delay: 300,
                      curve: Curves.ease,
                      child: IconButton(
                        icon: FaIcon(
                          FontAwesomeIcons.check,
                          color: Colors.green,
                        ),
                        onPressed: () {
                          if (type == null) {
                            warningDialog(context, "Please select a placement type.");
                            return;
                          }
                          onPlacementChanged(count, type, description);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    SlideAndFadeTransition(
                      id: "placements_back",
                      delay: 400,
                      curve: Curves.ease,
                      child: IconButton(
                        icon: Icon(Icons.close, color: Colors.red, size: 35),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    )
                  ],
                ),
                Container(
                  height: MediaQuery.of(context).padding.bottom,
                )
              ]));
}

class _AddEditVisit extends StatefulWidget {
  final Visit visit;
  final Function(Visit visit) onVisitSaved;
  final Function(Visit visit) onVisitDeleted;
  final bool isDeleteable;
  _AddEditVisit(
      {Key key,
      @required this.visit,
      @required this.onVisitSaved,
      this.onVisitDeleted,
      this.isDeleteable})
      : super(key: key);

  @override
  __AddEditVisitState createState() => __AddEditVisitState();
}

class __AddEditVisitState extends State<_AddEditVisit> {
  bool addingPlacement = false;
  GlobalKey<FormState> _formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          VerticalSpace(AppStyles.leftMargin),
          Padding(
            padding: EdgeInsets.all(AppStyles.leftMargin),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Visit Date", style: AppStyles.heading4),
                FlutterSwitch(
                  value: widget.visit.type == VisitType.ReturnVisit,
                  activeColor: AppStyles.visitTypeToColor[VisitType.ReturnVisit],
                  inactiveColor: AppStyles.visitTypeToColor[VisitType.Study],
                  activeText: Translation.visitTypeToString[VisitType.ReturnVisit],
                  inactiveText: Translation.visitTypeToString[VisitType.Study],
                  showOnOff: true,
                  width: 150,
                  onToggle: (value) => setState(
                      () => widget.visit.type = value ? VisitType.ReturnVisit : VisitType.Study),
                )
              ],
            ),
          ),
          DateTimePickerWidget(
            maxDateTime: DateTime.now(),
            dateFormat: "EEEE MMMM d|hh|mm|a",
            initDateTime: widget.visit.date,
            onChange: (d, _) => widget.visit.date = d,
            pickerTheme: DateTimePickerTheme(
              backgroundColor: Colors.transparent,
              pickerHeight: 90.0,
              showTitle: false,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppStyles.leftMargin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                addingPlacement
                    ? buildAddPlacement(context, widget.visit)
                    : buildCurrentPlacementsList(context),
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        initialValue: widget.visit.nextTopic,
                        onSaved: (s) => widget.visit.nextTopic = s,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            labelText: widget.visit.type == VisitType.ReturnVisit
                                ? "Next Topic/Question?"
                                : "Material Covered?",
                            alignLabelWithHint: true,
                            labelStyle: AppStyles.smallTextStyle),
                      ),
                      TextFormField(
                          initialValue: widget.visit.notes,
                          onSaved: (s) => widget.visit.notes = s,
                          keyboardType: TextInputType.multiline,
                          maxLines: 4,
                          decoration: InputDecoration(
                              labelText: widget.visit.type == VisitType.ReturnVisit
                                  ? "Other Notes (Scriptures Used, etc.)"
                                  : "Other Notes (Questions? Where to start next?)",
                              alignLabelWithHint: true,
                              labelStyle: AppStyles.smallTextStyle))
                    ],
                  ),
                )
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              SlideAndFadeTransition(
                id: "placements_ok",
                delay: 300,
                curve: Curves.ease,
                child: IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.check,
                    color: Colors.green,
                  ),
                  onPressed: () {
                    if (widget.visit.type == null) {
                      warningDialog(context, "Please select a placement type.");
                      return;
                    }
                    _formKey.currentState.save();
                    widget.onVisitSaved(widget.visit);
                    Navigator.of(context).pop();
                  },
                ),
              ),
              SlideAndFadeTransition(
                id: "placements_back",
                delay: 400,
                curve: Curves.ease,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.red, size: 35),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              if (widget.isDeleteable)
                SlideAndFadeTransition(
                  id: "placements_delete",
                  delay: 500,
                  curve: Curves.ease,
                  child: IconButton(
                    icon: Icon(Icons.delete_forever, color: Colors.red, size: 35),
                    onPressed: () {
                      confirmationDialog(context, "Are you sure you want to delete this visit?",
                          positiveText: "Yes", positiveAction: () {
                        widget.onVisitDeleted(widget.visit);
                        Navigator.of(context).pop();
                      }, negativeText: "No");
                    },
                  ),
                )
            ],
          ),
          VerticalSpace(MediaQuery.of(context).padding.bottom)
        ],
      ),
    );
  }

  Column buildAddPlacement(BuildContext context, Visit visit) {
    int count = 0;
    PlacementType type;
    String notes = "";
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _AddPlacement(onPlacementChanged: (c, t, d) {
            count = c;
            type = t;
            notes = d;
          }),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              FlatButton.icon(
                  onPressed: () {
                    setState(() {
                      addingPlacement = false;
                    });
                  },
                  icon: Icon(Icons.close),
                  label: Text("cancel")),
              FlatButton.icon(
                icon: Icon(Icons.add),
                label: Text("add"),
                onPressed: () {
                  if (count <= 0 || type == null) {
                    infoDialog(context, "Please choose a placement type.");
                    return;
                  }
                  widget.visit.addPlacement(
                      Placement.create(parent: visit, count: count, type: type, notes: notes));

                  setState(() {
                    addingPlacement = false;
                  });
                },
              ),
            ],
          )
        ]);
  }

  Widget buildCurrentPlacementsList(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "Placements",
                style: AppStyles.smallTextStyle,
              ),
              FlatButton.icon(
                  icon: Icon(Icons.add),
                  label: Text("add"),
                  onPressed: () => setState(() => addingPlacement = true))
            ],
          ),
        ),
        widget.visit.placements.isNotEmpty
            ? ListView.builder(
                shrinkWrap: true,
                itemCount: widget.visit.placements.length,
                itemBuilder: (_, index) {
                  var placement = widget.visit.placements[index];
                  return Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              height: 50,
                              width: 50,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4.0, right: 8.0, bottom: 4.0),
                                child: Container(
                                  color: Colors.black12,
                                  child: Center(
                                    child: Text(placement.count.toString(),
                                        style: AppStyles.heading2
                                            .copyWith(fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                    Translation.placementTypeToString[placement.type] +
                                        (placement.count > 1 ? "(s)" : ""),
                                    style: AppStyles.smallTextStyle
                                        .copyWith(fontWeight: FontWeight.bold)),
                                if (placement.notes.isNotEmpty)
                                  Text(placement.notes,
                                      style:
                                          AppStyles.smallTextStyle.copyWith(color: Colors.black54))
                              ],
                            ),
                            Expanded(child: Container()),
                            IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () {
                                  setState(() => widget.visit.removePlacement(placement));
                                })
                          ],
                        ),
                      ),
                      if (placement != widget.visit.placements.last)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Container(
                            height: 1.00,
                            color: HexColor.fromHex("ffdbdbdb"),
                          ),
                        )
                    ],
                  );
                })
            : Center(
                child: Text(
                "no placements",
                style: AppStyles.smallTextStyle.copyWith(color: Colors.black38),
              )),
      ],
    );
  }
}

class _AddPlacement extends StatefulWidget {
  final Function(int count, PlacementType type, String description) onPlacementChanged;

  const _AddPlacement({
    Key key,
    @required this.onPlacementChanged,
  }) : super(key: key);

  @override
  _AddPlacementState createState() => _AddPlacementState();
}

class _AddPlacementState extends State<_AddPlacement> {
  int count = 1;
  PlacementType type;
  String description = "";
  String notes = "";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22.0).add(EdgeInsets.only(bottom: 34)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SlideAndFadeTransition(
            id: "count",
            direction: AxisDirection.right,
            offset: 1.0,
            delay: 50,
            curve: Curves.ease,
            child: GradualStepper(
              initialValue: count,
              backgroundColor: AppStyles.primaryColor,
              counterBackgroundColor: Colors.grey[200],
              buttonsColor: Colors.white,
              elevation: 2,
              onChanged: (newValue) => setState(() => count = newValue),
              minimumValue: 1,
            ),
          ),
          Container(height: 15.0),
          TreeSelect(
            node: _getPlacements(),
            onSelectionMade: (nodes) {
              if (nodes != null && nodes.isNotEmpty) {
                var typeString = nodes.first.content;
                type = PlacementType.values
                    .firstWhere((type) => type.toString().allAfter('.') == typeString);
                description = nodes.skip(1).map((e) => e.content).join(" ");
                var desc = description;
                if (description.isNotEmpty && notes.isNotEmpty) {
                  desc = "$description ($notes)";
                } else if (description.isEmpty && notes.isNotEmpty) {
                  desc = notes;
                }
                widget.onPlacementChanged(count, type, desc);
              }
            },
          ),
          TextFormField(
            keyboardType: TextInputType.multiline,
            maxLines: 4,
            onChanged: (value) {
              if (value.isNotEmpty) {
                notes = value;
                var desc = description.isEmpty ? notes : "$description ($value)";
                widget.onPlacementChanged(count, type, desc);
              }
            },
            decoration: InputDecoration(
                alignLabelWithHint: true, labelText: "Notes", labelStyle: AppStyles.smallTextStyle),
          ),
          Container(height: 50),
        ],
      ),
    );
  }

  Node _getPlacements() {
    var possiblities = Node(content: "Placements", children: [
      Node(content: PlacementType.Magazine.toString().allAfter("."), children: [
        Node(content: "Watchtower", children: [
          Node(content: "Issue #1"),
          Node(content: "Issue #2"),
        ]),
        Node(content: "Awake", children: [Node(content: "Issue #1")])
      ]),
      Node(
          content: PlacementType.Brochure.toString().allAfter("."),
          children: [Node(content: "Good News")])
    ]);

    return possiblities;
  }
}
