import 'package:flutter/foundation.dart';

import 'package:jama/data/models/dto/dto.dart';

class VisitDto extends DTO {
  static const String _column_Id = "VisitId";
  static const String _column_Date = "Date";
  static const String _column_Notes = "VisitNotes";
  static const String _column_Type = "VisitType";
  static const String _column_NextTopic = "NextTopic";
  static const String _column_ParentRv = "FK_ReturnVisit_Visit_ParentRv";

  /// the [id] of the parent return visit record.
  final int parentRvId;

  /// the [date] of the visit.
  final int date;

  /// [notes] regarding the visit.
  final String notes;

  /// the [type] of visit.
  final VisitType type;

  /// The [nextTopic] to discuss.
  final String nextTopic;

  const VisitDto(
      {int id = -1,
      @required this.parentRvId,
      @required this.date,
      this.notes = "",
      this.type = VisitType.ReturnVisit,
      this.nextTopic = ""})
      : super(id: id);

  @override
  VisitDto.fromMap(Map<String, dynamic> map)
      : this(
            id: map[_column_Id],
            parentRvId: map[_column_ParentRv],
            date: map[_column_Date],
            notes: map[_column_Notes],
            nextTopic: map[_column_NextTopic],
            type: VisitType.values
                .firstWhere((t) => t.toString().split('.').last == map[_column_Type]));

  @override
  VisitDto copy() {
    return VisitDto.fromMap(this.toMap());
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      if (id > 0) _column_Id: id,
      _column_ParentRv: parentRvId,
      _column_Date: date,
      _column_Notes: notes ?? "",
      _column_NextTopic: nextTopic ?? "",
      _column_Type: type.toString().split('.').last,
    };
  }

  VisitDto copyWith(
      {int id, int parentRvId, int date, String notes, VisitType type, String nextTopic}) {
    return VisitDto(
        id: id ?? this.id,
        parentRvId: parentRvId ?? this.parentRvId,
        date: date ?? this.date,
        notes: notes ?? this.notes,
        type: type ?? this.type,
        nextTopic: nextTopic ?? this.nextTopic);
  }
}

enum VisitType { NotAtHome, ReturnVisit, Study }

enum PlacementType {
  Magazine,
  Book,
  WebLink,
  Tract,
  Brochure,
  Dvd,
  Invitation,
  MemorialInvite,
  ConventionInvite,
  CampaignItem,
  Video,
  Other
}
