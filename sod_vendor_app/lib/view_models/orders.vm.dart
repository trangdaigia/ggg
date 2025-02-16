import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sod_vendor/constants/app_routes.dart';
import 'package:sod_vendor/models/order.dart';
import 'package:sod_vendor/requests/order.request.dart';
import 'package:sod_vendor/services/app.service.dart';
import 'package:sod_vendor/view_models/base.view_model.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:url_launcher/url_launcher_string.dart';

class OrdersViewModel extends MyBaseViewModel {
  //
  OrdersViewModel(BuildContext context) {
    this.viewContext = context;
  }

  //
  bool isUpdating = false;
  //bool willUpdate = false;
  OrderRequest orderRequest = OrderRequest();
  List<String> statuses = [
    'All',
    'Pending',
    'Scheduled',
    'Preparing',
    'Enroute',
    'Failed',
    'Cancelled',
    'Delivered'
  ];
  String selectedStatus = "All";

  PageController pageController = PageController(initialPage: 0);
  TabController? tabController = null;
  StreamSubscription? refreshOrderStream;

  Map<String, RefreshController> refreshControllers = {};
  Map<String, List<Order>> orders = {};
  Map<String, int> queryPages = {};
  Map<String, bool> willUpdate = {};

  //
  void initialise() async {
    refreshControllers = Map.fromEntries(
        statuses.map((status) => MapEntry(status, RefreshController())));
    orders = Map.fromEntries(statuses.map((status) => MapEntry(status, [])));
    queryPages = Map.fromEntries(statuses.map((status) => MapEntry(status, 1)));
    willUpdate =
        Map.fromEntries(statuses.map((status) => MapEntry(status, false)));

    refreshOrderStream = AppService().refreshAssignedOrders.listen((refresh) {
      if (refresh) {
        fetchMyOrders();
      }
    });

    await fetchMyOrders(forceRefresh: true);
  }

  void initTabController({required TickerProvider vsync}) {
    tabController = TabController(length: statuses.length, vsync: vsync);
  }

  @override
  void dispose() {
    super.dispose();
    refreshOrderStream?.cancel();
  }

  Future<void> fetchMyOrders({
    bool isLoadMore = false,
    bool forceRefresh = false,
    bool isShowBusy = true,
  }) async {
    final currentPage = queryPages[selectedStatus];
    if (isLoadMore) {
      queryPages[selectedStatus] = (currentPage ?? 1) + 1;
    }
    if (!isLoadMore) {
      setBusy(isShowBusy);
    }

    try {
      final mOrders = await orderRequest.getOrders(
        page: queryPages[selectedStatus]!,
        status: selectedStatus == "All" ? "" : selectedStatus.toLowerCase(),
        forceRefresh: forceRefresh,
      );
      if (isLoadMore) {
        orders[selectedStatus]!.addAll(mOrders);
      } else {
        orders[selectedStatus] = mOrders;
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

  openOrderDetails(Order order) async {
    final result = await Navigator.of(viewContext).pushNamed(
      AppRoutes.orderDetailsRoute,
      arguments: order,
    );

    // if (result != null && result is Order) {
    //   final orderIndex = orders[selectedStatus]!.indexWhere((order) => order.id == result.id);
    //   orders[selectedStatus]![orderIndex] = result;

    //   notifyListeners();
    // } else if (result != null && result is bool) {
    //   fetchMyOrders(forceRefresh: true);
    // }

    willUpdate.forEach((key, value) {
      willUpdate[key] = key != selectedStatus;
    });

    await updateOrder();
  }

  Future<void> updateOrder() async {
    queryPages[selectedStatus] = 1;
    isUpdating = true; // hiện thanh loading ở topbar
    await fetchMyOrders(forceRefresh: true, isShowBusy: false);
    isUpdating = false;
    notifyListeners();
  }

  void onPageChanged(int index) {
    selectedStatus = statuses[index];

    if (orders[selectedStatus]!.isEmpty) {
      fetchMyOrders();
    } 
    if (willUpdate[selectedStatus]!) {
      updateOrder();
      willUpdate[selectedStatus] = false;
    }

    tabController!.animateTo(index);
    pageController.jumpToPage(index);
    notifyListeners();
  }

  // tải lại từ đầu (kéo từ trên xuông)
  void onRefresh() async {
    queryPages[selectedStatus] = 1;

    await fetchMyOrders(forceRefresh: true);
    refreshControllers[selectedStatus]!.refreshCompleted();
  }

  // tải thêm (kéo từ dưới lên)
  void onLoading() async {
    await fetchMyOrders(isLoadMore: true, isShowBusy: false);
    refreshControllers[selectedStatus]!.loadComplete();
  }
}
