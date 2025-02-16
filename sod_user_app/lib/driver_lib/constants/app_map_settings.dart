import 'package:sod_user/driver_lib/constants/app_strings.dart';

class AppMapSettings extends AppStrings {
  static bool get useGoogleOnApp {
    if (AppStrings.env('map') == null ||
        AppStrings.env('map')["useGoogleOnApp"] == null) {
      return true;
    }
    return [1, "1"].contains(AppStrings.env('map')['useGoogleOnApp'] ?? "1");
  }

  static String get geocoderType {
    if (AppStrings.env('map') == null ||
        AppStrings.env('map')["geocoderType"] == null) {
      return "";
    } else {
      return AppStrings.env('map')["geocoderType"];
    }
  }

  static bool get isUsingVietmap => geocoderType == "vietmap";

  static bool get useVietMapOnApp {
    if (AppStrings.env('map') == null ||
        AppStrings.env('map')["useVietMapOnApp"] == null) {
      return true;
    }
    return [1, "1"].contains(AppStrings.env('map')['useVietMapOnApp'] ?? "1");
  }

  static String c = "";
}
