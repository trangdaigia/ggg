import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:sod_vendor/constants/app_theme.dart';
import 'package:sod_vendor/services/app.service.dart';
import 'package:sod_vendor/views/pages/splash.page.dart';

import 'package:localize_and_translate/localize_and_translate.dart';
import 'constants/app_strings.dart';
import 'package:sod_vendor/services/router.service.dart' as router;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //
    return AdaptiveTheme(
      light: AppTheme().lightTheme(),
      dark: AppTheme().lightTheme(),
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
          theme: theme,
          // darkTheme: darkTheme,
        );
      },
    );
  }
}
