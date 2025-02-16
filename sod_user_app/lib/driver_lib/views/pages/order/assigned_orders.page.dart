import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/driver_lib/services/taxi_background_order.service.dart';
import 'package:sod_user/driver_lib/utils/ui_spacer.dart';
import 'package:sod_user/driver_lib/view_models/assigned_orders.vm.dart';
import 'package:sod_user/driver_lib/view_models/home.vm.dart';
import 'package:sod_user/driver_lib/view_models/taxi/taxi.vm.dart';
import 'package:sod_user/driver_lib/views/pages/receive_behalf/receive_behalf.page.dart';
import 'package:sod_user/driver_lib/views/pages/taxi/taxi_order.page.dart';
import 'package:sod_user/driver_lib/widgets/base.page.dart';
import 'package:sod_user/driver_lib/widgets/custom_list_view.dart';
import 'package:sod_user/driver_lib/widgets/list_items/order.list_item.dart';
import 'package:sod_user/driver_lib/widgets/list_items/receive_behalf_order.list.item.dart';
import 'package:sod_user/driver_lib/widgets/states/error.state.dart';
import 'package:sod_user/driver_lib/widgets/states/order.empty.dart';
import 'package:sod_user/services/app.service.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

import 'widgets/online_offline.fab.dart';

class AssignedOrdersPage extends StatefulWidget {
  const AssignedOrdersPage({Key? key, required this.homeVm}) : super(key: key);
  final HomeViewModel homeVm;
  @override
  _AssignedOrdersPageState createState() => _AssignedOrdersPageState();
}

class _AssignedOrdersPageState extends State<AssignedOrdersPage>
    with
        AutomaticKeepAliveClientMixin<AssignedOrdersPage>,
        WidgetsBindingObserver {
  late AssignedOrdersViewModel assignedOrdersViewModel;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      assignedOrdersViewModel.refreshController.requestRefresh();
      assignedOrdersViewModel.taxiViewModel.checkForOnGoingTrip();
      _checkPermissions(); // Kiểm tra quyền khi ứng dụng trở lại foreground
      _checkNewOrder(); // Kiểm tra đơn hàng mới
    }
  }

  Future<void> _checkPermissions() async {
    var statusFine = await Permission.locationWhenInUse.request();
    var statusCoarse = await Permission.locationAlways.request();
    // Yêu cầu quyền Foreground Service
    var statusForegroundService =
        await Permission.manageExternalStorage.request();

    if (statusFine.isGranted &&
        statusCoarse.isGranted &&
        statusForegroundService.isGranted) {
      // Khởi động dịch vụ nền
      const platform = MethodChannel('com.example.myapplication/service');
      await platform.invokeMethod('startService');
    } else {
      // Hiển thị thông báo lỗi nếu không có quyền
      // print("Không có quyền truy cập vị trí và dịch vụ nền!");
    }
  }

  void _checkNewOrder() {
    final taxiService = TaxiBackgroundOrderService();
    final hasShownNewOrder = taxiService.checkHasShownNewOrder();

    if (!hasShownNewOrder) {
      final newOrder = taxiService.newOrder;
      print('id new order: ${newOrder?.id}');
      if (newOrder != null) {
        taxiService.showNewOrderInAppAlert(newOrder);

        taxiService.setHasShownNewOrder(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: ViewModelBuilder<AssignedOrdersViewModel>.reactive(
        viewModelBuilder: () {
          assignedOrdersViewModel = new AssignedOrdersViewModel(context);
          return assignedOrdersViewModel;
        },
        onViewModelReady: (vm) => assignedOrdersViewModel.initialise(),
        builder: (context, assignedOrdersViewModel, child) {
          return BasePage(
            showAppBar: true,
            title: "Assigned orders".tr(),
            showLeadingAction: true,
            actions: [
              HStack([
                VxBox(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TaxiOrderPage(
                                  taxiViewModel: TaxiViewModel(context),
                                )),
                      );
                    },
                    child: Icon(Icons.map, color: Colors.black),
                  ),
                )
                    .make()
                    .p16()
                    // .backgroundColor(Colors.green)
                    .cornerRadius(20)
                    .px4(),
                if (assignedOrdersViewModel
                    .checkVendorHasSlug("receive_behalf"))
                  VxBox(
                    child: GestureDetector(
                      onTap: () {
                        context.nextPage(ReceiveBehalfPage());
                      },
                      child: HStack(
                        [
                          'Receive Behalf'.tr().text.white.make(),
                          Icon(
                            Icons.add,
                          ),
                        ],
                      ),
                    ),
                  ).make().p16().backgroundColor(Colors.grey).cornerRadius(20)
              ])
            ],
            appBarColor: context.theme.colorScheme.surface,
            appBarItemColor: AppColor.primaryColor,
            body: Stack(
              children: [
                VStack(
                  [
                    if (!assignedOrdersViewModel
                        .checkVendorHasOnlySlugReceiveBehalf())
                      OnlineOfflineFab(homeVm: widget.homeVm),
                    UiSpacer.vSpace(),
                    CustomListView(
                      canRefresh: true,
                      canPullUp: true,
                      refreshController:
                          assignedOrdersViewModel.refreshController,
                      onRefresh: assignedOrdersViewModel.fetchOrders,
                      onLoading: () => assignedOrdersViewModel.fetchOrders(
                          initialLoading: false),
                      isLoading: assignedOrdersViewModel.isBusy,
                      dataSet: assignedOrdersViewModel.orders,
                      hasError: assignedOrdersViewModel.hasError,
                      errorWidget: LoadingError(
                        onrefresh: assignedOrdersViewModel.fetchOrders,
                      ),
                      // noScrollPhysics: true,
                      emptyWidget: VStack(
                        [
                          EmptyOrder(
                            title: "Assigned Orders".tr(),
                          ),
                        ],
                      ),
                      itemBuilder: (context, index) {
                        final onGoingOrderLength = assignedOrdersViewModel.onGoingOrder.length;
                        final order = index < onGoingOrderLength ?  assignedOrdersViewModel.onGoingOrder[index] : assignedOrdersViewModel.doneOrder[index - onGoingOrderLength];
                        if (order.receiveBehalfOrder != null) {
                          return ReceiveBehalfListItem(
                            order: order,
                            orderPressed: () =>
                                assignedOrdersViewModel.handleOrderClick(order),
                          );
                        }
                        return OrderListItem(
                          order: order,
                          onLongPressed: () =>
                              assignedOrdersViewModel.openOrderDetails(order),
                          orderPressed: () =>
                              assignedOrdersViewModel.handleOrderClick(order),
                        );
                      },
                    ).expand(),
                  ],
                ).px20(),
                Positioned(
                    child: StreamBuilder<Widget?>(
                  stream: assignedOrdersViewModel.taxiViewModel.uiStream.stream,
                  builder: (ctx, snapshot) {
                    print("Build snapshot: ${snapshot.hasData}");
                    if (!snapshot.hasData || snapshot.data == null) {
                      return SizedBox.shrink();
                    }
                    return snapshot.data!;
                  },
                ))
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
