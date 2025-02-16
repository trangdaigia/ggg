import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sod_user/models/order.dart';
import 'package:sod_user/requests/order.request.dart';
import 'base.view_model.dart';

class OrderCancellationViewModel extends MyBaseViewModel {
  //
  OrderRequest orderRequest = OrderRequest();
  List<String> reasons = [];
  Order order;

  OrderCancellationViewModel(BuildContext context, this.order) {
    this.viewContext = context;
  }

  void initialise() async {
    setBusyForObject(reasons, true);
    try {
      reasons = await orderRequest.orderCancellationReasons(order: order);

      // Kiểm tra nếu danh sách rỗng hoặc chỉ chứa các phần tử rỗng
      if (reasons.isEmpty || reasons.every((element) => element.isEmpty)) {
        reasons = ["Đổi ý không muốn đặt nữa", "Lý do khác"];
      }
    } catch (error) {
      log("Error ==> $error");
    }
    setBusyForObject(reasons, false);
  }
}
