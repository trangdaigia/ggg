import 'package:firestore_chat/firestore_chat.dart';
import 'package:flutter/material.dart';
import 'package:sod_vendor/constants/app_routes.dart';
import 'package:sod_vendor/models/order.dart';
import 'package:sod_vendor/models/notification.dart';
import 'package:sod_vendor/models/product.dart';
import 'package:sod_vendor/views/pages/auth/forgot_password.page.dart';
import 'package:sod_vendor/views/pages/auth/login.page.dart';
import 'package:sod_vendor/views/pages/home.page.dart';
import 'package:sod_vendor/views/pages/notification/notification_details.page.dart';
import 'package:sod_vendor/views/pages/notification/notifications.page.dart';
import 'package:sod_vendor/views/pages/onboarding.page.dart';
import 'package:sod_vendor/views/pages/order/orders_details.page.dart';
import 'package:sod_vendor/views/pages/product/product_details.page.dart';
import 'package:sod_vendor/views/pages/profile/change_password.page.dart';
import 'package:sod_vendor/views/pages/profile/edit_profile.page.dart';
import 'package:sod_vendor/views/pages/shared/location_fetch.page.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.welcomeRoute:
      return MaterialPageRoute(builder: (context) => OnboardingPage());

    case AppRoutes.loginRoute: 
      return MaterialPageRoute(builder: (context) => LocationFetchPage(
          child: LoginPage(),
        ),);

    case AppRoutes.forgotPasswordRoute:
      return MaterialPageRoute(builder: (context) => ForgotPasswordPage());

    case AppRoutes.homeRoute:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.homeRoute, arguments: Map()),
        builder: (context) => HomePage(),
      );

    //order details page
    case AppRoutes.orderDetailsRoute:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.orderDetailsRoute),
        builder: (context) => OrderDetailsPage(
          order: settings.arguments as Order,
        ),
      );
    case AppRoutes.productDetailsRoute:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.productDetailsRoute),
        builder: (context) => ProductDetailsPage(
          product: settings.arguments as Product,
        ),
      );
    //chat page
    case AppRoutes.chatRoute:
      return FirestoreChat().chatPageWidget(
        settings.arguments as ChatEntity,
      );

    //
    case AppRoutes.editProfileRoute:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.editProfileRoute),
        builder: (context) => EditProfilePage(),
      );

    //change password
    case AppRoutes.changePasswordRoute:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.changePasswordRoute),
        builder: (context) => ChangePasswordPage(),
      );

    //profile settings/actions
    case AppRoutes.notificationsRoute:
      return MaterialPageRoute(
        settings:
            RouteSettings(name: AppRoutes.notificationsRoute, arguments: Map()),
        builder: (context) => NotificationsPage(),
      );

    //
    case AppRoutes.notificationDetailsRoute:
      return MaterialPageRoute(
        settings: RouteSettings(
            name: AppRoutes.notificationDetailsRoute, arguments: Map()),
        builder: (context) => NotificationDetailsPage(
          notification: settings.arguments as NotificationModel,
        ),
      );

    default:
      return MaterialPageRoute(builder: (context) => OnboardingPage());
  }
}
