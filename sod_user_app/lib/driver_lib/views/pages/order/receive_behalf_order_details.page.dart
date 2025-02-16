import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_user/driver_lib/constants/app_colors.dart';
import 'package:sod_user/driver_lib/constants/app_ui_settings.dart';
import 'package:sod_user/driver_lib/models/order.dart';
import 'package:sod_user/driver_lib/utils/ui_spacer.dart';
import 'package:sod_user/driver_lib/view_models/order_details.vm.dart';
import 'package:sod_user/driver_lib/views/pages/order/widgets/order_customer_info.view.dart';
import 'package:sod_user/driver_lib/views/pages/order/widgets/order_payment_info.view.dart';
import 'package:sod_user/driver_lib/views/pages/order/widgets/receive_behalf_order_box.view.dart';
import 'package:sod_user/driver_lib/widgets/base.page.dart';
import 'package:sod_user/driver_lib/widgets/busy_indicator.dart';
import 'package:sod_user/driver_lib/widgets/buttons/custom_button.dart';
import 'package:sod_user/driver_lib/widgets/cards/receive_behalf_order_details_summary.dart';
import 'package:jiffy/jiffy.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class ReceiveBehalfOrderDetailsPage extends StatelessWidget {
  const ReceiveBehalfOrderDetailsPage({
    required this.order,
    Key? key,
  }) : super(key: key);

  final Order order;

  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
      body: ViewModelBuilder<OrderDetailsViewModel>.reactive(
        viewModelBuilder: () => OrderDetailsViewModel(context, order),
        onViewModelReady: (vm) => vm.initialise(),
        builder: (context, vm, child) {
          return BasePage(
            title: "Receive Behalf Order Details".tr(),
            showAppBar: true,
            showLeadingAction: true,
            isLoading: vm.isBusy,
            onBackPressed: () {
              Navigator.pop(context, vm.order);
            },
            //share button for parcel delivery order
            body: vm.isBusy
                ? BusyIndicator().centered()
                : SmartRefresher(
                    controller: vm.refreshController,
                    onRefresh: vm.fetchOrderDetails,
                    child: Stack(
                      children: [
                        //
                        VStack(
                          [
                            // UiSpacer.verticalSpace(space: 160),
                            VStack(
                              [
                                //free space
                                //header view
                                UiSpacer.horizontalSpace(),
                                //
                                VStack(
                                  [
                                    //
                                    "${vm.order.status.tr().capitalized}"
                                        .text
                                        .semiBold
                                        .xl
                                        .color(AppColor.getStausColor(
                                            vm.order.status))
                                        .make(),
                                    "${Jiffy(vm.order.updatedAt).format('MMM dd, yyyy \| HH:mm')}"
                                        .text
                                        .light
                                        .lg
                                        .make(),
                                    "#${vm.order.code}"
                                        .text
                                        .xs
                                        .gray400
                                        .light
                                        .make(),
                                  ],
                                ).p20().wFull(context),
                                //
                                //Payment status
                                OrderPaymentInfoView(vm).p20(),
                                //show package delivery addresses
                                // show order box
                                Visibility(
                                    visible: vm.order.receiveBehalfOrder?.box !=
                                        null,
                                    child: ReceiveBehalfOrderBoxView(vm).p20()),
                                //receive behalf images
                                VStack(
                                  [
                                    "Package images"
                                        .tr()
                                        .text
                                        .gray500
                                        .medium
                                        .sm
                                        .make(),
                                    UiSpacer.vSpace(10),
                                    CarouselSlider(
                                      items: vm.order.attachments!
                                          .map(
                                            (element) => ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.network(
                                                  element.link!,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity),
                                            ),
                                          )
                                          .toList(),
                                      options: CarouselOptions(
                                          autoPlay: true, viewportFraction: 1),
                                    ),
                                  ],
                                ).px20(),
                                if (vm.order.receiveBehalfOrder!.photos!
                                    .isNotEmpty) ...[
                                  UiSpacer.vSpace(20),
                                  VStack(
                                    [
                                      "Confirm Package images"
                                          .tr()
                                          .text
                                          .gray500
                                          .medium
                                          .sm
                                          .make(),
                                      UiSpacer.vSpace(10),
                                      CarouselSlider(
                                        items: vm
                                            .order.receiveBehalfOrder!.photos!
                                            .map(
                                              (element) => ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.network(element,
                                                    fit: BoxFit.cover,
                                                    width: double.infinity),
                                              ),
                                            )
                                            .toList(),
                                        options: CarouselOptions(
                                            autoPlay: true,
                                            viewportFraction: 1),
                                      ),
                                    ],
                                  ).px20(),
                                ],
                                //customer
                                UiSpacer.vSpace(20),
                                HStack(
                                  crossAlignment: CrossAxisAlignment.start,
                                  [
                                    //
                                    VStack(
                                      [
                                        "Customer"
                                            .tr()
                                            .text
                                            .gray500
                                            .medium
                                            .sm
                                            .make(),
                                        vm.order.user.name.text.medium.xl
                                            .make(),
                                        vm.order.user.rawPhone!.text.medium
                                            .medium
                                            .make()
                                            .pOnly(bottom: Vx.dp20),
                                      ],
                                    ).pOnly(left: Vx.dp20).expand(),
                                    //call
                                    if (vm.order.canChatCustomer &&
                                        AppUISettings.canCallCustomer &&
                                        !vm.order.status.contains("completed"))
                                      CustomButton(
                                        icon: FlutterIcons.phone_call_fea,
                                        iconColor: Colors.white,
                                        color: AppColor.primaryColor,
                                        shapeRadius: Vx.dp20,
                                        onPressed: vm.callCustomer,
                                      )
                                          .wh(Vx.dp64, Vx.dp40)
                                          .pOnly(right: Vx.dp20),
                                  ],
                                ),
                                if (vm.order.canChatCustomer &&
                                    !vm.order.status.contains("completed")) ...[
                                  Visibility(
                                    visible: AppUISettings.canCustomerChat,
                                    child: CustomButton(
                                      icon: FlutterIcons.chat_ent,
                                      iconColor: Colors.white,
                                      title: "Chat with customer".tr(),
                                      color: AppColor.primaryColor,
                                      onPressed: vm.chatCustomer,
                                    )
                                        .h(Vx.dp48)
                                        .pSymmetric(h: Vx.dp20, v: Vx.dp10),
                                  ),
                                ],
                                if (vm.order.receiveBehalfOrder!.complaint !=
                                    null) ...[
                                  VStack(
                                    [
                                      "Complaint"
                                          .tr()
                                          .text
                                          .gray500
                                          .medium
                                          .sm
                                          .make(),
                                      "${vm.order.receiveBehalfOrder!.complaint}"
                                          .text
                                          .medium
                                          .xl
                                          .make(),
                                    ],
                                  ).px20().pOnly(bottom: Vx.dp20),
                                ],
                                UiSpacer.divider(),
                                //order summary
                                ReceiveBehalfOrderDetailsSummary(vm.order)
                                    .wFull(context)
                                    .p20()
                                    .pOnly(bottom: context.percentHeight * 10)
                                    .box
                                    .make()
                              ],
                            )
                                .box
                                .topRounded(value: 15)
                                .clip(Clip.antiAlias)
                                .color(context.theme.colorScheme.background)
                                .make(),
                            //
                            UiSpacer.vSpace(50),
                          ],
                        ).scrollVertical(),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }
}
