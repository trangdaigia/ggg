import 'package:firestore_chat/firestore_chat.dart';
import 'package:flutter/material.dart';
import 'package:sod_user/driver_lib/constants/app_routes.dart';
import 'package:sod_user/driver_lib/models/notification.dart';
import 'package:sod_user/driver_lib/models/order.dart';
import 'package:sod_user/driver_lib/views/pages/auth/forgot_password.page.dart';
import 'package:sod_user/driver_lib/views/pages/auth/login.page.dart';
import 'package:sod_user/driver_lib/views/pages/order/receive_behalf_order_details.page.dart';
import 'package:sod_user/driver_lib/views/pages/shared/home.page.dart';
import 'package:sod_user/driver_lib/views/pages/notification/notification_details.page.dart';
import 'package:sod_user/driver_lib/views/pages/notification/notifications.page.dart';
import 'package:sod_user/driver_lib/views/pages/onboarding.page.dart';
import 'package:sod_user/driver_lib/views/pages/order/orders_details.page.dart';
import 'package:sod_user/driver_lib/views/pages/profile/change_password.page.dart';
import 'package:sod_user/driver_lib/views/pages/profile/edit_profile.page.dart';
import 'package:sod_user/driver_lib/views/pages/wallet/wallet.page.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.welcomeRoute:
      return MaterialPageRoute(builder: (context) => OnboardingPage());

    case AppRoutes.loginRoute:
      return MaterialPageRoute(builder: (context) => LoginPage());

    case AppRoutes.forgotPasswordRoute:
      return MaterialPageRoute(builder: (context) => ForgotPasswordPage());

    case AppRoutes.homeRoute:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.homeRoute, arguments: Map()),
        builder: (context) => HomePage(),
        // Directionality(
        //   textDirection: TextDirection.rtl,
        //   child: HomePage(),
        // ),
      );

    //order details page
    case AppRoutes.orderDetailsRoute:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.orderDetailsRoute),
        builder: (context) => OrderDetailsPage(
          order: settings.arguments as Order,
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

    //wallets
    case AppRoutes.walletRoute:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.walletRoute),
        builder: (context) => WalletPage(),
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

    case AppRoutes.receiveBehalfOrderDetailsRoute:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.receiveBehalfOrderDetailsRoute),
        builder: (context) => ReceiveBehalfOrderDetailsPage(
          order: settings.arguments as Order,
        ),
      );

    default:
      return MaterialPageRoute(builder: (context) => OnboardingPage());
  }
}
