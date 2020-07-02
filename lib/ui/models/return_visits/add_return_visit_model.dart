import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';
import 'package:jama/data/models/address_model.dart';
import 'package:jama/data/models/placement_model.dart';
import 'package:jama/data/models/return_visit_model.dart';
import 'package:jama/data/models/visit_model.dart';
import 'package:jama/services/image_service.dart';
import 'package:jama/services/location_service.dart';
import 'package:jama/services/return_visit_service.dart';
import 'package:jama/ui/controllers/address_controller.dart';
import 'package:jama/ui/models/return_visits/edittable_return_visit_base_model.dart';
import 'package:kiwi/kiwi.dart' as kiwi;

class AddReturnVisitModel extends EdittableReturnVisitBaseModel {

  AddressController _addressController = AddressController();

  ReturnVisitService _returnVisitService;
  ImageService _imageService;
  LocationService _locationService;

  String _name = "";
  Gender _gender;
  String _street = "";
  String _city = "";
  String _state = "";
  String _postalCode = "";
  String _country = "";
  String _notes = "";
  double _latitude;
  double _longitude;
  bool _pinned = false;
  DateTime _initialCallDate = DateTime.now();
  List<Placement> _initialCallPlacements = [];
  String _initialCallNotes = "";
  String _initialCallNextTopic = "";
  Uint8List _image;


  AddressController get addressController => _addressController;

  bool get pinned => _pinned;

  set pinned(bool isPinned) {
    if(_pinned != isPinned) {
      _pinned = isPinned;
      notifyListeners();
    }
  }

  String get name => _name ?? "";

  set name(String name) {
    if(_name != name) {
      _name = name;
      notifyListeners();
    }
  }

  Gender get gender => _gender == null ? Gender.Male : _gender;

  set gender(Gender value) {
    if(_gender != value) {
      _gender = value;
      notifyListeners();
    }
  }

  Address get address => _getAddress();

  String get street => _street;

  set street(String street) {
    if(_street != street) {
      _street = street;
      checkForNewCoordinates();
      notifyListeners();
    }
  }

  String get city => _city;

  set city(String city) {
    if(_city != city) {
      _city = city;
      checkForNewCoordinates();
      notifyListeners();
    }
  }

  String get state => _state;

  set state(String state) {
    if(_state != state) {
      _state = state;
      checkForNewCoordinates();
      notifyListeners();
    }
  }

  String get postalCode => _postalCode;

  set postalCode(String postalCode) {
    if(_postalCode != postalCode) {
      _postalCode = postalCode;
      checkForNewCoordinates();
      notifyListeners();
    }
  }

  String get country => _country;

  set country(String country) {
    if(_country != country) {
      _country = country;
      checkForNewCoordinates();
      notifyListeners();
    }
  }

  String get notes => _notes ?? "";

  set notes(String notes) {
    if(_notes != notes) {
      _notes = notes;
      notifyListeners();
    }
  }

  Uint8List get image => _image ?? [];

  set image(Uint8List value) {
    if(_image != value) {
      _image = value;
      notifyListeners();
    }
  }

  double get latitude => _latitude;

  @override
  set latitude(double lat) {
    if(_latitude != lat) {
      _latitude = lat;
      notifyListeners();
    }
  }

  double get longitude => _longitude;

  @override
  set longitude(double long) {
    if(_longitude != long) {
      _longitude = long;
      notifyListeners();
    }
  }

  DateTime get initialCallDate => _initialCallDate;

  set initialCallDate(DateTime date) {
    if(_initialCallDate == null || (_initialCallDate.day != date.day && _initialCallDate.year != date.year && _initialCallDate.month != date.month)) {
      _initialCallDate = date;
      notifyListeners();
    }
  }

  UnmodifiableListView<Placement> get initialCallPlacements => UnmodifiableListView(_initialCallPlacements);

  String get initialCallNotes => _initialCallNotes;

  set initialCallNotes(String notes) {
    if(_initialCallNotes != notes) {
      _initialCallNotes = notes;
      notifyListeners();
    }
  }

  String get initialCallNextTopic => _initialCallNotes;

  set initialCallNextTopic(String topic) {
    if(_initialCallNextTopic != topic) {
      _initialCallNextTopic = topic;
      notifyListeners();
    }
  }

  AddReturnVisitModel([LocationService locationService, ReturnVisitService rvService, ImageService imageService]) {
    var container = kiwi.Container();

    _locationService = locationService ?? container.resolve<LocationService>();
    _returnVisitService = rvService ?? container.resolve<ReturnVisitService>();
    _imageService = imageService ?? container.resolve<ImageService>();
  }

  /// Add a new placement by indicating the [count] of the placement [type] and include a [description] as needed.
  void addPlacement(int count, PlacementType type, [String description]) {
    _initialCallPlacements.add(Placement(type: type, count: count, notes: description));
    notifyListeners();
  }

  /// Determines whether the return visit contains the minimum information to save it.
  bool validate() {
    if(!_validateAddress()) {
      return false;
    }

    if(gender == null) {
      return false;
    }

    if(!_validateInitialVisit()) {
      return false;
    }

    return true;
    }
  
    Future checkForNewCoordinates() async {
      if(_validateAddress()) {
        var place = await _locationService.getCoordinatesFromAddress(_getAddress());
        print("found new coords: ${place.latitude}, ${place.longitude}");
        if(place != null) {
          var hasChanged = false;
          if(_latitude != place.latitude) {
            _latitude = place.latitude;
            hasChanged = true;
          }
          if(_longitude != place.longitude) {
            _longitude = place.longitude;
            hasChanged = true;
          }
          if(hasChanged) {
            _addressController.updateAddress(address);
          }
        }
      }
    }

    Address _getAddress() => Address(
      city: _city, 
      country: _country, 
      street: _street, 
      postalCode: _postalCode, 
      state: _state, 
      latitude: _latitude == 0.0 ? null : _latitude, 
      longitude: _longitude == 0.0 ? null : longitude);
      
    bool _validateAddress() {
      return _city.isNotEmpty;
    }
  
    bool _validateInitialVisit() {
      return _initialCallDate != null;
    }

    void removePlacement(Placement placement) {
      if(_initialCallPlacements != null 
         && _initialCallPlacements.contains(placement) 
         && _initialCallPlacements.remove(placement)) {
        notifyListeners();
      }
    }

  Future save() async {
    if(validate()) {
      String imagePath;
      if(image != null && image.isNotEmpty) {
        imagePath = await _imageService.saveToFile(
          image,
          path: "images/",
        );
      }

      var rv = ReturnVisitDto(
        address: address,
        name: name,
        gender: gender,
        notes: notes,
        imagePath: imagePath,
        pinned: pinned
      );

      await _returnVisitService.addNewReturnVisit(
        rv: rv, 
        initialCallDate: initialCallDate, 
        initialCallPlacements: initialCallPlacements, 
        initialCallNotes: initialCallNotes);
    }
  }

  @override
  set address(Address address) {
    _street = address.street;
      _city = address.city;
      _country = address.country;
      _postalCode = address.postalCode;
      _state = address.state;
      _latitude = address.latitude;
      _longitude = address.longitude;
      notifyListeners();
  }
}