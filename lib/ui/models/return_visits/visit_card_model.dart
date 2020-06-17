import 'package:intl/intl.dart';
import 'package:jama/data/models/visit_model.dart';

import '../../translation.dart';

class VisitCardModel {
  final Visit _visit;

  VisitCardModel._(this._visit);

  factory VisitCardModel({Visit visit}) {
    return VisitCardModel._(visit);
  }

  String get formattedDate => DateFormat
  .yMMMMd(Intl.defaultLocale)
  .format(DateTime
    .fromMillisecondsSinceEpoch(_visit.date));

  String get formattedTime => DateFormat
    .jm(Intl.defaultLocale)
    .format(DateTime
      .fromMillisecondsSinceEpoch(_visit.date));

  String get visitTypeString => Translation.visitTypeToString[_visit.type];
  VisitType get visitType => _visit.type;
  String get placements => _getPlacementsString();
  String get nextTopic => _visit.nextTopic ?? "";
  String get notes => _visit.notes ?? "";

  String _getPlacementsString() {
    if(_visit.placements.isEmpty) {
      return "";
    }

    var s = "${_visit.placements.first.count} ${Translation.placementTypeToString[_visit.placements.first.type]}" + (_visit.placements.first.notes.isEmpty ? "" : " (${_visit.placements.first.notes})");
    if(_visit.placements.length > 1) {
      s += " and others";
    }

    return s;
  }
}