import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/services/order.service.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/view_models/orders.vm.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/widgets/custom_list_view.dart';
import 'package:sod_user/widgets/list_items/order.list_item.dart';
import 'package:sod_user/widgets/list_items/receive_behalf_order.list.item.dart';
import 'package:sod_user/widgets/list_items/rental_vehicle_requests.list.item.dart';
import 'package:sod_user/widgets/list_items/taxi_order.list_item.dart';
import 'package:sod_user/widgets/states/empty.state.dart';
import 'package:sod_user/widgets/states/error.state.dart';
import 'package:sod_user/widgets/states/order.empty.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with AutomaticKeepAliveClientMixin<OrdersPage>, WidgetsBindingObserver {
  //
  late OrdersViewModel vm;
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
      vm.fetchMyOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    vm = OrdersViewModel(context);
    super.build(context);
    return BasePage(
      showAppBar: true,
      title: 'Activity'.tr(),
      actions: [
        vm.isAuthenticated()
            ? TextButton.icon(
                onPressed: () => vm.openHistoryOrder(),
                icon: Icon(Icons.history),
                label: Text('History'.tr()),
              )
            : Text("")
      ],
      appBarColor: context.theme.colorScheme.background,
      backgroundColor: AppColor.onboarding3Color,
      body: SafeArea(
        child: ViewModelBuilder<OrdersViewModel>.reactive(
          viewModelBuilder: () => vm,
          onViewModelReady: (vm) => vm.initialise(),
          builder: (context, vm, child) {
            return VStack(
              [
                //
                vm.isAuthenticated()
                    ? CustomListView(
                        canRefresh: true,
                        canPullUp: true,
                        refreshController: vm.refreshController,
                        onRefresh: vm.fetchMyOrders,
                        onLoading: () => vm.fetchMyOrders(initialLoading: false),
                        isLoading: vm.isBusy,
                        dataSet: vm.orders.take(10).toList(),
                        hasError: vm.hasError,
                        errorWidget: LoadingError(
                          onrefresh: vm.fetchMyOrders,
                        ),
                        //
                        emptyWidget: EmptyOrder(),
                        itemBuilder: (context, index) {
                          //
                          final order = vm.orders.take(10).toList()[index];
                          //for taxi tye of order
                          if (order.taxiOrder != null) {
                            return TaxiOrderListItem(
                              order: order,
                              orderPressed: () => vm.openOrderDetails(order),
                            );
                          }
                          if (order.receiveBehalfOrder != null) {
                            return ReceiveBehalfListItem(
                              order: order,
                              orderPressed: () => vm.openOrderDetails(order),
                              onPayPressed: () => OrderService.openOrderPayment(order, vm),
                            );
                          }
                          if(order.rentalVehicleRequests != null){
                             return RentalVehicleRequestsListItem(
                              order: order,
                              orderPressed: () => vm.openOrderDetails(order),
                              onPayPressed: () => OrderService.openOrderPayment(order, vm),
                            );
                          }
                          return OrderListItem(
                            order: order,
                            orderPressed: () => vm.openOrderDetails(order),
                            onPayPressed: () => OrderService.openOrderPayment(order, vm),
                          );
                        },
                        separatorBuilder: (context, index) => UiSpacer.verticalSpace(space: 2),
                      ).expand()
                    : EmptyState(
                        auth: true,
                        showAction: true,
                        actionPressed: vm.openLogin,
                      ).py12().centered().expand(),
              ],
            ).pOnly(top: Vx.dp20);
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
