import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'package:quiver/core.dart';
import 'package:quiver/time.dart';
import 'package:sqflite/sqflite.dart';
import 'package:supercharged/supercharged.dart';
import 'package:kiwi/kiwi\.dart';

import 'package:jama/data/models/dto/time_category_dto.dart';
import 'package:jama/data/models/dto/time_dto.dart';
import 'package:jama/mixins/color_mixin.dart';
import 'package:jama/mixins/date_mixin.dart';
import 'package:jama/mixins/duration_mixin.dart';
import 'package:jama/services/database_service.dart';
import 'package:jama/ui/app_styles.dart';

class TimeService {
  static const String _timeTable = "TimeEntries";
  static const String _timeCategoryTable = "TimeCategory";

  final StreamController<Time> _timeUpdatedController = StreamController<Time>.broadcast();
  final Completer<Database> _databaseCompleter;

  TimeService._(this._databaseCompleter);

  /// Creates an instance of the `TimeService`.
  /// For unit testing provide the [dbService]. Otherwise,
  /// the [context] will provide the `DatabaseService`.
  factory TimeService([DatabaseService dbService]) {
    dbService = dbService ?? KiwiContainer().resolve<DatabaseService>();

    var getTimeDb = () async {
      return await dbService.getLocalMainStorage();
    };

    return TimeService._(Completer()..complete(getTimeDb()));
  }

  /// Gets a `Stream` representing changes to time entries.
  Stream<Time> get timeUpdatedStream => _timeUpdatedController.stream;

  void dispose() {
    _timeUpdatedController.close();
  }

  /// Get a list of available `TimeCategory`
  Future<List<TimeCategory>> getCategories() async {
    final db = await _databaseCompleter.future;

    var categories = await db.rawQuery("SELECT * FROM $_timeCategoryTable;");

    if (categories.isEmpty) {
      var defaultCategory = TimeCategoryDto(
          name: "ministry",
          description: "Time spent in the field minstry.",
          color: AppStyles.primaryColor.toHex());

      var ldcCategory = TimeCategoryDto(
          name: "local design construction",
          description: "Time spent in ldc support.",
          color: Colors.yellow.toHex());

      var remoteWorkCategory = TimeCategoryDto(
          name: "remote work",
          description: "Time spent as a Bethel remote volunteer.",
          color: Colors.red.toHex());

      int defaultId, ldcId, remoteWorkId = -1;

      await db.transaction((txn) async {
        defaultId = await txn.insert(_timeCategoryTable, defaultCategory.toMap());
        ldcId = await txn.insert(_timeCategoryTable, ldcCategory.toMap());
        remoteWorkId = await txn.insert(_timeCategoryTable, remoteWorkCategory.toMap());
      });

      defaultCategory = defaultCategory.copyWith(id: defaultId);

      ldcCategory = ldcCategory.copyWith(id: ldcId);

      remoteWorkCategory = remoteWorkCategory.copyWith(id: remoteWorkId);

      return [defaultCategory, ldcCategory, remoteWorkCategory]
          .map((e) => TimeCategory.fromDto(e))
          .toList();
    }

    return categories.map((e) => TimeCategory.fromDto(TimeCategoryDto.fromMap(e))).toList();
  }

  /// Get all of the `Time` entries.
  Future<List<Time>> getAllTimeEntries() async {
    final db = await _databaseCompleter.future;

    var entries = await db.rawQuery("""
  SELECT * FROM $_timeTable
	  INNER JOIN $_timeCategoryTable 
    ON $_timeTable.FK_TimeCategory_Time = $_timeCategoryTable.TimeCategoryId;
  """);

    return entries.map((e) => Time.fromDto(TimeDto.fromMap(e))).toList();
  }

  /// Gets all of the `Time` entries by [category] name.
  Future<List<Time>> getTimeEntriesByCategoryName(String category) async {
    if (category == null || category.isEmpty) {
      throw ArgumentError.notNull("category");
    }

    final db = await _databaseCompleter.future;

    var entries = await db.rawQuery("""
SELECT * FROM TimeEntries
	INNER JOIN TimeCategory ON TimeEntries.FK_TimeCategory_Time = TimeCategory.TimeCategoryId
	WHERE TimeCategory.Name = ?;
""", [category]);

    return entries.map((e) => Time.fromDto(TimeDto.fromMap(e))).toList();
  }

  /// Get all the `Time` entries by [category].
  Future<List<Time>> getTimeEntriesByCategory(TimeCategory category) async {
    if (category == null || category._id <= 0) {
      throw ArgumentError.notNull("category");
    }

    final db = await _databaseCompleter.future;

    var entries = await db.rawQuery("""
SELECT * FROM TimeEntries
	INNER JOIN TimeCategory ON TimeEntries.FK_TimeCategory_Time = TimeCategory.TimeCategoryId
	WHERE FK_TimeCategory_Time = ?;
""", [category._id]);

    return entries.map((e) => Time.fromDto(TimeDto.fromMap(e))).toList();
  }

  Future<List<Time>> getTimeEntriesByDate(
      {DateTime start, DateTime end, bool dropTime = true}) async {
    if (start == null && end == null) {
      return await getAllTimeEntries();
    } else if ((start != null && end != null) && start.compareTo(end) > 0) {
      throw ArgumentError("[start] cannot be after [end]");
    }

    final db = await _databaseCompleter.future;

    if (dropTime) {
      start = start.dropTime();
      end = end.dropTime().add(1.days).subtract(1.milliseconds);
    }

    var baseQuery = """
SELECT * FROM TimeEntries
	INNER JOIN TimeCategory ON TimeEntries.FK_TimeCategory_Time = TimeCategory.TimeCategoryId
	WHERE""";
    var arguments = [];
    if (start != null) {
      baseQuery = "$baseQuery Date >= ?";
      arguments.add(start.millisecondsSinceEpoch);
      if (end != null) {
        baseQuery = "$baseQuery AND Date <= ?";
        arguments.add(end.millisecondsSinceEpoch);
      }
    } else if (end != null) {
      baseQuery = "$baseQuery Date <= ?";
      arguments.add(end.millisecondsSinceEpoch);
    }

    baseQuery = "$baseQuery ORDER BY Date DESC;";

    var entries = await db.rawQuery(baseQuery, arguments);

    return entries.map((map) => Time.fromDto(TimeDto.fromMap(map))).toList();
  }

  /// Save or Add a `Time` entry.
  /// [timeData.category] must not be null.
  Future<Time> saveOrAddTime(Time timeData) async {
    if (timeData.category == null || timeData.category._id <= 0) {
      throw ArgumentError.notNull("category");
    } else if (timeData.date == null || timeData.date.millisecondsSinceEpoch <= 0) {
      throw ArgumentError("Date must be set.");
    } else if (timeData.totalMinutes == 0) {
      throw ArgumentError("Total minutes must not be zero.");
    }

    final db = await _databaseCompleter.future;

    if (timeData.id <= 0) {
      timeData.id = await db.insert(_timeTable, timeData._toDto().toMap());
    } else {
      await db.update(_timeTable, timeData._toDto().toMap(),
          where: "TimeEntryId = ?", whereArgs: [timeData.id]);
    }

    _timeUpdatedController.sink.add(timeData);

    return timeData;
  }

  /// Delete the [timeData].
  Future deleteTime(Time timeData) async {
    if (timeData.id <= 0) {
      return;
    }

    final db = await _databaseCompleter.future;

    await db.delete(_timeTable, where: "TimeEntryId = ?", whereArgs: [timeData.id]);

    _timeUpdatedController.add(null);
  }

  /// Forward any time over 60 minutes from every category to the next month.
  /// Returns a list of categories that could not be updated.
  Future<List<TimeCategory>> forwardTime(final DateTime startDate) async {
    final start = startDate.toFirstDayOfMonth();
    final end = startDate.toLastDayOfMonth();

    var entries = await getTimeEntriesByDate(start: start, end: end);
    var categories = await getCategories();

    Map<TimeCategory, List<Time>> timeByCategory = {};
    categories.forEach((e) => timeByCategory[e] = <Time>[]);
    entries.forEach((e) => timeByCategory[e.category].add(e));
    List<TimeCategory> failedCategories = [];
    for (var category in categories) {
      // If the user only has 1 entry for the category and it's less than 1 hour, move it to the next month.
      if (timeByCategory[category].length == 1 &&
          timeByCategory[category].first.totalMinutes < 60) {
        var entry = timeByCategory[category].first;
        var oldDate = entry.date;
        entry.date = entry.date.toLastDayOfMonth().add(1.days).dropTime();
        entry.notes =
            "Moved from ${DateFormat.yMMMM(Intl.systemLocale).format(oldDate)}\n\n${entry.notes}";

        await saveOrAddTime(entry);
        continue;
      }

      var totalForCategory = timeByCategory[category].fold(0, (p, e) => p + e.totalMinutes);
      var amountNeeded = totalForCategory % 60;

      if (totalForCategory % 60 == 0) {
        continue;
      }

      // If the total for the category is less than 1 hour, merge all entries and move to the next month.
      if (totalForCategory < 60) {
        var notes = timeByCategory[category].fold(
            "Merged Entries from last month",
            (previousValue, element) =>
                "$previousValue\n${DateFormat.yMd(Intl.systemLocale).format(element.date)}: ${element.duration.toShortString()} ");

        var mergedEntry = Time.create(
            date: end.add(1.days).dropTime(),
            totalMinutes: totalForCategory,
            category: category,
            notes: notes,
            placements: timeByCategory[category].fold(0, (p, e) => p + e.placements),
            videos: timeByCategory[category].fold(0, (p, e) => p + e.videos));

        saveOrAddTime(mergedEntry);
        timeByCategory[category].forEach((time) => deleteTime(time));
      } else if (timeByCategory[category].isNotEmpty && amountNeeded > 0) {
        bool didDoUpdate = false;
        for (var entry in entries.reversed) {
          if (entry.totalMinutes >= amountNeeded + 15) {
            entry.totalMinutes -= amountNeeded;
            entry.notes = "Moved $amountNeeded minutes to the next month.\n${entry.notes}";
            if (entry.totalMinutes == 0) {
              await deleteTime(entry);
            } else {
              await saveOrAddTime(entry);
            }
            var date = startDate.toLastDayOfMonth().add(aDay).dropTime();
            var newTime = Time.create(
                date: date,
                totalMinutes: amountNeeded,
                category: category,
                notes: "Moved from ${DateFormat.yMMMM(Intl.systemLocale).format(date)}.");
            await saveOrAddTime(newTime);
            didDoUpdate = true;
            break;
          }
        }

        if (!didDoUpdate) {
          failedCategories.add(category);
        }
      }
    }

    return failedCategories;
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
      (dto.color != null && dto.color.isNotEmpty)
          ? HexColor.fromHex(dto.color)
          : Colors.transparent,
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
