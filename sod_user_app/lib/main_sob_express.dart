import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sod_user/global/global_variable.dart';
import 'package:sod_user/my_app.dart';
import 'package:sod_user/services/cart.service.dart';
import 'package:sod_user/services/firebase.service.dart';
import 'package:sod_user/services/general_app.service.dart';
import 'package:sod_user/services/local_storage.service.dart';
import 'package:sod_user/services/notification.service.dart';

import 'constants/app_languages.dart';
import 'flavors.dart';

//ssll handshake error
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  F.appFlavor = Flavor.sob_express;
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      //setting up firebase notifications
      await Firebase.initializeApp();

      await translator.init(
        localeType: LocalizationDefaultType.asDefined,
        languagesList: AppLanguages.codes,
        assetsDirectory: 'assets/lang/',
      );
      // Initialize Hive with a specific path
      final appDocumentDir = await getApplicationDocumentsDirectory();
      Hive.init(appDocumentDir.path);
      //
      await LocalStorageService.getPrefs();
      await CartServices.getCartItems();
      await NotificationService.clearIrrelevantNotificationChannels();
      await NotificationService.initializeAwesomeNotification();
      await NotificationService.listenToActions();
      await FirebaseService().setUpFirebaseMessaging();
      FirebaseMessaging.onBackgroundMessage(
          GeneralAppService.onBackgroundMessageHandler);

      //prevent ssl error
      HttpOverrides.global = new MyHttpOverrides();
      //setting up crashlytics only for production
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

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
