import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jama/data/models/dto/visit_dto.dart';
import 'package:jama/ui/transitions/slide_and_fade_transition.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:provider/provider.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:tuple/tuple.dart';

import 'package:jama/mixins/color_mixin.dart';
import 'package:jama/ui/models/return_visits/edit_return_visit_model.dart';
import 'package:jama/ui/widgets/donut_chart_widget.dart';
import 'package:jama/ui/widgets/return_visit_personal_info_form.dart';
import 'package:jama/ui/widgets/timeline_card.dart';
import 'package:jama/ui/widgets/timeline_title.dart';
import 'package:jama/ui/app_styles.dart';

class EditReturnVisitScreen extends StatefulWidget {
  final EditReturnVisitModel returnVisit;
  EditReturnVisitScreen({Key key, @required this.returnVisit}) : super(key: key);

  @override
  _EditReturnVisitScreenState createState() => _EditReturnVisitScreenState();
}

class _EditReturnVisitScreenState extends State<EditReturnVisitScreen>
    with TickerProviderStateMixin {
  double _defaultZoom = 14.75;
  TabController _tabController;
  GlobalKey _addressWidgetKey = GlobalKey();

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EditReturnVisitModel>.value(
      value: widget.returnVisit,
      child: FocusWatcher(
        child: Scaffold(
          floatingActionButton: SpeedDial(
            marginBottom:
                MediaQuery.of(context).size.height - 200 - MediaQuery.of(context).padding.top - 28,
            animatedIcon: AnimatedIcons.add_event,
            foregroundColor: AppStyles.primaryColor,
            backgroundColor: Colors.white,
            orientation: SpeedDialOrientation.Down,
            overlayColor: HexColor.fromHex("#9F9F9F"),
            overlayOpacity: 0.7,
            children: [
              SpeedDialChild(
                  child: Icon(Icons.thumb_up),
                  label: "add visit",
                  labelStyle: AppStyles.heading4,
                  onTap: () =>
                      widget.returnVisit.addVisit(context: context, type: VisitType.ReturnVisit)),
              SpeedDialChild(
                  child: Icon(Icons.library_books),
                  label: "add study",
                  labelStyle: AppStyles.heading4,
                  onTap: () =>
                      widget.returnVisit.addVisit(context: context, type: VisitType.Study)),
              SpeedDialChild(
                  child: Icon(Icons.not_interested),
                  label: "add not at home",
                  labelStyle: AppStyles.heading4,
                  onTap: () =>
                      widget.returnVisit.addVisit(context: context, type: VisitType.NotAtHome)),
            ],
          ),
          body: Stack(
            children: <Widget>[
              Positioned(
                top: 0,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).padding.top + 227.0,
                child: widget.returnVisit.mapPosition == null
                    ? Container(
                        color: AppStyles.primaryBackground,
                      )
                    : SlideAndFadeTransition(
                        id: "map",
                        offset: 0.0,
                        child: GoogleMap(
                          rotateGesturesEnabled: false,
                          scrollGesturesEnabled: false,
                          tiltGesturesEnabled: false,
                          zoomGesturesEnabled: false,
                          myLocationButtonEnabled: false,
                          buildingsEnabled: false,
                          mapToolbarEnabled: false,
                          circles: Set.from([
                            Circle(
                              circleId: CircleId("main location"),
                              center: widget.returnVisit.mapPosition,
                              radius: 25,
                              fillColor: AppStyles.primaryColor,
                              strokeColor: Colors.transparent,
                            )
                          ]),
                          initialCameraPosition: CameraPosition(
                            bearing: 360.0,
                            target:
                                widget.returnVisit.mapPosition.addOffset(latitudeOffset: -0.0012),
                            zoom: _defaultZoom,
                          ),
                        ),
                      ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + AppStyles.topMargin,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Selector<EditReturnVisitModel, String>(
                        selector: (_, rv) => rv.nameOrDescription,
                        builder: (_, nameOrDescription, __) =>
                            Text(nameOrDescription, style: AppStyles.heading1))
                  ],
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 10.0,
                right: 10.0,
                child: Selector<EditReturnVisitModel, bool>(
                    selector: (_, rv) => rv.pinned,
                    builder: (_, pinned, __) => FlutterSwitch(
                          activeColor: AppStyles.primaryColor,
                          value: pinned,
                          activeText: "pinned",
                          inactiveText: "unpinned",
                          showOnOff: true,
                          width: 125,
                          onToggle: (v) => widget.returnVisit.pinned = v,
                        )),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 130.0,
                width: MediaQuery.of(context).size.width,
                child: SlideAndFadeTransition(
                  id: "tabs_back",
                  offset: 0.5,
                  curve: Curves.ease,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppStyles.secondaryBackground,
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(1.00, -1.00),
                          color: AppStyles.primaryBackground,
                          blurRadius: 15,
                        ),
                      ],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.00),
                        topRight: Radius.circular(30.00),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(top: 35.0),
                      child: SlideAndFadeTransition(
                        id: "tabs_front",
                        offset: 2.0,
                        curve: Curves.ease,
                        child: TabBar(
                            controller: _tabController,
                            isScrollable: true,
                            labelColor: Colors.black,
                            unselectedLabelColor: Colors.white,
                            indicatorSize: TabBarIndicatorSize.tab,
                            labelPadding: EdgeInsets.only(left: 40.0, right: 40.0, bottom: 20.0),
                            indicator: BoxDecoration(
                              color: AppStyles.primaryBackground,
                              boxShadow: [AppStyles.defaultBoxShadow],
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20.00),
                                topRight: Radius.circular(20.00),
                              ),
                            ),
                            tabs: [
                              Tab(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "personal",
                                    style: AppStyles.smallTextStyle
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              Tab(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "visits",
                                    style: AppStyles.smallTextStyle
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ]),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                  top: MediaQuery.of(context).padding.top + 200.0,
                  child: Container(
                    color: AppStyles.primaryBackground,
                    child: SlideAndFadeTransition(
                      id: "tab_body",
                      offset: 0.25,
                      curve: Curves.ease,
                      child: TabBarView(
                        controller: _tabController,
                        children: <Widget>[
                          Consumer<EditReturnVisitModel>(
                              builder: (context, model, __) => _buildPersonalTab(context)),
                          Selector<EditReturnVisitModel, UnmodifiableListView<VisitCardModel>>(
                              selector: (_, rv) => rv.visits,
                              builder: (context, visits, __) =>
                                  visits.isEmpty ? Container() : _buildVisitsTab(context, visits))
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalTab(BuildContext context) {
    var model = Provider.of<EditReturnVisitModel>(context);
    var popupMenu = PopupMenu(
        context: context,
        onClickMenu: (item) {
          if (item.menuTitle == "Directions") {
            if (model.mapPosition != null) {
              MapsLauncher.launchCoordinates(
                  model.mapPosition.latitude, model.mapPosition.longitude, model.formattedAddress);
            } else {
              MapsLauncher.launchQuery(model.formattedAddress);
            }
          } else if (item.menuTitle == "Edit") {
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  GlobalKey<FormState> _editRvAddressForm = GlobalKey();
                  return AlertDialog(
                    content: SizedBox(
                      width: MediaQuery.of(context).size.width - 100.0,
                      height: MediaQuery.of(context).size.height - 200.0,
                      child: Stack(
                        children: <Widget>[
                          Positioned.fill(
                              bottom: 40.0,
                              child: SingleChildScrollView(
                                  child: Form(
                                      key: _editRvAddressForm,
                                      child: ReturnVisitPersonalInfoForm(
                                        returnVisitModel: widget.returnVisit,
                                      )))),
                          Positioned(
                              bottom: 0.0,
                              child: FlatButton(
                                color: AppStyles.primaryColor,
                                textColor: AppStyles.secondaryTextColor,
                                onPressed: () {
                                  if (_editRvAddressForm.currentState.validate()) {
                                    _editRvAddressForm.currentState.save();
                                    widget.returnVisit.save();
                                    Navigator.of(context, rootNavigator: true).pop();
                                  }
                                },
                                child: Text("save"),
                              ))
                        ],
                      ),
                    ),
                  );
                });
          }
        },
        items: [
          MenuItem(
              image: Icon(
                Icons.edit,
                color: Colors.white,
              ),
              title: "Edit"),
          MenuItem(image: Icon(Icons.navigation, color: Colors.white), title: "Directions")
        ]);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: AppStyles.topMargin),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    child: Selector<EditReturnVisitModel,
                        Tuple2<UnmodifiableListView<charts.Series<dynamic, dynamic>>, int>>(
                      selector: (_, rv) => Tuple2(rv.visitsByTypeSeries, rv.totalVisits),
                      builder: (_, tuple, __) => DonutChartWidget(tuple.item1,
                          height: 70,
                          width: 70,
                          textStyle: AppStyles.heading2,
                          text: tuple.item2.toString()),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: AppStyles.leftMargin),
                    child: Text(
                      widget.returnVisit.lastVisitString,
                      style: AppStyles.smallTextStyle.copyWith(fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 35.0, horizontal: 90.0),
            child: Selector<EditReturnVisitModel, String>(
              selector: (_, rv) => rv.bestTimeString,
              builder: (_, bestTimeString, __) => Text(
                bestTimeString,
                maxLines: 3,
                textAlign: TextAlign.center,
                style: AppStyles.heading4.copyWith(color: AppStyles.captionText),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppStyles.leftMargin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Address",
                  style: AppStyles.smallTextStyle,
                ),
                GestureDetector(
                  key: _addressWidgetKey,
                  onTap: () => popupMenu.show(widgetKey: _addressWidgetKey),
                  child: Container(
                    color: AppStyles.primaryBackground,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Selector<EditReturnVisitModel, String>(
                            selector: (_, rv) => rv.formattedAddress,
                            builder: (_, formattedAddress, __) => Text(
                                  formattedAddress,
                                  style: AppStyles.heading2,
                                )),
                        Icon(Icons.arrow_forward_ios, size: 17.0),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 14.0),
                ),
                Container(
                  height: 1,
                  color: AppStyles.lightGrey,
                ),
                Selector<EditReturnVisitModel, String>(
                  selector: (_, rv) => rv.notes,
                  builder: (_, notes, __) => notes.isEmpty
                      ? Container()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 14.0),
                              child: Text(
                                notes,
                                maxLines: 2,
                                style: AppStyles.smallTextStyle,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              height: 1,
                              color: AppStyles.lightGrey,
                            ),
                          ],
                        ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 14.0),
                ),
                Row(
                  children: <Widget>[
                    Text(
                      "Last Visit Date: ",
                      style: AppStyles.smallTextStyle,
                    ),
                    Selector<EditReturnVisitModel, String>(
                        selector: (_, rv) => rv.lastVisitString,
                        builder: (_, lastVisitDate, __) => Text(
                              widget.returnVisit.lastVisitDate,
                              style: AppStyles.smallTextStyle.copyWith(fontWeight: FontWeight.bold),
                            )),
                  ],
                ),
                Selector<EditReturnVisitModel, String>(
                  selector: (_, rv) => rv.lastVisitNotes,
                  builder: (_, lastVisitNotes, __) => lastVisitNotes.isEmpty
                      ? Container()
                      : Text(lastVisitNotes, style: AppStyles.smallTextStyle),
                ),
                Selector<EditReturnVisitModel, String>(
                  selector: (_, rv) => rv.nextTopicToDsicuss,
                  builder: (_, nextTopicToDiscuss, __) => nextTopicToDiscuss.isEmpty
                      ? Container()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 14.0),
                              child: Text(
                                "Topic To Discuss: ",
                                style: AppStyles.smallTextStyle,
                              ),
                            ),
                            Text(
                              nextTopicToDiscuss,
                              maxLines: 2,
                              style: AppStyles.smallTextStyle,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildVisitsTab(BuildContext context, UnmodifiableListView<VisitCardModel> visitsList) {
    var model = Provider.of<EditReturnVisitModel>(context, listen: false);

    List<Widget> children = [];
    var first = visitsList.first;
    var last = visitsList.last;

    for (var visit in visitsList) {
      children.add(TimelineTitle(
          isFirst: visit == first, title: visit.formattedDate, subtitle: visit.formattedTime));
      IconData icon;
      Color iconColor;
      if (visit == last && visit.visitType == VisitType.ReturnVisit) {
        icon = Icons.star;
        iconColor = Colors.amber;
      } else if (visit.visitType == VisitType.ReturnVisit) {
        icon = Icons.thumb_up;
        iconColor = AppStyles.visitTypeToColor[visit.visitType];
      } else if (visit.visitType == VisitType.NotAtHome) {
        icon = Icons.not_interested;
        iconColor = AppStyles.visitTypeToColor[visit.visitType];
      } else if (visit.visitType == VisitType.Study) {
        icon = Icons.library_books;
        iconColor = AppStyles.visitTypeToColor[visit.visitType];
      }

      children.add(TimelineCard(
        title: visit == last ? "Initial Visit" : visit.visitTypeString,
        icon: Icon(
          icon,
          color: Colors.white,
          size: 20.0,
        ),
        iconColor: iconColor,
        isFirst: visit == first,
        isLast: visit == last,
        onTap: () => model.editVisit(context, visit),
        children: visit.visitType == VisitType.NotAtHome ||
                (visit.placements.isEmpty && visit.nextTopic.isEmpty && visit.notes.isEmpty)
            ? null
            : <Widget>[
                if (visit.placements.isNotEmpty)
                  Text(
                    visit.placements,
                    style: AppStyles.smallTextStyle.copyWith(fontWeight: FontWeight.bold),
                  ),
                if (visit.nextTopic.isNotEmpty)
                  Text(visit.nextTopic, style: AppStyles.smallTextStyle),
                if (visit.notes.isNotEmpty) Text(visit.notes, style: AppStyles.smallTextStyle)
              ],
      ));
    }

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppStyles.leftMargin),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: AppStyles.topMargin),
                  )
                ] +
                children),
      ),
    );
  }
}

extension _LatLngMixin on LatLng {
  LatLng addOffset({double latitudeOffset = 0.0, double longitudeOffset = 0.0}) {
    return LatLng(this.latitude + latitudeOffset, this.longitude + longitudeOffset);
  }
}
