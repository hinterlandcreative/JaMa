import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jama/data/core/db/db_collection.dart';
import 'package:jama/data/core/db/query_package.dart';
import 'package:jama/data/models/time_category_model.dart';
import 'package:jama/data/models/time_model.dart';
import 'package:jama/services/database_service.dart';
import 'package:jama/ui/app_styles.dart';
import 'package:kiwi/kiwi.dart' as kiwi;

class TimeService {
  DatabaseService _dbService;
  DbCollection _timeCollection;

  // we are not concerned with disposing of this because TimeService is registered as a singleton that 
  // lasts the entire lifetime of the app.
  final StreamController<Time> _timeUpdatedController = StreamController<Time>.broadcast();
  final _timeCollectionName = "time";
  final _categoriesCollectionName = "categories";
  Stream<Time> get timeUpdatedStream => _timeUpdatedController.stream;


  TimeService([DatabaseService databaseService]) {
    var container = kiwi.Container();

    _dbService = databaseService ?? container.resolve<DatabaseService>();
  }

  Future<List<TimeCategory>> getCategories() async {
    final db = await _dbService.getMainStorage();
    final catCollection = db.collections(_categoriesCollectionName);

    var categories =
        await catCollection.getAll((map) => TimeCategory.fromMap(map));
    if (categories.isEmpty) {
      return await _createDefaultCategories(catCollection);
    }

    return categories;
  }

  Future<List<TimeCategory>> _createDefaultCategories(DbCollection catCollection) async {
    var defaultCategory = TimeCategory(
      name: "ministry",
      description: "Time spent in the minstry.",
      color: AppStyles.primaryColor);

    var ldcCategory = TimeCategory(
      name: "local design construction",
      description: "Time spent in ldc support.",
      color: Colors.yellow
    );

    var remoteWorkCategory = TimeCategory(
      name: "remote work",
      description: "Time spent as a Bethel remote volunteer.",
      color: Colors.red
    );
    
    defaultCategory.id = await catCollection.add(defaultCategory);
    ldcCategory.id = await catCollection.add(ldcCategory);
    remoteWorkCategory.id = await catCollection.add(remoteWorkCategory);
    return [defaultCategory, ldcCategory, remoteWorkCategory];
  }

  Future<DbCollection> _getTimeCollection() async {
    if (_timeCollection != null) {
      return _timeCollection;
    }

    final db = await _dbService.getMainStorage();

    return _timeCollection = db.collections(_timeCollectionName);
  }

  /// gets all time entires.
  Future<List<Time>> getAllTimeEntries() async {
    final collection = await _getTimeCollection();

    return await collection.getAll((map) => Time.fromMap(map));
  }

  Future<List<Time>> getTimeEntriesByCategory(String category) async {
    if (category == null || !category.isNotEmpty) {
      throw ArgumentError.notNull('category');
    }

    final collection = await _getTimeCollection();
    return await collection.query([
      QueryPackage(
          key: "category.name", value: category, filter: FilterType.EqualTo)
    ], (x) => Time.fromMap(x));
  }

  /// get time entries filtered by date.
  /// If [startTime] is not set it will include all entries before [endTime].
  /// If [endTime] is not set it will include all entries after [startTime].
  /// Otherwise, it will include all entries between [startTime] and [endTime].
  /// If no dates are provided it returns all entries.
  Future<List<Time>> getTimeEntriesByDate(
      {DateTime startTime, DateTime endTime}) async {
    if (startTime == null && endTime == null) {
      return await getAllTimeEntries();
    } else if ((startTime != null && endTime != null) &&
        startTime.compareTo(endTime) > 0) {
      throw new ArgumentError("start time cannot be after end time.");
    }

    List<QueryPackage> query = _getQueryPackageForDates(startTime, endTime);

    final collection = await _getTimeCollection();

    return await collection.query(query, (x) => Time.fromMap(x),
        sort: SortOrderType.Decending, sortKey: "date");
  }

  /// saves or updates an existing time entry.
  Future<Time> saveOrAddTime(Time timeData) async {
    if (timeData.category == null || timeData.category.id == -1) {
      throw new ArgumentError.notNull("category");
    } else if (timeData.totalMinutes == 0) {
      throw new ArgumentError("Total minutes must not be zero.");
    } else if (timeData.date == 0) {
      throw new ArgumentError("Date must be set");
    }

    final collection = await _getTimeCollection();
    if (timeData.id == -1) {
      timeData.id = await collection.add(timeData);
    } else {
      await collection.update(timeData);
    }

    _timeUpdatedController.sink.add(timeData);

    return timeData;
  }

  /// deletes a time entry if has been previously saved.
  Future deleteTime(Time timeData) async {
    if (timeData.id == -1) {
      return;
    }

    final collection = await _getTimeCollection();
    await collection.deleteFromDto(timeData);

    _timeUpdatedController.sink.add(null);
  }



  List<QueryPackage> _getQueryPackageForDates(DateTime startTime, DateTime endTime) {
    var query = List<QueryPackage>();
    if (startTime == null) {
      query.add(QueryPackage(
          key: "date",
          value: endTime.millisecondsSinceEpoch,
          filter: FilterType.LessThanOrEqualTo));
    } else if (endTime == null) {
      query.add(QueryPackage(
          key: "date",
          value: startTime.millisecondsSinceEpoch,
          filter: FilterType.GreaterThanOrEqualTo));
    } else {
      query.add(QueryPackage(
          key: "date",
          value: startTime.millisecondsSinceEpoch,
          filter: FilterType.GreaterThanOrEqualTo));
      query.add(QueryPackage(
          key: "date",
          value: endTime.millisecondsSinceEpoch,
          filter: FilterType.LessThanOrEqualTo));
    }
    return query;
  }
}
