import 'package:duration/duration.dart';

extension DurationMixin on Duration {
  String toShortString() {
    return printDuration(this, abbreviated: true, spacer: "", delimiter: "");
  }
}
