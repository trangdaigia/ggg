import 'dart:convert';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_languages.dart';
import 'package:sod_user/constants/app_routes.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/constants/app_theme.dart';
import 'package:sod_user/requests/settings.request.dart';
import 'package:sod_user/services/auth.service.dart';
import 'package:sod_user/services/firebase.service.dart';
import 'package:sod_user/utils/utils.dart';
import 'package:sod_user/widgets/cards/language_selector.view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/widgets/update_dialog.dart';
import 'base.view_model.dart';
import 'package:sod_user/flavors.dart';
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

    await loadForbidenWords();
    await loadAppSettings();
    if (AuthServices.authenticated()) {
      await AuthServices.getCurrentUser(force: true);
    }
  }

  Future<void> _checkForUpdates() async {
    // Create an instance of the updater class
    final shorebirdCodePush = ShorebirdCodePush();

    // Check whether a patch is available to install.
    final isUpdateAvailable =
        await shorebirdCodePush.isNewPatchAvailableForDownload();

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
              logoPath: 'assets/images/cloud-download.png',
            )),
          );
        },
      );
    }
  }

  //
  Future<void> loadForbidenWords() async {
    List<String> forbidenWords = [];

    final response = await settingsRequest.getForbiddenWords();
    if (response.allGood && response.body != null) {
      List<dynamic> wordsData = response.body;
      wordsData.forEach((word) {
        forbidenWords.add(word["name"]);
      });

      await AppStrings.saveForbiddenWordsToLocalStorage(
          jsonEncode(forbidenWords));

      // Debug
      print("Forbiden words loaded: ${AppStrings.forbiddenWords}");
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
      //show a dialog
      CoolAlert.show(
        context: viewContext,
        barrierDismissible: false,
        type: CoolAlertType.error,
        title: "An error occurred".tr(),
        text: "$error",
        confirmBtnText: "Retry".tr(),
        onConfirmBtnTap: () {
          Navigator.pop(viewContext);
          initialise();
        },
      );
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
    } else if (AuthServices.firstTimeOnApp()) {
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
    if (AuthServices.firstTimeOnApp()) {
      Navigator.of(viewContext).pushNamedAndRemoveUntil(
        AppRoutes.welcomeRoute,
        (Route<dynamic> route) => false,
      );
    } else {
      Navigator.of(viewContext).pushNamedAndRemoveUntil(
        AppRoutes.homeRoute,
        (Route<dynamic> route) => false,
      );
    }

    //
    RemoteMessage? initialMessage =
        await FirebaseService().firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      //
      FirebaseService().saveNewNotification(initialMessage);
      FirebaseService().notificationPayloadData = initialMessage.data;
      FirebaseService().selectNotification("");
    }
  }

  String getSplashImagePath() {
    switch (F.appFlavor) {
      case Flavor.sod_user:
        return "assets/images/app_icons/sod_user/icon-transparent.png";
      case Flavor.sob_express:
        return "assets/images/app_icons/sob_express/icon.png";
      case Flavor.suc365_user:
        return "assets/images/app_icons/suc365_user/icon-transparent.png";
      case Flavor.g47_user:
        return "assets/images/app_icons/g47_user/icon-transparent.png";
      case Flavor.appvietsob_user:
        return "assets/images/app_icons/appvietsob_user/icon-transparent.png";
      case Flavor.vasone:
        return "assets/images/app_icons/vasone/icon.png";
      case Flavor.fasthub_user:
        return "assets/images/app_icons/fasthub_user/icon.png";
      case Flavor.goingship:
        return "assets/images/app_icons/goingship/icon-transparent.png";
      case Flavor.grabxanh:
        return "assets/images/app_icons/grabxanh/icon-transparent.png";
      default:
        return "assets/images/app_icons/sod_user/icon-transparent.png";
    }
  }
}
