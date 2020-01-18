import 'package:jama/data/core/db/db_collection.dart';

class QueryPackage {
  String key;
  dynamic value;
  FilterType filter;

  QueryPackage({this.key, this.value, this.filter});
}