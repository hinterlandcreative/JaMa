import 'package:geolocator/geolocator.dart';
import 'package:jama/data/models/mappable.dart';
import 'package:quiver/core.dart';

class Address extends Mappable {
  String street;
  String city;
  String country;
  String postalCode;
  String state;
  double latitude;
  double longitude;

  Address({
    this.street,
    this.city,
    this.country,
    this.postalCode,
    this.state,
    this.latitude = 0.0,
    this.longitude = 0.0
  });

  @override
  Address.fromMap(Map<String, dynamic> map) {
      street = map['street'];
      city = map['city'];
      country = map['country'];
      postalCode = map['postalCode'];
      state = map['state'];
      latitude = map['latitude'] ?? 0.0;
      longitude = map['longitude'] ?? 0.0;
  }

  Address.fromPlacemark(Placemark placemark) {
    street = placemark.name; 
    city = placemark.locality; 
    state = placemark.administrativeArea; 
    country = placemark.country; 
    postalCode = placemark.postalCode;
    latitude = placemark.position.latitude;
    longitude = placemark.position.longitude;
  }
  
  Map<String, dynamic> toMap() {
    return {
      'street' : street,
      'city' : city,
      'country' : country,
      'postalCode' : postalCode,
      'state' : state,
      'latitude' : latitude,
      'longitude' : longitude
    };
  }

  Address copy() {
    return Address.fromMap(this.toMap());
  }

  @override
  String toString() {
    return toFormattedString();
   }

  String toFormattedString([bool useTwoLines = false, bool showCountry = true, bool showPostalCode = true]) {
    return "${(street != null && street.isNotEmpty) ? street + " " : ""}" + 
        ((useTwoLines && (street != null && street.isNotEmpty)) ? "\n" : "") +
        "${(city != null && city.isNotEmpty) ? city + ", " : ""}" + 
        "${(state != null && state.isNotEmpty) ? state + " " : ""}" + 
        (showPostalCode ? "${(postalCode != null && postalCode.isNotEmpty) ? postalCode + " " : ""}" : "") + 
        (showCountry ? "$country" : "");
  }

  @override
  bool operator ==(dynamic other) {
    if(identical(this, other)) return true;

    if(other.runtimeType != this.runtimeType) return false;

    return this.street == other.street &&
      this.city == other.city &&
      this.country == other.country &&
      this.postalCode == other.postalCode &&
      this.state == other.state &&
      this.latitude == other.latitude &&
      this.longitude == other.longitude;
  }

  @override
  int get hashCode => hash2(
    hash3(
      street.hashCode, 
      city.hashCode, 
      country.hashCode), 
    hash4(
      postalCode.hashCode, 
      state.hashCode, 
      latitude.hashCode, 
      longitude.hashCode));
  }