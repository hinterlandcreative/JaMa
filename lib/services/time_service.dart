import 'dart:async';
import 'package:flutter/material.dart';

import 'package:kiwi/kiwi.dart' as kiwi;
import 'package:quiver/core.dart';

import 'package:jama/data/core/db/db_collection.dart';
import 'package:jama/data/core/db/query_package.dart';
import 'package:jama/data/models/dto/time_category_model.dart';
import 'package:jama/data/models/dto/time_model.dart';
import 'package:jama/services/database_service.dart';
import 'package:jama/ui/app_styles.dart';
import 'package:jama/mixins/color_mixin.dart';

class TimeService {
  DatabaseService _dbService;

  // we are not concerned with disposing of this because TimeService is registered as a singleton that
  // lasts the entire lifetime of the app.
  final StreamController<Time> _timeUpdatedController = StreamController<Time>.broadcast();
  final _timeCollectionName = "time";
  final _categoriesCollectionName = "categories";
  final Completer<DbCollection> _timeCollection = Completer();
  Stream<Time> get timeUpdatedStream => _timeUpdatedController.stream;

  TimeService([DatabaseService databaseService]) {
    var container = kiwi.Container();

    _dbService = databaseService ?? container.resolve<DatabaseService>();

    var getTimeCollection = () async {
      final db = await _dbService.getMainStorage();
      return db.collections(_timeCollectionName);
    };
    _timeCollection.complete(getTimeCollection());
  }

  void dispose() {
    _timeUpdatedController.close();
  }

  Future<List<TimeCategory>> getCategories() async {
    final db = await _dbService.getMainStorage();
    final catCollection = db.collections(_categoriesCollectionName);

    var categories = await catCollection.getAll((map) => TimeCategoryDto.fromMap(map));
    if (categories.isEmpty) {
      return await _createDefaultCategories(catCollection);
    }

    return categories.map((e) => TimeCategory.fromDto(e)).toList();
  }

  Future<List<TimeCategory>> _createDefaultCategories(DbCollection catCollection) async {
    var defaultCategory = TimeCategoryDto(
        name: "ministry",
        description: "Time spent in the minstry.",
        color: AppStyles.primaryColor.toHex());

    var ldcCategory = TimeCategoryDto(
        name: "local design construction",
        description: "Time spent in ldc support.",
        color: Colors.yellow.toHex());

    var remoteWorkCategory = TimeCategoryDto(
        name: "remote work",
        description: "Time spent as a Bethel remote volunteer.",
        color: Colors.red.toHex());

    defaultCategory = defaultCategory.copyWith(id: await catCollection.add(defaultCategory));
    ldcCategory = ldcCategory.copyWith(id: await catCollection.add(ldcCategory));
    remoteWorkCategory =
        remoteWorkCategory.copyWith(id: await catCollection.add(remoteWorkCategory));
    return [defaultCategory, ldcCategory, remoteWorkCategory]
        .map((e) => TimeCategory.fromDto(e))
        .toList();
  }

  /// gets all time entires.
  Future<List<Time>> getAllTimeEntries() async {
    final db = await _timeCollection.future;

    var entries = await db.getAll((map) => TimeDto.fromMap(map));

    return entries == null ? <Time>[] : entries.map((e) => Time.fromDto(e)).toList();
  }

  Future<List<Time>> getTimeEntriesByCategory(String category) async {
    if (category == null || !category.isNotEmpty) {
      throw ArgumentError.notNull('category');
    }

    final db = await _timeCollection.future;
    var entries = await db.query(
        [QueryPackage(key: "category.name", value: category, filter: FilterType.EqualTo)],
        (x) => TimeDto.fromMap(x));

    return entries == null ? <Time>[] : entries.map((e) => Time.fromDto(e)).toList();
  }

  /// get time entries filtered by date.
  /// If [startTime] is not set it will include all entries before [endTime].
  /// If [endTime] is not set it will include all entries after [startTime].
  /// Otherwise, it will include all entries between [startTime] and [endTime].
  /// If no dates are provided it returns all entries.
  Future<List<Time>> getTimeEntriesByDate({DateTime startTime, DateTime endTime}) async {
    if (startTime == null && endTime == null) {
      return await getAllTimeEntries();
    } else if ((startTime != null && endTime != null) && startTime.compareTo(endTime) > 0) {
      throw new ArgumentError("start time cannot be after end time.");
    }

    List<QueryPackage> query = _getQueryPackageForDates(startTime, endTime);

    final db = await _timeCollection.future;

    var entries = await db.query(query, (x) => TimeDto.fromMap(x),
        sort: SortOrderType.Decending, sortKey: "date");

    return entries == null ? <Time>[] : entries.map((e) => Time.fromDto(e)).toList();
  }

  /// saves or updates an existing time entry.
  Future<Time> saveOrAddTime(Time timeData) async {
    if (timeData.category == null) {
      throw ArgumentError.notNull("category");
    } else if (timeData.date == null || timeData.date.millisecondsSinceEpoch <= 0) {
      throw ArgumentError("Date must be set.");
    } else if (timeData.totalMinutes == 0) {
      throw ArgumentError("Total minutes must not be zero.");
    }

    final db = await _timeCollection.future;
    if (timeData.id <= 0) {
      timeData.id = await db.add(timeData._toDto());
    } else {
      await db.update(timeData._toDto());
    }

    _timeUpdatedController.sink.add(timeData);

    return timeData;
  }

  /// deletes a time entry if has been previously saved.
  Future deleteTime(Time timeData) async {
    if (timeData.id <= 0) {
      return;
    }

    final collection = await _timeCollection.future;
    await collection.deleteFromDto(timeData._toDto());

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

class Time {
  @visibleForTesting
  int id;
  TimeCategory _category;
  int _date;
  String _notes;
  int _placements;
  int _totalMinutes;
  int _videos;

  Time._(this.id, this._category, this._date, this._notes, this._placements, this._totalMinutes,
      this._videos);

  /// Creates a new time entry.
  factory Time.create(
          {@required DateTime date,
          @required int totalMinutes,
          @required TimeCategory category,
          String notes,
          int placements,
          int videos}) =>
      Time._(-1, category, date.millisecondsSinceEpoch, notes ?? "", placements ?? 0, totalMinutes,
          videos ?? 0);

  /// Creates a time entry from an `TimeDto`.
  factory Time.fromDto(TimeDto dto) => Time._(dto.id, TimeCategory.fromDto(dto.category), dto.date,
      dto.notes, dto.placements, dto.totalMinutes, dto.videos);

  bool get isSaved => id > 0;

  /// Gets the [category] of the time entry.
  TimeCategory get category => _category;

  /// Gets the [date] of the time entry.
  DateTime get date => DateTime.fromMillisecondsSinceEpoch(_date);

  /// Gets the [notes] of the time entry.
  String get notes => _notes;

  /// Gets the count of [placements] of the time entry.
  int get placements => _placements;

  /// Gets the [totalMinutes] of the time entry.
  int get totalMinutes => _totalMinutes;

  /// Gets the [duration] of the time entry.
  Duration get duration => Duration(minutes: _totalMinutes);

  /// Gets the count of [videos] of the time entry.
  int get videos => _videos;

  set category(TimeCategory value) {
    if (_category != value) {
      _category = value;
    }
  }

  set date(DateTime value) {
    if (_date != value.millisecondsSinceEpoch) {
      _date = value.millisecondsSinceEpoch;
    }
  }

  set notes(String value) {
    if (_notes != value) {
      _notes = value;
    }
  }

  set placements(int value) {
    if (_placements != value) {
      _placements = value;
    }
  }

  set totalMinutes(int value) {
    if (_totalMinutes != value) {
      _totalMinutes = value;
    }
  }

  set duration(Duration value) {
    if (_totalMinutes != value.inMinutes) {
      _totalMinutes = value.inMinutes;
    }
  }

  set videos(int value) {
    if (_videos != value) {
      _videos = value;
    }
  }

  TimeDto _toDto() => TimeDto(
      category: _category._toDto(),
      id: id,
      date: _date,
      totalMinutes: _totalMinutes,
      placements: _placements,
      videos: _videos,
      notes: _notes);

  Time copy() {
    return Time.fromDto(_toDto());
  }
}

class TimeCategory {
  int _id;
  Color _color;
  String _description;
  String _name;

  TimeCategory._(this._id, this._color, this._description, this._name);

  /// Creates a new time category.
  factory TimeCategory.create({@required Color color, @required String name, String description}) =>
      TimeCategory._(-1, color, description, name);

  /// Creates a time category from a `TimeCategoryDto`.
  factory TimeCategory.fromDto(TimeCategoryDto dto) => TimeCategory._(
      dto.id,
      dto.color?.isNotEmpty == false ? HexColor.fromHex(dto.color) : Colors.transparent,
      dto.description,
      dto.name);

  /// Gets the [color] of the category.
  Color get color => _color;

  /// Gets the [description] of the category.
  String get description => _description;

  /// Gets the [name] of the category.
  String get name => _name;

  bool get isMinistry => _id == 1;

  set color(Color value) {
    if (_color != value) {
      _color = value;
    }
  }

  set description(String value) {
    if (_description != value) {
      _description = value;
    }
  }

  set name(String value) {
    if (_name != value) {
      _name = value;
    }
  }

  TimeCategoryDto _toDto() =>
      TimeCategoryDto(id: _id, name: _name, description: _description, color: _color.toHex());

  @override
  operator ==(other) =>
      (other is TimeCategory &&
          this._id == other._id &&
          this.name == other.name &&
          this.description == other.description &&
          this.color == other.color) ||
      (other is TimeCategoryDto &&
          this._id == other.id &&
          this.name == other.name &&
          this.description == other.description &&
          this.color == HexColor.fromHex(other.color));

  @override
  int get hashCode => hash3(name, description, color);
}
