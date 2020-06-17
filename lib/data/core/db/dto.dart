import 'package:jama/data/core/mappable.dart';

abstract class DTO extends Mappable {
  int id = -1;

  DTO({this.id});
}