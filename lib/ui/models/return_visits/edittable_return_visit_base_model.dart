import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:jama/data/models/address_model.dart';
import 'package:jama/data/models/return_visit_model.dart';

abstract class EdittableReturnVisitBaseModel extends ChangeNotifier {
  bool get pinned => null;
  set pinned(bool isPinned);

  String get name => null;
  set name(String name);

  Gender get gender => null;
  set gender(Gender gender);

  Address get address => null;
  set address(Address address);

  String get street => null;
  set street(String street);

  String get city => null;
  set city(String city);

  String get state => null;
  set state(String state);

  String get postalCode => null;
  set postalCode(String postalCode);

  String get country => null;
  set country(String country);

  String get notes => null;
  set notes(String notes);

  Uint8List get image => null;
  set image(Uint8List imagePath);

  double get latitude => null;
  set latitude(double lat);

  double get longitude => null;
  set longitude(double long);

  Future save();

  bool validate();
}