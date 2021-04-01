import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong/latlong.dart';

import 'package:jama/data/models/address_model.dart';

class LocationService {
  bool _hasPermissionStatus;

  bool get hasLocationPermission => _hasPermissionStatus;

  Stream<Position> get locationStream =>
      Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.best);

  Future<bool> checkLocationPermissionStatus() async {
    final permissionStatus = await Geolocator.checkPermission();
    if (permissionStatus == LocationPermission.always ||
        permissionStatus == LocationPermission.whileInUse) {
      _hasPermissionStatus = true;
    } else {
      _hasPermissionStatus = false;
    }

    return _hasPermissionStatus;
  }

  Future<Address> getAddressFromCoordinates(
      {@required double latitude, @required double longitude, String locale}) async {
    if (latitude == 0.0 && longitude == 0.0) {
      return await getAddressFromCurrentCoordinates(locale: locale);
    }

    var placemarks = await placemarkFromCoordinates(latitude, longitude,
        localeIdentifier: locale ?? Intl.defaultLocale);

    if (placemarks != null && placemarks.isNotEmpty) {
      var placemark = placemarks.first;
      return Address.fromPlacemark(placemark, latitude, longitude);
    }

    return null;
  }

  Future<Address> getAddressFromCurrentCoordinates({String locale}) async {
    var position = await _getCurrentOrLastKnownPosition(false);

    var placemarks = await placemarkFromCoordinates(position.latitude, position.longitude,
        localeIdentifier: locale ?? Intl.defaultLocale);
    if (placemarks != null && placemarks.isNotEmpty) {
      var placemark = placemarks.first;
      return Address.fromPlacemark(placemark, position.latitude, position.longitude);
    }

    return null;
  }

  Future<Position> getCoordinatesFromAddress(Address address, {String locale}) async {
    var adrStr = address.toFormattedString();
    var locations =
        await locationFromAddress(adrStr, localeIdentifier: locale ?? Intl.defaultLocale);

    if (locations != null && locations.isNotEmpty) {
      return Position(longitude: locations.first.longitude, latitude: locations.first.latitude);
    }

    return null;
  }

  Future<Position> getCurrentOrLastKnownPosition([bool useCachedPosition = true]) async {
    return await _getCurrentOrLastKnownPosition(useCachedPosition);
  }

  _getCurrentOrLastKnownPosition(bool useCachedPosition) async {
    Position position;
    if (useCachedPosition) {
      position = await Geolocator.getLastKnownPosition();
    }

    if (position == null) {
      position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      if (position == null) {
        return null;
      }
    }

    return position;
  }

  /// Returns the distance between two coordinates in [unit].
  double getDistanceBetweenCoordinates(
      double startLatitude, double startLongitude, double endLatitude, double endLongitude,
      [LengthUnit unit = LengthUnit.Kilometer]) {
    final distance = Distance();
    return distance.as(
        unit, LatLng(startLatitude, startLongitude), LatLng(endLatitude, endLongitude));
  }
}
