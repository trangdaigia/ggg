import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_routes.dart';
import 'package:sod_user/models/order.dart';
import 'package:sod_user/requests/order.request.dart';
import 'package:sod_user/services/app.service.dart';
import 'package:sod_user/view_models/payment.view_model.dart';
import 'package:sod_user/views/pages/order/receive_behalf_order_details.page.dart';
import 'package:sod_user/views/pages/order/taxi_order_details.page.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:sod_user/views/pages/trip/trip_detail_page.dart';

class OrdersViewModel extends PaymentViewModel {
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
  StreamSubscription? homePageChangeStream;
  StreamSubscription? refreshOrderStream;

  void initialise() async {
    await fetchMyOrders();

    homePageChangeStream = AppService().homePageIndex.stream.listen(
      (index) {
        //
        fetchMyOrders();
      },
    );

    refreshOrderStream = AppService().refreshAssignedOrders.listen((refresh) {
      if (refresh) {
        fetchMyOrders();
      }
    });
  }

  //
  dispose() {
    super.dispose();
    homePageChangeStream?.cancel();
    refreshOrderStream?.cancel();
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
      final mOrders = await orderRequest.getOrders(page: queryPage);
      if (!initialLoading) {
        orders.addAll(mOrders);
        refreshController.loadComplete();
      } else {
        orders = mOrders;
      }
      clearErrors();
    } catch (error) {
      print("Order Error ==> $error");
      setError(error);
    }

    setBusy(false);
  }

  refreshDataSet() {
    initialise();
  }

  openOrderDetails(Order order) async {
    //
    if (order.taxiOrder != null) {
      await Navigator.push(
        viewContext,
        MaterialPageRoute(
          builder: (context) => TaxiOrderDetailPage(order: order),
        ),
      );
      return;
    }
    if (order.receiveBehalfOrder != null) {
      await Navigator.push(
        viewContext,
        MaterialPageRoute(
          builder: (context) => ReceiveBehalfOrderDetailsPage(order: order),
        ),
      );
      return;
    }

    if (order.rentalVehicleRequests != null) {
      await Navigator.push(
          viewContext,
          MaterialPageRoute(
              builder: ((context) => TripDetailPage(
                    trip: order.rentalVehicleRequests!,
                    order: order,
                  ))));
      return;
    }

    final result = await Navigator.of(viewContext).pushNamed(
      AppRoutes.orderDetailsRoute,
      arguments: order,
    );

    //
    if (result != null && (result is Order || result is bool)) {
      if (result is Order) {
        final orderIndex = orders.indexWhere((e) => e.id == result.id);
        orders[orderIndex] = result;
        notifyListeners();
      } else {
        fetchMyOrders();
      }
    }
  }

  void openLogin() async {
    await Navigator.of(viewContext).pushNamed(AppRoutes.loginRoute);
    notifyListeners();
    fetchMyOrders();
  }

  void openHistoryOrder() async {
    await Navigator.of(viewContext).pushNamed(AppRoutes.activityHistory);
    notifyListeners();
    fetchMyOrders();
  }
}
