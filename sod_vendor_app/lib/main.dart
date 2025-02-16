import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:sod_vendor/constants/app_languages.dart';
import 'package:sod_vendor/my_app.dart';
import 'package:sod_vendor/services/general_app.service.dart';
import 'package:sod_vendor/services/local_storage.service.dart';
import 'package:sod_vendor/services/firebase.service.dart';
import 'package:sod_vendor/services/notification.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import 'package:flutter_background_service/flutter_background_service.dart';


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

      //
      await LocalStorageService.getPrefs();
      await NotificationService.clearIrrelevantNotificationChannels();
      await NotificationService.initializeAwesomeNotification();
      await NotificationService.listenToActions();
      await FirebaseService().setUpFirebaseMessaging();
      FirebaseMessaging.onBackgroundMessage(
          GeneralAppService.onBackgroundMessageHandler);

      //prevent ssl error
      HttpOverrides.global = new MyHttpOverrides();
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

//chạy ngầm
void onStart(ServiceInstance service) {
  // Xử lý các tác vụ cần chạy trong nền
  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  Timer.periodic(const Duration(seconds: 5), (timer) async {
    print('Running in the background...');

    // Cập nhật trạng thái
    service.invoke('update', {
      'status': 'running',
      'timestamp': DateTime.now().toIso8601String(),
    });
  });
}