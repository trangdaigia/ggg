import 'package:flutter/material.dart';
import 'package:sod_vendor/constants/app_colors.dart';
import 'package:sod_vendor/constants/app_text_styles.dart';
import 'package:sod_vendor/utils/ui_spacer.dart';
import 'package:sod_vendor/view_models/orders.vm.dart';
import 'package:sod_vendor/widgets/base.page.dart';
import 'package:sod_vendor/widgets/custom_list_view.dart';
import 'package:sod_vendor/widgets/list_items/order.list_item.dart';
import 'package:sod_vendor/widgets/list_items/unpaid_order.list_item.dart';
import 'package:sod_vendor/widgets/states/error.state.dart';
import 'package:sod_vendor/widgets/states/order.empty.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage>
    with AutomaticKeepAliveClientMixin<OrdersPage>, TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: ViewModelBuilder<OrdersViewModel>.reactive(
        viewModelBuilder: () => OrdersViewModel(context),
        onViewModelReady: (vm) {
          vm.initialise();
          vm.initTabController(vsync: this);
        },
        builder: (context, vm, child) {
          return BasePage(
            showAppBar: true,
            isLoading: vm.isUpdating,
            title: "Orders".tr(),
            body: VStack(
              [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: DefaultTabController(
                    length: vm.statuses.length,
                    child: Column(
                      children: [
                        TabBar(
                            onTap: vm.onPageChanged,
                            controller: vm.tabController,
                            isScrollable: true,
                            labelColor: AppColor.primaryColor,
                            unselectedLabelColor: AppColor.cancelledColor,
                            labelStyle: AppTextStyle.h5TitleTextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                            tabs: vm.statuses
                                .map((e) =>
                                    Tab(text: e.toLowerCase().tr().capitalized))
                                .toList()),
                        Expanded(
                          child: PageView.builder(
                            controller: vm.pageController,
                            itemCount: vm.statuses.length,
                            itemBuilder: (context, index) {
                              final status = vm.statuses[index];
                              return Padding(
                                padding: EdgeInsets.only(bottom: 180),
                                child: customlistview(vm, status),
                              );
                            },
                            onPageChanged: vm.onPageChanged,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ).scrollVertical(),
          );
        },
      ),
    );
  }

  //Tách widget hiện thị theo loại
  CustomListView customlistview(OrdersViewModel vm, String status) {
    return CustomListView(
      key: ValueKey(status),
      canRefresh: true,
      canPullUp: vm.orders[status]!.length >= 15,
      refreshController: vm.refreshControllers[status]!,
      onRefresh: vm.onRefresh, // tải lại từ đầu (kéo từ trên xuông)
      onLoading: vm.onLoading, // tải thêm (kéo từ dưới lên)
      isLoading: vm.isBusy,
      dataSet: vm.orders[status]!,
      hasError: vm.hasError,
      errorWidget: LoadingError(
        onrefresh: vm.onRefresh,
      ),
      //
      emptyWidget: EmptyOrder(),
      separatorBuilder: (context, index) => UiSpacer.verticalSpace(space: 5),
      itemBuilder: (context, index) {
        //
        final order = vm.orders[status]![index];
        if (order.isUnpaid) {
          return UnPaidOrderListItem(key: ValueKey(order.id), order: order);
        }
        return OrderListItem(
          key: ValueKey(order.id),
          order: order,
          orderPressed: () => vm.openOrderDetails(order),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
