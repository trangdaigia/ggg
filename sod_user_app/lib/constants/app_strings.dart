import 'dart:convert';

import 'package:dartx/dartx.dart';
import 'package:sod_user/services/local_storage.service.dart';

class AppStrings {
  //
  static String get appName => env('app_name');
  static String get companyName => env('company_name');
  static String get googleMapApiKey => env('google_maps_key');
  static String get vietMapMapApiKey => env('viet_maps_key');
  // static String get vietMapMapApiKey => "22656161e4231b14fb8897e4591a66eb312c445f76e60643"; // temporary set
  static String get fcmApiKey => env('fcm_key');
  static String get currencySymbol => env('currency');
  static String get countryCode => env('country_code');
  static bool get enableOtp => env('enble_otp') == "1";
  static bool get enableOTPLogin => env('enableOTPLogin') == "1";
  static String get onlineOnApp => "online";
  static String driverVehicleKey = "driver_vehicle";

  //
  static bool get enableEmailLogin => env('enableEmailLogin');
  static bool get enableProfileUpdate => env('enableProfileUpdate');

  static bool get enableGoogleDistance => env('enableGoogleDistance') == "1";
  static bool get enableSingleVendor => env('enableSingleVendor') == "1";
  static bool get enableMultipleVendorOrder =>
      env('enableMultipleVendorOrder') ?? false;
  static bool get enableReferSystem => env('enableReferSystem') == "1";
  static String get referAmount => env('referAmount');
  static bool get enableChat => env('enableChat') == "1";
  static bool get enableOrderTracking => env('enableOrderTracking') == "1";
  static bool get enableFatchByLocation => env('enableFatchByLocation') ?? true;
  static bool get showVendorTypeImageOnly =>
      env('showVendorTypeImageOnly') == "1";
  static bool get enableUploadPrescription =>
      env('enableUploadPrescription') == "1";
  static bool get enableParcelVendorByLocation =>
      env('enableParcelVendorByLocation') == "1";
  static bool get enableParcelMultipleStops =>
      env('enableParcelMultipleStops') == "1";
  static int get maxParcelStops =>
      env('maxParcelStops').toString().toIntOrNull() ?? 1;
  static String get what3wordsApiKey => env('what3wordsApiKey') ?? "";
  static bool get isWhat3wordsApiKey => what3wordsApiKey.isNotEmpty;
  //App download links

  static String get androidDownloadLink => env('androidDownloadLink') ?? "";
  static String get iOSDownloadLink => env('iosDownloadLink') ?? "";
  //
  static bool get isSingleVendorMode => env('isSingleVendorMode') == "1";
  static bool get canScheduleTaxiOrder => env('taxi') != null
      ? (env('taxi')['canScheduleTaxiOrder'] != null
          ? (env('taxi')['canScheduleTaxiOrder'] == "1")
          : false)
      : false;
  static int get taxiMaxScheduleDays =>
      (env('taxi')['taxiMaxScheduleDays'].toString().toIntOrNull()) ?? 2;
  static double get drivingSpeed =>
      (env('taxi')['drivingSpeed'].toString().toDoubleOrNull()) ?? 45.0;

  static Map<String, dynamic> get enabledVendorType =>
      env('enabledVendorType') ?? {};
  static double get bannerHeight =>
      double.parse("${env('bannerHeight') ?? 150.00}");

  //
  static String get otpGateway => (env('otpGateway') ?? "none").toString().toLowerCase();
  static bool get isFirebaseOtp => otpGateway.toLowerCase() == "firebase";
  static bool get isCustomOtp =>
      !["none", "firebase"].contains(otpGateway.toLowerCase());

  static String get emergencyContact => env('emergencyContact') ?? "911";

  //Social media logins
  static bool get googleLogin => env('auth')['googleLogin'] ?? false;
  static bool get appleLogin => env('auth')['appleLogin'] ?? false;
  static bool get facebbokLogin => env('auth')['facebbokLogin'] ?? false;
  static bool get qrcodeLogin => env('auth')['qrcodeLogin'] ?? false;

  //UI Configures
  static dynamic get uiConfig {
    return env('ui') ?? null;
  }

  static double get categoryImageWidth {
    if (env('ui') == null || env('ui')["categorySize"] == null) {
      return 40.00;
    }
    return double.parse((env('ui')['categorySize']["w"] ?? 40.00).toString());
  }

  static double get categoryImageHeight {
    if (env('ui') == null || env('ui')["categorySize"] == null) {
      return 60.00;
    }
    return double.parse((env('ui')['categorySize']["h"] ?? 40.00).toString());
  }

  static double get categoryTextSize {
    if (env('ui') == null || env('ui')["categorySize"] == null) {
      return 12.00;
    }
    return double.parse(
        (env('ui')['categorySize']["text"]['size'] ?? 12.00).toString());
  }

  static int get categoryPerRow {
    try {
      if (env('ui') == null || env('ui')["categorySize"] == null) {
        return 4;
      }
      return int.parse((env('ui')['categorySize']["row"] ?? 4).toString());
    } catch (e) {
      return 3;
    }
  }
  
  static String get defaultCountryCode {
    final code = AppStrings.countryCode
            .toUpperCase()
            .replaceAll("AUTO", "")
            .replaceAll("INTERNATIONAL", "")
            .split(",").firstOrNullWhere((a) => a.isNotEmpty);
    print("Code ${AppStrings.countryCode}");
    if(code.isNullOrEmpty)
      return 'us';
    return code!;
  }

  static bool get searchGoogleMapByCountry {
    if (env('ui') == null || env('ui')["google"] == null) {
      return false;
    }
    return env('ui')['google']["searchByCountry"] ?? false;
  }

  static String get searchGoogleMapByCountries {
    if (env('ui') == null || env('ui')["google"] == null) {
      return "";
    }
    return env('ui')['google']["searchByCountries"] ?? "";
  }

  //DONT'T TOUCH
  static const String notificationChannel = "high_importance_channel";

  //START DON'T TOUNCH
  //for app usage
  static String firstTimeOnApp = "first_time";
  static String authenticated = "authenticated";
  static String userAuthToken = "auth_token";
  static String userKey = "user";
  static String driverKey = "driver";
  static String appLocale = "locale";
  static String notificationsKey = "notifications";
  static String appCurrency = "currency";
  static String appColors = "colors";
  static String appRemoteSettings = "appRemoteSettings";
  static String receiveBehalfSlug = "receive_behalf";
  //END DON'T TOUNCH

  static String apiUrlKey = "api_url";
  static String forbiddenWordsKey = "forbidden_words";
  static String tempPassword = "temp_password";
  static String driverWaitingForApproval = "driver_waiting_for_approval";

  //
  //Change to your app store id
  static String appStoreId = "";
  static int get alertDuration {
    final duration = env('alertDuration').toString().toIntOrNull();
    if (duration == null || duration < 10) {
      return 10;
    }
    return duration;
  }
  //
  //saving
  static Future<bool> saveAppSettingsToLocalStorage(String stringMap) async {
    return await LocalStorageService.prefs!
        .setString(AppStrings.appRemoteSettings, stringMap);
  }

  static Future<bool> saveForbiddenWordsToLocalStorage(String wordsMap) async {
    return await LocalStorageService.prefs!
        .setString(AppStrings.forbiddenWordsKey, wordsMap);
  }

  static List<String> get forbiddenWords {
    final json =
        LocalStorageService.prefs!.getString(AppStrings.forbiddenWordsKey) ??
            "";

    // Decode JSON and convert to List<String>
    final List<dynamic> dynamicList = jsonDecode(json);
    return dynamicList.map((e) => e.toString()).toList();
  }

  static dynamic appSettingsObject;
  static Future<void> getAppSettingsFromLocalStorage() async {
    appSettingsObject =
        LocalStorageService.prefs?.getString(AppStrings.appRemoteSettings);
    if (appSettingsObject != null) {
      appSettingsObject = jsonDecode(appSettingsObject);
    }
  }

  static dynamic env(String ref) {
    //
    getAppSettingsFromLocalStorage();
    //
    return appSettingsObject != null ? appSettingsObject[ref] : "";
  }

  //
  static List<String> get orderCancellationReasons {
    return ["Long pickup time", "Vendor is too slow", "custom"];
  }

  //
  static List<String> get orderStatuses {
    return [
      'pending',
      'preparing',
      'ready',
      'enroute',
      'failed',
      'cancelled',
      'delivered'
    ];
  }
}
