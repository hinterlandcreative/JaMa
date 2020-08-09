import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong/latlong.dart';

import 'package:jama/data/models/address_model.dart';

class LocationService {
  static const _defaultLocationPermission = GeolocationPermission.locationWhenInUse;
  final Geolocator _geolocator;
  bool _hasPermissionStatus;

  bool get hasLocationPermission => _hasPermissionStatus;

  Stream<Position> get locationStream => _geolocator.getPositionStream(LocationOptions(accuracy: LocationAccuracy.best), _defaultLocationPermission);

  LocationService._([this._geolocator]);

  factory LocationService([Geolocator geoLocator]) {
    if(geoLocator == null) {
      geoLocator = Geolocator();
    }

    return LocationService._(geoLocator);
  }

  Future<bool> checkLocationPermissionStatus() async {
    final permissionStatus =  await _geolocator.checkGeolocationPermissionStatus(locationPermission: _defaultLocationPermission);
    if(permissionStatus == GeolocationStatus.granted || permissionStatus == GeolocationStatus.restricted) {
      _hasPermissionStatus = true;
    } else {
      _hasPermissionStatus = false;
    }

    return _hasPermissionStatus;
  }

  Future<Address> getAddressFromCoordinates({@required double latitude, @required double longitude, String locale}) async {
    if(latitude == 0.0 && longitude == 0.0) {
      return await getAddressFromCurrentCoordinates(locale: locale);
    }

    var placemarks = await _geolocator.placemarkFromCoordinates(latitude, longitude, localeIdentifier: locale ?? Intl.defaultLocale);


    if(placemarks != null && placemarks.isNotEmpty) {
      var placemark = placemarks.first;
      return Address.fromPlacemark(placemark);
    }

    return null;
  }

  Future<Address> getAddressFromCurrentCoordinates({String locale}) async {
    var position = await _getCurrentOrLastKnownPosition(false);
    
      var placemarks = await _geolocator.placemarkFromCoordinates(position.latitude, position.longitude, localeIdentifier: locale ?? Intl.defaultLocale);
      if(placemarks != null && placemarks.isNotEmpty) {
        var placemark = placemarks.first;
        return Address.fromPlacemark(placemark);
      }
  
      return null;
    }
  
    Future<Position> getCoordinatesFromAddress(Address address, {String locale}) async { 
      var adrStr = address.toFormattedString();
      var placemarks = await _geolocator.placemarkFromAddress(adrStr, localeIdentifier: locale ?? Intl.defaultLocale);
  
      if(placemarks != null && placemarks.isNotEmpty) {
        return placemarks.first.position;
      }
  
      return null;
    }

    Future<Position> getCurrentOrLastKnownPosition([bool useCachedPosition = true]) async {
      return await _getCurrentOrLastKnownPosition(useCachedPosition);
    }
  
    _getCurrentOrLastKnownPosition(bool useCachedPosition) async {
      Position position; 
      if(useCachedPosition) {
        position = await _geolocator.getLastKnownPosition();
      }

      if(position == null) {
        position = await _geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best, locationPermissionLevel: _defaultLocationPermission);
        if(position == null) {
          return null;
        }
      }

      return position;
    }

  /// Returns the distance between two coordinates in [unit].
  double getDistanceBetweenCoordinates(double startLatitude, double startLongitude, double endLatitude, double endLongitude, [LengthUnit unit = LengthUnit.Kilometer]) {
    final distance = Distance();
    return distance.as(unit, LatLng(startLatitude, startLongitude), LatLng(endLatitude, endLongitude));
  }
}