import 'package:jama/ui/models/collection_base_model.dart';
import 'package:jama/ui/models/grouped_collection_base_model.dart';

/// A collection of return visits grouped by a common value
abstract class GroupedReturnVisitCollection<TModel> extends CollectionBaseModel<GroupedCollection<TModel>> {}