import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sod_user/models/order.dart';
import 'package:sod_user/models/vendor_type.dart';
import 'package:sod_user/requests/order.request.dart';
import 'package:sod_user/view_models/orders.vm.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class RecentOrderViewModel extends OrdersViewModel {
  //
  RecentOrderViewModel(BuildContext context, {this.vendorType})
      : super(context) {
    this.viewContext = context;
  }

  //
  VendorType? vendorType;
  OrderRequest orderRequest = OrderRequest();
  RefreshController refreshController = RefreshController();
  List<Order> orders = [];

  //
  fetchMyOrders({bool initialLoading = true}) async {
    setBusy(true);
    refreshController.refreshCompleted();

    try {
      orders = await orderRequest.getOrders(
        params: {
          "vendor_type_id": vendorType?.id,
        },
      );
      clearErrors();
    } catch (error) {
      print("Order Error ==> $error");
      setError(error);
    }

    setBusy(false);
  }
}
