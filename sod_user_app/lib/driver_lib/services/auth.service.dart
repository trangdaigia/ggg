import 'dart:convert';

import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:sod_user/driver_lib/constants/app_strings.dart';
import 'package:sod_user/driver_lib/models/user.dart';
import 'package:sod_user/driver_lib/models/vehicle.dart';
import 'package:sod_user/driver_lib/models/vendor_type.dart';
import 'package:sod_user/driver_lib/requests/auth.request.dart';
import 'package:sod_user/driver_lib/requests/vendor_type.request.dart';
import 'package:sod_user/driver_lib/services/app.service.dart';
import 'package:sod_user/driver_lib/services/appbackground.service.dart';
import 'package:sod_user/driver_lib/services/firebase.service.dart';
import 'package:sod_user/driver_lib/services/location.service.dart';
import 'package:sod_user/driver_lib/services/taxi/new_taxi_booking.service.dart';
import 'package:sod_user/driver_lib/view_models/home.vm.dart';
import 'package:sod_user/driver_lib/view_models/taxi/taxi.vm.dart';
import 'package:sod_user/models/driver.dart';
import 'package:sod_user/view_models/taxi_new_order_location_entry.vm.dart';
import 'package:velocity_x/velocity_x.dart';

import 'http.service.dart';
import 'local_storage.service.dart';

class AuthServices {
  //
  static Future<bool> firstTimeOnApp() async {
    return (await LocalStorageService.getPrefs())
            .getBool(AppStrings.firstTimeOnApp) ??
        true;
  }

  static firstTimeCompleted() async {
    await (await LocalStorageService.getPrefs())
        .setBool(AppStrings.firstTimeOnApp, false);
  }

  //
  static Future<bool> authenticated() async {
    return (await LocalStorageService.getPrefs())
            .getBool(AppStrings.authenticated) ??
        false;
  }

  static Future<bool> isAuthenticated() async {
    return (await LocalStorageService.getPrefs())
        .setBool(AppStrings.authenticated, true);
  }

  // Token
  static Future<String> getAuthBearerToken() async {
    return (await LocalStorageService.getPrefs())
            .getString(AppStrings.userAuthToken) ??
        "";
  }

  static Future<bool> setAuthBearerToken(token) async {
    return (await LocalStorageService.getPrefs())
        .setString(AppStrings.userAuthToken, token);
  }

  //Locale
  static getLocale() async {
    return (await LocalStorageService.getPrefs())
            .getString(AppStrings.appLocale) ??
        "vi";
  }

  static Future<bool> setLocale(language) async {
    return await (await LocalStorageService.getPrefs())
        .setString(AppStrings.appLocale, language);
  }

  //
  //
  static User? currentUser;
  static Future<User> getCurrentUser({bool force = false}) async {
    if (currentUser == null || force) {
      final userStringObject = await (await LocalStorageService.getPrefs())
          .getString(AppStrings.userKey);
      final userObject = json.decode(userStringObject ?? "{}");
      currentUser = User.fromJson(userObject);
      print("CurrentUser: ${currentUser!.name}");
    }
    return currentUser!;
  }

  ///
  ///
  ///
  static Future<User> saveUser(dynamic jsonObject) async {
    final currentUser = User.fromJson(jsonObject);
    try {
      await (await LocalStorageService.getPrefs()).setString(
        AppStrings.userKey,
        json.encode(currentUser.toJson()),
      );

      //subscribe to firebase topic
      FirebaseService().firebaseMessaging.subscribeToTopic("${currentUser.id}");
      FirebaseService()
          .firebaseMessaging
          .subscribeToTopic("d_${currentUser.id}");
      FirebaseService()
          .firebaseMessaging
          .subscribeToTopic("${currentUser.role}");

      return currentUser;
    } catch (error) {
      print("saveUser error ==> $error");
      throw error;
    }
  }

  //VEHICLE DETAILS
  //
  static Vehicle? driverVehicle;
  static List<Vehicle> driverVehicles = [];

  static Future<Vehicle?> getDriverVehicle({bool force = false}) async {
    if (driverVehicle == null || force) {
      final vehicleStringObject = await (await LocalStorageService.getPrefs())
          .getString(AppStrings.driverVehicleKey);
      //
      if (vehicleStringObject == null || vehicleStringObject.isEmpty) {
        driverVehicle = null;
      } else {
        final vehicleObject = json.decode(vehicleStringObject);
        driverVehicle = Vehicle.fromJson(vehicleObject);
      }
    }
    return driverVehicle;
  }

  ///
  ///
  ///
  static Future<Vehicle> saveVehicle(dynamic jsonObject) async {
    final driverVehicle = Vehicle.fromJson(jsonObject);
    try {
      //
      await (await LocalStorageService.getPrefs()).setString(
        AppStrings.driverVehicleKey,
        json.encode(
          driverVehicle.toJson(),
        ),
      );
      //sync vehicle data with free,is_online status with firebase

      return driverVehicle;
    } catch (error) {
      print("saveVehicle error ==> $error");
      throw error;
    }
  }

  static Future<Vehicle> saveVehicleType(
      dynamic jsonObject, String type) async {
    final driverVehicle = Vehicle.fromJson(jsonObject);
    try {
      await (await LocalStorageService.getPrefs()).setString(
        AppStrings.driverVehicleKey + type,
        json.encode(
          driverVehicle.toJson(),
        ),
      );
      return driverVehicle;
    } catch (error) {
      print("saveVehicle error ==> $error");
      throw error;
    }
  }

  static Future<List<Vehicle>?> getDriverVehicles() async {
    final vehicleStringObject = await (await LocalStorageService.getPrefs())
        .getString(AppStrings.driverVehicleKey + "taxi");
    if (vehicleStringObject != null || vehicleStringObject!.isNotEmpty) {
      final vehicleObject = json.decode(vehicleStringObject);
      driverVehicles.add(Vehicle.fromJson(vehicleObject));
    }

    final shippingVehicleObject = await (await LocalStorageService.getPrefs())
        .getString(AppStrings.driverVehicleKey + "shipping");
    if (shippingVehicleObject != null || shippingVehicleObject!.isNotEmpty) {
      final vehicleObject = json.decode(shippingVehicleObject);
      driverVehicles.add(Vehicle.fromJson(vehicleObject));
    }

    final vehicleRentalObject = await (await LocalStorageService.getPrefs())
        .getString(AppStrings.driverVehicleKey + "rental driver");
    if (vehicleRentalObject != null || vehicleRentalObject!.isNotEmpty) {
      final vehicleObject = json.decode(vehicleRentalObject);
      driverVehicles.add(Vehicle.fromJson(vehicleObject));
    }

    return driverVehicles;
  }

  ///
  ///
  //
  static logout() async {
    await HttpService().getCacheManager().clearAll();
    await (await LocalStorageService.getPrefs()).clear();
    await (await LocalStorageService.getPrefs())
        .setBool(AppStrings.firstTimeOnApp, false);
    FirebaseService()
        .firebaseMessaging
        .unsubscribeFromTopic("${currentUser?.id}");
    FirebaseService()
        .firebaseMessaging
        .unsubscribeFromTopic("d_${currentUser?.id}");
    FirebaseService()
        .firebaseMessaging
        .unsubscribeFromTopic("${currentUser?.role}");
  }

  //
  static Future<void> syncDriverData(Driver driver) async {
    try {
      //
      final assignedOrders = driver.assignedOrders;
      //sync vehicle data with free,is_online status with firebase
      // LocationService().firebaseFireStore.
      final serviceTypes = await VendorTypeRequest().index();
      final driverDoc = await LocationService()
          .firebaseFireStore
          .collection("drivers")
          .doc(driver.id.toString())
          .get();

      //
      final docRef = driverDoc.reference;
      print("Vehicles: ${driver.vehicles.length}");
      final activeVehicles = driver.vehicles.where((e) => e.isActive == 1);
      for (var vehicle in activeVehicles) {
        final service = serviceTypes
            .firstWhere((a) => a.id == vehicle.vehicleType?.vendorTypeId);
        vehicle.service = service as VendorType?;
      }
      
      final vehicleMap = Map.fromEntries(activeVehicles
          .map((e) => MapEntry(e.service!.slug, e.vehicleTypeId)));
      print("VEhicle map: $vehicleMap");
      if (driverDoc.data() == null) {
        docRef.set(
          {
            "id": driver.id,
            "free": assignedOrders <= 0 ? 1 : 0,
            "online": driver.isOnline ? 1 : 0,
            ...vehicleMap
          },
        );
      } else {
        docRef.update(
          {
            "id": driver.id,
            "free": assignedOrders <= 0 ? 1 : 0,
            "online": driver.isOnline ? 1 : 0,
            ...vehicleMap,
          },
        );
      }
    } catch (error) {
      print("error ==> $error");
    }
  }

  static Future<void> toggleDriverStatus(
      TaxiViewModel taxiViewModel, HomeViewModel homeViewModel) async {
    final authRequest = AuthRequest();
    final apiResponse = await authRequest.switchOnOff(
      isOnline: !AppService().driverIsOnline,
    );
    // final apiResponse = ApiResponse.fromResponse(res);
    if (apiResponse.allGood) {
      AppService().driverIsOnline = !AppService().driverIsOnline;
      if (AppService().driverIsOnline) {
        if (AppService().driverIsOnline &&
            taxiViewModel.onGoingOrderTrip == null) {
          NewTaxiBookingService(taxiViewModel).startNewOrderListener();
          AppbackgroundService().startBg();
        } else {
          NewTaxiBookingService(taxiViewModel).startNewOrderListener();
          AppbackgroundService().stopBg();
        }
      }
      await (await LocalStorageService.getPrefs()).setBool(
        AppStrings.onlineOnApp,
        AppService().driverIsOnline,
      );
      homeViewModel.handleNewOrderServices();
    } else {
      homeViewModel.viewContext.showToast(
        msg: "${apiResponse.message}",
        bgColor: Colors.red,
      );
    }
  }
}
