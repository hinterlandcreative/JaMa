import 'package:flutter/material.dart';
import 'package:jama/data/models/dto/dto.dart';
import 'package:meta/meta.dart';

class TimeCategoryDto extends DTO {
  /// the [name] of the category. (REQUIRED)
  final String name;

  /// A [description] of the category.
  final String description;

  /// The display [color].
  final String color;

  /// Instantiated a new instance of TimeCategory with the specified [name] (required), [description] and [color].
  TimeCategoryDto({int id, @required this.name, this.description, this.color}) : super(id: id ?? -1);

  @override
  TimeCategoryDto.fromMap(Map<String, dynamic> map) : this(
    id: map["id"],
    name: map["name"],
    description: map["description"],
    color: map["color"]
  );

  TimeCategoryDto copyWith({int id, String name, String description, String color}) => TimeCategoryDto(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description, 
    color: color ?? this.color
  );

  @override
  Map<String, dynamic> toMap() {
     return {
       'id' : id,
       'name' : name,
       'description' : description,
       'color' : color
     };
  }

  @override
  TimeCategoryDto copy() {
    return TimeCategoryDto.fromMap(this.toMap());
  }
}