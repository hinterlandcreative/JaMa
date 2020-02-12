import 'package:flutter/foundation.dart';
import 'package:jama/data/core/mappable.dart';
import 'package:jama/data/models/visit_model.dart';

class Placement extends Mappable {
  int count;
  PlacementType type;
  String notes;

  Placement({@required this.count, @required this.type, this.notes});

  @override
  Placement.fromMap(Map<String,dynamic> map) {
    count = map["count"];
    type = PlacementType.values.firstWhere((t) => t.toString().split('.').last == map["type"]);
    notes = map["notes"];
  }

  @override
  Placement copy() {
    return Placement.fromMap(this.toMap());
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'count' : count,
      'type' : type.toString().split('.').last,
      'notes' : notes
    };
  }

}