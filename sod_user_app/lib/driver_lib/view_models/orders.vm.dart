import 'package:flutter/material.dart';
import 'package:sod_user/driver_lib/constants/app_routes.dart';
import 'package:sod_user/driver_lib/models/order.dart';
import 'package:sod_user/driver_lib/models/vendor_type.dart';
import 'package:sod_user/driver_lib/requests/order.request.dart';
import 'package:sod_user/driver_lib/requests/vendor_type.request.dart';
import 'package:sod_user/driver_lib/view_models/base.view_model.dart';
import 'package:sod_user/driver_lib/views/pages/order/receive_behalf_order_details.page.dart';
import 'package:sod_user/driver_lib/views/pages/order/taxi_order_details.page.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:velocity_x/velocity_x.dart';

class OrdersViewModel extends MyBaseViewModel {
  //
  OrdersViewModel(BuildContext context) {
    this.viewContext = context;
  }

  //
  OrderRequest orderRequest = OrderRequest();
  List<Order> orders = [];
  //
  int queryPage = 1;
  RefreshController refreshController = RefreshController();
  List<VendorType> vendorTypes = [];
  void initialise() async {
    vendorTypes = await VendorTypeRequest().index();

    await fetchMyOrders();
  }

  bool checkVendorHasSlug(String slug) {
    for (var i = 0; i < vendorTypes.length; i++) {
      if (vendorTypes[i].slug == slug) {
        return true;
      }
    }
    return false;
  }

  //
  fetchMyOrders({bool initialLoading = true}) async {
    if (initialLoading) {
      setBusy(true);
      refreshController.refreshCompleted();
      queryPage = 1;
    } else {
      queryPage++;
    }

    try {
      final mOrders = await orderRequest.getOrders(
        page: queryPage,
        type: "history",
      );
      if (!initialLoading) {
        orders.addAll(mOrders);
        refreshController.loadComplete();
      } else {
        orders = mOrders;
      }
      clearErrors();
    } catch (error) {
      orders = [];
      print("Order Error ==> $error");
      setError(error);
    }
    notifyListeners();
    setBusy(false);
  }

  //
  openPaymentPage(Order order) async {
    launchUrlString(order.paymentLink);
  }

  openOrderDetails(Order order) async {
    //
    if (order.taxiOrder != null) {
      await Navigator.push(
          viewContext,
          MaterialPageRoute(
            builder: (context) => TaxiOrderDetailPage(order: order),
          ));
      return;
    }
    if (order.receiveBehalfOrder != null) {
      await Navigator.push(
          viewContext,
          MaterialPageRoute(
            builder: (context) => ReceiveBehalfOrderDetailsPage(order: order),
          ));
      return;
    }

    final result = await Navigator.of(viewContext).pushNamed(
      AppRoutes.orderDetailsRoute,
      arguments: order,
    );

    //
    if (result != null && (result is Order || result is bool)) {
      fetchMyOrders();
    }
  }

  void openLogin() async {
    await Navigator.of(viewContext).pushNamed(AppRoutes.loginRoute);
    notifyListeners();
    fetchMyOrders();
  }
}
