import 'package:flutter/foundation.dart';
import 'package:jama/data/core/db/dto.dart';
import 'package:jama/data/models/placement_model.dart';

class VisitDto extends DTO {
  /// the id of the parent return visit record.
  int parentRvId;

  /// the date of the visit.
  int date = DateTime.now().millisecondsSinceEpoch;

  /// notes regarding the visit.
  String notes;

  /// the type of visit.
  VisitType type;

  /// the placements made and videos shown during this visit.
  List<Placement> placements;

  String nextTopic;

  VisitDto._(
      {int id,
      @required this.parentRvId,
      @required this.date,
      this.notes,
      this.type,
      this.placements,
      this.nextTopic})
      : super(id: id);

  /// Instantiates a new visit for a given return visit.
  /// [id] The id of this record.
  /// [parentRvId] the id of the return visit record, must not be null.
  /// [date] The date of the visit.
  /// [type] The type of visit.
  /// [placements] The placements made or videos shown during this visit.
  factory VisitDto(
      {int id = -1,
      @required int parentRvId,
      @required DateTime date,
      String notes = "",
      VisitType type = VisitType.ReturnVisit,
      List<Placement> placements,
      String nextTopic}) {
    if (parentRvId == null || parentRvId == -1) {
      throw new ArgumentError.notNull("parent rv id");
    }
    if(date == null) {
      throw ArgumentError.notNull("visit date");
    }

    return VisitDto._(
        id: id ?? -1,
        parentRvId: parentRvId,
        date: date.millisecondsSinceEpoch,
        notes: notes ?? "",
        type: type ?? VisitType.ReturnVisit,
        placements: placements ?? [],
        nextTopic: nextTopic ?? "");
  }

  @override
  VisitDto.fromMap(Map<String, dynamic> map) {
    id = map["id"];
    parentRvId = map["parentRvId"];
    date = map["date"];
    notes = map["notes"];
    nextTopic = map["nextTopic"];
    type = VisitType.values.firstWhere((t) => t.toString().split('.').last == map["type"]);
    placements = [];
    for(var p in map["placements"] ?? []) {
      placements.add(Placement.fromMap(p));
    }
  }

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
