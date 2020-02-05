import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:jama/data/core/db/dto.dart';
import 'package:jama/mixins/color_mixin.dart';

class TimeCategory extends DTO {
  /// the name of the category. (REQUIRED)
  String name;

  /// A description of the category.
  String description;

  /// The display color.
  Color color;

  /// Instantiated a new instance of TimeCategory with the specified [name] (required), [description] and [color].
  TimeCategory({@required this.name, this.description, this.color});

  @override
  TimeCategory.fromMap(Map<String, dynamic> map) {
    id = map["id"];
    name = map["name"];
    description = map["description"];
    color = HexColor.fromHex(map["color"]);
  }

  @override
  Map<String, dynamic> toMap() {
     return {
       'id' : id,
       'name' : name,
       'description' : description,
       'color' : color.toHex()
     };
  }

  TimeCategory copy() {
    return TimeCategory.fromMap(this.toMap());
  }
}