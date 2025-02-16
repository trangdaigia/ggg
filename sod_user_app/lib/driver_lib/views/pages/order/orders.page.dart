import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/driver_lib/utils/ui_spacer.dart';
import 'package:sod_user/driver_lib/view_models/orders.vm.dart';
import 'package:sod_user/driver_lib/views/pages/receive_behalf/receive_behalf.page.dart';
import 'package:sod_user/driver_lib/widgets/base.page.dart';
import 'package:sod_user/driver_lib/widgets/custom_list_view.dart';
import 'package:sod_user/driver_lib/widgets/list_items/order.list_item.dart';
import 'package:sod_user/driver_lib/widgets/list_items/receive_behalf_order.list.item.dart';
import 'package:sod_user/driver_lib/widgets/list_items/taxi_order.list_item.dart';
import 'package:sod_user/driver_lib/widgets/list_items/unpaid_order.list_item.dart';
import 'package:sod_user/driver_lib/widgets/states/error.state.dart';
import 'package:sod_user/driver_lib/widgets/states/order.empty.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage>
    with AutomaticKeepAliveClientMixin<OrdersPage>, WidgetsBindingObserver {
  //
  late OrdersViewModel vm;
  bool isShowBtnReceiveBehalf = true;

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
    isShowBtnReceiveBehalf = vm.checkVendorHasSlug("receive behalf");
    super.build(context);
    return BasePage(
      title: "Orders".tr(),
      showAppBar: true,
      actions: isShowBtnReceiveBehalf
          ? [
              Padding(
                padding: const EdgeInsets.all(8),
                child: GestureDetector(
                  onTap: () {
                    context.nextPage(ReceiveBehalfPage());
                    // controller.packageDetailsBottomSheet(context);
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: Row(
                      children: [
                        Text('Receive Behalf'.tr()),
                        const SizedBox(width: 4),
                        Icon(Icons.add),
                        const SizedBox(width: 12),
                      ],
                    ),
                  ),
                ),
              )
            ]
          : [],
      showLeadingAction: true,
      backgroundColor: Colors.grey.shade200,
      body: ViewModelBuilder<OrdersViewModel>.reactive(
        viewModelBuilder: () => vm,
        onViewModelReady: (vm) => vm.initialise(),
        builder: (context, vm, child) {
          return CustomListView(
            canRefresh: true,
            canPullUp: true,
            refreshController: vm.refreshController,
            onRefresh: vm.fetchMyOrders,
            onLoading: () => vm.fetchMyOrders(initialLoading: false),
            isLoading: vm.isBusy,
            dataSet: vm.orders,
            padding: EdgeInsets.all(20),
            // hasError: vm.hasError,
            // errorWidget: LoadingError(
            //   onrefresh: vm.fetchMyOrders,
            // ),

            emptyWidget: EmptyOrder(),
            itemBuilder: (context, index) {
              //
              final order = vm.orders[index];
              //for taxi tye of order
              if (order.receiveBehalfOrder != null) {
                return ReceiveBehalfListItem(
                  order: order,
                  orderPressed: () => vm.openOrderDetails(order),
                );
              }
              if (order.taxiOrder != null) {
                return TaxiOrderListItem(
                  order: order,
                  orderPressed: () => vm.openOrderDetails(order),
                );
              } else if (order.isUnpaid == {order.status == "cancelled".tr()}) {
                return UnPaidOrderListItem(order: order);
              }
              return OrderListItem(
                order: order,
                orderPressed: () => vm.openOrderDetails(order),
              );
            },
            separatorBuilder: (context, index) => UiSpacer.vSpace(10),
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
