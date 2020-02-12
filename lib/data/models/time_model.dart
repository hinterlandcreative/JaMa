import 'package:jama/data/core/db/dto.dart';
import 'package:jama/data/models/time_category_model.dart';
import 'package:meta/meta.dart';

class Time extends DTO {
  /// the date of this time entry in [milliseconds since epoch].
  int date;

  /// the total number of minutes.
  int totalMinutes;

  /// the category of time.
  TimeCategory category;

  /// notes about the entry.
  String notes;

  /// the number of placements.
  int placements;

  /// the number of videos.
  int videos;

  DateTime get formattedDate => DateTime.fromMillisecondsSinceEpoch(date);
  Duration get duration => Duration(minutes: totalMinutes);

  Time(
      {int id,
      @required this.date,
      @required this.totalMinutes,
      @required this.category,
      this.notes = "",
      this.placements = 0,
      this.videos = 0}) : super(id: id ?? -1);

  @override
  Time.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    date = map['date'];
    totalMinutes = map['totalMinutes'];
    category = TimeCategory.fromMap(map['category']);
    notes = map['notes'];
    placements = map['placements'];
    videos = map['videos'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'totalMinutes': totalMinutes,
      'category': category.toMap(),
      'notes': notes,
      'placements': placements,
      'videos': videos
    };
  }
  
  Time copy() {
    return Time.fromMap(this.toMap());
  }
}
