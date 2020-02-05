import 'package:duration/duration.dart';
import 'package:intl/intl.dart';

extension DurationMixin on Duration {
  String toShortString() {
    return printDuration(this, abbreviated: true, spacer: "", delimiter: "");
  }
}
