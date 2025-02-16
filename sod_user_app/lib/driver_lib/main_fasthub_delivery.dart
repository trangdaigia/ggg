import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sod_user/driver_lib/app_initialized.dart';
import 'package:sod_user/driver_lib/my_app.dart';
import 'package:sod_user/driver_lib/services/general_app.service.dart';
import 'package:sod_user/driver_lib/services/local_storage.service.dart';
import 'package:sod_user/driver_lib/services/firebase.service.dart';
import 'package:sod_user/driver_lib/services/location_watcher.service.dart';
import 'package:sod_user/driver_lib/services/notification.service.dart';
import 'package:sod_user/driver_lib/services/overlay.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'flavors.dart';

import 'constants/app_languages.dart';
import 'views/overlays/floating_app_bubble.view.dart';

//ssll handshake error
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

@pragma("vm:entry-point")
void overlayMain() {
  F.appFlavor = Flavor.fasthub_delivery;
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FloatingAppBubble(),
    ),
  );
}

void main() async {
  F.appFlavor = Flavor.fasthub_delivery;

  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      //setting up firebase notifications
      await Firebase.initializeApp();
      //
      await translator.init(
        localeType: LocalizationDefaultType.asDefined,
        languagesList: AppLanguages.codes,
        assetsDirectory: 'assets/lang/',
      );
      // Initialize Hive with a specific path
      final appDocumentDir = await getApplicationDocumentsDirectory();
      Hive.init(appDocumentDir.path);
      await LocalStorageService.getPrefs();

      await NotificationService.clearIrrelevantNotificationChannels();
      await NotificationService.initializeAwesomeNotification();
      await NotificationService.listenToActions();
      await FirebaseService().setUpFirebaseMessaging();
      FirebaseMessaging.onBackgroundMessage(
        GeneralAppService.onBackgroundMessageHandler,
      );
      LocationServiceWatcher.listenToDelayLocationUpdate();
      //
      OverlayService().closeFloatingBubble();

      //prevent ssl error
      HttpOverrides.global = new MyHttpOverrides();
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

      //Error handler
      AppInitializer.initializeGlobalErrorHandler();
      // Run app!
      runApp(
        LocalizedApp(
          child: MyApp(),
        ),
      );
    },
    (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
    },
  );
}
