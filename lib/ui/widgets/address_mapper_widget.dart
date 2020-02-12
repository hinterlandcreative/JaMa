import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image/image.dart';
import 'package:jama/data/models/address_model.dart';
import 'package:jama/services/location_service.dart';
import 'package:jama/ui/controllers/address_controller.dart';
import 'package:jama/ui/controllers/address_image_controller.dart';
import 'package:kiwi/kiwi.dart' as kiwi;
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import '../app_styles.dart';

class AddressMapper extends StatefulWidget {
  /// the height to constrain the widget to.
  final double height;

  /// the width to constrain the widget to.
  final double width;

  /// set to [true] if you want the widget to search for the current address of the current location.
  final bool findCurrentAddress;

  /// The initial position to show on the map while loading. If [initialAddress] is set, that will take precedence.
  /// If [findCurrentLocation] is set to [true] then the initial position will be overwritten by the current location as it updates.
  final Position initialPosition;

  /// The address to show on the map.
  ///
  /// If this is set, [findCurrentAddress] is ignored and the widget will not try to find the current address.
  final Address address;

  /// The address controller to update the address shown on the map.
  ///
  /// If this is set, [findCurrentAddress] is ignored and [address] is ignore and the widget will not try to find the current address.
  final AddressController addressController;

  /// The address image controller which contains the image of the currently found address.
  /// 
  /// If a valid address hasn't been found the value will be [null].
  final AddressImageController addressImageController;

  /// Callback method for if the user indicates they want to use the address found that cooresponds to the current location.
  ///
  /// If [address] is [not null] this will never be called.
  final Function(Address address) onUseAddressSelected;

  /// this widget will only be shown if the map cannot be loaded.
  final Widget emptyState;

  

  AddressMapper(
      {Key key,
      this.height = 227,
      this.width,
      this.findCurrentAddress,
      this.initialPosition,
      this.address,
      this.onUseAddressSelected,
      this.emptyState,
      this.addressController,
      this.addressImageController})
      : super(key: key);

  @override
  _AddressMapperState createState() => _AddressMapperState();
}

class _AddressMapperState extends State<AddressMapper> {
  Completer<GoogleMapController> _mapController;

  LatLng _mapPosition;

  LocationService _locationServices;

  StreamSubscription<Position> _currentLocationSubscription;

  double _defaultZoom = 14.75;

  Address _foundAddress;

  Completer<String> _defaultMapScreenshotPath;

  Address get foundAddress => _foundAddress;

  set foundAddress(Address address) {
    _foundAddress = address;
    if(widget.addressImageController != null) {
      _defaultMapScreenshotPath.future.then((path) {
        var defaultFile = File(path);
        if(defaultFile.existsSync()) {
          defaultFile.deleteSync();
        }

        _mapImageController.capture(path: path).then((originalImage) {
          originalImage.readAsBytes().then((bytes) {
            var image = decodeImage(bytes);

            var x = ((image.width / 2) - 50).toInt();
            var y = ((image.height / 2) - 50).toInt();
            var croppedImage = copyCrop(
              image, 
              x < 0 ? 0 : x, 
              y < 0 ? 0 : y, 
              100, 
              100);

            widget.addressImageController.value = encodePng(croppedImage);
          });
        });
      });
    }
  }

  ScreenshotController _mapImageController;

  bool get _showFoundAddressWidget =>
      foundAddress != null && widget.address == null;

  @override
  void initState() {
    super.initState();
    _mapImageController = ScreenshotController();

    _defaultMapScreenshotPath = Completer();
    getApplicationDocumentsDirectory().then((directory) {
      _defaultMapScreenshotPath.complete("${directory.path}/defaultAddressImage.png");
    });


    _mapController = Completer();
    _mapPosition = widget.initialPosition != null
        ? LatLng(
            widget.initialPosition.latitude, widget.initialPosition.longitude)
        : LatLng(41.158961, -74.255364);

    _locationServices = kiwi.Container().resolve<LocationService>();

    if (widget.address == null) {
      if (widget.findCurrentAddress) {
        _currentLocationSubscription =
            _locationServices.locationStream.listen((position) async {
          if (_mapPosition.latitude != position.latitude &&
              _mapPosition.longitude != position.longitude) {
            var foundLatLng = LatLng(position.latitude, position.longitude);
            Address foundAddress;
            if (widget.findCurrentAddress) {
              foundAddress = await _locationServices.getAddressFromCoordinates(
                  latitude: position.latitude, longitude: position.longitude);
            }

            setState(() {
              _mapPosition = foundLatLng;
              this.foundAddress = foundAddress;
            });

            var controller = await _mapController.future;
            controller.animateCamera(CameraUpdate.newCameraPosition(
                CameraPosition(
                    bearing: 360.0,
                    target: LatLng(
                        _mapPosition.latitude -
                            (widget.findCurrentAddress && foundAddress != null
                                ? 0.0015
                                : 0.0),
                        _mapPosition.longitude),
                    zoom: _defaultZoom)));
          }
        });
      }
    } else if (widget.address != null && widget.addressController == null) {
      _doSuppliedAddressChange(widget.address);
    }

    if (widget.addressController != null) {
      widget.addressController.addListener(_onAddressControllerChanged);
    }
  }

  @override
  void dispose() {
    _currentLocationSubscription.cancel();
    if (widget.addressController != null) {
      widget.addressController.removeListener(_onAddressControllerChanged);
      widget.addressController.dispose();
    }

    if(_defaultMapScreenshotPath.isCompleted) {
      _defaultMapScreenshotPath.future.then((path) {
        File(path).deleteSync();
      });
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var h = widget.height ?? MediaQuery.of(context).size.height;
    var w = widget.width ?? MediaQuery.of(context).size.width;

    return Container(
      width: w,
      height: h,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
              child: Center(
            child: widget.emptyState,
          )),
          Positioned.fill(
            child: Screenshot(
              controller: _mapImageController,
              child: GoogleMap(
                rotateGesturesEnabled: false,
                scrollGesturesEnabled: false,
                tiltGesturesEnabled: false,
                zoomGesturesEnabled: false,
                myLocationButtonEnabled: false,
                buildingsEnabled: false,
                mapToolbarEnabled: false,
                circles: Set.from([
                  Circle(
                    circleId: CircleId("main location"),
                    center: _mapPosition,
                    radius: 25,
                    fillColor: AppStyles.primaryColor,
                    strokeColor: Colors.transparent,
                  )
                ]),
                onMapCreated: (controller) {
                  _mapController.complete(controller);
                },
                initialCameraPosition: CameraPosition(
                  bearing: 360.0,
                  target: _mapPosition,
                  zoom: _defaultZoom,
                ),
              ),
          )),
          AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              top: _showFoundAddressWidget
                  ? 131 + MediaQuery.of(context).padding.top
                  : h,
              width: MediaQuery.of(context).size.width,
              height: 115,
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 100),
                opacity: _showFoundAddressWidget ? 1 : 0,
                child: Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.only(top: 10.0, left: 33.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        foundAddress == null
                            ? ""
                            : foundAddress
                                .toFormattedString(true, false, false)
                                .toUpperCase(),
                        maxLines: 2,
                        style: AppStyles.smallTextStyle.copyWith(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      RawMaterialButton(
                        shape: new CircleBorder(),
                        elevation: 8.0,
                        fillColor: Colors.white,
                        child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Icon(Icons.location_searching, size: 17)),
                        onPressed: () {
                          if (widget.onUseAddressSelected != null) {
                            _currentLocationSubscription.cancel();
                            widget.onUseAddressSelected(foundAddress.copy());
                            foundAddress = null;
                          }
                        },
                      )
                    ],
                  ),
                  decoration: BoxDecoration(
                      color: AppStyles.primaryColor,
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 15.0,
                            color: AppStyles.shadowColor,
                            offset: Offset(1.00, -10.00))
                      ],
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30.0),
                          topRight: Radius.circular(30.0))),
                ),
              )),
        ],
      ),
    );
  }

  Future _doSuppliedAddressChange(Address address) async {
    _mapController.future.then((controller) async {
      LatLng newLatLng;
      if ((address.latitude == 0.0 || address.latitude == null) &&
          (address.longitude == 0.0 || address.longitude == null)) {
        var position =
            await _locationServices.getCoordinatesFromAddress(address);
        if (position != null) {
          newLatLng = LatLng(position.latitude, position.longitude);
        } else {
          newLatLng = _mapPosition;
        }
      } else {
        newLatLng = LatLng(address.latitude, address.longitude);
      }
      controller.animateCamera(CameraUpdate.newLatLng(newLatLng));
      setState(() {
        _mapPosition = newLatLng;
      });
    });
  }

  void _onAddressControllerChanged() async {
    _currentLocationSubscription.cancel();
    foundAddress = foundAddress == widget.addressController.value
        ? foundAddress
        : await _locationServices.getAddressFromCoordinates(
            latitude: widget.addressController.value.latitude,
            longitude: widget.addressController.value.longitude);
    _doSuppliedAddressChange(widget.addressController.value);
  }
}
