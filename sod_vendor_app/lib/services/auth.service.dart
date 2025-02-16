import 'dart:convert';

import 'package:sod_vendor/constants/app_strings.dart';
import 'package:sod_vendor/models/user.dart';
import 'package:sod_vendor/models/vendor.dart';
import 'package:sod_vendor/services/firebase.service.dart';

import 'http.service.dart';
import 'local_storage.service.dart';

class AuthServices {
  //
  static bool firstTimeOnApp() {
    return LocalStorageService.prefs!.getBool(AppStrings.firstTimeOnApp) ??
        true;
  }

  static firstTimeCompleted() async {
    await LocalStorageService.prefs!.setBool(AppStrings.firstTimeOnApp, false);
  }

  //
  static bool authenticated() {
    return LocalStorageService.prefs!.getBool(AppStrings.authenticated) ??
        false;
  }

  static Future<bool> isAuthenticated() {
    return LocalStorageService.prefs!.setBool(AppStrings.authenticated, true);
  }

  // Token
  static Future<String> getAuthBearerToken() async {
    return LocalStorageService.prefs!.getString(AppStrings.userAuthToken) ?? "";
  }

  static Future<bool> setAuthBearerToken(token) async {
    return LocalStorageService.prefs!
        .setString(AppStrings.userAuthToken, token);
  }

  //Locale
  static String getLocale() {
    return LocalStorageService.prefs!.getString(AppStrings.appLocale) ?? "vi";
  }

  static Future<bool> setLocale(language) async {
    return await LocalStorageService.prefs!.setString(AppStrings.appLocale, language);
  }

  //
  //
  static User? currentUser;
  static Future<User> getCurrentUser({bool force = false}) async {
    if (currentUser == null || force) {
      final userStringObject =
          await LocalStorageService.prefs!.getString(AppStrings.userKey);
      final userObject = json.decode(userStringObject!);
      currentUser = User.fromJson(userObject);
    }
    return currentUser!;
  }

//
  static Vendor? currentVendor;
  static Future<Vendor?> getCurrentVendor({bool force = false}) async {
    if (currentVendor == null || force) {
      final vendorStringObject =
          await LocalStorageService.prefs!.getString(AppStrings.vendorKey);
      final vendorObject = json.decode(vendorStringObject!);
      if (vendorObject != null) {
        return currentVendor = Vendor.fromJson(vendorObject);
      }
    }
    return null;
  }

  ///
  ///
  ///
  static Future<User?> saveUser(dynamic jsonObject) async {
    final currentUser = User.fromJson(jsonObject);
    try {
      await LocalStorageService.prefs!.setString(
        AppStrings.userKey,
        json.encode(
          currentUser.toJson(),
        ),
      );
      //subscribe to firebase topic
      FirebaseService()
          .firebaseMessaging
          .subscribeToTopic("v_${currentUser.vendor_id}");
      FirebaseService()
          .firebaseMessaging
          .subscribeToTopic("${currentUser.role}");

      return currentUser;
    } catch (error) {
      print("Error Saving user ==> $error");
      return null;
    }
  }

  //save vendor info
  static Future<void> saveVendor(dynamic jsonObject) async {
    try {
      if (jsonObject != null) {
        final userVendor = Vendor.fromJson(jsonObject);
        await LocalStorageService.prefs!.setString(
          AppStrings.vendorKey,
          json.encode(
            userVendor.toJson(),
          ),
        );
      } else {
        await LocalStorageService.prefs!.setString(
          AppStrings.vendorKey,
          json.encode(
            null,
          ),
        );
      }
    } catch (error) {
      print("Error vendor ==> $error");
    }
  }

  ///
  ///
  //
  static Future<void> logout() async {
    await HttpService().getCacheManager().clearAll();
    await LocalStorageService.prefs!.clear();
    await LocalStorageService.prefs!.setBool(AppStrings.firstTimeOnApp, false);
    FirebaseService()
        .firebaseMessaging
        .unsubscribeFromTopic("v_${currentUser?.vendor_id}");
    FirebaseService()
        .firebaseMessaging
        .unsubscribeFromTopic("${currentUser?.role}");
  }

  //firebase subscription
  static Future<void> subscribeToFirebaseTopic(
    String topic, {
    bool clear = false,
  }) async {
    if (clear) {
      List topics = [
        "v_${currentUser?.vendor_id}",
        "${currentUser?.role}",
      ];
      for (var topic in topics) {
        await FirebaseService().firebaseMessaging.unsubscribeFromTopic(topic);
      }
    }
    await FirebaseService().firebaseMessaging.subscribeToTopic(topic);
  }
}
