import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';

import 'package:jama/data/core/db/db_collection.dart';
import 'package:jama/data/core/db/query_package.dart';
import 'package:jama/data/models/address_model.dart';
import 'package:jama/data/models/dto/return_visit_model.dart';
import 'package:jama/data/models/dto/visit_model.dart';
import 'package:jama/data/models/placement.dart';
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
  final StreamController<ReturnVisit> _returnVisitsUpdated = StreamController.broadcast();

  /// Get the stream of events indicating the return visits have changed.
  Stream<ReturnVisit> get returnVisitUpdates => _returnVisitsUpdated.stream;

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
  Future<ReturnVisit> addNewReturnVisit({
    @required ReturnVisit rv, 
    @required DateTime initialCallDate, 
    List<Placement> initialCallPlacements, 
    String initialCallNotes}) async {
    assert(initialCallDate != null);
    assert(rv != null);

    var rvDto = rv._toDto();

    var returnVisitDb = await _returnVisitCollection.future;
    var rvId = await returnVisitDb.add(rvDto);
    assert(rvId != null);
    assert(rvId >= 0);
    rvDto = rvDto.copyWith(id: rvId);
    
    
    var initialCall = VisitDto(
      date: initialCallDate.millisecondsSinceEpoch,
      parentRvId: rvId,
      notes: initialCallNotes,
      type: VisitType.ReturnVisit,
      placements: initialCallPlacements);
    
    var visitsDb = await _visitsCollection.future;
    
    var visitId = await visitsDb.add(initialCall);

    rvDto = rvDto.copyWith(
      lastVisitDate: initialCallDate.millisecondsSinceEpoch,
      lastVisitId: visitId
    );

    await returnVisitDb.update(rvDto);

    _returnVisitsUpdated.add(ReturnVisit.fromDto(rvDto, [initialCall]));
    return rv;
  }

  Future<List<ReturnVisit>> getAllReturnVisits() async {
    var returnVisitsDb = await _returnVisitCollection.future;
    var dtoList = await returnVisitsDb.getAll((map) => ReturnVisitDto.fromMap(map));
    List<ReturnVisit> rvList = [];
    for(var dto in dtoList) {
      var visits = await _getAllVisitsForRv(dto);
      rvList.add(ReturnVisit.fromDto(dto, visits));
    }

    return rvList;
  }

  Future<List<VisitDto>> _getAllVisitsForRv(ReturnVisitDto rv) async {
    var visitsDb = await _visitsCollection.future;
    return await visitsDb.query([
      QueryPackage(
        key: "parentRvId",
        value: rv.id,
        filter: FilterType.EqualTo)
    ],  
    (map) => VisitDto.fromMap(map));
  }

  Future delete(ReturnVisit rv) async {
    assert(rv != null);
    assert(rv._id > 0);
    var dto = rv._toDto();
    var returnVisitsDb = await _returnVisitCollection.future;
    await returnVisitsDb.deleteFromDto(dto);

    var visits = await _getAllVisitsForRv(dto);
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

  Future updateReturnVisit(ReturnVisit rv) async {
    assert(rv != null);
    assert(rv._id > 0);
    assert(rv.lastVisitDate != null);
    assert(rv.lastVisit._id > 0);

    var returnVisitsDb = await _returnVisitCollection.future;
    await returnVisitsDb.update(rv._toDto());

    _returnVisitsUpdated.add(rv);
  }

  Future addVisit(Visit visit) async {
    assert(visit != null);
    assert(visit._parentId > 0);
    assert(visit.date != null);
    if(visit._id > 0) return await updateVisit(visit);
    var dto = visit._toDto();

    var rvDb = await _returnVisitCollection.future;
    var rv = await rvDb.getOne(visit._parentId, itemCreator: (map) => ReturnVisitDto.fromMap(map));
    
    var visitsDb = await _visitsCollection.future;

    var id = await visitsDb.add(dto);
    dto = dto.copyWith(id: id);

    if(visit.type != VisitType.NotAtHome && visit.date.millisecondsSinceEpoch > rv.lastVisitDate) {

      rv = rv.copyWith(
        lastVisitDate: dto.date,
        lastVisitId: id
      );
      
      await rvDb.update(rv);
      var visits = await _getAllVisitsForRv(rv);

      _returnVisitsUpdated.add(ReturnVisit.fromDto(rv, visits));
    }
  }

  Future updateVisit(Visit visit) async {
    assert(visit._parentId >= 0);
    assert(visit.date != null);

    if(visit._id <= 0) return await addVisit(visit);

    var rvDb = await _returnVisitCollection.future;
    var rv = await rvDb.getOne(visit._parentId, itemCreator: (map) => ReturnVisitDto.fromMap(map));
    var dto = visit._toDto();

    assert(rv != null);

    var visitsDb = await _visitsCollection.future;

    var id = await visitsDb.update(dto);
    dto = dto.copyWith(id: id);

    // TODO: this needs lots of tests.
    if((rv.lastVisitId == id && dto.date != rv.lastVisitDate)
      || (dto.date > rv.lastVisitDate)) {

      var visits = await _getAllVisitsForRv(rv);
      var latestVisit = visits
        .where((element) => element.type != VisitType.NotAtHome)
        .maxBy((a, b) => a.date.compareTo(b.date));

      rv = rv.copyWith(
        lastVisitDate: latestVisit.date,
        lastVisitId: latestVisit.id
      );
      await rvDb.update(rv);
      _returnVisitsUpdated.add(ReturnVisit.fromDto(rv, visits));
    }
  }

  Future deleteVisit(Visit visit) async {
    assert(visit._parentId >= 0);
    assert(visit.date != null);

    var rvDb = await _returnVisitCollection.future;
    var rv = await rvDb.getOne(
      visit._parentId, 
      itemCreator: (map) => ReturnVisitDto.fromMap(map));

    assert(rv != null);

    var visitsDb = await _visitsCollection.future;

    await visitsDb.deleteFromId(visit._id);

    if(rv.lastVisitId == visit._id) {
      var visits = await _getAllVisitsForRv(rv);
      var last = visits
        .where((v) => v.type != VisitType.NotAtHome)
        .maxBy((a, b) => a.date.compareTo(b.date));
      
      rv = rv.copyWith(
        lastVisitDate: last.date,
        lastVisitId: last.id
      );

      await rvDb.update(rv);
      _returnVisitsUpdated.add(ReturnVisit.fromDto(rv, visits));
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

class ReturnVisit {
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

  factory ReturnVisit.create(
    {Address address,
    String name,
    Gender gender,
    String notes,
    String imagePath,
    bool pinned}
  ) {
    return ReturnVisit._(
      -1, 
      address ?? Address(), 
      name ?? "", 
      gender ?? Gender.Male, 
      imagePath ?? "", 
      null, 
      notes ?? "", 
      pinned ?? false);
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
  UnmodifiableListView<Visit> get visits => UnmodifiableListView(_visits);
  String get searchString => _toDto().createSearchString();

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
      address: address,
      name: name,
      gender: gender,
      notes: notes,
      imagePath: imagePath,
      lastVisitId: lastVisit._id,
      lastVisitDate: lastVisit._date,
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
  int _parentId;

  Visit._(
    this._id,
    this._date,
    this._nextTopic,
    this._notes,
    this._parentId,
    this._placements,
    this._type
  );

  factory Visit.fromDto({VisitDto dto, ReturnVisit parent}) => Visit._(
    dto.id, 
    dto.date, 
    dto.nextTopic, 
    dto.notes, 
    parent._id, 
    dto.placements, 
    dto.type);

  factory Visit.create({
    @required ReturnVisit parent, 
    @required DateTime date, 
    @required VisitType type}) => Visit._(
    -1, 
    date.millisecondsSinceEpoch, 
    "", 
    "", 
    parent._id, 
    [], 
    type);
  
  bool get isSaved => _id > 0;
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

  set type(VisitType value) {
    if(_type != value) {
      _type = value;
    }
  }

  set nextTopic(String value) {
    if(_nextTopic != value) {
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
      placements: placements, 
      nextTopic: nextTopic
    );
}