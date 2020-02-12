import 'package:flutter/material.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:jama/data/models/return_visit_model.dart';
import 'package:jama/ui/models/return_visits/edittable_return_visit_base_model.dart';
import 'package:jama/ui/translation.dart';
import 'package:provider/provider.dart';

import '../app_styles.dart';

class ReturnVisitPersonalInfoForm extends StatefulWidget {
  final EdittableReturnVisitBaseModel returnVisitModel;
  ReturnVisitPersonalInfoForm({Key key, this.returnVisitModel})
      : super(key: key);

  @override
  _ReturnVisitPersonalInfoFormState createState() =>
      _ReturnVisitPersonalInfoFormState();
}

class _ReturnVisitPersonalInfoFormState
    extends State<ReturnVisitPersonalInfoForm> {
  FocusNode _nameFocusNode;
  FocusNode _streetFocusNode;
  TextEditingController _streetTextController;
  FocusNode _cityFocusNode;
  TextEditingController _cityTextController;
  FocusNode _stateFocusNode;
  TextEditingController _stateTextController;
  FocusNode _postalCodeFocusNode;
  TextEditingController _postalCodeTextController;
  FocusNode _countryFocusNode;
  TextEditingController _countryTextControlller;
  FocusNode _notesFocusNode;

  @override
  void initState() {
    _nameFocusNode = FocusNode();
    _streetTextController = TextEditingController();
    _streetFocusNode = FocusNode();
    _cityTextController = TextEditingController();
    _cityFocusNode = FocusNode();
    _stateTextController = TextEditingController();
    _stateFocusNode = FocusNode();
    _postalCodeFocusNode = FocusNode();
    _postalCodeTextController = TextEditingController();
    _countryFocusNode = FocusNode();
    _countryTextControlller = TextEditingController();
    _notesFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _streetFocusNode.dispose();
    _streetTextController.dispose();
    _cityFocusNode.dispose();
    _cityTextController.dispose();
    _stateFocusNode.dispose();
    _stateTextController.dispose();
    _postalCodeFocusNode.dispose();
    _postalCodeTextController.dispose();
    _countryFocusNode.dispose();
    _countryTextControlller.dispose();
    _notesFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.returnVisitModel,
      child: Consumer<EdittableReturnVisitBaseModel>(
        builder: (_, model, __) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Selector<EdittableReturnVisitBaseModel, String>(
              selector: (_, m) => m.name,
              builder: (_, name, __) => Padding(
                padding: EdgeInsets.only(bottom: 24.0),
                child: TextFormField(
                  focusNode: _nameFocusNode,
                  textInputAction: TextInputAction.next,
                  initialValue: name,
                  onSaved: (s) => model.name = s,
                  onFieldSubmitted: (s) {
                    model.name = s;
                    _nameFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(_streetFocusNode);
                  },
                  decoration: InputDecoration(
                    labelText: "Name",
                    labelStyle: AppStyles.smallTextStyle)),
              ),
            ),
            Text(
              "Gender",
              style: AppStyles.smallTextStyle.copyWith(color: Colors.black54)),
            Selector<EdittableReturnVisitBaseModel, String>(
              selector: (_, m) => m.gender,
              builder: (_, gender, __) => RadioButtonGroup(
                picked: gender,
                orientation: GroupedButtonsOrientation.HORIZONTAL,
                labels: [Translation.genderToString[Gender.Male], Translation.genderToString[Gender.Female]],
                activeColor: AppStyles.primaryColor,
                labelStyle: AppStyles.heading4,
                itemBuilder: (radio, text, i) => Padding(
                  padding: EdgeInsets.only(right: 45.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[radio, text],
                  ),
                ),
                onSelected: (s) {
                  model.gender = s;
                },
              ),
            ),
            Selector<EdittableReturnVisitBaseModel, String>(
              selector: (_, m) => m.street,
              builder: (_, street, __) {
                if (!_streetFocusNode.hasFocus) {
                  _streetTextController.text = street;
                }
                return Padding(
                  padding: EdgeInsets.only(bottom: 24.0),
                  child: TextFormField(
                    focusNode: _streetFocusNode,
                    controller: _streetTextController,
                    textInputAction: TextInputAction.next,
                    onSaved: (s) => model.street = s,
                    onChanged: (s) => model.street = s,
                    onFieldSubmitted: (s) {
                      model.street = s;
                      _streetFocusNode.unfocus();
                      FocusScope.of(context).requestFocus(_cityFocusNode);
                    },
                    style: AppStyles.heading4,
                    decoration: InputDecoration(
                      labelText: "Address",
                      labelStyle: AppStyles.smallTextStyle)),
                );
              },
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Selector<EdittableReturnVisitBaseModel, String>(
                    selector: (_, m) => m.city,
                    builder: (_, city, __) {
                      if (!_cityFocusNode.hasFocus) {
                        _cityTextController.text = city;
                      }
                      return Flexible(
                        child: TextFormField(
                          focusNode: _cityFocusNode,
                          controller: _cityTextController,
                          textInputAction: TextInputAction.next,
                          validator: (s) {
                            if (s.isEmpty) {
                              return "City must not be empty.";
                            } else {
                              return null;
                            }
                          },
                          onSaved: (s) => model.city = s,
                          onChanged: (s) => model.city = s,
                          onFieldSubmitted: (s) {
                            model.city = s;
                            _cityFocusNode.unfocus();
                            FocusScope.of(context)
                                .requestFocus(_stateFocusNode);
                          },
                          decoration: InputDecoration(
                            labelText: "City",
                            labelStyle: AppStyles.smallTextStyle)));
                  },
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.0),
                  ),
                  Selector<EdittableReturnVisitBaseModel, String>(
                    selector: (_, m) => m.state,
                    builder: (_, state, __) {
                      if (!_stateFocusNode.hasFocus) {
                        _stateTextController.text = state;
                      }
                      return Flexible(
                        child: TextFormField(
                          focusNode: _stateFocusNode,
                          controller: _stateTextController,
                          textInputAction: TextInputAction.next,
                          onSaved: (s) => model.state = s,
                          onChanged: (s) => model.state = s,
                          onFieldSubmitted: (s) {
                            model.state = s;
                            _stateFocusNode.unfocus();
                            FocusScope.of(context)
                                .requestFocus(_postalCodeFocusNode);
                          },
                          decoration: InputDecoration(
                            labelText: "State / Province",
                            labelStyle: AppStyles.smallTextStyle)));
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Selector<EdittableReturnVisitBaseModel, String>(
                    selector: (_, m) => m.postalCode,
                    builder: (_, postalCode, __) {
                      if (!_postalCodeFocusNode.hasFocus) {
                        _postalCodeTextController.text = postalCode;
                      }
                      return Flexible(
                        flex: 35,
                        child: TextFormField(
                          focusNode: _postalCodeFocusNode,
                          controller: _postalCodeTextController,
                          textInputAction: TextInputAction.next,
                          onSaved: (s) => model.postalCode = s,
                          onChanged: (s) => model.postalCode = s,
                          onFieldSubmitted: (s) {
                            model.postalCode = s;
                            _postalCodeFocusNode.unfocus();
                            FocusScope.of(context).requestFocus(_countryFocusNode);
                          },
                          decoration: InputDecoration(
                            labelText: "Postal Code",
                            labelStyle: AppStyles.smallTextStyle)));
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.0),
                  ),
                  Selector<EdittableReturnVisitBaseModel, String>(
                    selector: (_, m) => m.country,
                    builder: (_, country, __) {
                      if (!_countryFocusNode.hasFocus) {
                        _countryTextControlller.text = country;
                      }
                      return Flexible(
                        flex: 65,
                        child: TextFormField(
                          focusNode: _countryFocusNode,
                          controller: _countryTextControlller,
                          textInputAction: TextInputAction.next,
                          onSaved: (s) => model.country = s,
                          onChanged: (s) => model.country = s,
                          onFieldSubmitted: (s) {
                            model.country = s;
                            _countryFocusNode.unfocus();
                            FocusScope.of(context).requestFocus(_notesFocusNode);
                          },
                          decoration: InputDecoration(
                            labelText: "Country",
                            labelStyle: AppStyles.smallTextStyle)));
                    },
                  ),
                ],
              ),
            ),
            Selector<EdittableReturnVisitBaseModel, String>(
              selector: (_, m) => m.notes,
              builder: (_, notes, __) => TextFormField(
                initialValue: notes,
                focusNode: _notesFocusNode,
                onSaved: (s) => model.notes = s,
                onFieldSubmitted: (s) => model.notes = s,
                keyboardType: TextInputType.multiline,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: "Notes",
                  alignLabelWithHint: true,
                  labelStyle: AppStyles.smallTextStyle)),
            ),
          ]),
      ),
    );
  }
}
