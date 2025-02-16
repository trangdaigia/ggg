import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sod_user/driver_lib/constants/app_strings.dart';
import 'package:sod_user/driver_lib/services/local_storage.service.dart';
import 'package:velocity_x/velocity_x.dart';

class AppColor {
  static Color get accentColor => Vx.hexToColor(colorEnv('accentColor'));
  //static Color accentColor = Color.fromRGBO(242, 74, 74, 1);
  static Color get primaryColor => Vx.hexToColor(colorEnv('primaryColor'));
  // static Color primaryColor = Color.fromRGBO(235, 25, 25, 1);
  static Color get primaryColorDark =>
      Vx.hexToColor(colorEnv('primaryColorDark'));
  //static Color primaryColorDark = Color.fromRGBO(184, 35, 35, 1);

  static Color get cursorColor => deliveredColor;

  //material color
  static MaterialColor get accentMaterialColor => MaterialColor(
        Vx.getColorFromHex(colorEnv('accentColor')),
        <int, Color>{
          50: Vx.hexToColor(colorEnv('accentColor')),
          100: Vx.hexToColor(colorEnv('accentColor')),
          200: Vx.hexToColor(colorEnv('accentColor')),
          300: Vx.hexToColor(colorEnv('accentColor')),
          400: Vx.hexToColor(colorEnv('accentColor')),
          500: Vx.hexToColor(colorEnv('accentColor')),
          600: Vx.hexToColor(colorEnv('accentColor')),
          700: Vx.hexToColor(colorEnv('accentColor')),
          800: Vx.hexToColor(colorEnv('accentColor')),
          900: Vx.hexToColor(colorEnv('accentColor')),
        },
      );
  static MaterialColor get primaryMaterialColor => MaterialColor(
        Vx.getColorFromHex(colorEnv('primaryColor')),
        <int, Color>{
          50: Vx.hexToColor(colorEnv('primaryColor')),
          100: Vx.hexToColor(colorEnv('primaryColor')),
          200: Vx.hexToColor(colorEnv('primaryColor')),
          300: Vx.hexToColor(colorEnv('primaryColor')),
          400: Vx.hexToColor(colorEnv('primaryColor')),
          500: Vx.hexToColor(colorEnv('primaryColor')),
          600: Vx.hexToColor(colorEnv('primaryColor')),
          700: Vx.hexToColor(colorEnv('primaryColor')),
          800: Vx.hexToColor(colorEnv('primaryColor')),
          900: Vx.hexToColor(colorEnv('primaryColor')),
        },
      );
  static Color get primaryMaterialColorDark =>
      Vx.hexToColor(colorEnv('primaryColorDark'));
  static Color get cursorMaterialColor => accentColor;

  //onboarding colors
  static Color get onboarding1Color =>
      Vx.hexToColor(colorEnv('onboarding1Color'));
  static Color get onboarding2Color =>
      Vx.hexToColor(colorEnv('onboarding2Color'));
  static Color get onboarding3Color =>
      Vx.hexToColor(colorEnv('onboarding3Color'));

  static Color get onboardingIndicatorDotColor =>
      Vx.hexToColor(colorEnv('onboardingIndicatorDotColor'));
  static Color get onboardingIndicatorActiveDotColor =>
      Vx.hexToColor(colorEnv('onboardingIndicatorActiveDotColor'));

  //Shimmer Colors
  static Color shimmerBaseColor = Colors.grey.shade300;
  static Color shimmerHighlightColor = Colors.grey.shade200;

  //inputs
  static Color get inputFillColor => Colors.grey.shade200;
  static Color get iconHintColor => Colors.grey.shade500;

  static Color get openColor => Vx.hexToColor(colorEnv('openColor'));
  static Color get closeColor => Vx.hexToColor(colorEnv('closeColor'));
  static Color get deliveryColor => Vx.hexToColor(colorEnv('deliveryColor'));
  static Color get pickupColor => Vx.hexToColor(colorEnv('pickupColor'));
  static Color get ratingColor => Vx.hexToColor(colorEnv('ratingColor'));
  static Color get deliveredColor => getStausColor("delivered");
  static Color get cancelledColor => getStausColor("cancelled");

  static Color getStausColor(String status) {
    //'pending','preparing','enroute','failed','cancelled','delivered'
    switch (status) {
      case "pending":
        return Vx.hexToColor(colorEnv('pendingColor'));

      case "preparing":
        return Vx.hexToColor(colorEnv('preparingColor'));

      case "enroute":
        return Vx.hexToColor(colorEnv('enrouteColor'));

      case "failed":
        return Vx.hexToColor(colorEnv('failedColor'));

      case "cancelled":
        return Vx.hexToColor(colorEnv('cancelledColor'));

      case "delivered":
        return Vx.hexToColor(colorEnv('deliveredColor'));
      case "successful":
        return Vx.hexToColor(colorEnv('successfulColor'));

      default:
        return Vx.hexToColor(colorEnv('pendingColor'));
    }
  }

  //saving
  static Future<bool> saveColorsToLocalStorage(String colorsMap) async {
    return await (await LocalStorageService.getPrefs())
        .setString(AppStrings.appColors, colorsMap);
  }

  static dynamic appColorsObject;
  static Future<void> getColorsFromLocalStorage() async {
    appColorsObject =
        (await LocalStorageService.getPrefs()).getString(AppStrings.appColors);
    if (appColorsObject != null) {
      appColorsObject = jsonDecode(appColorsObject);
    }
  }

  static String colorEnv(String colorRef) {
    //
    getColorsFromLocalStorage();
    //
    final selectedColor =
        appColorsObject != null ? appColorsObject[colorRef] : "#000000";
    return selectedColor;
  }
}
