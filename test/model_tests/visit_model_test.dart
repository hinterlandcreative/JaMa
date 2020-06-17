import 'package:flutter_test/flutter_test.dart';
import 'package:jama/data/models/placement_model.dart';
import 'package:jama/data/models/visit_model.dart';
import 'package:tuple/tuple.dart';

void main() {
  group("Visit model tests:", () {
    test("toMap() works.", () {
      Visit visit = Visit(
        id:123,
        parentRvId: 123,
        date: DateTime.now(),
        notes: "",
        type: VisitType.NotAtHome,
        placements: []);

        var map = visit.toMap();

        expect(map.keys, hasLength(6));
        expect(map.containsKey("id"), isTrue);
        expect(map.containsKey("parentRvId"), isTrue);
        expect(map.containsKey("date"), isTrue);
        expect(map.containsKey("notes"), isTrue);
        expect(map.containsKey("type"), isTrue);
        expect(map.containsKey("placements"), isTrue);
    });

    test("fromMap() works.", () {
      var placementMap = {
        PlacementType.Book: Tuple2(100, "placement note")
      };

      var visit = Visit.fromMap({
        'id': 123,
        'parentRvId': 456,
        'date': 789,
        'notes': "some notes",
        'type': VisitType.Study,
        'placements': placementMap
      });

      expect(visit.id, 123);
      expect(visit.parentRvId, 456);
      expect(visit.date, 789);
      expect(visit.notes, equals("some notes"));
      expect(visit.type, VisitType.Study);
      expect(placementMap, equals(placementMap));
    });

    test("round trip", () {
      var placements = [
        Placement(count: 100, type: PlacementType.Book, notes: "placement note")
      ];

      Visit visit = Visit(
        id:123,
        parentRvId: 456,
        date: DateTime.now(),
        notes: "some notes",
        type: VisitType.NotAtHome,
        placements: placements);

      var visitCopy = visit.copy();

      expect(visit.toMap().keys, visitCopy.toMap().keys);

      expect(visit.id, visitCopy.id);
      expect(visit.parentRvId, visitCopy.parentRvId);
      expect(visit.date, visitCopy.date);
      expect(visit.notes, visitCopy.notes);
      expect(visit.type, visitCopy.type);
      expect(visit.placements, visitCopy.placements);
    });

    test("constructor requires a valid parent return visit", () {
      expect(
        () => Visit(date:DateTime.now(), parentRvId: -1),
        throwsArgumentError);
      
      expect(
        () => Visit(date:DateTime.now(), parentRvId: null), 
        throwsArgumentError);
    });
  });
}