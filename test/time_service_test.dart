import 'package:flutter_test/flutter_test.dart';
import 'package:jama/data/core/db/db_collection.dart';
import 'package:jama/data/core/db/query_package.dart';
import 'package:jama/data/models/time_category_model.dart';
import 'package:jama/data/models/time_model.dart';
import 'package:jama/services/time_service.dart';
import 'package:mockito/mockito.dart';

import 'mocks/app_database_mock.dart';
import 'mocks/database_collection_mock.dart';
import 'mocks/database_service_mock.dart';

void main() {
  group("TimeService tests:", () {
    test("TimeService.getTimeEntriesByDate() calls getAll() with correct sort.", () async {
      var dbCollectionMock = DbCollectionMock();

      var appDb = AppDatabaseMock();
      when(appDb.collections("time")).thenReturn(dbCollectionMock);

      var dbServiceMock = DatabaseServiceMock();
      when(dbServiceMock.getMainStorage()).thenAnswer((_) async => appDb);

      var timeService = TimeService(dbServiceMock);

      var now = DateTime.now();
      await timeService.getTimeEntriesByDate(endTime: now);

      var capturedArgs = verify(
        dbCollectionMock.query(
          any, 
          any, 
          sort: captureAnyNamed("sort"), 
          sortKey: captureAnyNamed("sortKey")))
        .captured;

      var foundSort = capturedArgs[0];
      var foundSortKey = capturedArgs[1];

      expect(foundSort, same(SortOrderType.Decending));
      expect(foundSortKey, same("date"));
    });
    test("TimeService.getTimeEntriesByDate(startDate, endDate) calls query() with correct filters.", () async {
      var dbCollectionMock = DbCollectionMock();

      var appDb = AppDatabaseMock();
      when(appDb.collections("time")).thenReturn(dbCollectionMock);

      var dbServiceMock = DatabaseServiceMock();
      when(dbServiceMock.getMainStorage()).thenAnswer((_) async => appDb);

      var timeService = TimeService(dbServiceMock);

      var start = DateTime.now();
      start = start.subtract(Duration(days: 1));
      var end = start.add(Duration(days: 2));
      await timeService.getTimeEntriesByDate(startTime: start, endTime: end);

      List<QueryPackage> foundQueryPackageList = verify(
          dbCollectionMock.query(
            captureAny, 
            any, 
            sort: anyNamed("sort"), 
            sortKey: anyNamed("sortKey")))
          .captured
          .first;

      var expectedStartQueryPackage = QueryPackage(
        filter: FilterType.GreaterThanOrEqualTo, 
        key: "date", 
        value: start.millisecondsSinceEpoch
      );
      
      var expectedEndQueryPackage = QueryPackage(
        filter: FilterType.LessThanOrEqualTo,
        key: "date",
        value: end.millisecondsSinceEpoch
      );

      expect(foundQueryPackageList, hasLength(2));
      expect(foundQueryPackageList[0].filter,  expectedStartQueryPackage.filter);
      expect(foundQueryPackageList[0].key, expectedStartQueryPackage.key);
      expect(foundQueryPackageList[0].value, expectedStartQueryPackage.value);
      expect(foundQueryPackageList[1].filter,  expectedEndQueryPackage.filter);
      expect(foundQueryPackageList[1].key, expectedEndQueryPackage.key);
      expect(foundQueryPackageList[1].value, expectedEndQueryPackage.value);
    });
    test("TimeService.getTimeEntriesByDate(null, endTime) calls query() with correct filters.", () async {
      var dbCollectionMock = DbCollectionMock();

      var appDb = AppDatabaseMock();
      when(appDb.collections("time")).thenReturn(dbCollectionMock);

      var dbServiceMock = DatabaseServiceMock();
      when(dbServiceMock.getMainStorage()).thenAnswer((_) async => appDb);

      var timeService = TimeService(dbServiceMock);

      var now = DateTime.now();
      await timeService.getTimeEntriesByDate(endTime: now);

      List<QueryPackage> foundQueryPackageList = verify(
          dbCollectionMock.query(
            captureAny, 
            any, 
            sort: anyNamed("sort"), 
            sortKey: anyNamed("sortKey")))
          .captured
          .first;

      var expectedQueryPackage = QueryPackage(
            filter: FilterType.LessThanOrEqualTo, 
            key: "date", 
            value: now.millisecondsSinceEpoch);

      expect(foundQueryPackageList, hasLength(1));
      expect(foundQueryPackageList[0].filter,  expectedQueryPackage.filter);
      expect(foundQueryPackageList[0].key, expectedQueryPackage.key);
      expect(foundQueryPackageList[0].value, expectedQueryPackage.value);
    });
    test("TimeService.getTimeEntriesByDate(startDate, null) calls query() with correct filters.", () async {
      var dbCollectionMock = DbCollectionMock();

      var appDb = AppDatabaseMock();
      when(appDb.collections("time")).thenReturn(dbCollectionMock);

      var dbServiceMock = DatabaseServiceMock();
      when(dbServiceMock.getMainStorage()).thenAnswer((_) async => appDb);

      var timeService = TimeService(dbServiceMock);

      var now = DateTime.now();
      await timeService.getTimeEntriesByDate(startTime: now);

      List<QueryPackage> foundQueryPackageList = verify(
          dbCollectionMock.query(
            captureAny, 
            any, 
            sort: anyNamed("sort"), 
            sortKey: anyNamed("sortKey")))
          .captured
          .first;

      var expectedQueryPackage = QueryPackage(
            filter: FilterType.GreaterThanOrEqualTo, 
            key: "date", 
            value: now.millisecondsSinceEpoch);

      expect(foundQueryPackageList, hasLength(1));
      expect(foundQueryPackageList[0].filter,  expectedQueryPackage.filter);
      expect(foundQueryPackageList[0].key, expectedQueryPackage.key);
      expect(foundQueryPackageList[0].value, expectedQueryPackage.value);
    });
    test("TimeService.getTimeEntriesByDate() throws ArgumentError if the start date is after the end date.", () async {
      var dbCollectionMock = DbCollectionMock();

      var appDb = AppDatabaseMock();
      when(appDb.collections("time")).thenReturn(dbCollectionMock);

      var dbServiceMock = DatabaseServiceMock();
      when(dbServiceMock.getMainStorage()).thenAnswer((_) async => appDb);

      var timeService = TimeService(dbServiceMock);

      expect(
        () async => await timeService.getTimeEntriesByDate(startTime: DateTime.now().add(Duration(hours: 1)), endTime: DateTime.now()),
        throwsArgumentError
      );
    });
    test("TimeService.getTimeEntriesByDate() calls getAll() if no dates are supplied.", () async {
      var dbCollectionMock = DbCollectionMock();

      var appDb = AppDatabaseMock();
      when(appDb.collections("time")).thenReturn(dbCollectionMock);

      var dbServiceMock = DatabaseServiceMock();
      when(dbServiceMock.getMainStorage()).thenAnswer((_) async => appDb);

      var timeService = TimeService(dbServiceMock);

      await timeService.getTimeEntriesByDate();

      verify(dbCollectionMock.getAll(any)).called(1);
    });
    test("TimeService.getTimeEntriesByCategory() calls query() with correct filters.", () async {
      var dbCollectionMock = DbCollectionMock();

      var appDb = AppDatabaseMock();
      when(appDb.collections("time")).thenReturn(dbCollectionMock);

      var dbServiceMock = DatabaseServiceMock();
      when(dbServiceMock.getMainStorage()).thenAnswer((_) async => appDb);

      var timeService = TimeService(dbServiceMock);

      await timeService.getTimeEntriesByCategory("test_me");

      List<QueryPackage> foundQueryPackageList = verify(
          dbCollectionMock.query(
            captureAny, 
            any, 
            sort: anyNamed("sort"), 
            sortKey: anyNamed("sortKey")))
          .captured
          .first;

      var expectedQueryPackage = QueryPackage(
            filter: FilterType.EqualTo, 
            key: "category.name", 
            value: "test_me");

      expect(foundQueryPackageList, hasLength(1));
      expect(foundQueryPackageList[0].filter,  expectedQueryPackage.filter);
      expect(foundQueryPackageList[0].key, expectedQueryPackage.key);
      expect(foundQueryPackageList[0].value, expectedQueryPackage.value);
    });
    test("TimeService.getAllTimeEntries() calls getAll().", () async {
      var dbCollectionMock = DbCollectionMock();

      var appDb = AppDatabaseMock();
      when(appDb.collections("time")).thenReturn(dbCollectionMock);

      var dbServiceMock = DatabaseServiceMock();
      when(dbServiceMock.getMainStorage()).thenAnswer((_) async => appDb);

      var timeService = TimeService(dbServiceMock);

      await timeService.getAllTimeEntries();

      verify(dbCollectionMock.getAll(any)).called(1);
    });
    test("TimeService.saveOrAddTime() throws on invalid date.", () async {
      var timeData = Time(
        date: 0,
        totalMinutes: 60,
        category: TimeCategory(name: "ministry")
      );
      timeData.id = 0xDEADBEEF;

      var dbCollectionMock = DbCollectionMock();

      var appDb = AppDatabaseMock();
      when(appDb.collections("time")).thenReturn(dbCollectionMock);

      var dbServiceMock = DatabaseServiceMock();
      when(dbServiceMock.getMainStorage()).thenAnswer((_) async => appDb);

      var timeService = TimeService(dbServiceMock);

      expect(
        () async => await timeService.saveOrAddTime(timeData),
        throwsArgumentError
      );
    });
    test("TimeService.saveOrAddTime() throws on invalid type.", () async {
      var timeData = Time(
        date: DateTime.now().millisecondsSinceEpoch,
        totalMinutes: 60,
        category: null
      );
      timeData.id = 0xDEADBEEF;

      var dbCollectionMock = DbCollectionMock();

      var appDb = AppDatabaseMock();
      when(appDb.collections("time")).thenReturn(dbCollectionMock);

      var dbServiceMock = DatabaseServiceMock();
      when(dbServiceMock.getMainStorage()).thenAnswer((_) async => appDb);

      var timeService = TimeService(dbServiceMock);

      expect(
        () async => await timeService.saveOrAddTime(timeData),
        throwsArgumentError
      );
    });
    test("TimeService.saveOrAddTime() throws on invalid time amount.", () async {
      var timeData = Time(
        date: DateTime.now().millisecondsSinceEpoch,
        totalMinutes: 0,
        category: TimeCategory(name: "ministry")
      );
      timeData.id = 0xDEADBEEF;

      var dbCollectionMock = DbCollectionMock();

      var appDb = AppDatabaseMock();
      when(appDb.collections("time")).thenReturn(dbCollectionMock);

      var dbServiceMock = DatabaseServiceMock();
      when(dbServiceMock.getMainStorage()).thenAnswer((_) async => appDb);

      var timeService = TimeService(dbServiceMock);

      expect(
        () async => await timeService.saveOrAddTime(timeData),
        throwsArgumentError
      );
    });
    test("TimeService.deleteTime() calls deleteFromDTO() if the time entry has an id.", () async {
      var timeData = Time(
        date: DateTime.now().millisecondsSinceEpoch,
        totalMinutes: 60,
        category: TimeCategory(name: "ministry")
      );
      timeData.id = 0xDEADBEEF;

      var dbCollectionMock = DbCollectionMock();

      var appDb = AppDatabaseMock();
      when(appDb.collections("time")).thenReturn(dbCollectionMock);

      var dbServiceMock = DatabaseServiceMock();
      when(dbServiceMock.getMainStorage()).thenAnswer((_) async => appDb);

      var timeService = TimeService(dbServiceMock);

      await timeService.deleteTime(timeData);

      verify(dbCollectionMock.deleteFromDto(timeData)).called(1);
    });
    test("TimeService.deleteTime() does not call deleteFromDto() if the item is missing an id.", () async {
      var timeData = Time(
        date: DateTime.now().millisecondsSinceEpoch,
        totalMinutes: 60,
        category: TimeCategory(name: "ministry")
      );
      timeData.id = -1;

      var dbCollectionMock = DbCollectionMock();

      var appDb = AppDatabaseMock();
      when(appDb.collections("time")).thenReturn(dbCollectionMock);

      var dbServiceMock = DatabaseServiceMock();
      when(dbServiceMock.getMainStorage()).thenAnswer((_) async => appDb);

      var timeService = TimeService(dbServiceMock);

      await timeService.deleteTime(timeData);

      verifyNever(dbCollectionMock.deleteFromDto(timeData));
    });
    test("TimeService.saveOrAddTime() calls update() if the item has an id.", () async {
      var timeData = Time(
        date: DateTime.now().millisecondsSinceEpoch,
        totalMinutes: 60,
        category: TimeCategory(name: "ministry")
      );
      timeData.id = 0xDEADBEEF;
      timeData.category.id = 1;

      var dbCollectionMock = DbCollectionMock();

      var appDb = AppDatabaseMock();
      when(appDb.collections("time")).thenReturn(dbCollectionMock);

      var dbServiceMock = DatabaseServiceMock();
      when(dbServiceMock.getMainStorage()).thenAnswer((_) async => appDb);

      var timeService = TimeService(dbServiceMock);

      await timeService.saveOrAddTime(timeData);

      verifyNever(dbCollectionMock.add(timeData));
      verify(dbCollectionMock.update(timeData)).called(1);
    });
    test("TimeService.saveOrAddTime() calls add() if the doesn't exist and returns an id.", () async {
      var timeData = Time(
        date: DateTime.now().millisecondsSinceEpoch,
        totalMinutes: 60,
        category: TimeCategory(name: "ministry")
      );
      timeData.id = -1;
      timeData.category.id = 1;

      var dbCollectionMock = DbCollectionMock();
      when(dbCollectionMock.add(timeData)).thenAnswer((_) async => 0xDEADBEEF);

      var appDb = AppDatabaseMock();
      when(appDb.collections("time")).thenReturn(dbCollectionMock);

      var dbServiceMock = DatabaseServiceMock();
      when(dbServiceMock.getMainStorage()).thenAnswer((_) async => appDb);

      var timeService = TimeService(dbServiceMock);

      var newTimeData = await timeService.saveOrAddTime(timeData);

      verifyNever(dbCollectionMock.update(timeData));
      verify(dbCollectionMock.add(timeData)).called(1);

      expect(newTimeData.id, 0xDEADBEEF);
    });
  });
}