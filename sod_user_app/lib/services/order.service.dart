import 'dart:async';
import 'package:sod_user/models/order.dart';

class OrderService {
  //

//Hnadle background message
  static Future<dynamic> openOrderPayment(Order? order, dynamic vm,
      [String? paymentLink]) async {
    //
    if (paymentLink == null) {
      if ((order!.paymentMethod?.slug ?? "offline") != "offline") {
        print('Link payment: ${order.paymentLink}');
        return vm.openWebpageLink(order.paymentLink);
      } else {
        return vm.openExternalWebpageLink(order.paymentLink);
      }
    } else {
      return vm.openWebpageLink(paymentLink);
    }
  }
}
