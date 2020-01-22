
import 'package:flutter_test/flutter_test.dart';
import 'package:jama/data/models/time_category_model.dart';
import 'package:jama/data/models/time_model.dart';
import 'package:jama/ui/models/time/time_collection.dart';
import 'package:mockito/mockito.dart';

import 'mocks/time_service_mock.dart';

void main() {
  // group("RangedTimeCollection tests: ", () {
  //   test("loadChildren() gets all time.", () async {
  //     var timeServiceMock = TimeServiceMock();
      
  //     var rangedTimeCollection = TimeCollectionModel(timeServiceMock);

  //     await rangedTimeCollection.loadChildren();

  //     verify(timeServiceMock.getTimeEntriesByDate(startTime: argThat(isNull, named: "startTime"), endTime: argThat(isNull, named: "endTime"))).called(1);
  //   });
  //   test("loadChildren() notifies listeners.", () async {
  //     var timeServiceMock = TimeServiceMock();
      
  //     var rangedTimeCollection = TimeCollectionModel(timeServiceMock);

  //     var wasCalled = false;
  //     rangedTimeCollection.addListener(() {
  //       wasCalled = true;
  //     });

  //     await rangedTimeCollection.loadChildren();

  //     expect(wasCalled, isTrue);
  //   });
  //   test("loadChildrenByDate() calls TimeService with correct parameters", () async {
  //     var timeServiceMock = TimeServiceMock();
      
  //     var rangedTimeCollection = TimeCollectionModel(timeServiceMock);

  //     var startDate = DateTime.now();
  //     var endDate = DateTime.now();
  //     await rangedTimeCollection.loadChildrenByDate(start: startDate, end: endDate);

  //     verify(timeServiceMock.getTimeEntriesByDate(startTime: argThat(equals(startDate), named: "startTime"), endTime: argThat(equals(endDate), named: "endTime"))).called(1);
  //   });
  //   test("loadChildrenByDate() notifies listeners.", () async {
  //     var timeServiceMock = TimeServiceMock();
      
  //     var rangedTimeCollection = TimeCollectionModel(timeServiceMock);

  //     var wasCalled = false;
  //     rangedTimeCollection.addListener(() {
  //       wasCalled = true;
  //     });

  //     await rangedTimeCollection.loadChildrenByDate();

  //     expect(wasCalled, isTrue);
  //   });
  //   test("saveOrUpdate() notifies listeners.", () async {
  //     var listOfTime = [
  //       Time(
  //         date: DateTime(2020, 1, 1, 0, 0).millisecondsSinceEpoch,
  //         totalMinutes: 1,
  //         category: TimeCategory(name: "ministry")
  //       ),
  //       Time(
  //         date: DateTime(2020, 1, 2, 0, 0).millisecondsSinceEpoch,
  //         totalMinutes: 1,
  //         category: TimeCategory(name: "ministry")
  //       ),
  //       Time(
  //         date: DateTime(2020, 1, 3, 0, 0).millisecondsSinceEpoch,
  //         totalMinutes: 1,
  //         category: TimeCategory(name: "ministry")
  //       ),
  //     ];
  //     listOfTime[0].id = 1;
  //     listOfTime[1].id = 2;
  //     listOfTime[2].id = 3;

  //     var newTime = Time(
  //       date: DateTime(2020,01,31,0,0).millisecondsSinceEpoch,
  //       totalMinutes: 1,
  //       category: TimeCategory(name: "ministry")
  //     );
  //     newTime.id = 4;

  //     var timeServiceMock = TimeServiceMock();
  //     when(timeServiceMock.getTimeEntriesByDate(startTime: anyNamed("startTime"), endTime: anyNamed("endTime"))).thenAnswer((_) => Future.value(listOfTime));
  //     when(timeServiceMock.saveOrAddTime(any)).thenAnswer((_) => Future.value(newTime));

  //     var rangedTimeCollection = TimeCollectionModel(timeServiceMock);

  //     await rangedTimeCollection.loadChildren();

  //     var wasCalled = false;
  //     rangedTimeCollection.addListener(() => wasCalled = true);
  //     await rangedTimeCollection.saveOrUpdate(newTime);

  //     expect(wasCalled, isTrue);
  //   });
  //   test("saveOrUpdate() adds new time to end of list.", () async {
  //     var listOfTime = [
  //       Time(
  //         date: DateTime(2020, 1, 1, 0, 0).millisecondsSinceEpoch,
  //         totalMinutes: 1,
  //         category: TimeCategory(name: "ministry")
  //       ),
  //       Time(
  //         date: DateTime(2020, 1, 2, 0, 0).millisecondsSinceEpoch,
  //         totalMinutes: 1,
  //         category: TimeCategory(name: "ministry")
  //       ),
  //       Time(
  //         date: DateTime(2020, 1, 3, 0, 0).millisecondsSinceEpoch,
  //         totalMinutes: 1,
  //         category: TimeCategory(name: "ministry")
  //       ),
  //     ];
  //     listOfTime[0].id = 1;
  //     listOfTime[1].id = 2;
  //     listOfTime[2].id = 3;

  //     var newTime = Time(
  //       date: DateTime(2020,01,31,0,0).millisecondsSinceEpoch,
  //       totalMinutes: 1,
  //       category: TimeCategory(name: "ministry")
  //     );
  //     newTime.id = 4;

  //     var timeServiceMock = TimeServiceMock();
  //     when(timeServiceMock.getTimeEntriesByDate(startTime: anyNamed("startTime"), endTime: anyNamed("endTime"))).thenAnswer((_) => Future.value(listOfTime));
  //     when(timeServiceMock.saveOrAddTime(any)).thenAnswer((_) => Future.value(newTime));

  //     var rangedTimeCollection = TimeCollectionModel(timeServiceMock);

  //     await rangedTimeCollection.loadChildren();

  //     await rangedTimeCollection.saveOrUpdate(newTime);

  //     expect(rangedTimeCollection.items, hasLength(4));
  //     expect(rangedTimeCollection.items[3], same(newTime));
  //   });
  //   test("saveOrUpdate() inserts new time based on date.", () async {
  //     var listOfTime = [
  //       Time(
  //         date: DateTime(2020, 1, 1, 0, 0).millisecondsSinceEpoch,
  //         totalMinutes: 1,
  //         category: TimeCategory(name: "ministry")
  //       ),
  //       Time(
  //         date: DateTime(2020, 1, 2, 0, 0).millisecondsSinceEpoch,
  //         totalMinutes: 1,
  //         category: TimeCategory(name: "ministry")
  //       ),
  //       Time(
  //         date: DateTime(2020, 1, 3, 0, 0).millisecondsSinceEpoch,
  //         totalMinutes: 1,
  //         category: TimeCategory(name: "ministry")
  //       ),
  //     ];
  //     listOfTime[0].id = 1;
  //     listOfTime[1].id = 2;
  //     listOfTime[2].id = 3;

  //     var newTime = Time(
  //       date: DateTime(2020, 1, 2, 1, 0).millisecondsSinceEpoch,
  //       totalMinutes: 1,
  //       category: TimeCategory(name: "ministry")
  //     );
  //     newTime.id = 4;

  //     var timeServiceMock = TimeServiceMock();
  //     when(timeServiceMock.getTimeEntriesByDate(startTime: anyNamed("startTime"), endTime: anyNamed("endTime"))).thenAnswer((_) => Future.value(listOfTime));
  //     when(timeServiceMock.saveOrAddTime(any)).thenAnswer((_) => Future.value(newTime));
      
  //     var rangedTimeCollection = TimeCollectionModel(timeServiceMock);

  //     await rangedTimeCollection.loadChildren();

  //     await rangedTimeCollection.saveOrUpdate(newTime);

  //     expect(rangedTimeCollection.items, hasLength(4));
  //     expect(rangedTimeCollection.items[2], same(newTime));
  //   });
  //   test("saveOrUpdate() replaces time based on id.", () async {
  //     var listOfTime = [
  //       Time(
  //         date: DateTime(2020, 1, 1, 0, 0).millisecondsSinceEpoch,
  //         totalMinutes: 1,
  //         category: TimeCategory(name: "ministry")
  //       ),
  //       Time(
  //         date: DateTime(2020, 1, 2, 0, 0).millisecondsSinceEpoch,
  //         totalMinutes: 1,
  //         category: TimeCategory(name: "ministry")
  //       ),
  //       Time(
  //         date: DateTime(2020, 1, 3, 0, 0).millisecondsSinceEpoch,
  //         totalMinutes: 1,
  //         category: TimeCategory(name: "ministry")
  //       ),
  //     ];
  //     listOfTime[0].id = 1;
  //     listOfTime[1].id = 2;
  //     listOfTime[2].id = 3;

  //     var newTime = Time(
  //       date: DateTime(2020, 1, 31, 1, 0).millisecondsSinceEpoch,
  //       totalMinutes: 1,
  //       category: TimeCategory(name: "ministry")
  //     );
  //     newTime.id = 1;

  //     var timeServiceMock = TimeServiceMock();
  //     when(timeServiceMock.getTimeEntriesByDate(startTime: anyNamed("startTime"), endTime: anyNamed("endTime"))).thenAnswer((_) => Future.value(listOfTime));
  //     when(timeServiceMock.saveOrAddTime(any)).thenAnswer((_) => Future.value(newTime));
      
  //     var rangedTimeCollection = TimeCollectionModel(timeServiceMock);

  //     await rangedTimeCollection.loadChildren();

  //     await rangedTimeCollection.saveOrUpdate(newTime);

  //     expect(rangedTimeCollection.items, hasLength(3));
  //     expect(rangedTimeCollection.items[0], same(newTime));
  //   });
  // });
}