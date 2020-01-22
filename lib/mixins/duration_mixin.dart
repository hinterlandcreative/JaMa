import 'package:duration/duration.dart';

extension DurationMixin on Duration {
  String toShortString() =>
      printDuration(this, abbreviated: true, spacer: "", delimiter: "");
}
