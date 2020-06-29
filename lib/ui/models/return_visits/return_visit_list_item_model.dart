import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:jama/data/models/return_visit_model.dart';
import 'package:jama/services/image_service.dart';
import 'package:jama/services/location_service.dart';
import 'package:jama/services/return_visit_service.dart';
import 'package:jama/ui/models/return_visits/edit_return_visit_model.dart';
import 'package:jama/ui/screens/return_visits/edit_return_visit_screen.dart';
import 'package:jama/mixins/date_mixin.dart';
import 'package:jama/mixins/num_mixin.dart';
import 'package:kiwi/kiwi.dart' as kiwi;
import 'package:latlong/latlong.dart';
import 'package:path/path.dart' as path;

class ReturnVisitListItemModel {
  final ReturnVisit _returnVisit;
  final String distanceFromCurrentLocation;
  final Color timeSinceColor;
  final String timeSinceString;
  final ReturnVisitService _rvService;
  final ImageService _imageService;
  String _basePath;

  ReturnVisitListItemModel._(
    this._returnVisit, 
    this.distanceFromCurrentLocation, 
    this.timeSinceColor, 
    this.timeSinceString, 
    this._rvService, 
    this._imageService) {
      _imageService.documentsDirectory.then((value) => _basePath = value.path);
    }
  
  factory ReturnVisitListItemModel({@required ReturnVisit returnVisit, @required double currentLatitude, @required double currentLongitude, LocationService locationService, ReturnVisitService returnVisitService, ImageService imageService}) {
    assert(returnVisit != null);
    assert(returnVisit.id >= 0);
    assert(currentLatitude != null);
    assert(currentLongitude != null);

    var container = kiwi.Container();
    locationService = locationService ?? container.resolve<LocationService>();
    

    var distance = "";
    Color timeSinceColor = Colors.green;
    var lastVisitDate = DateTime.fromMillisecondsSinceEpoch(returnVisit.lastVisitDate);
    var duration = DateTime.now().difference(lastVisitDate);
    var aMonth = aWeek + aWeek + aWeek + aWeek;
    if(duration.inDays >= 30) {
      timeSinceColor = Colors.red;
    } else if(duration.inDays > 13) {
      timeSinceColor = Colors.orange;
    } 

    var timeSinceString = lastVisitDate.humanizeTimeSince();

    if(returnVisit.address.latitude != null && returnVisit.address.latitude != 0 && returnVisit.address.longitude != null && returnVisit.address.longitude != 0) {
      var distanceInMiles = locationService.getDistanceBetweenCoordinates(returnVisit.address.latitude, returnVisit.address.longitude, currentLatitude, currentLongitude, LengthUnit.Mile);
        if(distanceInMiles < 1.0) {
          var distanceInFeet = (distanceInMiles * 5280).toInt(); 
          distance = "${distanceInFeet.commaize()} FEET";
        } else {
          distance = "${distanceInMiles.toInt().commaize()} MILES";
        }
    }
    
    return ReturnVisitListItemModel._(
      returnVisit,
      distance,
      timeSinceColor,
      timeSinceString,
      returnVisitService ?? container.resolve<ReturnVisitService>(),
      imageService ?? container.resolve<ImageService>());
  }

  Future delete() async {
    await _rvService.delete(_returnVisit);
  }

  bool get hasEmptyName => _returnVisit.name.isEmpty;
  
  String get nameOrDescription => _returnVisit.name.isNotEmpty ? _returnVisit.name : _returnVisit.gender == Gender.Male ? "Man" : "Woman";
  
  Gender get gender => _returnVisit.gender;
  
  String get formattedAddress => _returnVisit.address.toFormattedString(true, false, false);

  String get imagePath => _returnVisit.imagePath.isNotEmpty ? path.join(_basePath, _returnVisit.imagePath) : "";

  String get searchString => _returnVisit.createSearchString();

  bool get isPinned => _returnVisit.pinned;

  void navigate(BuildContext context) {
    if(_returnVisit.id != null && _returnVisit.id > 0) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => EditReturnVisitScreen(
            returnVisit: EditReturnVisitModel(_returnVisit),)));
    }
  }
}