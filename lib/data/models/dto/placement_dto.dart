import 'package:flutter/foundation.dart';
import 'package:jama/data/models/dto/dto.dart';
import 'package:jama/data/models/dto/visit_dto.dart';
import 'package:quiver/core.dart';

class PlacementDto extends DTO {
  static const String _columnId = "PlacementId";
  static const String _columnCount = "Count";
  static const String _columnNotes = "PlacementNotes";
  static const String _columnType = "PlacementType";
  static const String _columnParentVisit = "FK_Visit_Placement_ParentVisit";

  /// The [count] of placements.
  final int count;

  /// The [type] of the placement.
  final PlacementType type;

  /// Optional [notes] of the placement.
  final String notes;

  /// The [parentVisit] of the placement.
  final int parentVisit;

  const PlacementDto(
      {int id = -1,
      @required this.count,
      @required this.type,
      @required this.parentVisit,
      this.notes = ""})
      : super(id: id);

  @override
  PlacementDto.fromMap(Map<String, dynamic> map)
      : this(
            id: map[_columnId],
            count: map[_columnCount],
            type: PlacementType.values
                .firstWhere((element) => element.toString().split('.').last == map[_columnType]),
            notes: map[_columnNotes],
            parentVisit: map[_columnParentVisit]);

  @override
  PlacementDto copy() {
    return PlacementDto.fromMap(this.toMap());
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      if (id > 0) _columnId: id,
      _columnCount: count,
      _columnType: type.toString().split('.').last,
      _columnNotes: notes,
      _columnParentVisit: parentVisit
    };
  }

  @override
  int get hashCode => hash3(count, type, notes);

  @override
  operator ==(other) {
    if (other is PlacementDto) {
      return other.count == count && other.notes == notes && other.type == type;
    }

    return false;
  }
}
