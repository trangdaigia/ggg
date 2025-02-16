import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_vendor/constants/app_map_settings.dart';
import 'package:sod_vendor/constants/app_strings.dart';
import 'package:sod_vendor/models/addresses.dart';
import 'package:sod_vendor/models/coordinates.dart';
import 'package:sod_vendor/services/geocoder.service.dart';
import 'package:sod_vendor/services/location.service.dart';
import 'package:sod_vendor/services/toast.service.dart';
import 'package:sod_vendor/services/update.service.dart';
import 'package:sod_vendor/utils/utils.dart';
import 'package:sod_vendor/views/pages/shared/custom_webview.page.dart';
import 'package:sod_vendor/views/pages/shared/ops_map.page.dart';
import 'package:stacked/stacked.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:velocity_x/velocity_x.dart';

class MyBaseViewModel extends BaseViewModel with UpdateService {
  //
  late BuildContext viewContext;
  final formKey = GlobalKey<FormState>();
  final formBuilderKey = GlobalKey<FormBuilderState>();
  final currencySymbol = AppStrings.currencySymbol;
  GlobalKey pageKey = GlobalKey<FormState>();
  String? firebaseVerificationId;
  Addresses? deliveryAddress = Addresses();
  void initialise() {
    //FirestoreRepository();
  }

  newPageKey() {
    pageKey = GlobalKey<FormState>();
    notifyListeners();
  }

  //show toast
  toastSuccessful(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  toastError(String msg, {Toast? length}) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: length ?? Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  openWebpageLink(String url, {bool external = false}) async {
    if (Platform.isIOS || external) {
      await launchUrlString(url);
      return;
    }
    await Navigator.push(
      viewContext,
      MaterialPageRoute(
        builder: (context) => CustomWebviewPage(
          selectedUrl: url,
        ),
      ),
    );
  }

  Future<dynamic> openExternalWebpageLink(String url) async {
    try {
      await launchUrlString(
        url,
        mode: LaunchMode.externalApplication,
      );
      return;
    } catch (error) {
      ToastService.toastError("$error");
    }
  }

  Future<void> fetchCurrentLocation() async {
    //
    Position currentLocation = await Geolocator.getCurrentPosition();
    //
    final address = await LocationService.addressFromCoordinates(
      lat: currentLocation.latitude,
      lng: currentLocation.longitude,
    );
    //
    LocationService.currenctAddress = address;
    if (address != null) {
      LocationService.currenctAddressSubject.sink.add(address);
    }
    deliveryAddress ??= Addresses();
    deliveryAddress!.address = address?.addressLine;
    deliveryAddress!.latitude = address?.coordinates?.latitude;
    deliveryAddress!.longitude = address?.coordinates?.longitude;
    deliveryAddress!.name = "Current Location".tr();
    LocationService.deliveryaddress = deliveryAddress;
  }

  // NEW LOCATION PICKER
  Future<dynamic> newPlacePicker() async {
    //
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    LatLng initialPosition = LatLng(
      position.latitude,
      position.longitude,
    );
    double initialZoom = 0;
    initialZoom = 15;

    String? mapRegion;
    try {
      mapRegion = await Utils.getCurrentCountryCode();
    } catch (error) {
      print("Error getting sim country code => $error");
    }
    mapRegion ??= AppStrings.countryCode.trim().split(",").firstWhere(
      (e) => !e.toLowerCase().contains("auto"),
      orElse: () {
        return "";
      },
    );

    //
    if (!AppMapSettings.useGoogleOnApp) {
      return await Navigator.push(
        viewContext,
        MaterialPageRoute(
          builder: (context) => OPSMapPage(
            region: mapRegion,
            initialPosition: initialPosition,
            useCurrentLocation: true,
            initialZoom: initialZoom,
          ),
        ),
      );
    }

    //google maps
    return await Navigator.push(
      viewContext,
      MaterialPageRoute(
        builder: (context) => PlacePicker(
          apiKey: AppStrings.googleMapApiKey,
          autocompleteLanguage: translator.activeLocale.languageCode,
          region: mapRegion,
          onPlacePicked: (result) {
            Navigator.of(context).pop(result);
          },
          initialPosition: initialPosition,
        ),
      ),
    );
  }

  //
  Future<Addresses> getLocationCityName(Addresses deliveryAddress) async {
    final coordinates = new Coordinates(
      deliveryAddress.latitude ?? 0.00,
      deliveryAddress.longitude ?? 0.00,
    );
    final addresses = await GeocoderService().findAddressesFromCoordinates(
      coordinates,
    );
    // loop through the addresses and get data
    for (var address in addresses) {
      //address
      deliveryAddress.address ??= address.addressLine;
      //name
      deliveryAddress.name ??= address.featureName;
      if (deliveryAddress.name == null || deliveryAddress.name!.isEmpty) {
        deliveryAddress.name = address.addressLine;
      }
      //city
      deliveryAddress.city ??= address.locality;
      if (deliveryAddress.city == null || deliveryAddress.city!.isEmpty) {
        deliveryAddress.city = address.subLocality;
      }
      //state
      deliveryAddress.state ??= address.adminArea;
      if (deliveryAddress.state == null || deliveryAddress.state!.isEmpty) {
        deliveryAddress.state = address.subAdminArea;
      }
      //country
      deliveryAddress.country ??= address.countryName;

      //break if all data is set
      if (deliveryAddress.address != null &&
          deliveryAddress.city != null &&
          deliveryAddress.state != null &&
          deliveryAddress.country != null) {
        break;
      }
    }
    //
    // deliveryAddress.city = addresses.first.locality;
    // deliveryAddress.state = addresses.first.adminArea;
    // deliveryAddress.country = addresses.first.countryName;
    return deliveryAddress;
  }
}
