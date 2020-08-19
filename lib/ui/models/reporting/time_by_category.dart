import 'package:jama/services/time_service.dart';
import 'package:jama/mixins/duration_mixin.dart';

class DurationByCategory {
  final Duration time;
  final TimeCategory category;

  DurationByCategory(this.category, this.time);

  /// Gets the [time] as a formatted string.
  String get timeString => time.toShortString();
}
