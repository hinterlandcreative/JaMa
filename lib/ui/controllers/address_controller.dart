import 'package:flutter/material.dart';
import 'package:jama/data/models/address_model.dart';

class AddressController extends ValueNotifier<Address> {
  AddressController([Address value]) : super(value ?? Address());

  void updateAddress(Address address) {
    this.value = address;
  }
}