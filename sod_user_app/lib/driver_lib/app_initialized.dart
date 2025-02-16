import 'dart:async';
import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:sod_user/driver_lib/constants/app_routes.dart';
import 'package:sod_user/driver_lib/services/app.service.dart';

class AppInitializer {
  static final navigatorKey = AppService().navigatorKey;
  static Future<void> initializeGlobalErrorHandler() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Global Error Handling
    FlutterError.onError = (details) {
      FirebaseCrashlytics.instance.recordFlutterError(details);
      FlutterError.presentError(details);
      debugPrint("Navigator key: ${navigatorKey.currentState}");
      debugPrint("Unhandled error. Routing back to home");
      debugPrint("Error ${details.toString()}");
      navigatorKey.currentState?.popAndPushNamed(AppRoutes.homeRoute);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint("Navigator key: ${navigatorKey.currentState}");
      debugPrint("Unhandled error. Routing back to home");
      debugPrint("Error: ${error}");
      navigatorKey.currentState?.pushReplacementNamed(AppRoutes.homeRoute);
      return true;
    };
  }
}
