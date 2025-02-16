import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/driver_lib/models/new_taxi_order.dart';
import 'package:sod_user/driver_lib/requests/order.request.dart';
import 'package:sod_user/driver_lib/requests/taxi.request.dart';
import 'package:sod_user/driver_lib/services/alert.service.dart';
import 'package:sod_user/driver_lib/services/app.service.dart';
import 'package:sod_user/services/auth.service.dart';
import 'package:sod_user/driver_lib/services/taxi_background_order.service.dart';
import 'package:sod_user/driver_lib/view_models/base.view_model.dart';
import 'package:velocity_x/velocity_x.dart';

class NewTaxiOrderAlertViewModel extends MyBaseViewModel {
  //
  OrderRequest orderRequest = OrderRequest();
  TaxiRequest taxiRequest = TaxiRequest();
  NewTaxiOrder newOrder;
  bool canDismiss = false;
  bool? accpectOrder;
  CountDownController countDownTimerController = CountDownController();
  NewTaxiOrderAlertViewModel(
      this.newOrder, BuildContext context, this.accpectOrder) {
    this.viewContext = context;
  }

  initialise() async {
    if (accpectOrder != null) {
      if (accpectOrder!) {
        await processOrderAcceptance();
      } else {
        Navigator.pop(viewContext);
        await rejectOrder();
      }
    } else {
      //
      AppService().playNotificationSound();
      //
      countDownTimerController.start();
    }
    TaxiBackgroundOrderService().setHasShownNewOrder(true);
  }

  Future<void> processOrderAcceptance() async {
    setBusy(true);
    try {
      final order = await orderRequest.acceptNewOrder(
        newOrder.id,
        status: "preparing",
      );
      AppService().stopNotificationSound();
      //
      Navigator.pop(viewContext, order);
      // return;
    } catch (error) {
      viewContext.showToast(
        msg: "$error",
        bgColor: Colors.red,
        textColor: Colors.white,
        textSize: 20,
      );

      //
      canDismiss = true;
    }
    setBusy(false);
    //
    if (canDismiss) {
      AppService().stopNotificationSound();
      Navigator.pop(viewContext);
    }
  }

  Future<void> rejectOrder() async {
    setBusy(true);
    try {
      await taxiRequest.rejectAssignment(
        newOrder.id,
        AuthServices.currentUser!.id,
      );
    } catch (error) {
      print("error ignoring trip assignment ==> $error");
    }
    setBusy(false);
  }

  Future<void> countDownCompleted(bool started) async {
    print('Countdown Ended');
    if (started) {
      if (isBusy) {
        canDismiss = true;
      } else {
        AppService().stopNotificationSound();
        Navigator.pop(viewContext);
        //STOP NOTIFICATION SOUND
        AppService().stopNotificationSound();
        //silently reject order assignment
        await rejectOrder();
      }
    }
  }
}
