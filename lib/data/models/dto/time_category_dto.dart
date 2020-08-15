import 'package:flutter/material.dart';
import 'package:jama/data/models/dto/dto.dart';
import 'package:meta/meta.dart';

class TimeCategoryDto extends DTO {
  static const String _idColumnName = "TimeCategoryId";
  static const String _nameColumnName = "Name";
  static const String _colorColumnName = "Color";
  static const String _descriptionColumnName = "Description";

  /// the [name] of the category. (REQUIRED)
  final String name;

  /// A [description] of the category.
  final String description;

  /// The display [color].
  final String color;

  /// Instantiated a new instance of TimeCategory with the specified [name] (required), [description] and [color].
  TimeCategoryDto({int id, @required this.name, this.description, this.color})
      : super(id: id ?? -1);

  @override
  TimeCategoryDto.fromMap(Map<String, dynamic> map)
      : this(
            id: map[_idColumnName],
            name: map[_nameColumnName],
            description: map[_descriptionColumnName],
            color: map[_colorColumnName]);

  TimeCategoryDto copyWith({int id, String name, String description, String color}) =>
      TimeCategoryDto(
          id: id ?? this.id,
          name: name ?? this.name,
          description: description ?? this.description,
          color: color ?? this.color);

  @override
  Map<String, dynamic> toMap() {
    return {
      if (id != null && id > 0) _idColumnName: id,
      _nameColumnName: name,
      _descriptionColumnName: description,
      _colorColumnName: color
    };
  }

  @override
  TimeCategoryDto copy() {
    return TimeCategoryDto.fromMap(this.toMap());
  }
}
