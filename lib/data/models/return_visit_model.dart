import 'package:jama/data/core/db/dto.dart';
import 'package:jama/data/models/visit_model.dart';

import 'address_model.dart';

class ReturnVisit extends DTO {
  Address address;
  String name;
  Gender gender;
  String notes;
  String imagePath;
  int lastVisitDate;
  int lastVisitId;
  bool pinned;

  ReturnVisit({Address address, String name, Gender gender, String notes, String imagePath, Visit lastVisit, bool pinned}) : super(id: -1) {
    this.address = address ?? Address();
    this.name = name;
    this.gender = gender;
    this.notes = notes;
    this.imagePath = imagePath;
    this.lastVisitDate = lastVisit?.date;
    this.lastVisitId = lastVisit?.id;
    this.pinned = pinned;
  }

  @override
  ReturnVisit.fromMap(Map<String, dynamic> map) {
      id = map['id'];
      address = Address.fromMap(map['address']);
      name = map['name'];
      gender = map['gender'] == "Male" ? Gender.Male : Gender.Female;
      notes = map['notes'];
      imagePath = map["imagePath"];
      lastVisitDate = map['lastVisitDate'];
      lastVisitId = map['lastVisitId'];
      pinned = map['pinned'] ?? false;
  }

  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'address' : address.toMap(),
      'name' : name,
      'gender' : gender.toString().split('.').last,
      'notes' : notes,
      'imagePath' : imagePath,
      'lastVisitDate' : lastVisitDate,
      'lastVisitId' : lastVisitId,
      'searchString' : createSearchString(),
      'pinned' : pinned
      };
  }
      
        ReturnVisit copy() {
          return ReturnVisit.fromMap(this.toMap());
        }
      
    String createSearchString() {
      var s = "";
      if(name.isNotEmpty) {
        s += name;
      } else {
        s += gender.toString().split('.').last;
      }
      s += ' ' + address.toFormattedString();
      return s;
    }
}

enum  Gender {
  Male,
  Female
}