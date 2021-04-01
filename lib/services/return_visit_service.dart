import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:jama/services/database_service.dart';
import 'package:jama/services/image_service.dart';
import 'package:kiwi/kiwi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:supercharged/supercharged.dart';

import 'package:jama/data/models/address_model.dart';
import 'package:jama/data/models/dto/return_visit_dto.dart';
import 'package:jama/data/models/dto/visit_dto.dart';
import 'package:jama/data/models/dto/placement_dto.dart';
import 'package:tuple/tuple.dart';

class ReturnVisitService {
  static const String _tableName_ReturnVisits = "ReturnVisit";
  static const String _tableName_Visits = "Visit";
  static const String _tableName_Placements = "Placements";

  final ImageService _imageService;
  final Completer<Database> _dbCompleter;
  final StreamController<ReturnVisit> _returnVisitsUpdated;

  const ReturnVisitService._(this._imageService, this._dbCompleter, this._returnVisitsUpdated);

  factory ReturnVisitService([ImageService imageService, DatabaseService databaseService]) {
    databaseService = databaseService ?? KiwiContainer().resolve<DatabaseService>();
    imageService = imageService ?? KiwiContainer().resolve<ImageService>();

    final completer = Completer<Database>()..complete(databaseService.getLocalMainStorage());

    return ReturnVisitService._(imageService, completer, StreamController<ReturnVisit>.broadcast());
  }

  Stream<ReturnVisit> get returnVisitUpdates => _returnVisitsUpdated.stream;

  /// Gets all the available return visits.
  /// If [shallow] is true then the visits and placements are not retrieved.
  /// [shallow] = false is not currently supported.
  Future<List<ReturnVisit>> getAllReturnVisits({bool shallow = true}) async {
    final db = await _dbCompleter.future;

    if (shallow) {
      var items = await db.query(_tableName_ReturnVisits);
      return items.map((e) => ReturnVisit._shallowDto(ReturnVisitDto.fromMap(e))).toList();
    } else {
      var entries = await db.rawQuery("""SELECT * FROM ReturnVisit """ +
          """LEFT JOIN Visit ON ReturnVisit.ReturnVisitId = Visit.FK_ReturnVisit_Visit_ParentRv """ +
          """LEFT JOIN Placements ON Visit.VisitId = Placements.FK_Visit_Placement_ParentVisit """ +
          """ORDER BY ReturnVisitId DESC""");
      if (entries.isEmpty) return <ReturnVisit>[];

      var rvList = <ReturnVisit>[];
      var mapList = <Map<String, dynamic>>[];
      var currentRvId = entries.first["ReturnVisitId"];

      for (var map in entries) {
        var id = map["ReturnVisitId"];
        if (id != currentRvId) {
          rvList.add(_parseReturnVisitDtos(mapList));
          mapList.clear();
          mapList.add(map);
          currentRvId = id;
        } else {
          mapList.add(map);
        }
      }
      rvList.add(_parseReturnVisitDtos(mapList));

      return rvList;
    }
  }

  /// Get all the `Visit`s and `Placement`s for the provided [rv].
  Future<ReturnVisit> getAllVisitsForRv(ReturnVisit rv) async {
    assert(rv._id > 0);
    final db = await _dbCompleter.future;

    var entries = await db.rawQuery(
        """SELECT * FROM ReturnVisit """ +
            """LEFT JOIN Visit ON ReturnVisit.ReturnVisitId = Visit.FK_ReturnVisit_Visit_ParentRv """ +
            """LEFT JOIN Placements ON Visit.VisitId = Placements.FK_Visit_Placement_ParentVisit """ +
            """WHERE ReturnVisitId = ? """ +
            """ORDER BY Visit.Date DESC;""",
        [rv._id]);
    if (entries == null) return rv;

    return _parseReturnVisitDtos(entries);
  }

  // Gets all the `ReturnVisit`s that have a visit after [start] and before [end].
  // Future<List<ReturnVisit>> getAllReturnVisitsWithVisitsInDateRange(
  //     {DateTime start, DateTime end}) async {
  //   assert(start.compareTo(end) <= 0);

  //   var db = await _dbCompleter.future;

  //   final rvIds = await db.rawQuery("""SELECT FK_ReturnVisit_Visit_ParentRv FROM Visit """ +
  //       """WHERE Date > 0 """ +
  //       """ORDER BY Date DESC;""");

  //   final rvIdParam = "(${rvIds.toSet().join(", ")})";

  //   if (rvIds.isEmpty) return <ReturnVisit>[];

  //   var entries = await db.rawQuery(
  //       """SELECT * FROM ReturnVisit """ +
  //           """LEFT JOIN Visit ON ReturnVisit.ReturnVisitId = Visit.FK_ReturnVisit_Visit_ParentRv """ +
  //           """LEFT JOIN Placements ON Visit.VisitId = Placements.FK_Visit_Placement_ParentVisit """ +
  //           """WHERE ReturnVisitId IN ? """ +
  //           """ORDER BY Visit.Date DESC;""",
  //       [rvIdParam]);

  // }

  ReturnVisit _parseReturnVisitDtos(List<Map<String, dynamic>> entries) {
    var placements = entries
        .where((map) => map["PlacementId"] != null)
        .map((e) => Placement._fromDto(dto: PlacementDto.fromMap(e)))
        .toList();

    var visitIds = entries.map((e) => e["VisitId"]).toList().toSet();
    var visits = <Visit>[];
    for (var id in visitIds) {
      var visitMap = entries.firstWhere((map) => map["VisitId"] == id);
      var visitsPlacements = placements.where((p) => p._parentVisit == id).toList();
      visits.add(Visit._fromDto(dto: VisitDto.fromMap(visitMap), placements: visitsPlacements));
    }

    return ReturnVisit._fromDto(ReturnVisitDto.fromMap(entries.first), visits);
  }

  /// Add a new `ReturnVisit` with the initial visit information.
  /// The [rv] must not have been saved and the [rv.visits] must be empty.
  /// [intialCallDate] must be set.
  Future<ReturnVisit> addReturnVisit(
      {@required ReturnVisit rv,
      @required DateTime initialCallDate,
      List<Tuple3<int, PlacementType, String>> initialCallPlacements,
      String initialCallNotes,
      String initialCallNextTopic}) async {
    assert(initialCallDate != null);
    assert(rv != null);
    assert(rv._id <= 0);
    assert(rv.visits.isEmpty);

    final db = await _dbCompleter.future;

    await db.transaction((txn) async {
      rv._id = await txn.insert(_tableName_ReturnVisits, rv._toMap());
      var visitDto = VisitDto(
          parentRvId: rv._id,
          date: initialCallDate.millisecondsSinceEpoch,
          notes: initialCallNotes,
          nextTopic: initialCallNextTopic);
      var visitId = await txn.insert(_tableName_Visits, visitDto.toMap());
      visitDto = visitDto.copyWith(id: visitId);

      var initialVisit = Visit._fromDto(dto: visitDto);
      for (var t in initialCallPlacements) {
        var p =
            Placement.create(parent: initialVisit, count: t.item1, type: t.item2, notes: t.item3);
        p._id = await txn.insert(_tableName_Placements, p._toMap());
        initialVisit.addPlacement(p);
      }

      rv.addVisit(initialVisit);

      await txn.update(_tableName_ReturnVisits, rv._toMap(),
          where: "ReturnVisitId = ?", whereArgs: [rv._id]);
    });

    _returnVisitsUpdated.sink.add(rv);
    return rv;
  }

  /// Delete the [rv] and all associated `Visit` and `Placement` entries.
  Future deleteReturnVisit(ReturnVisit rv) async {
    assert(rv != null);
    assert(rv._id > 0);

    final db = await _dbCompleter.future;

    var rvId = rv._id;

    await db.transaction((txn) async {
      var results = await txn.rawQuery(
          """SELECT VisitId FROM Visit WHERE FK_ReturnVisit_Visit_ParentRv = ?;""", [rvId]);
      if (results.length > 0) {
        String visitMatcher = results.length > 1
            ? "IN (${results.map((e) => e["VisitId"]).join(", ")})"
            : "= ${results.first["VisitId"]}";

        await txn.rawDelete(
            """DELETE FROM Placements WHERE FK_Visit_Placement_ParentVisit $visitMatcher;""");
        await txn.rawDelete("""DELETE FROM Visit WHERE VisitID $visitMatcher;""");
      }
      await txn.rawDelete("""DELETE FROM ReturnVisit WHERE ReturnVisitId = ?""", [rvId]);
    });

    if (rv.imagePath.isNotEmpty) {
      var image = await _imageService.getImageFile(rv.imagePath);
      await image.delete();
    }

    _returnVisitsUpdated.sink.add(null);
  }

  /// Updates an existing [rv].
  /// Does not update the `Visit` or `Placement` of the RV.
  /// Use the `updateVisit()` method to update those.
  Future updateReturnVisit(ReturnVisit rv) async {
    assert(rv != null);
    assert(rv._id > 0);

    final db = await _dbCompleter.future;

    await db.update(_tableName_ReturnVisits, rv._toMap(),
        where: "ReturnVisitId = ?", whereArgs: [rv._id]);

    _returnVisitsUpdated.sink.add(rv);
  }

  /// Add the [visit] to an existing `ReturnVisit`.
  /// If the [visit] is the lastest visit it will update the `ReturnVisit`.
  Future<Visit> addVisit(Visit visit) async {
    assert(visit != null);
    assert(visit._parentId > 0);
    assert(visit.date != null);
    if (visit._id > 0) return await updateVisit(visit);

    final db = await _dbCompleter.future;

    visit._id = await db.insert(_tableName_Visits, visit._toMap());

    if (visit.type != VisitType.NotAtHome) {
      var rv = await _getSingleRVDto(db, visit._parentId);

      if (rv.lastVisitDate < visit._date) {
        rv = rv.copyWith(lastVisitId: visit._id, lastVisitDate: visit._date);

        await db.update(_tableName_ReturnVisits, rv.toMap(),
            where: "ReturnVisitId = ?", whereArgs: [rv.id]);
      }

      await _updatePlacements(visit, db);
    }

    return visit;
  }

  /// Updates an existing [visit].
  /// If the [visit] is the lastest visit it will update the `ReturnVisit`.
  Future<Visit> updateVisit(Visit visit) async {
    assert(visit != null);
    assert(visit._parentId > 0);
    if (visit._id <= 0) return await addVisit(visit);

    final db = await _dbCompleter.future;

    if (visit.type != VisitType.NotAtHome) {
      var rv = await _getSingleRVDto(db, visit._parentId);

      if (rv.lastVisitDate < visit._date) {
        rv = rv.copyWith(lastVisitDate: visit._date, lastVisitId: visit._id);

        await db.update(_tableName_ReturnVisits, rv.toMap(),
            where: "ReturnVisitId = ?", whereArgs: [rv.id]);
      }

      await _updatePlacements(visit, db);

      await db
          .update(_tableName_Visits, visit._toMap(), where: "VisitId = ?", whereArgs: [visit._id]);
    }

    return visit;
  }

  /// Delete an existing [visit] and all it's associated `Placement`s.
  Future deleteVisit(Visit visit) async {
    assert(visit != null);
    assert(visit._id > 0);

    final db = await _dbCompleter.future;

    await db.transaction((txn) async {
      await txn.rawDelete(
          """DELETE FROM Placements WHERE FK_Visit_Placement_ParentVisit = ?;""", [visit._id]);
      await txn.rawDelete("""DELETE FROM Visit WHERE VisitID = ?;""", [visit._id]);
    });
  }

  Future _updatePlacements(Visit visit, Database db) async {
    for (var placement in visit.placements) {
      if (placement._id > 0) {
        await db.update(_tableName_Placements, placement._toMap(),
            where: "PlacementId = ?", whereArgs: [placement._id]);
      } else {
        placement._id = await db.insert(_tableName_Placements, placement._toMap());
      }
    }
  }

  Future<ReturnVisitDto> _getSingleRVDto(Database db, int id) async {
    var rvMap =
        await db.rawQuery("""SELECT * FROM ReturnVisit WHERE ReturnVisitId = ? LIMIT 1;""", [id]);
    var rv = ReturnVisitDto.fromMap(rvMap.first);
    return rv;
  }

  Future<List<Placement>> getPlacementsFromDates({DateTime start, DateTime end}) async {
    assert(start != null);
    assert(end != null);
    assert(start.isBefore(end));

    final db = await _dbCompleter.future;

    var placementsMap = await db.rawQuery(
        "SELECT * FROM Placements " +
            "WHERE FK_Visit_Placement_ParentVisit IN " +
            "(SELECT VisitId FROM Visit " +
            "WHERE Date >= ? AND Date <= ?);",
        [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch]);
    return placementsMap == null || placementsMap.isEmpty
        ? <Placement>[]
        : placementsMap.map((e) => Placement._fromDto(dto: PlacementDto.fromMap(e))).toList();
  }
}

class ReturnVisit {
  int _id;
  Address _address;
  String _name;
  Gender _gender;
  String _notes;
  String _imagePath;
  DateTime _lastVisitDate;
  bool _pinned;
  List<Visit> _visits = [];
  bool _isShallow = false;

  ReturnVisit._(
      [this._id,
      this._address,
      this._name,
      this._gender,
      this._imagePath,
      this._notes,
      this._pinned,
      this._isShallow,
      this._visits,
      this._lastVisitDate]) {
    _visits = _visits ?? <Visit>[];
  }

  factory ReturnVisit._shallowDto(ReturnVisitDto dto) {
    return ReturnVisit._(
        dto.id,
        Address(
            street: dto.street,
            city: dto.city,
            state: dto.state,
            postalCode: dto.postalCode,
            country: dto.country,
            latitude: dto.latitude ?? 0.0,
            longitude: dto.longitude ?? 0.0),
        dto.name,
        dto.gender,
        dto.imagePath,
        dto.notes,
        dto.pinned,
        true,
        [],
        DateTime.fromMillisecondsSinceEpoch(dto.lastVisitDate));
  }

  factory ReturnVisit._fromDto(ReturnVisitDto dto, List<Visit> visits) {
    var rv = ReturnVisit._(
        dto.id,
        Address(
            street: dto.street,
            city: dto.city,
            state: dto.state,
            postalCode: dto.postalCode,
            country: dto.country,
            latitude: dto.latitude ?? 0.0,
            longitude: dto.longitude ?? 0.0),
        dto.name,
        dto.gender,
        dto.imagePath,
        dto.notes,
        dto.pinned,
        false,
        visits);

    return rv;
  }

  factory ReturnVisit.create(
      {Address address,
      String name,
      Gender gender,
      String notes,
      String imagePath,
      bool pinned,
      DateTime initialVisitDate}) {
    return ReturnVisit._(-1, address ?? Address(), name ?? "", gender ?? Gender.Male,
        imagePath ?? "", notes ?? "", pinned ?? false, false, <Visit>[], initialVisitDate);
  }

  bool get isSaved => _id > 0;
  bool get isShallow => _isShallow;
  bool get pinned => _pinned;
  Address get address => _address;
  String get name => _name;
  String get notes => _notes;
  Gender get gender => _gender;
  String get imagePath => _imagePath;
  DateTime get lastVisitDate => (_isShallow && _visits.isEmpty)
      ? _lastVisitDate
      : _visits.maxBy((a, b) => a.date.compareTo(b.date)).date;
  Visit get lastVisit => _visits.maxBy((a, b) => a.date.compareTo(b.date));
  Visit get initialVisit => _visits.minBy((a, b) => a.date.compareTo(b.date));
  UnmodifiableListView<Visit> get visits => UnmodifiableListView(_visits ?? <Visit>[]);
  String get searchString => _toDto().createSearchString();

  set address(Address value) {
    if (_address != value) {
      _address = value;
    }
  }

  set name(String value) {
    if (_name != value) {
      _name = value;
    }
  }

  set notes(String value) {
    if (_notes != value) {
      _notes = value;
    }
  }

  set gender(Gender value) {
    if (_gender != value) {
      _gender = value;
    }
  }

  set imagePath(String value) {
    if (_imagePath != value) {
      _imagePath = value;
    }
  }

  set pinned(bool value) {
    if (_pinned != value) {
      _pinned = value;
    }
  }

  /// Examines the [other] return visit to determine if [other] is an updated
  /// copy of this return visit.
  bool isSameAs(ReturnVisit other) => _id == other._id;

  /// Examines the [visit] to determine if it is a child of this return visit.
  bool isParentOf(Visit visit) => _id == visit._parentId;

  /// Add a [visit] to this return visits list. Does not save to the database.
  void addVisit(Visit visit) => _visits.add(visit);

  /// Remove a [visit] from this object's list of visits.
  void deleteVisit(Visit visit) => _visits.removeWhere((element) => element._id == visit._id);

  ReturnVisitDto _toDto() => ReturnVisitDto(
      id: _id,
      street: address.street,
      city: address.city,
      state: address.state,
      postalCode: address.postalCode,
      country: address.country,
      latitude: address.latitude,
      longitude: address.longitude,
      name: name,
      gender: gender,
      notes: notes,
      imagePath: imagePath,
      lastVisitId: lastVisit != null ? lastVisit._id : null,
      lastVisitDate: lastVisit != null ? lastVisit._date : null,
      pinned: pinned);

  Map<String, dynamic> _toMap() => _toDto().toMap();
}

class Visit {
  int _id;
  int _date;
  String _notes;
  VisitType _type;
  List<Placement> _placements;
  String _nextTopic;
  int _parentId;

  Visit._(this._id, this._date, this._nextTopic, this._notes, this._parentId, this._placements,
      this._type);

  factory Visit._fromDto({VisitDto dto, List<Placement> placements}) => Visit._(
      dto.id, dto.date, dto.nextTopic ?? "", dto.notes ?? "", dto.parentRvId, placements, dto.type);

  factory Visit.create(
          {@required ReturnVisit parent, @required DateTime date, @required VisitType type}) =>
      Visit._(-1, date.millisecondsSinceEpoch, "", "", parent._id, [], type);

  bool get isSaved => _id > 0;
  DateTime get date => DateTime.fromMillisecondsSinceEpoch(_date);
  String get notes => _notes;
  VisitType get type => _type;
  UnmodifiableListView<Placement> get placements => UnmodifiableListView(_placements);
  String get nextTopic => _nextTopic;

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

  set type(VisitType value) {
    if (_type != value) {
      _type = value;
    }
  }

  set nextTopic(String value) {
    if (_nextTopic != value) {
      _nextTopic = value;
    }
  }

  // Examines the [other] visit to determine if [other] is an updated
  /// copy of this visit.
  bool isSameAs(Visit other) => _id == other._id;

  /// Examines the [rv] to determine if it is the parent of this visit.
  bool isChildOf(ReturnVisit rv) => _parentId == rv._id;

  void addPlacement(Placement placement) => _placements.add(placement);

  void removePlacement(Placement placement) => _placements.removeWhere((p) => p == placement);

  VisitDto _toDto() => VisitDto(
      id: _id,
      parentRvId: _parentId,
      date: date.millisecondsSinceEpoch,
      notes: notes,
      type: type,
      nextTopic: nextTopic);

  Map<String, dynamic> _toMap() => _toDto().toMap();
}

class Placement {
  int _id;
  int _count;
  String _notes;
  PlacementType _type;
  int _parentVisit;

  Placement._(this._id, this._count, this._notes, this._parentVisit, this._type);

  /// Creates a new `Placement` from a `DTO`
  factory Placement._fromDto({PlacementDto dto}) =>
      Placement._(dto.id, dto.count, dto.notes, dto.parentVisit, dto.type);

  factory Placement.create(
          {@required Visit parent,
          @required int count,
          @required PlacementType type,
          String notes}) =>
      Placement._(-1, count, notes, parent._id, type);

  /// The [count] of the placements.
  int get count => _count;

  /// The [notes] of the placement.
  String get notes => _notes;

  /// The [type] of the placement.
  PlacementType get type => _type;

  /// The [count] of the placements.
  set count(int value) {
    if (value != _count) {
      _count = value;
    }
  }

  /// The [notes] of the placement.
  set notes(String value) {
    if (value != _notes) {
      _notes = value;
    }
  }

  /// The [type] of the placement.
  set type(PlacementType value) {
    if (value != _type) {
      _type = value;
    }
  }

  PlacementDto _toDto() =>
      PlacementDto(id: _id, count: _count, type: _type, notes: _notes, parentVisit: _parentVisit);

  Map<String, dynamic> _toMap() => _toDto().toMap();
}
