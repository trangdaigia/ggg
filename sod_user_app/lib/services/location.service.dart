import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sod_user/models/delivery_address.dart';
import 'package:sod_user/services/app.service.dart';
import 'package:sod_user/widgets/bottomsheets/location_permission.bottomsheet.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
// import 'package:geocoder/geocoder.dart';
import 'package:rxdart/rxdart.dart';
import 'geocoder.service.dart';

class LocationService {
  //
  static Location location = new Location();

  static bool? serviceEnabled;
  static PermissionStatus? _permissionGranted;
  static LocationData? _locationData;
  static Address? currenctAddress;
  static DeliveryAddress? deliveryaddress;
  static DeliveryAddress? currentAddress;
  static StreamSubscription? currentLocationListener;

  //
  static BehaviorSubject<Address> currenctAddressSubject =
      BehaviorSubject<Address>();
  // static Stream<Address> get currenctAddressStream =>
  //     _currenctAddressSubject.stream;


  static Future<void> prepareLocationListener(BuildContext context) async {
    _permissionGranted = await location.hasPermission();

    if (_permissionGranted == PermissionStatus.denied) {
      bool requestPermission = true;

      if (!Platform.isIOS) {
        requestPermission = await showRequestDialog(context);
        if (!requestPermission) {
          // Hiển thị popup thông báo
          
          // Dừng khởi tạo
          return;
        }
      }
      if (requestPermission) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return;
        }
      }
    }

    serviceEnabled = await location.serviceEnabled();
    if (serviceEnabled == null || serviceEnabled! == false) {
      serviceEnabled = await location.requestService();
      if (serviceEnabled == null || serviceEnabled! == false) {
        return;
      }
    }

    _startLocationListner();
  }

  static Future<bool> showRequestDialog(BuildContext context) async {
    //
    var requestResult = false;
    //
    await showDialog(
      context: AppService().navigatorKey.currentContext!,
      builder: (context) {
        return LocationPermissionDialog(onResult: (result) {
          requestResult = result;
        });
      },
    );
    if(!requestResult){
      showDialog(
            context: context,  
            builder: (context) {
              return AlertDialog(
                title: Text('Thông báo'),
                content: Text('Ứng dụng cần quyền truy cập vị trí để hoạt động.\nVui lòng khởi động lại ứng dụng và cấp quyền vị trí.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      exit(0); // Thoát ứng dụng
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
    }
    //
    return requestResult;
  }

  static void _startLocationListner() async {
    //
    //update location every 100meters
    // await location.changeSettings(distanceFilter: 50);
    // //listen
    // currentLocationListener =
    //     location.onLocationChanged.listen((LocationData currentLocation) {
    //   // Use current location
    //   _locationData = currentLocation;
    //   //
    //   geocodeCurrentLocation(true);
    // });

    //listen
    currentLocationListener =
        Geolocator.getPositionStream().listen((Position currentLocation) {
      // Use current location
      _locationData = LocationData.fromMap(currentLocation.toJson());
      //
      geocodeCurrentLocation(true);
    });

    //get the current location on send to listeners
    _locationData = await location.getLocation();
    geocodeCurrentLocation();
  }

  //
  static Future<void> geocodeCurrentLocation(
      [bool closeListener = false]) async {
    if (_locationData != null) {
      final coordinates = new Coordinates(
        _locationData?.latitude ?? 0.0,
        _locationData?.longitude ?? 0.0,
      );

      try {
        //
        final addresses = await GeocoderService().findAddressesFromCoordinates(
          coordinates,
        );
        //
        currenctAddress = addresses.first;
        //
        if (currenctAddress != null) {
          currenctAddressSubject.add(currenctAddress!);
        }
      } catch (error) {
        print("Error get location ==> $error");
      }
    }

    //
    if (closeListener) {
      print("Location listener closed");
      currentLocationListener?.cancel();
    }
  }

  //coordinates to address
  static Future<Address?> addressFromCoordinates({
    required double lat,
    required double lng,
  }) async {
    Address? address;
    final coordinates = new Coordinates(
      lat,
      lng,
    );

    try {
      //
      final addresses = await GeocoderService().findAddressesFromCoordinates(
        coordinates,
      );
      //
      address = addresses.first;
    } catch (error) {
      print("Issue with addressFromCoordinates ==> $error");
    }
    return address;
  }

  //Helper methods

  //get current lat
  static double? get cLat {
    return LocationService.currenctAddress?.coordinates?.latitude;
  }

  //get current lng
  static double? get cLng {
    return LocationService.currenctAddress?.coordinates?.longitude;
  }
}
