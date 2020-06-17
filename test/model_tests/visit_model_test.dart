import 'package:flutter_test/flutter_test.dart';
import 'package:jama/data/models/placement_model.dart';
import 'package:jama/data/models/visit_model.dart';
import 'package:tuple/tuple.dart';

void main() {
  group("Visit model tests:", () {
    test("toMap() works.", () {
      var placement = Placement(
        count: 1,
        type: PlacementType.CampaignItem,
        notes: "placement notes"
      );

      var now = DateTime.now();

      Visit visit = Visit(
        id:123,
        parentRvId: 321,
        date: now,
        notes: "some notes",
        type: VisitType.NotAtHome,
        nextTopic: "Something",
        placements: [
          placement
        ]);

        var map = visit.toMap();

        expect(map.keys, hasLength(7));
        expect(map.containsKey("id"), isTrue);
        expect(map["id"], equals(123));
        expect(map.containsKey("parentRvId"), isTrue);
        expect(map["parentRvId"], equals(visit.parentRvId));
        expect(map.containsKey("date"), isTrue);
        expect(map["date"], equals(visit.date));
        expect(map.containsKey("notes"), isTrue);
        expect(map["notes"], equals(visit.notes));
        expect(map.containsKey("type"), isTrue);
        expect(map["type"], equals(visit.type.toString().split('.').last));
        expect(map.containsKey("nextTopic"), isTrue);
        expect(map["nextTopic"], equals(visit.nextTopic));
        expect(map.containsKey("placements"), isTrue);
        expect(map["placements"], equals([placement.toMap()]));
    });

    test("fromMap() works.", () {
      var placement = Placement(
        count: 1,
        type: PlacementType.CampaignItem,
        notes: "placement notes"
      );

      var visit = Visit.fromMap({
        'id': 123,
        'parentRvId': 456,
        'date': 789,
        'notes': "some notes",
        'type': "Study",
        'nextTopic': "some topic",
        'placements': [
          placement.toMap()
        ]
      });

      expect(visit.id, 123);
      expect(visit.parentRvId, 456);
      expect(visit.date, 789);
      expect(visit.notes, equals("some notes"));
      expect(visit.type, VisitType.Study);
      expect(visit.nextTopic, equals("some topic"));
      expect(visit.placements, hasLength(1));
      expect(visit.placements[0].count, equals(placement.count));
      expect(visit.placements[0].notes, equals(placement.notes));
      expect(visit.placements[0].type, equals(placement.type));
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
        nextTopic: "some topic",
        placements: placements);

      var visitCopy = visit.copy();

      expect(visit.toMap().keys, visitCopy.toMap().keys);

      expect(visit.id, equals(visitCopy.id));
      expect(visit.parentRvId, equals(visitCopy.parentRvId));
      expect(visit.date, equals(visitCopy.date));
      expect(visit.notes, equals(visitCopy.notes));
      expect(visit.type, equals(visitCopy.type));
      expect(visit.placements, equals(visitCopy.placements));
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