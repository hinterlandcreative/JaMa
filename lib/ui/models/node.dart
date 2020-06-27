import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

class Node {
  final String content;
  final List<Node> children;

  Node({this.content, this.children});

  @override
  bool operator ==(other) => other is Node 
      && this.content == other.content 
      && listEquals(this.children, other.children);

  @override
  int get hashCode => hash2(content, children);


}

