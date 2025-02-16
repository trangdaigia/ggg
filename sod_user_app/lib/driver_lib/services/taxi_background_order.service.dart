import 'dart:async';
import 'dart:io';

import 'package:app_to_foreground/app_to_foreground.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:sod_user/driver_lib/models/order.dart';
import 'package:sod_user/driver_lib/requests/order.request.dart';
import 'package:sod_user/driver_lib/services/alert.service.dart';
import 'package:sod_user/driver_lib/view_models/taxi/taxi.vm.dart';
import 'package:sod_user/driver_lib/views/pages/taxi/widgets/incoming_new_order_alert.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:sod_user/driver_lib/constants/app_colors.dart';
import 'package:sod_user/driver_lib/constants/app_strings.dart';
import 'package:sod_user/driver_lib/models/new_taxi_order.dart';
import 'package:sod_user/driver_lib/services/extened_order_service.dart';
import 'package:sod_user/driver_lib/services/notification.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:singleton/singleton.dart';
import 'package:sod_user/services/app.service.dart';

class TaxiBackgroundOrderService extends ExtendedOrderService {
  //
  /// Factory method that reuse same instance automatically
  factory TaxiBackgroundOrderService() =>
      Singleton.lazy(() => TaxiBackgroundOrderService._());

  /// Private constructor
  TaxiBackgroundOrderService._() {
    this.fbListener();
  }

  BehaviorSubject<dynamic> showNewOrderStream = BehaviorSubject();
  OrderRequest orderRequest = OrderRequest();
  NewTaxiOrder? newOrder;
  TaxiViewModel? taxiViewModel;
  Order? newTaxiOrderDetail;

  bool _hasShownNewOrder = false;

  bool checkHasShownNewOrder() {
    return _hasShownNewOrder;
  }

  void setHasShownNewOrder(bool value) {
    _hasShownNewOrder = value;
  }

  processOrderNotification(NewTaxiOrder newOrder, {bool? accpectOrder}) async {
    //not in background
    if (appIsInBackground()) {
      //send notification to phone notification tray
      //check if overlay is permitted
      if (Platform.isAndroid && await FlutterOverlayWindow.isActive()) {
        AppToForeground.appToForeground();
        showNewOrderInAppAlert(newOrder, accpectOrder: accpectOrder);
      } else {
        showNewOrderNotificationAlert(newOrder);
      }
    } else {
      showNewOrderInAppAlert(newOrder, accpectOrder: accpectOrder);
    }
  }

  //handle showing new order alert bottom sheet to driver in app
  showNewOrderInAppAlert(NewTaxiOrder newOrder, {bool? accpectOrder}) async {
    AlertService.showLoading();
    try {
      taxiViewModel?.newOrder = newOrder;
      // taxiViewModel?.newTaxiBookingService.stopListeningToNewOrder();
      // //send zoom to new order point via stream
      // taxiViewModel?.onGoingTaxiBookingService.zoomToPickupLocation(
      //   LatLng(
      //     newOrder.pickup!.lat!,
      //     newOrder.pickup!.long!,
      //   ),
      // );
      //

      await fetchOrderDetails(taxiViewModel!.newOrder!.id);
      setHasShownNewOrder(true);
      await showModalBottomSheet(
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        context: AppService().navigatorKey.currentContext!,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return IncomingNewOrderAlert(
            taxiViewModel!.newOrder!,
            this.newTaxiOrderDetail!,
            accpectOrder: accpectOrder,
          );
        },
      );
    } catch (e) {
      print("Error: ====> ${e}. StackTrace: ${StackTrace.current}");
    } finally {
      AlertService.stopLoading();
    }
  }

  showNewOrderNotificationAlert(
    NewTaxiOrder newOrder, {
    int notifcationId = 10,
  }) async {
    //
    // await LocalStorageService.getPrefs();
    //show action notification to driver
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notifcationId,
        ticker: "${AppStrings.appName}",
        channelKey:
            NotificationService.newOrderNotificationChannel().channelKey!,
        title: "New Order Alert".tr(),
        backgroundColor: AppColor.primaryColorDark,
        body: ("Pickup Location".tr() +
            ": " +
            "${newOrder.pickup?.address} (${newOrder.pickupDistance.toInt().ceil()}km)"),
        notificationLayout: NotificationLayout.BigText,
        //
        payload: {
          "id": newOrder.id.toString(),
          "notifcationId": notifcationId.toString(),
          "newOrder": jsonEncode(newOrder.toJson()),
        },
      ),
      actionButtons: [
        NotificationActionButton(
          key: "accept",
          label: "Accept".tr(),
          color: Colors.green,
        ),
        NotificationActionButton(
          key: "reject",
          label: "Reject".tr(),
          color: Colors.red,
        ),
      ],
    );

    return;
  }

  Future<void> fetchOrderDetails(newOrderId) async {
    try {
      this.newTaxiOrderDetail =
          await orderRequest.getOrderDetails(id: newOrderId);
    } catch (error) {
      print("Error ==> $error");
    }
  }
}
