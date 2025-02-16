import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/view_models/orders.vm.dart';
import 'package:sod_user/view_models/welcome.vm.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/widgets/contained_tab_bar_view_custom/src/contained_tab_bar_view.dart';
import 'package:sod_user/widgets/custom_list_view.dart';
import 'package:sod_user/widgets/list_items/taxi_order.list_item.dart';
import 'package:sod_user/widgets/list_items/taxi_ship_package_type.list_item.dart';
import 'package:sod_user/widgets/states/error.state.dart';
import 'package:sod_user/widgets/states/order.empty.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../services/order.service.dart';
import '../../../widgets/list_items/order.list_item.dart';

class ActivityHistoryPage extends StatefulWidget {
  ActivityHistoryPage({super.key});

  @override
  State<ActivityHistoryPage> createState() => _ActivityHistoryPageState();
}

class _ActivityHistoryPageState extends State<ActivityHistoryPage> {
  @override
  int lengthTab = 5;
  Widget build(BuildContext context) {
    return ViewModelBuilder<WelcomeViewModel>.reactive(
      viewModelBuilder: () => WelcomeViewModel(context),
      onViewModelReady: (vmWC) => vmWC.initialise(),
      disposeViewModel: false,
      builder: (context, vmWC, child) {
        return ViewModelBuilder<OrdersViewModel>.reactive(
            viewModelBuilder: () => OrdersViewModel(context),
            onViewModelReady: (vm) => vm.initialise(),
            disposeViewModel: false,
            builder: (context, vm, child) {
              return BasePage(
                showAppBar: true,
                showLeadingAction: true,
                title: 'Activity history'.tr(),
                appBarColor: context.theme.colorScheme.background,
                backgroundColor: AppColor.onboarding3Color,
                body: SafeArea(
                  child: VStack([
                    TabBarPropertiesCustom(
                      callOnChangeWhileIndexIsChanging: true,
                      length: lengthTab,
                      tabBarProperties: TabBarProperties(
                        alignment: TabBarAlignment.center,
                        isScrollable: true,
                        labelPadding: EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 0,
                        ),
                        //
                        padding: EdgeInsets.all(0),
                        labelColor: AppColor.primaryColor,
                        unselectedLabelColor: AppColor.primaryColor,
                        labelStyle: context.textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        unselectedLabelStyle:
                            context.textTheme.bodyLarge!.copyWith(),
                      ),
                      tabs: [
                        Tab(text: "All".tr()),
                        if (vmWC.checkVendorHasSlug("food")) ...[
                          Tab(text: "Food".tr()),
                        ],
                        if (vmWC.checkVendorHasSlug("taxi")) ...[
                          Tab(text: "Transport".tr())
                        ],
                        if (vmWC.checkVendorHasSlug("service")) ...[
                          Tab(text: "Service".tr()),
                        ],
                        if (vmWC.checkVendorHasSlug("shipping")) ...[
                          Tab(text: "Delivery".tr()),
                        ]
                      ],
                      views: [
                        //Danh sách tất cả lịch sử hoạt động theo thời gian
                        CustomListView(
                          canRefresh: true,
                          canPullUp: true,
                          refreshController: RefreshController(),
                          onRefresh: vm.fetchMyOrders,
                          onLoading: () =>
                              vm.fetchMyOrders(initialLoading: false),
                          isLoading: vm.isBusy,
                          dataSet: vm.orders,
                          hasError: vm.hasError,
                          errorWidget: LoadingError(
                            onrefresh: vm.fetchMyOrders,
                          ),
                          //
                          emptyWidget: EmptyOrder(),
                          itemBuilder: (context, index) {
                            //
                            final order = vm.orders[index];
                            //for taxi type of order
                            if (order.taxiOrder != null) {
                              return TaxiOrderListItem(
                                order: order,
                                orderPressed: () => vm.openOrderDetails(order),
                              );
                            } else
                              return OrderListItem(
                                order: order,
                                orderPressed: () => vm.openOrderDetails(order),
                                onPayPressed: () =>
                                    OrderService.openOrderPayment(order, vm),
                              );
                          },
                          separatorBuilder: (context, index) =>
                              UiSpacer.verticalSpace(space: 2),
                        ),
                        if (vmWC.checkVendorHasSlug("food")) ...[
                          CustomListView(
                            canRefresh: true,
                            canPullUp: true,
                            refreshController: RefreshController(),
                            onRefresh: vm.fetchMyOrders,
                            onLoading: () =>
                                vm.fetchMyOrders(initialLoading: false),
                            isLoading: vm.isBusy,
                            dataSet: vm.orders
                                .where((order) =>
                                    order != order.orderService &&
                                    order.orderProducts!.length > 0 &&
                                    order != order.isPackageDelivery)
                                .toList(),
                            hasError: vm.hasError,
                            errorWidget: LoadingError(
                              onrefresh: vm.fetchMyOrders,
                            ),
                            //
                            emptyWidget: EmptyOrder(),
                            itemBuilder: (context, index) {
                              //
                              final order = vm.orders
                                  .where((order) =>
                                      order != order.orderService &&
                                      order.orderProducts!.length > 0 &&
                                      order != order.isPackageDelivery)
                                  .toList()[index];
                              //for food type of order
                              return OrderListItem(
                                  order: order,
                                  orderPressed: () =>
                                      vm.openOrderDetails(order),
                                  onPayPressed: () =>
                                      OrderService.openOrderPayment(order, vm));
                            },
                            separatorBuilder: (context, index) =>
                                UiSpacer.verticalSpace(space: 2),
                          ),
                        ],
                        // Danh sách đơn thức ăn
                        if (vmWC.checkVendorHasSlug("taxi")) ...[
                          CustomListView(
                            canRefresh: true,
                            canPullUp: true,
                            refreshController: RefreshController(),
                            onRefresh: vm.fetchMyOrders,
                            onLoading: () =>
                                vm.fetchMyOrders(initialLoading: false),
                            isLoading: vm.isBusy,
                            dataSet: vm.orders
                                .where((order) =>
                                    order.taxiOrder != null &&
                                    order.taxiOrder?.type == "taxi" &&
                                    order != order.isPackageDelivery &&
                                    order != order.isSerice &&
                                    order.orderProducts!.isNotEmpty != 0)
                                .toList(), // còn sót các đơn giao hàng
                            hasError: vm.hasError,
                            errorWidget: LoadingError(
                              onrefresh: vm.fetchMyOrders,
                            ),
                            //
                            emptyWidget: EmptyOrder(),
                            itemBuilder: (context, index) {
                              //
                              final order = vm.orders
                                  .where((order) =>
                                      order.taxiOrder != null &&
                                      order.taxiOrder?.type == "taxi" &&
                                      order != order.isPackageDelivery &&
                                      order != order.isSerice &&
                                      order.orderProducts!.isNotEmpty != 0)
                                  .toList()[index];
                              //for taxi type of order
                              return TaxiOrderListItem(
                                order: order,
                                orderPressed: () => vm.openOrderDetails(order),
                              );
                            },
                            separatorBuilder: (context, index) =>
                                UiSpacer.verticalSpace(space: 2),
                          ),
                        ],
                        if (vmWC.checkVendorHasSlug("service")) ...[
                          // Danh sách hoạt động dịch vụ

                          CustomListView(
                            canRefresh: true,
                            canPullUp: true,
                            refreshController: RefreshController(),
                            onRefresh: vm.fetchMyOrders,
                            onLoading: () =>
                                vm.fetchMyOrders(initialLoading: false),
                            isLoading: vm.isBusy,
                            dataSet: vm.orders
                                .where((order) =>
                                    order.orderService != null &&
                                    order.orderProducts!.isNotEmpty != 0 &&
                                    order != order.isPackageDelivery)
                                .toList(),
                            hasError: vm.hasError,
                            errorWidget: LoadingError(
                              onrefresh: vm.fetchMyOrders,
                            ),
                            //
                            emptyWidget: EmptyOrder(),
                            itemBuilder: (context, index) {
                              //
                              final order = vm.orders
                                  .where((order) =>
                                      order.orderService != null &&
                                      order.orderProducts!.isNotEmpty != 0 &&
                                      order != order.isPackageDelivery)
                                  .toList()[index];
                              //for service type of order
                              return OrderListItem(
                                  order: order,
                                  orderPressed: () =>
                                      vm.openOrderDetails(order),
                                  onPayPressed: () =>
                                      OrderService.openOrderPayment(order, vm));
                            },
                            separatorBuilder: (context, index) =>
                                UiSpacer.verticalSpace(space: 2),
                          ),
                        ],
                        if (vmWC.checkVendorHasSlug("shipping")) ...[
                          CustomListView(
                            canRefresh: true,
                            canPullUp: true,
                            refreshController: RefreshController(),
                            onRefresh: vm.fetchMyOrders,
                            onLoading: () =>
                                vm.fetchMyOrders(initialLoading: false),
                            isLoading: vm.isBusy,
                            dataSet: vm.orders
                                .where((order) =>
                                    order.taxiOrder != null &&
                                    order.taxiOrder?.type == "ship" &&
                                    order != order.isPackageDelivery &&
                                    order != order.isSerice &&
                                    order.orderProducts!.isNotEmpty != 0)
                                .toList(),
                            hasError: vm.hasError,
                            errorWidget: LoadingError(
                              onrefresh: vm.fetchMyOrders,
                            ),
                            //
                            emptyWidget: EmptyOrder(),
                            itemBuilder: (context, index) {
                              //
                              final order = vm.orders
                                  .where((order) =>
                                      order.taxiOrder != null &&
                                      order.taxiOrder?.type == "ship" &&
                                      order != order.isPackageDelivery &&
                                      order != order.isSerice &&
                                      order.orderProducts!.isNotEmpty != 0)
                                  .toList()[index];
                              return TaxiOrderListItem(
                                order: order,
                                orderPressed: () => vm.openOrderDetails(order),
                              );
                            },
                            separatorBuilder: (context, index) =>
                                UiSpacer.verticalSpace(space: 2),
                          ),
                        ]
                      ],
                      onChange: (selectedIndex) {},
                    ).expand(),
                  ]),
                ),
              );
            });
      },
    );
  }
}
