import 'package:meta/meta.dart';

import 'package:jama/data/models/dto/dto.dart';
import 'package:jama/data/models/dto/time_category_model.dart';

class TimeDto extends DTO {
  /// the date of this time entry in [milliseconds since epoch].
  final int date;

  /// the total number of minutes.
  final int totalMinutes;

  /// the category of time.
  final TimeCategoryDto category;

  /// notes about the entry.
  final String notes;

  /// the number of placements.
  final int placements;

  /// the number of videos.
  final int videos;

  const TimeDto({
    int id = -1,
    @required this.date,
    @required this.totalMinutes,
    @required this.category,
    this.notes = "",
    this.placements = 0,
    this.videos = 0
  }) : super(id: id);

  @override
  TimeDto.fromMap(Map<String, dynamic> map) : this(
    id: map['id'],
    date: map['date'],
    totalMinutes: map['totalMinutes'],
    category: TimeCategoryDto.fromMap(map['category']),
    notes: map['notes'],
    placements: map['placements'],
    videos: map['videos']
  );

  @override
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
  
  @override
  TimeDto copy() {
    return TimeDto.fromMap(this.toMap());
  }
}
