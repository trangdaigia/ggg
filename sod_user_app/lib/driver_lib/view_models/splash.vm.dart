import 'dart:convert';
import 'dart:io';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:sod_user/driver_lib/constants/app_colors.dart';
import 'package:sod_user/driver_lib/constants/app_routes.dart';
import 'package:sod_user/driver_lib/constants/app_strings.dart';
import 'package:sod_user/driver_lib/constants/app_theme.dart';
import 'package:sod_user/driver_lib/flavors.dart';
import 'package:sod_user/driver_lib/requests/settings.request.dart';
import 'package:sod_user/driver_lib/constants/app_languages.dart';
import 'package:sod_user/services/auth.service.dart';
import 'package:sod_user/driver_lib/services/firebase.service.dart';
import 'package:sod_user/driver_lib/utils/utils.dart';
import 'package:sod_user/driver_lib/views/pages/permission/permission.page.dart';
import 'package:sod_user/driver_lib/widgets/cards/language_selector.view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sod_user/driver_lib/widgets/update_dialog.dart';
import 'base.view_model.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

class SplashViewModel extends MyBaseViewModel {
  SplashViewModel(BuildContext context) {
    this.viewContext = context;
  }

  //
  SettingsRequest settingsRequest = SettingsRequest();
  List<String> availableLanguageCodes = [];

  //
  initialise() async {
    super.initialise();
    await _checkForUpdates();

    await loadAppSettings();
  }

  Future<void> _checkForUpdates() async {
    // Create an instance of the updater class
    final shorebirdCodePush = ShorebirdCodePush();

    // Check whether a patch is available to install.
    final isUpdateAvailable =
        await shorebirdCodePush.isNewPatchAvailableForDownload();

    // For testing
    if (isUpdateAvailable) {
      // Show a dialog to the user to inform them that a new update is available.
      await showDialog(
        context: viewContext,
        barrierDismissible: false,
        builder: (context) {
          return PopScope(
            canPop: false,
            child: Dialog(
                child: UpdateDialog(
              logoPath: getSplashImagePath(),
            )),
          );
        },
      );
    }
  }

  //
  loadAppSettings() async {
    setBusy(true);
    try {
      final appSettingsObject = await settingsRequest.appSettings();
      //app settings
      await updateAppVariables(appSettingsObject.body["strings"]);
      availableLanguageCodes = (appSettingsObject.body["strings"]
                  ["enabledLanguage"] as List<dynamic>?)
              ?.map((e) => e["code"] as String)
              .toList() ??
          [];
      //colors
      await updateAppTheme(appSettingsObject.body["colors"]);

      await loadNextPage();
    } catch (error) {
      setError(error);
      print("Error loading app settings ==> $error");
    }
    setBusy(false);
  }

  //
  updateAppVariables(dynamic json) async {
    //
    await AppStrings.saveAppSettingsToLocalStorage(jsonEncode(json));
  }

  //theme change
  updateAppTheme(dynamic colorJson) async {
    //
    await AppColor.saveColorsToLocalStorage(jsonEncode(colorJson));
    //change theme
    // await AdaptiveTheme.of(viewContext).reset();
    AdaptiveTheme.of(viewContext).setTheme(
      light: AppTheme().lightTheme(),
      dark: AppTheme().darkTheme(),
      notify: true,
    );
    await AdaptiveTheme.of(viewContext).persist();
  }

  //
  loadNextPage() async {
    //
    await Utils.setJiffyLocale();
    String currentLanguageCode = translator.activeLocale.languageCode;

    // take availableLanguageCodes from remote settings, not from AppLanguages (it's not synch :v)
    if (availableLanguageCodes.isEmpty) {
      availableLanguageCodes = AppLanguages.allLanguageCodes;
    }

    if (availableLanguageCodes.length == 1) {
      final newCode = availableLanguageCodes.first;
      if (newCode != currentLanguageCode) {
        await AuthServices.setLocale(newCode);
        await translator.setNewLanguage(
          viewContext,
          newLanguage: newCode,
          remember: true,
          restart: true,
        );
        await Utils.setJiffyLocale();
      }
    } else if (await AuthServices.firstTimeOnApp()) {
      // Choose language
      await showModalBottomSheet(
        context: viewContext,
        builder: (context) {
          return AppLanguageSelector();
        },
      );
    } else if (!availableLanguageCodes.contains(currentLanguageCode)) {
      // If the current language is not in the updated list, set to default language
      final code = AppLanguages.defaultLanguage;
      await AuthServices.setLocale(code);
      await translator.setNewLanguage(
        viewContext,
        newLanguage: code,
        remember: true,
        restart: true,
      );
      await Utils.setJiffyLocale();
    }
    //
    if (await AuthServices.firstTimeOnApp()) {
      Navigator.of(viewContext)
          .pushNamedAndRemoveUntil(AppRoutes.welcomeRoute, (route) => false);
    } else if (! (await AuthServices.authenticated())) {
      Navigator.of(viewContext)
          .pushNamedAndRemoveUntil(AppRoutes.loginRoute, (route) => false);
    } else {
      var inUseStatus = await Permission.locationWhenInUse.status;
      var alwaysUseStatus = F.appFlavor == Flavor.sob_express_admin
          ? true
          : await Permission.locationAlways.status.isGranted;
      final bgPermissinGranted =
          Platform.isIOS ? true : await FlutterBackground.hasPermissions;

      if (inUseStatus.isGranted && alwaysUseStatus && bgPermissinGranted) {
        Navigator.of(viewContext).pushNamedAndRemoveUntil(
          AppRoutes.homeRoute,
          (route) => false,
        );
      } else {
        viewContext.nextAndRemoveUntilPage(PermissionPage());
      }
    }

    //
    RemoteMessage? initialMessage =
        await FirebaseService().firebaseMessaging.getInitialMessage();
    if (initialMessage == null) {
      return;
    }
    FirebaseService().saveNewNotification(initialMessage);
    FirebaseService().notificationPayloadData = initialMessage.data;
    FirebaseService().selectNotification("");
  }

  String getSplashImagePath() {
    switch (F.appFlavor) {
      case Flavor.sod_delivery:
        return "assets/images/app_icons/sod_delivery/icon-transparent.png";
      case Flavor.sob_express_admin:
        return "assets/images/app_icons/sob_express_admin/icon.png";
      case Flavor.suc365_driver:
        return "assets/images/app_icons/suc365_driver/icon-transparent.png";
      case Flavor.g47_driver:
        return "assets/images/app_icons/g47_driver/icon-transparent.png";
      case Flavor.appvietsob_delivery:
        return "assets/images/app_icons/appvietsob_delivery/icon-transparent.png";
      case Flavor.vasone_driver:
        return "assets/images/app_icons/vasone_driver/icon.png";
      case Flavor.fasthub_delivery:
        return "assets/images/app_icons/fasthub_delivery/icon.png";
      case Flavor.goingship_driver:
        return "assets/images/app_icons/goingship_driver/icon-transparent.png";
      case Flavor.grabxanh_driver:
        return "assets/images/app_icons/grabxanh_driver/icon-transparent.png";
      default:
        return "assets/images/app_icons/sod_delivery/icon-transparent.png";
    }
  }
}
