import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';

import 'package:jama/data/core/db/db_collection.dart';
import 'package:jama/data/core/db/query_package.dart';
import 'package:jama/data/models/address_model.dart';
import 'package:jama/data/models/placement_model.dart';
import 'package:jama/data/models/return_visit_model.dart';
import 'package:jama/data/models/visit_model.dart';
import 'package:jama/services/database_service.dart';
import 'package:jama/services/image_service.dart';

import 'package:kiwi/kiwi.dart';
import 'package:supercharged/supercharged.dart';

class ReturnVisitService {
  ImageService _imageService;

  final String _returnVisitDatabaseName = "returnvisits";
  final String _visitsDatabaseName = "visits";
  final Completer<DbCollection> _returnVisitCollection = Completer();
  final Completer<DbCollection> _visitsCollection = Completer();
  final StreamController<ReturnVisitDto> _returnVisitsUpdated = StreamController.broadcast();

  /// Get the stream of events indicating the return visits have changed.
  Stream<ReturnVisitDto> get returnVisitUpdates => _returnVisitsUpdated.stream;

  ReturnVisitService([ImageService imageService, DatabaseService databaseService]) {
    var container = Container();

    var dbService = databaseService ?? container.resolve<DatabaseService>();
    _imageService = imageService ?? container.resolve<ImageService>();

    var getReturnVisitCollection = () async {
      final db = await dbService.getMainStorage();
      return db.collections(_returnVisitDatabaseName);
    };
    
    _returnVisitCollection.complete(getReturnVisitCollection());

    var getVisitsCollection = () async {
      final db = await dbService.getMainStorage();
      return db.collections(_visitsDatabaseName);
    };

    _visitsCollection.complete(getVisitsCollection());
  }

  /// Add [rv] as a new return visit.
  /// 
  /// The [rv] and [initialCallDate] are required.
  Future<ReturnVisitDto> addNewReturnVisit({
    @required ReturnVisitDto rv, 
    @required DateTime initialCallDate, 
    List<Placement> initialCallPlacements, 
    String initialCallNotes}) async {
    assert(initialCallDate != null);
    assert(rv != null);

    var returnVisitDb = await _returnVisitCollection.future;
    var rvId = await returnVisitDb.add(rv);
    assert(rvId != null);
    assert(rvId >= 0);
    
    rv.id = rvId;
    rv.lastVisitDate = initialCallDate.millisecondsSinceEpoch;
    
    var initialCall = VisitDto(
      date: initialCallDate,
      parentRvId: rvId,
      notes: initialCallNotes,
      type: VisitType.ReturnVisit,
      placements: initialCallPlacements);
    
    var visitsDb = await _visitsCollection.future;
    
    rv.lastVisitId = await visitsDb.add(initialCall);

    assert(rv.lastVisitId != null);
    assert(rv.lastVisitId >= 0);

    await returnVisitDb.update(rv);

    _returnVisitsUpdated.add(rv);
    return rv;
  }

  Future<List<ReturnVisitDto>> getAllReturnVisits() async {
    var returnVisitsDb = await _returnVisitCollection.future;
    return await returnVisitsDb.getAll((map) => ReturnVisitDto.fromMap(map));
  }

  Future<List<VisitDto>> getAllVisitsForRv(ReturnVisitDto rv) async {
    var visitsDb = await _visitsCollection.future;
    return await visitsDb.query([
      QueryPackage(
        key: "parentRvId",
        value: rv.id,
        filter: FilterType.EqualTo)
    ], 
    (map) => VisitDto.fromMap(map));
  }

  Future delete(ReturnVisitDto rv) async {
    assert(rv != null);
    assert(rv.id > 0);
    var returnVisitsDb = await _returnVisitCollection.future;
    await returnVisitsDb.deleteFromDto(rv);

    var visits = await getAllVisitsForRv(rv);
    var visitsDb = await _visitsCollection.future;
    for(var visit in visits) {
      await visitsDb.deleteFromDto(visit);
    }

    if(rv.imagePath.isNotEmpty) {
      var imageFile = await _imageService.getImageFile(rv.imagePath);
      await imageFile.delete();
    }

    _returnVisitsUpdated.add(rv);
  }

  Future updateReturnVisit(ReturnVisitDto rv) async {
    assert(rv != null);
    assert(rv.id > 0);
    assert(rv.lastVisitDate != null);
    assert(rv.lastVisitId > 0);

    var returnVisitsDb = await _returnVisitCollection.future;
    await returnVisitsDb.update(rv);

    _returnVisitsUpdated.add(rv);
  }

  Future addOrUpdateVisit(VisitDto visit) async {
    assert(visit.parentRvId >= 0);
    assert(visit.date != null);

    var rvDb = await _returnVisitCollection.future;
    var rv = await rvDb.getOne(
      visit.parentRvId, 
      itemCreator: (map) => ReturnVisitDto.fromMap(map));

    assert(rv != null);

    var visitsDb = await _visitsCollection.future;

    var id = await visitsDb.add(visit);
    visit.id = id;

    if(visit.type != VisitType.NotAtHome && (visit.date != rv.lastVisitDate || visit.id != rv.lastVisitId)) {
      rv.lastVisitDate = visit.date;
      rv.lastVisitId = id;
      await updateReturnVisit(rv);
      _returnVisitsUpdated.add(rv);
    }
  }

  Future deleteVisit(VisitDto visit) async {
    assert(visit.parentRvId >= 0);
    assert(visit.date != null);

    var rvDb = await _returnVisitCollection.future;
    var rv = await rvDb.getOne(
      visit.parentRvId, 
      itemCreator: (map) => ReturnVisitDto.fromMap(map));

    assert(rv != null);

    var visitsDb = await _visitsCollection.future;

    await visitsDb.deleteFromId(visit.id);

    if(rv.lastVisitId == visit.id) {
      var visits = await getAllVisitsForRv(rv);
      var last = visits.where((v) => v.type != VisitType.NotAtHome).maxBy((a, b) => a.date.compareTo(b.date));
      rv.lastVisitDate = last.date;
      rv.lastVisitId = last.id;

      await updateReturnVisit(rv);
      _returnVisitsUpdated.add(rv);
    }
  }

  Future<List<ReturnVisit>> getVisitsByDate({DateTime start, DateTime end}) async {
    assert(end != null);
    assert(start != null);
    assert(start.isAfter(end));
    
    var visitDb = await _visitsCollection.future;
    var rvDb = await _returnVisitCollection.future;

    var visits = await visitDb.query([
      QueryPackage(
        filter: FilterType.GreaterThanOrEqualTo,
        key: "date",
        value: start.millisecondsSinceEpoch
      ),
      QueryPackage(
        filter: FilterType.LessThanOrEqualTo,
        key: "date",
        value: end.millisecondsSinceEpoch
      )], 
      (map) => VisitDto.fromMap(map)); 

    var rvIds = visits.map((e) => e.parentRvId).toSet();

    var returnVisits = <ReturnVisit>[];
    for(var id in rvIds) {
      var rv = await rvDb.getOne(id, itemCreator: (map) => ReturnVisitDto.fromMap(map));
      returnVisits.add(ReturnVisit.fromDto(
        rv, 
        visits.where((element) => element.parentRvId == id)));
    }

    return returnVisits;
  }
}

class ReturnVisit extends ChangeNotifier {
  int _id;
  Address _address;
  String _name;
  Gender _gender;
  String _notes;
  String _imagePath;
  int _lastVisitId;
  bool _pinned;
  List<Visit> _visits;

  ReturnVisit._(
    this._id, 
    this._address, 
    this._name, 
    this._gender, 
    this._imagePath,
    this._lastVisitId, 
    this._notes, 
    this._pinned);

  factory ReturnVisit.fromDto(ReturnVisitDto dto, List<VisitDto> visits) {
    var rv = ReturnVisit._(dto.id, dto.address, dto.name, dto.gender, dto.imagePath, dto.lastVisitId, dto.notes, dto.pinned);
    rv._visits = visits
      .map((e) => Visit.fromDto(dto: e, parent: rv))
      .toList();
    
    return rv;
  }

  factory ReturnVisit.create() {
    return ReturnVisit._(-1, Address(), "", Gender.Male, "", null, "", false);
  }

  bool get isSaved => _id > 0;
  bool get pinned => _pinned;
  Address get address => _address;
  String get name => _name;
  String get notes => _notes;
  Gender get gender => _gender;
  String get imagePath => _imagePath;
  DateTime get lastVisitDate => _visits.maxBy((a, b) => a.date.compareTo(b.date)).date;
  Visit get lastVisit => _visits.firstWhere((element) => element._id == _lastVisitId);
  Visit get initialVisit => _visits.minBy((a, b) => a.date.compareTo(b.date));

  set address(Address value) {
    if(_address != value) {
      _address = value;
    }
  }

  set name(String value) {
    if(_name != value) {
      _name = value;
    }
  }

  set notes(String value) {
    if(_notes != value) {
      _notes = value;
    }
  }

  set gender(Gender value) {
    if(_gender != value) {
      _gender = value;
    }
  }

  set imagePath(String value) {
    if(_imagePath != value) {
      _imagePath = value;
    }
  }

  set pinned(bool value) {
    if(_pinned != value) {
      _pinned = value;
    }
  }

  void addVisit(Visit visit) => _visits.add(visit);

  void deleteVisit(Visit visit) => _visits.removeWhere((element) => element._id == visit._id);

  ReturnVisitDto _toDto() => ReturnVisitDto(
      address: address,
      name: name,
      gender: gender,
      notes: notes,
      imagePath: imagePath,
      lastVisit: lastVisit._toDto(),
      pinned: pinned
    );
}

class Visit {
  int _id;
  int _date;
  String _notes;
  VisitType _type;
  List<Placement> _placements;
  String _nextTopic;
  ReturnVisit _parent;

  Visit._(
    this._id,
    this._date,
    this._nextTopic,
    this._notes,
    this._parent,
    this._placements,
    this._type
  );

  factory Visit.fromDto({VisitDto dto, ReturnVisit parent}) {
    return Visit._(dto.id, dto.date, dto.nextTopic, dto.notes, parent, dto.placements, dto.type);
  }

  factory Visit.create({ReturnVisit parent, DateTime date, VisitType type}) {
    return Visit._(-1, date.millisecondsSinceEpoch, "", "", parent, [], type);
  }

  ReturnVisit get parent => _parent;
  DateTime get date => DateTime.fromMillisecondsSinceEpoch(_date);
  String get notes => _notes;
  VisitType get type => _type;
  UnmodifiableListView<Placement> get placements => UnmodifiableListView(_placements);
  String get nextTopic => _nextTopic;

  set date(DateTime value) {
    if(_date != value.millisecondsSinceEpoch) {
      _date = value.millisecondsSinceEpoch;
    }
  }

  set notes(String value) {
    if(_notes != value) {
      _notes = value;
    }
  }

  VisitDto _toDto() => VisitDto(
      id: _id,
      parentRvId: parent._id,
      date: date,
      notes: notes,
      type: type,
      placements: placements, 
      nextTopic: nextTopic
    );
}