import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/driver_lib/services/appbackground.service.dart';
import 'package:sod_user/driver_lib/services/taxi/new_taxi_booking.service.dart';
import 'package:sod_user/driver_lib/view_models/home.vm.dart';
import 'package:sod_user/driver_lib/view_models/taxi/taxi.vm.dart';
import 'package:sod_user/models/driver.dart';
import 'package:sod_user/models/user.dart';
import 'package:sod_user/models/vehicle.dart';
import 'package:sod_user/requests/auth.request.dart';
import 'package:sod_user/services/app.service.dart';
import 'package:sod_user/services/firebase.service.dart';
import 'package:sod_user/services/http.service.dart';
import 'package:sod_user/view_models/splash.vm.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';
import 'package:sod_user/driver_lib/services/auth.service.dart' as driverLib;
import 'package:sod_user/view_models/taxi_new_order_location_entry.vm.dart';
import 'package:velocity_x/velocity_x.dart';

import 'local_storage.service.dart';

class AuthServices {
  //
  static bool firstTimeOnApp() {
    return LocalStorageService.prefs?.getBool(AppStrings.firstTimeOnApp) ??
        true;
  }

  static firstTimeCompleted() async {
    await LocalStorageService.prefs?.setBool(AppStrings.firstTimeOnApp, false);
  }

  //
  static bool authenticated() {
    return LocalStorageService.prefs?.getBool(AppStrings.authenticated) ??
        false;
  }

  static Future<bool> isAuthenticated() async {
    await LocalStorageService.rxPrefs?.write(
      AppStrings.authenticated,
      true,
      (value) {
        return value;
      },
    );
    return LocalStorageService.prefs!.setBool(AppStrings.authenticated, true);
  }

  // Token
  static Future<String> getAuthBearerToken() async {
    return LocalStorageService.prefs?.getString(AppStrings.userAuthToken) ?? "";
  }

  static Future<bool> setAuthBearerToken(token) async {
    return LocalStorageService.prefs!
        .setString(AppStrings.userAuthToken, token);
  }

  //Locale
  static String getLocale() {
    return LocalStorageService.prefs?.getString(AppStrings.appLocale) ?? "vi";
  }

  static Future<bool> setLocale(language) async {
    return await LocalStorageService.prefs!
        .setString(AppStrings.appLocale, language);
  }

  static Stream<bool?> listenToAuthState() {
    return LocalStorageService.rxPrefs!.getBoolStream(AppStrings.authenticated);
  }

  //
  //
  static User? currentUser;
  static bool isDriver() =>
      currentUser?.roles.firstOrNullWhere((e) => e.name == "driver") != null;
  static Future<User> getCurrentUser({bool force = false}) async {
    if (currentUser == null || force) {
      final userStringObject = await LocalStorageService.prefs?.getString(
        AppStrings.userKey,
      );
      final userObject = json.decode(userStringObject ?? "{}");
      currentUser = User.fromJson(userObject);
    }
    return currentUser!;
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
      print("Driver status: ${AppService().driverIsOnline}");
      if (AppService().driverIsOnline &&
          taxiViewModel.onGoingOrderTrip == null) {
        NewTaxiBookingService(taxiViewModel).startNewOrderListener();
        AppbackgroundService().startBg();
      } else {
        NewTaxiBookingService(taxiViewModel).stopListeningToNewOrder();
        AppbackgroundService().stopBg();
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

  ///
  ///
  ///
  static Future<User?> saveUser(dynamic jsonObject,
      {bool reload = true}) async {
    final currentUser = User.fromJson(jsonObject);
    try {
      await LocalStorageService.prefs?.setString(
        AppStrings.userKey,
        json.encode(
          currentUser.toJson(),
        ),
      );

      //subscribe to firebase topic
      FirebaseService().firebaseMessaging.subscribeToTopic("all");
      FirebaseService().firebaseMessaging.subscribeToTopic("${currentUser.id}");
      FirebaseService()
          .firebaseMessaging
          .subscribeToTopic("${currentUser.role}");
      FirebaseService().firebaseMessaging.subscribeToTopic("client");

      //log the new
      if (reload) {
        await SplashViewModel(AppService().navigatorKey.currentContext!)
            .loadAppSettings();
      }

      return currentUser;
    } catch (error) {
      return null;
    }
  }

  static Future<Driver?> saveDriver(dynamic jsonObject,
      {bool reload = true}) async {
    final currentUser = Driver.fromJson(jsonObject);
    try {
      await LocalStorageService.prefs?.setString(
        AppStrings.driverKey,
        json.encode(currentUser.toJson()),
      );

      return currentUser;
    } catch (error) {
      return null;
    }
  }

  static Future<Driver?> getCurrentDriver() async {
    final currentDriverStringObject =
        await LocalStorageService.prefs?.getString(AppStrings.driverKey);
    if (currentDriverStringObject == null) return null;
    final currentDriverObject = json.decode(currentDriverStringObject ?? "{}");
    final currentDriver = Driver.fromJson(currentDriverObject);
    return currentDriver;
  }

  ///
  ///
  //
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

  static Future<void> logout() async {
    if (!kIsWeb) {
      await HttpService().getCacheManager().clearAll();
    }
    await LocalStorageService.prefs?.clear();
    await LocalStorageService.rxPrefs?.clear();
    await LocalStorageService.prefs?.setBool(AppStrings.firstTimeOnApp, false);
    await AuthServices.removeTempPassword();
    if (currentUser == null) return;
    await Future.wait([
      FirebaseService().firebaseMessaging.unsubscribeFromTopic("all"),
      FirebaseService()
          .firebaseMessaging
          .unsubscribeFromTopic("${currentUser?.id}"),
      FirebaseFirestore.instance
          .collection("drivers")
          .doc(AuthServices.currentUser!.id.toString())
          .set({
        'free': 0,
        'online': 0,
      })
    ]);
    FirebaseService()
        .firebaseMessaging
        .unsubscribeFromTopic("${currentUser?.role}");
    FirebaseService().firebaseMessaging.unsubscribeFromTopic("client");
  }

  static Future<bool?> setTempPassword(String password) async {
    print("setTempPassword ==> $password");
    return LocalStorageService.prefs
        ?.setString(AppStrings.tempPassword, password);
  }

  static Future<String?> getTempPassword() async {
    print(
        "getTempPassword ==> ${await LocalStorageService.prefs?.getString(AppStrings.tempPassword)}");
    return LocalStorageService.prefs?.getString(AppStrings.tempPassword);
  }

  static Future<bool?> removeTempPassword() async {
    print("removeTempPassword");
    return LocalStorageService.prefs?.remove(AppStrings.tempPassword);
  }

  static Future<bool?> setIsDriverWaitingForApproval(bool value) async {
    return LocalStorageService.prefs
        ?.setBool(AppStrings.driverWaitingForApproval, value);
  }

  static Future<bool?> getIsDriverWaitingForApproval() async {
    return LocalStorageService.prefs
        ?.getBool(AppStrings.driverWaitingForApproval);
  }
}
