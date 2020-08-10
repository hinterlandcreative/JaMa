import 'package:flutter/foundation.dart';

import 'package:jama/data/models/dto/dto.dart';
import 'package:jama/data/models/placement.dart';

class VisitDto extends DTO {
  /// the [id] of the parent return visit record.
  final int parentRvId;

  /// the [date] of the visit.
  final int date;

  /// [notes] regarding the visit.
  final String notes;

  /// the [type] of visit.
  final VisitType type;

  /// the [placements] made and videos shown during this visit.
  final List<Placement> placements;

  /// The [nextTopic] to discuss.
  final String nextTopic;

  const VisitDto(
      {int id = -1,
      @required this.parentRvId,
      @required this.date,
      this.notes = "",
      this.type = VisitType.ReturnVisit,
      this.placements,
      this.nextTopic = ""})
      : super(id: id);

  @override
  VisitDto.fromMap(Map<String, dynamic> map)
      : this(
            id: map["id"],
            parentRvId: map["parentRvId"],
            date: map["date"],
            notes: map["notes"],
            nextTopic: map["nextTopic"],
            type: VisitType.values.firstWhere((t) => t.toString().split('.').last == map["type"]),
            placements: map.containsKey("placements")
                ? map["placements"].map<Placement>((p) => Placement.fromMap(p)).toList()
                : <Placement>[]);

  @override
  VisitDto copy() {
    return VisitDto.fromMap(this.toMap());
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'parentRvId': parentRvId,
      'date': date,
      'notes': notes,
      'nextTopic': nextTopic,
      'type': type.toString().split('.').last,
      'placements': placements.map((p) => p.toMap()).toList()
    };
  }

  VisitDto copyWith(
      {int id,
      int parentRvId,
      int date,
      String notes,
      VisitType type,
      List<Placement> placements,
      String nextTopic}) {
    return VisitDto(
        id: id ?? this.id,
        parentRvId: parentRvId ?? this.parentRvId,
        date: date ?? this.parentRvId,
        notes: notes ?? this.notes,
        type: type ?? this.type,
        placements: placements ?? this.placements,
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
