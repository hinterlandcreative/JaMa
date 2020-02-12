import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:jama/data/models/address_model.dart';
import 'package:jama/data/models/return_visit_model.dart';
import 'package:jama/data/models/visit_model.dart';
import 'package:jama/services/return_visit_service.dart';
import 'package:jama/ui/app_styles.dart';
import 'package:jama/ui/models/return_visits/edittable_return_visit_base_model.dart';
import 'package:jama/ui/models/return_visits/visit_card_model.dart';
import 'package:jama/ui/translation.dart';
import 'package:kiwi/kiwi.dart' as kiwi;
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:tuple/tuple.dart';

class EditReturnVisitModel extends EdittableReturnVisitBaseModel {
  final ReturnVisit _returnVisit;
  final ReturnVisitService _rvService;
  final List<Color> colors = [AppStyles.primaryColor, Colors.red, Colors.yellow];

  String _nextTopic = "";
  String _lastVisitString = "";
  String _bestTimeString = "";
  int _totalVisits = 1;
  List<VisitCardModel> _visits = [];
  List<charts.Series> _visitsByTypeSeries = [];

  EditReturnVisitModel._(this._returnVisit, this._rvService) {
    _loadData();
  }

  factory EditReturnVisitModel(ReturnVisit returnVisit, [ReturnVisitService rvService]) {
    var container = kiwi.Container();
    return EditReturnVisitModel._(returnVisit, rvService ?? container.resolve<ReturnVisitService>());
  }

  LatLng get mapPosition => _getPosition();

  String get nameOrDescription => _returnVisit.name.isNotEmpty ? _returnVisit.name : Translation.genderToString[_returnVisit.gender];

  String get lastVisitString => _lastVisitString;

  int get totalVisits => _totalVisits;

  UnmodifiableListView<VisitCardModel> get visits => UnmodifiableListView(_visits);

  String get formattedAddress => _returnVisit.address.toFormattedString(true, false);

  UnmodifiableListView<charts.Series> get visitsByTypeSeries => UnmodifiableListView(_visitsByTypeSeries);

  String get bestTimeString => _bestTimeString;

  String get notes => _returnVisit.notes;

  String get lastVisitDate => DateFormat.yMMMEd(Intl.defaultLocale).format(DateTime.fromMillisecondsSinceEpoch(_returnVisit.lastVisitDate));

  String get nextTopicToDsicuss => _nextTopic;

  Future _loadData() async {
    var visits = await _rvService.getAllVisitsForRv(_returnVisit);
    visits.sort((a,b) => a.date.compareTo(b.date));
    _totalVisits = visits.length;

    _setMostPopularTime(visits);
    _setTimeByTypeSeries(visits);

    _visits = visits.reversed
      .map((v) => VisitCardModel(visit: v))
      .toList();

    notifyListeners();
  }

  void _setTimeByTypeSeries(List<Visit> visits) {
    List<Tuple2<int, Color>> data = [];
    for(var type in VisitType.values) {
      var visitsOfType = visits.where((v) => v.type == type).toList();
      if(visitsOfType.length == 0) continue;
    
      data.add(Tuple2(visitsOfType.length, AppStyles.visitTypeToColor[type]));      
    }
    
    _visitsByTypeSeries.add(
      charts.Series<int, String>(
        id: "visits",
        data: data.map((d) => d.item1).toList(),
        domainFn: (int series, _) => series.toString(),
        measureFn: (int series, _) => series,
        colorFn: (int series, i) => charts.ColorUtil.fromDartColor(data[i].item2))
    );
  }

  void _setMostPopularTime(List<Visit> visits) {
    List<DateTime> datesOfVisits = visits
      .where((v) => v.type != VisitType.NotAtHome)
      .map((v) => DateTime.fromMillisecondsSinceEpoch(v.date))
      .toList();
    
    int mostPopularDay = _getMostPopularDay(datesOfVisits);
    String mostPopularDayString = Translation.daysOfTheWeek[mostPopularDay];

    
    var visitsFromMostPopularDay = datesOfVisits
      .where((v) => v.weekday == mostPopularDay)
      .toList();
    
    var mostPopularHours = _getMostPopularHour(visitsFromMostPopularDay);
    var startTime = DateTime(DateTime.now().year, 1,1, mostPopularHours.first);
    var endTime = DateTime(DateTime.now().year, 1,1, mostPopularHours.last);
    _bestTimeString = "Usually home on $mostPopularDayString between ${DateFormat.jm(Intl.defaultLocale).format(startTime)} - ${DateFormat.jm(Intl.defaultLocale).format(endTime)}";
  }
  
  LatLng _getPosition() {
    if(_returnVisit.address.latitude != null && _returnVisit.address.latitude != 0.0
       && _returnVisit.address.longitude != null && _returnVisit.address.longitude != 0.0) {
        return LatLng(_returnVisit.address.latitude, _returnVisit.address.longitude);
      }
    
    return null;
  }

  int _getMostPopularDay(List<DateTime> days) {
    Map<int,int> countByDaysOfTheWeek = { };
    var dayOfWeek = 1;
    var highestCount = 0;
    for(var day in [1, 2, 3, 4, 5, 6, 7]) {
      countByDaysOfTheWeek[day] = days.fold(0, (x, v) => x + v.weekday == day ? 1 : 0);
      var count = countByDaysOfTheWeek[day];
      if(count > highestCount) {
        dayOfWeek = day;
      }
    }
    return dayOfWeek;
  }

  List<int> _getMostPopularHour(List<DateTime> days) {
    Map<int,int> countByHourOfTheDay = { };
    if(days.length == 1) {
      return [days.first.hour, days.first.hour + 1];
    } else if(days.length == 2) {
      var hours = days.map((x) => x.hour).toList();
      hours.sort();
      return [hours.first, hours.last];
    } else if(days.length == 3) {
      var hours = days.map((x) => x.hour).toList();
      hours.sort();
      var minDiff = hours[1] - hours[0];
      var minDiff2 = hours[2] - hours[1];
      if (minDiff > minDiff2) {
        return [hours[0], hours[1]];
      } else {
        return [hours[1], hours[2]];
      }
    } else {
      for(int hour in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 23, 24]) {
        countByHourOfTheDay[hour] = days.fold(0, (x, v) => x + v.hour == hour ? 1 : 0);
      }
      var sortedHours = countByHourOfTheDay.values.where((x) => x != 0).toList();
      sortedHours.sort();
      if(sortedHours.last == 1) {
        var hour = sortedHours.reduce((a,b) => a + b) ~/ sortedHours.length;
        return [hour, hour + 1];
      } else {
        return [sortedHours.last, sortedHours.last + 1];
      }
    }
  }

  @override
  bool get pinned => _returnVisit.pinned;
  @override
  set pinned(bool isPinned){
    if(_returnVisit.pinned != isPinned) {
      _returnVisit.pinned = isPinned;
      save();
      notifyListeners();
    }
  }

  @override
  String get name => _returnVisit.name;
  @override
  set name(String name) {
    if(_returnVisit.name != name) {
      _returnVisit.name = name;
      notifyListeners();
    }
  }

  @override
  String get gender => Translation.genderToString[_returnVisit.gender];
  @override
  set gender(String gender) {
    if(Translation.genderToString[_returnVisit.gender] != gender) {
      _returnVisit.gender = gender == Translation.genderToString[Gender.Male] ? Gender.Male : Gender.Female;
      notifyListeners();
    }

  }

  @override
  Address get address => _returnVisit.address;
  @override
  set address(Address address) {
    if(_returnVisit.address != address) {
      _returnVisit.address = address;
      notifyListeners();
    }
  }

  @override
  String get street => _returnVisit.address.street;
  @override
  set street(String street) {
    if(_returnVisit.address.street != street) {
      _returnVisit.address.street = street;
      notifyListeners();
    }
  }

  @override
  String get city => _returnVisit.address.city;
  @override
  set city(String city) {
    if(_returnVisit.address.city != city) {
      _returnVisit.address.city = city;
      notifyListeners();
    }
  }

  @override
  String get state => _returnVisit.address.state;
  @override
  set state(String state) {
    if(_returnVisit.address.state != state) {
      _returnVisit.address.state = state;
      notifyListeners();
    }
  }

  @override
  String get postalCode => _returnVisit.address.postalCode;
  @override
  set postalCode(String postalCode) {
    if(_returnVisit.address.postalCode != postalCode) {
      _returnVisit.address.postalCode = postalCode;
      notifyListeners();
    }
  }

  @override
  String get country => _returnVisit.address.country;
  @override
  set country(String country) {
    if(_returnVisit.address.country != country) {
      _returnVisit.address.country = country;
      notifyListeners();
    }
  }

  @override
  set notes(String notes) {
    if(_returnVisit.notes != notes) {
      _returnVisit.notes = notes;
      notifyListeners();
    }
  }

  @override
  List<int> get image => [];
  @override
  set image(List<int> imagePath) {
    // TODO: implement once maps support screenshots.
  }

  @override
  double get latitude => _returnVisit.address.latitude;
  @override
  set latitude(double lat) {
    if(_returnVisit.address.latitude != lat) {
      _returnVisit.address.latitude = lat;
      notifyListeners();
    }
  }

  @override
  double get longitude => _returnVisit.address.longitude;
  @override
  set longitude(double long) {
    if(_returnVisit.address.longitude != long) {
      _returnVisit.address.longitude = long;
      notifyListeners();
    }
  }

  @override
  Future save() async {
    if(validate()) {
      await _rvService.updateReturnVisit(_returnVisit);
    }
  }

  @override
  bool validate() {
    return _returnVisit.address.city != null 
        && _returnVisit.address.city.isNotEmpty 
        && _returnVisit.lastVisitDate != null 
        && _returnVisit.lastVisitId > 0;
  }
}