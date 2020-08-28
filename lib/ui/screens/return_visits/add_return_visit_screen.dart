import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:jama/ui/widgets/add_placement_call.dart';
import 'package:jama/ui/app_styles.dart';
import 'package:jama/ui/controllers/address_image_controller.dart';
import 'package:jama/ui/models/return_visits/add_return_visit_model.dart';
import 'package:jama/ui/widgets/address_mapper_widget.dart';
import 'package:jama/ui/widgets/return_visit_personal_info_form.dart';
import 'package:jama/mixins/date_mixin.dart';
import 'package:jama/mixins/color_mixin.dart';
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers.dart';

import 'package:jama/ui/translation.dart';

class AddReturnVisitScreen extends StatefulWidget {
  AddReturnVisitScreen({Key key}) : super(key: key);

  @override
  _AddReturnVisitScreenState createState() => _AddReturnVisitScreenState();
}

class _AddReturnVisitScreenState extends State<AddReturnVisitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressImageController = AddressImageController();

  @override
  void dispose() {
    super.dispose();
    _addressImageController.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FocusWatcher(
      child: Scaffold(
        body: Container(
          color: AppStyles.primaryColor,
          child: SafeArea(
            top: false,
            child: ChangeNotifierProvider(
              create: (context) => AddReturnVisitModel(),
              child: Consumer<AddReturnVisitModel>(
                builder: (_, model, __) {
                  return Container(
                    color: AppStyles.primaryBackground,
                    child: Stack(children: <Widget>[
                      Positioned.fill(
                        bottom: 86,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                height: 227 + MediaQuery.of(context).padding.top,
                                width: MediaQuery.of(context).size.width,
                                child: Stack(
                                  children: <Widget>[
                                    Positioned.fill(
                                        top: 0,
                                        child: AddressMapper(
                                          addressImageController: _addressImageController,
                                          addressController: model.addressController,
                                          onUseAddressSelected: (address) {
                                            FocusScope.of(context).unfocus();
                                            model.address = address;
                                          },
                                          findCurrentAddress: true,
                                        )),
                                    Positioned(
                                      bottom: 0,
                                      width: MediaQuery.of(context).size.width,
                                      child: new Container(
                                        height: 38.00,
                                        decoration: BoxDecoration(
                                          color: AppStyles.primaryBackground,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(30.00),
                                            topRight: Radius.circular(30.00),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                        top: MediaQuery.of(context).padding.top +
                                            AppStyles.leftMargin,
                                        left: AppStyles.leftMargin,
                                        child: ClipOval(
                                          child: Material(
                                            color: Colors.white, // button color
                                            child: InkWell(
                                              // inkwell color
                                              child: SizedBox(
                                                  width: 38.0,
                                                  height: 38.0,
                                                  child: Center(
                                                      child: Icon(
                                                    Icons.close,
                                                    size: 17.0,
                                                  ))),
                                              onTap: () => Navigator.of(context).pop(),
                                            ),
                                          ),
                                        ))
                                  ],
                                ),
                              ),
                              Container(
                                  color: AppStyles.primaryBackground,
                                  child: _buildFormWidget(context, model))
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        width: MediaQuery.of(context).size.width,
                        height: 86,
                        child: Container(
                          color: AppStyles.secondaryBackground,
                          child: Column(
                            children: <Widget>[
                              Container(
                                height: 38.00,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: AppStyles.primaryBackground,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(30.00),
                                    bottomRight: Radius.circular(30.00),
                                  ),
                                ),
                              ),
                              FlatButton(
                                onPressed: () async {
                                  model.image = _addressImageController.value;
                                  if (_formKey.currentState.validate()) {
                                    _formKey.currentState.save();
                                    model.save();
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: Center(
                                  child: Text("save",
                                      style: AppStyles.heading2.copyWith(
                                          color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  _buildFormWidget(BuildContext context, AddReturnVisitModel model) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Selector<AddReturnVisitModel, bool>(
                selector: (_, m) => m.pinned,
                builder: (_, pinned, __) => Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: FlutterSwitch(
                        activeColor: AppStyles.primaryColor,
                        value: pinned,
                        activeText: "pinned",
                        inactiveText: "unpinned",
                        showOnOff: true,
                        width: 125,
                        onToggle: (v) => model.pinned = v,
                      )),
                ),
              ),
              StickyHeader(
                header: Container(
                  color: AppStyles.primaryBackground,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Divider(
                          color: Colors.black,
                          thickness: 1.0,
                          height: 10,
                        ),
                      )),
                      Text("Personal Info"),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Divider(
                          color: Colors.black,
                          thickness: 1.0,
                        ),
                      ))
                    ],
                  ),
                ),
                content: ReturnVisitPersonalInfoForm(returnVisitModel: model),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 15.0),
              ),
              StickyHeader(
                header: Container(
                  color: AppStyles.primaryBackground,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Divider(
                          color: Colors.black,
                          thickness: 1.0,
                          height: 10,
                        ),
                      )),
                      Text("Initial Call"),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Divider(
                          color: Colors.black,
                          thickness: 1.0,
                        ),
                      ))
                    ],
                  ),
                ),
                content: Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Selector<AddReturnVisitModel, DateTime>(
                        selector: (_, m) => m.initialCallDate,
                        shouldRebuild: (a, b) => !a.isSameDayAs(b),
                        builder: (_, date, __) => DatePickerTimeline(
                          date ?? DateTime.now(),
                          selectionColor: Colors.black12,
                          onDateChange: (date) {
                            model.initialCallDate = date;
                          },
                        ),
                      ),
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
                                onPressed: () => showAddSinglePlacementModal(
                                    context,
                                    (count, type, description) =>
                                        model.addPlacement(count, type, description)))
                          ],
                        ),
                      ),
                      model.initialCallPlacements.isNotEmpty
                          ? ListView.builder(
                              shrinkWrap: true,
                              itemCount: model.initialCallPlacements.length,
                              itemBuilder: (_, index) {
                                var placement = model.initialCallPlacements[index];
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
                                              padding: const EdgeInsets.only(
                                                  top: 4.0, right: 8.0, bottom: 4.0),
                                              child: Container(
                                                color: Colors.black12,
                                                child: Center(
                                                  child: Text(placement.item1.toString(),
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
                                                  Translation
                                                          .placementTypeToString[placement.item2] +
                                                      (placement.item1 > 1 ? "(s)" : ""),
                                                  style: AppStyles.smallTextStyle
                                                      .copyWith(fontWeight: FontWeight.bold)),
                                              if (placement.item3.isNotEmpty)
                                                Text(placement.item3,
                                                    style: AppStyles.smallTextStyle
                                                        .copyWith(color: Colors.black54))
                                            ],
                                          ),
                                          Expanded(child: Container()),
                                          IconButton(
                                              icon: Icon(Icons.close),
                                              onPressed: () {
                                                model.removePlacement(placement);
                                              })
                                        ],
                                      ),
                                    ),
                                    if (placement != model.initialCallPlacements.last)
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
                      Selector<AddReturnVisitModel, String>(
                          selector: (_, m) => m.initialCallNextTopic,
                          builder: (_, nextTopic, __) => TextFormField(
                              initialValue: nextTopic,
                              onSaved: (s) => model.initialCallNextTopic = s,
                              onFieldSubmitted: (s) => model.initialCallNextTopic = s,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                  labelText: "Next Topic/Question?",
                                  alignLabelWithHint: true,
                                  labelStyle: AppStyles.smallTextStyle))),
                      Selector<AddReturnVisitModel, String>(
                        selector: (_, m) => m.initialCallNotes,
                        builder: (_, notes, __) => TextFormField(
                            initialValue: notes,
                            onSaved: (s) => model.initialCallNotes = s,
                            onFieldSubmitted: (s) => model.initialCallNotes = s,
                            keyboardType: TextInputType.multiline,
                            maxLines: 4,
                            decoration: InputDecoration(
                                labelText: "Other Notes (Scriptures Used, etc.)",
                                alignLabelWithHint: true,
                                labelStyle: AppStyles.smallTextStyle)),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 50.0),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
