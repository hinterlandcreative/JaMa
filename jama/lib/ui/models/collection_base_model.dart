import 'dart:collection';

import 'package:flutter/material.dart';

abstract class CollectionBaseModel<T> with ChangeNotifier {

  /// the items to display.
  UnmodifiableListView<T> get items;

  /// load the children items.
  Future loadChildren();
}