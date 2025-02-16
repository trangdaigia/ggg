import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sod_user/driver_lib/constants/app_theme.dart';
import 'package:sod_user/driver_lib/models/new_taxi_order.dart';
import 'package:sod_user/driver_lib/services/alert.service.dart';
import 'package:sod_user/driver_lib/services/app.service.dart';
import 'package:sod_user/driver_lib/services/taxi_background_order.service.dart';
import 'package:sod_user/driver_lib/views/pages/splash.page.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';
import 'constants/app_strings.dart';
import 'package:sod_user/driver_lib/services/router.service.dart' as router;
import 'package:firebase_messaging/firebase_messaging.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions(); // Kiểm tra quyền khi ứng dụng trở lại foreground
      _checkNewOrder(); // Kiểm tra đơn hàng mới
    }
  }

  Future<void> _checkPermissions() async {
    var statusFine = await Permission.locationWhenInUse.request();
    var statusCoarse = await Permission.locationAlways.request();
    // Yêu cầu quyền Foreground Service
    var statusForegroundService =
        await Permission.manageExternalStorage.request();

    if (statusFine.isGranted &&
        statusCoarse.isGranted &&
        statusForegroundService.isGranted) {
      // Khởi động dịch vụ nền
      const platform = MethodChannel('com.example.myapplication/service');
      await platform.invokeMethod('startService');
    } else {
      // Hiển thị thông báo lỗi nếu không có quyền
      // print("Không có quyền truy cập vị trí và dịch vụ nền!");
    }
  }

  void _checkNewOrder() {
    final taxiService = TaxiBackgroundOrderService();
    final hasShownNewOrder = taxiService.checkHasShownNewOrder();

    if (!hasShownNewOrder) {
      final newOrder = taxiService.newOrder;
      print('id new order: ${newOrder?.id}');
      if (newOrder != null) {
        taxiService.showNewOrderInAppAlert(newOrder);

        taxiService.setHasShownNewOrder(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: AppTheme().lightTheme(),
      dark: AppTheme().darkTheme(),
      initial: AdaptiveThemeMode.system,
      builder: (theme, darkTheme) {
        return MaterialApp(
          navigatorKey: AppService().navigatorKey,
          debugShowCheckedModeBanner: false,
          title: AppStrings.appName,
          onGenerateRoute: router.generateRoute,
          // initialRoute: _startRoute,
          localizationsDelegates: translator.delegates,
          locale: translator.activeLocale,
          supportedLocales: translator.locals(),
          home: SplashPage(),
          theme: AppTheme().lightTheme(),
          // darkTheme: darkTheme,
        );
      },
    );
  }
}
