import 'package:jama/data/core/db/dto.dart';
import 'package:meta/meta.dart';

class Address extends DTO {
  int id;
  
  String street1;
  String street2;
  String city;
  String country;
  String postalCode;
  String state;

  Address({
    @required this.street1,
    this.street2,
    this.city,
    @required this.country,
    this.postalCode,
    this.state
  });

  @override
  Address.fromMap(Map<String, dynamic> map) {
      street1 = map['street1'];
      street2 = map['street2'];
      city = map['city'];
      country = map['country'];
      postalCode = map['postalCode'];
      state = map['state'];
  }
  
  Map<String, dynamic> toMap() {
    return {
      'street1' : street1,
      'street2' : street2,
      'city' : city,
      'country' : country,
      'postalCode' : postalCode,
      'state' : state
    };
  }
}