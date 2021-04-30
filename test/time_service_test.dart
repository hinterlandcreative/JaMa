import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jama/data/core/db/database_provider.dart';
import 'package:jama/data/models/dto/time_category_dto.dart';
import 'package:jama/services/time_service.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tuple/tuple.dart';

import 'mocks/database_service_mock.dart';
import 'package:jama/mixins/date_mixin.dart';

void main() {
  group("Time Service Tests", () {
    test("saveOrAddTime adds time", () async {
      var testFixtures = await _getTestFixtures();
      var db = testFixtures.item1;
      var timeService = testFixtures.item2;

      var category = TimeCategory.fromDto(TimeCategoryDto.fromMap({"TimeCategoryId": 1}));

      var result = await timeService.saveOrAddTime(Time.create(
          date: DateTime.now().dropTime(), totalMinutes: 0xDEADBEEF, category: category));

      expect(result.id, greaterThan(0));

      var map = await db.rawQuery("SELECT * FROM TimeEntries;");

      expect(map.length, equals(1));
      expect(map[0]["TotalMinutes"], equals(0xDEADBEEF));

      db.close();
    });

    test("saveOrAddTime updates time", () async {
      var testFixtures = await _getTestFixtures();
      var db = testFixtures.item1;
      var timeService = testFixtures.item2;

      var category = TimeCategory.fromDto(TimeCategoryDto.fromMap({"TimeCategoryId": 1}));

      var result = await timeService.saveOrAddTime(Time.create(
          date: DateTime.now().dropTime(), totalMinutes: 0xDEADBEEF, category: category));

      var id = result.id;
      result.totalMinutes = 90;

      result = await timeService.saveOrAddTime(result);

      expect(result.id, equals(id));

      var map = await db.rawQuery("SELECT * FROM TimeEntries;");

      expect(map.length, equals(1));
      expect(map[0]["TotalMinutes"], equals(90));

      db.close();
    });

    test("saveOrAddTime updates stream when adding", () async {
      var testFixtures = await _getTestFixtures();
      var db = testFixtures.item1;
      var timeService = testFixtures.item2;

      var category = TimeCategory.fromDto(TimeCategoryDto.fromMap({"TimeCategoryId": 1}));

      var didPingStreamCompleter = Completer<bool>();

      var subscription = timeService.timeUpdatedStream.take(1).listen((event) {
        didPingStreamCompleter.complete(true);
      });

      await timeService.saveOrAddTime(Time.create(
          date: DateTime.now().dropTime(), totalMinutes: 0xDEADBEEF, category: category));

      var result = await didPingStreamCompleter.future;
      expect(result, isTrue);

      subscription.cancel();
      db.close();
    });

    test("saveOrAddTime updates stream when updating time", () async {
      var testFixtures = await _getTestFixtures();
      var db = testFixtures.item1;
      var timeService = testFixtures.item2;

      var category = TimeCategory.fromDto(TimeCategoryDto.fromMap({"TimeCategoryId": 1}));

      var didPingStreamCompleter = Completer<bool>();

      var subscription = timeService.timeUpdatedStream.take(1).listen((event) {
        didPingStreamCompleter.complete(true);
      });

      await timeService.saveOrAddTime(Time.create(
          date: DateTime.now().dropTime(), totalMinutes: 0xDEADBEEF, category: category));

      var result = await didPingStreamCompleter.future;
      expect(result, isTrue);

      subscription.cancel();
      db.close();
    });

    test("deleteTime deletes time", () async {
      var testFixtures = await _getTestFixtures();
      var db = testFixtures.item1;
      var timeService = testFixtures.item2;

      var category = TimeCategory.fromDto(TimeCategoryDto.fromMap({"TimeCategoryId": 1}));

      var result = await timeService.saveOrAddTime(Time.create(
          date: DateTime.now().dropTime(), totalMinutes: 0xDEADBEEF, category: category));

      expect(result.id, greaterThan(0));

      var map = await db.rawQuery("SELECT * FROM TimeEntries;");

      expect(map.length, equals(1));

      await timeService.deleteTime(result);

      map = await db.rawQuery("SELECT * FROM TimeEntries;");

      expect(map.length, equals(0));

      db.close();
    });

    test("getCategories creates categories", () async {
      var testFixtures = await _getTestFixtures();
      var db = testFixtures.item1;
      var timeService = testFixtures.item2;

      var map = await db.rawQuery("SELECT * FROM TimeCategory;");
      expect(map.length, equals(0));

      await timeService.getCategories();

      map = await db.rawQuery("SELECT * FROM TimeCategory;");
      expect(map.length, equals(3));

      db.close();
    });

    group("forwardTime forwards time in single category", () {
      List<Tuple4<List<int>, int, bool, int>> inputs = [
        Tuple4([], 0, false, 0),
        Tuple4([15, 15, 15], 1, true, 45),
        Tuple4([15, 15], 1, true, 30),
        Tuple4([15], 1, true, 15),
        Tuple4([60, 30], 3, true, 30),
        Tuple4([60, 45], 3, true, 45),
        Tuple4([60, 15], 3, true, 15),
        Tuple4([60, 45, 15, 30], 5, true, 30),
        Tuple4([60, 30, 30], 3, false, 0),
      ];
      for (var input in inputs) {
        test("forwardTime: ${input}", () async {
          var testFixtures = await _getTestFixtures();
          var db = testFixtures.item1;
          var timeService = testFixtures.item2;

          var timeInputs = input.item1;
          var expectedNumberOfEntries = input.item2;
          var shouldHaveUpdate = input.item3;
          var timeInNewEntry = input.item4;

          try {
            var categories = await timeService.getCategories();
            for (var t in timeInputs) {
              await timeService.saveOrAddTime(
                  Time.create(date: DateTime.now(), totalMinutes: t, category: categories.first));
            }

            var result = await timeService.forwardTime(DateTime.now().toFirstDayOfMonth());

            expect(result, isEmpty);

            var dbSnapshot = await timeService.getAllTimeEntries();

            expect(dbSnapshot.length, equals(expectedNumberOfEntries));
            if (shouldHaveUpdate) {
              expect(dbSnapshot.last.date.isAfter(DateTime.now().toLastDayOfMonth()), isTrue);
              expect(dbSnapshot.last.totalMinutes, equals(timeInNewEntry));
            }
          } finally {
            db.close();
          }
        });
      }
    });
  });
}

Future<Tuple2<Database, TimeService>> _getTestFixtures() async {
  var dbServiceMock = DatabaseServiceMock();

  var dbCompleter = Completer<Database>()..complete(_initNewDatabase());

  when(dbServiceMock.getLocalMainStorage()).thenAnswer((_) => dbCompleter.future);

  var timeService = TimeService(dbServiceMock);

  var db = await dbCompleter.future;

  return Tuple2(db, timeService);
}

Future<Database> _initNewDatabase() async {
  var db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);

  for (var cmd in LocalDatabaseFactory.version1Create) {
    await db.execute(cmd);
  }

  return db;
}
