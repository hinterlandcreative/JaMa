import 'package:meta/meta.dart';

import 'package:jama/data/models/dto/dto.dart';
import 'package:jama/data/models/dto/time_category_dto.dart';

class TimeDto extends DTO {
  static const String _idColumnName = "TimeEntryId";
  static const String _dateColumnName = "Date";
  static const String _totalMinutesColumnName = "TotalMinutes";
  static const String _placementsColumnName = "Placements";
  static const String _videosColumnName = "Videos";
  static const String _categoryIdColumnName = "FK_TimeCategory_Time";
  static const String _notesColumnName = "TimeNotes";

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

  const TimeDto(
      {int id = -1,
      @required this.date,
      @required this.totalMinutes,
      @required this.category,
      this.notes = "",
      this.placements = 0,
      this.videos = 0})
      : super(id: id);

  @override
  TimeDto.fromMap(Map<String, dynamic> map)
      : this(
            id: map[_idColumnName],
            date: map[_dateColumnName],
            totalMinutes: map[_totalMinutesColumnName],
            category: TimeCategoryDto.fromMap(map),
            notes: map[_notesColumnName],
            placements: map[_placementsColumnName],
            videos: map[_placementsColumnName]);

  @override
  Map<String, dynamic> toMap() {
    return {
      if (id != null && id > 0) _idColumnName: id,
      _dateColumnName: date,
      _totalMinutesColumnName: totalMinutes,
      _categoryIdColumnName: category.id,
      _notesColumnName: notes,
      _placementsColumnName: placements,
      _videosColumnName: videos
    };
  }

  @override
  TimeDto copy() {
    return TimeDto.fromMap(this.toMap());
  }
}
