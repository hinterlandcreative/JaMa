import 'package:jama/data/core/db/dto.dart';

import 'address_model.dart';

class ReturnVisit extends DTO {
  int id;
  Address address;
  String name;
  Gender gender;
  String notes;
  DateTime created;
  DateTime lastVisit;

  ReturnVisit({Address address, String name, Gender gender, String notes, DateTime created, DateTime lastVisit}) {
    this.address = address;
    this.name = name;
    this.gender = gender;
    this.notes = notes;
    this.created = created ?? DateTime.now();
    this.lastVisit = lastVisit;
  }

  @override
  ReturnVisit.fromMap(Map<String, dynamic> map) {
      id = map['id'];
      address = map['address'];
      name = map['name'];
      gender = map['gender'];
      notes = map['notes'];
      created = map['created'];
      lastVisit = map['lastVisit'];

  }

  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'address' : address,
      'name' : name,
      'gender' : gender,
      'notes' : notes,
      'created' : created,
      'lastVisit' : lastVisit
    };
  }

  ReturnVisit copy() {
    return ReturnVisit.fromMap(this.toMap());
  }
}

enum  Gender {
  Male,
  Female
}