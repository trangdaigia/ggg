import 'dart:async';
import 'dart:io';

import 'package:dio/io.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:sod_user/constants/app_languages.dart';
import 'package:sod_user/my_app.dart';
import 'package:sod_user/services/cart.service.dart';
import 'package:sod_user/services/general_app.service.dart';
import 'package:sod_user/services/local_storage.service.dart';
import 'package:sod_user/services/firebase.service.dart';
import 'package:sod_user/services/notification.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'flavors.dart';

void main() async {
  // Retrieve the flavor from dart-define
  F.appFlavor = Flavor.sod_user;

  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize Firebase
      if (kIsWeb) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: "AIzaSyDo2wW_EKlHlFrxIVGVjtPDHVoS9B_c_DQ",
            authDomain: "sod-di4l.firebaseapp.com",
            projectId: "sod-di4l",
            storageBucket: "sod-di4l.appspot.com",
            messagingSenderId: "140629869168",
            appId: "1:140629869168:web:bd502f2c1d0e20f6332ab5",
            measurementId: "G-SBVSF2BGCM",
          ),
        );
      } else {
        await Firebase.initializeApp();
      }

      // Initialize localization
      await translator.init(
        localeType: LocalizationDefaultType.asDefined,
        languagesList: AppLanguages.codes,
        assetsDirectory: 'assets/lang/',
      );

      // Initialize services
      await LocalStorageService.getPrefs();
      await CartServices.getCartItems();
      if (!kIsWeb) {
        await NotificationService.clearIrrelevantNotificationChannels();
        await NotificationService.initializeAwesomeNotification();
        await NotificationService.listenToActions();
        await FirebaseService().setUpFirebaseMessaging();
        FirebaseMessaging.onBackgroundMessage(
            GeneralAppService.onBackgroundMessageHandler);
      }

      // Set up Crashlytics for production builds, only for Android and iOS
      if (!kIsWeb) {
        // Ensure it's not a web build
        if (Platform.isAndroid || Platform.isIOS) {
          FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
          FlutterError.onError =
              FirebaseCrashlytics.instance.recordFlutterError;
        }
      }

      // Run the app
      runApp(
        MyApp(),
      );
    },
    (error, stackTrace) {
      // Log errors for mobile platforms only
      if (!kIsWeb) {
        if (Platform.isAndroid || Platform.isIOS) {
          FirebaseCrashlytics.instance.recordError(error, stackTrace);
        }
      }
    },
  );
}
