import 'package:flutter/widgets.dart';

abstract class Navigatable {
  /// Navigate to the item.
  Future navigate(BuildContext context);
}
