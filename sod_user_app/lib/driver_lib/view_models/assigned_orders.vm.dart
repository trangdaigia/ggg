import 'dart:async';

import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:sod_user/driver_lib/constants/app_routes.dart';
import 'package:sod_user/driver_lib/models/order.dart';
import 'package:sod_user/driver_lib/models/vendor_type.dart';
import 'package:sod_user/driver_lib/requests/order.request.dart';
import 'package:sod_user/driver_lib/requests/vendor_type.request.dart';
import 'package:sod_user/driver_lib/services/taxi/ongoing_taxi_booking.service.dart';
import 'package:sod_user/driver_lib/view_models/base.view_model.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:sod_user/driver_lib/view_models/taxi/taxi.vm.dart';
import 'package:sod_user/driver_lib/views/pages/order/orders_details.page.dart';
import 'package:sod_user/requests/auth.request.dart';
import 'package:sod_user/services/app.service.dart';
import 'package:sod_user/view_models/taxi_new_order_location_entry.vm.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AssignedOrdersViewModel extends MyBaseViewModel {
  AssignedOrdersViewModel(BuildContext context) {
    taxiViewModel = TaxiViewModel(context);
    onGoingTaxiBookingService = OnGoingTaxiBookingService(taxiViewModel);
  }
  //
  late TaxiViewModel taxiViewModel;
  late OnGoingTaxiBookingService onGoingTaxiBookingService;
  OrderRequest orderRequest = OrderRequest();
  List<Order> orders = [];
  List<Order> onGoingOrder = [];
  List<Order> doneOrder = [];
  //
  int queryPage = 1;
  RefreshController refreshController = RefreshController();
  StreamSubscription? refreshOrderStream;
  StreamSubscription? addOrderToListStream;
  List<VendorType> vendorTypes = [];
  bool isInitialized = false;

  Future<void> initialise() async {
    if (!isInitialized) {
      isInitialized = true;

      setBusy(true); // Đánh dấu trạng thái loading
      // Khởi tạo dữ liệu
      await getOnlineDriverState();
      taxiViewModel.initialise();
      vendorTypes = await VendorTypeRequest().index();

      // Lắng nghe sự kiện refresh hoặc thêm order
      refreshOrderStream = AppService().refreshAssignedOrders.listen((refresh) {
        if (refresh) {
          fetchOrders(); // Reload orders nếu có yêu cầu refresh
          taxiViewModel.checkForOnGoingTrip();
          notifyListeners();
        }
      });
      // addOrderToListStream = AppService().addToAssignedOrders.listen((order) {
      //   orders.insert(0, order); // Thêm order mới vào danh sách
      // });

      await fetchOrders(); // Lấy dữ liệu orders lần đầu tiên
      setBusy(false); // Kết thúc trạng thái loading
    }
  }

  getOnlineDriverState() async {
    setBusyForObject(AppService().driverIsOnline, true);
    try {
      final driverData = await AuthRequest().getMyDetails();
      AppService().driverIsOnline = driverData.isOnline;
    } catch (error) {
      print("error getting driver data ==> $error");
    }
    setBusyForObject(AppService().driverIsOnline, false);
  }

  dispose() {
    super.dispose();

    refreshOrderStream?.cancel();
    addOrderToListStream?.cancel();
  }

  bool checkVendorHasSlug(String slug) {
    return vendorTypes.any((vendor) => vendor.slug == slug);
  }

  bool checkVendorHasOnlySlugReceiveBehalf() {
    if (vendorTypes.isNotEmpty) {
      return vendorTypes[0].slug == "receive_behalf" && vendorTypes.length == 1;
    }
    return false;
  }

  //
  fetchOrders({bool initialLoading = true}) async {
    if (initialLoading) {
      setBusy(true);
      refreshController.refreshCompleted();
      queryPage = 1;
    } else {
      queryPage++;
    }

    try {
      final mOrders = await Future.wait([
        orderRequest.getOrders(
        page: queryPage,
        type: "assigned",
      ), orderRequest.getOrders(
        page: queryPage,
        type: "history",
      )
      ]);
      if (!initialLoading) {
        onGoingOrder.addAll(mOrders[0]);
        doneOrder.addAll(mOrders[1]);
        orders.addAll(mOrders.expand((list) => list).toList());
        refreshController.loadComplete();
      } else {
        onGoingOrder = mOrders[0];
        doneOrder = mOrders[1];
        orders = mOrders.expand((list) => list).toList();
      }
      clearErrors();
    } catch (error) {
      print("Order Error ==> $error");
      setError(error);
    }

    setBusy(false);
  }

  //
  openPaymentPage(Order order) async {
    launchUrlString(order.paymentLink);
  }

  //
  openOrderDetails(Order order) async {
    final result = order.receiveBehalfOrder != null
        ? await Navigator.of(AppService().navigatorKey.currentContext!)
            .pushNamed(
            AppRoutes.receiveBehalfOrderDetailsRoute,
            arguments: order,
          )
        : await Navigator.of(AppService().navigatorKey.currentContext!)
            .push(MaterialPageRoute(builder: (context) => OrderDetailsPage(order: order))
          );

    //
    if (result != null && (result is Order || result is bool)) {
      fetchOrders();
    }
  }

  handleOrderClick(Order order) {
    if (order.taxiOrder != null) {
      if (taxiViewModel.onGoingOrderTrip != null &&
          taxiViewModel.onGoingOrderTrip!.code == order.code) {
        taxiViewModel.onGoingOrderTrip = null;
        taxiViewModel.uiStream.drain();
        return;
      }
      taxiViewModel.onGoingOrderTrip = order;
      if(order.status == "delivered" || order.status == "cancelled")
        openOrderDetails(order);
      onGoingTaxiBookingService.loadTripUIByOrderStatus(withMap: false);
    } else {
      openOrderDetails(order);
    }
  }
}
