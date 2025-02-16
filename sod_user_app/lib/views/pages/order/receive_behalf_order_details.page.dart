import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/models/order.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/view_models/order_details.vm.dart';
import 'package:sod_user/views/pages/order/widgets/order.bottomsheet.dart';
import 'package:sod_user/views/pages/order/widgets/order_address.view.dart';
import 'package:sod_user/views/pages/order/widgets/order_details_driver_info.view.dart';
import 'package:sod_user/views/pages/order/widgets/order_payment_info.view.dart';
import 'package:sod_user/views/pages/order/widgets/receive_behalf_order_box.view.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/widgets/busy_indicator.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:sod_user/widgets/cards/custom.visibility.dart';
import 'package:sod_user/widgets/cards/receive_behalf_order_details_summary.dart';
import 'package:jiffy/jiffy.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class ReceiveBehalfOrderDetailsPage extends StatelessWidget {
  const ReceiveBehalfOrderDetailsPage({
    required this.order,
    this.isOrderTracking = false,
    Key? key,
  }) : super(key: key);

  final Order order;
  final bool isOrderTracking;

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
                                HStack(
                                  [
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
                                    ).expand(),
                                    //qr code icon
                                    Visibility(
                                      visible: !vm.order.isTaxi &&
                                          !vm.order.isSerice,
                                      child: Icon(
                                        FlutterIcons.qrcode_ant,
                                        size: 28,
                                      ).onInkTap(vm.showVerificationQRCode),
                                    ),
                                  ],
                                ).p20().wFull(context),
                                //
                                UiSpacer.cutDivider(),
                                //Payment status
                                OrderPaymentInfoView(vm),
                                CustomVisibilty(
                                  visible:
                                      vm.order.paymentStatus == "successful" &&
                                          !vm.order.isCompleted,
                                  child: CustomButton(
                                    title: "Complete receive behalf order".tr(),
                                    titleStyle:
                                        context.textTheme.bodyLarge!.copyWith(
                                      color: Colors.white,
                                    ),
                                    icon: FlutterIcons.verified_oct,
                                    iconSize: 18,
                                    loading: vm.busy(vm.order),
                                    onPressed: () =>
                                        vm.openImagePickerBottomSheet(context),
                                  ).p20().pOnly(bottom: Vx.dp20),
                                ),
                                CustomVisibilty(
                                  visible: vm.order.paymentStatus ==
                                          "successful" &&
                                      vm.order.isCompleted &&
                                      vm.order.receiveBehalfOrder!.complaint !=
                                          null,
                                  child: CustomButton(
                                    title: "Add complaint".tr(),
                                    titleStyle:
                                        context.textTheme.bodyLarge!.copyWith(
                                      color: Colors.white,
                                    ),
                                    icon: Icons.feedback,
                                    iconSize: 18,
                                    loading: vm.busy(vm.order),
                                    onPressed: () => vm.addComplaintDialog(),
                                  ).p20().pOnly(bottom: Vx.dp20),
                                ),
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
                                //driver
                                UiSpacer.vSpace(20),
                                OrderDetailsDriverInfoView(vm),
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
                                .color(context.theme.colorScheme.surface)
                                .make(),
                            //
                            UiSpacer.vSpace(50),
                          ],
                        ).scrollVertical(),
                      ],
                    ),
                  ),
            bottomSheet: isOrderTracking ? null : OrderBottomSheet(vm),
          );
        },
      ),
    );
  }
}
