import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_images.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/view_models/order_details.vm.dart';
import 'package:sod_user/widgets/list_items/parcel_order_stop.list_view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class OrderAddressesView extends StatelessWidget {
  const OrderAddressesView(this.vm, {Key? key}) : super(key: key);

  final OrderDetailsViewModel vm;
  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        //
        vm.order.isPackageDelivery
            ? VStack(
                [
                  //
                  ParcelOrderStopListView(
                    "Pickup Location",
                    vm.order.orderStops!.first,
                    canCall: vm.order.canChatVendor,
                  ),

                  //stops
                  ...stopsList(),
                  //
                  ParcelOrderStopListView(
                    "Dropoff Location",
                    vm.order.orderStops!.last,
                    canCall: vm.order.canChatVendor,
                  ),
                ],
              )
            : UiSpacer.emptySpace(),

        //regular delivery address

        // Visibility(
        //   visible: !vm.order.isPackageDelivery,
        //   child: VStack(
        //     [
        //       "Delivery details".tr().text.xl.semiBold.make(),
        //       //vendor address
        //       HStack(
        //         [
        //           //
        //           Image.asset(
        //             AppImages.pickupLocation,
        //             width: 15,
        //             height: 15,
        //           ),
        //           UiSpacer.smHorizontalSpace(),
        //           //
        //           "${vm.order.vendor?.address}".text.make().expand(),
        //         ],
        //         crossAlignment: CrossAxisAlignment.start,
        //       ).py12(),
        //       //delivery address
        //       Visibility(
        //         visible: vm.order.deliveryAddress != null,
        //         child: HStack(
        //           [
        //             //
        //             Image.asset(
        //               AppImages.dropoffLocation,
        //               width: 15,
        //               height: 15,
        //             ),
        //             UiSpacer.smHorizontalSpace(),
        //             //
        //             VStack(
        //               [
        //                 vm.order.deliveryAddress != null
        //                     ? "${vm.order.deliveryAddress!.address}".text.make()
        //                     : UiSpacer.emptySpace(),
        //                 vm.order.deliveryAddress != null
        //                     ? "${vm.order.deliveryAddress!.name}"
        //                         .text
        //                         .color(Vx.gray400)
        //                         .sm
        //                         .light
        //                         .make()
        //                     : UiSpacer.emptySpace(),
        //               ],
        //             ).expand(),
        //           ],
        //           crossAlignment: CrossAxisAlignment.start,
        //         ),
        //       ),
        //     ],
        //   ),
        // ),

        //new way to treat null delivery address when it is null
        Visibility(
          visible: !vm.order.isPackageDelivery,
          child: VStack(
            [
              "Delivery details".tr().text.xl.semiBold.make(),
              // vendor address
              HStack(
                [
                  //
                  Image.asset(
                    AppImages.pickupLocation,
                    width: 15,
                    height: 15,
                  ),
                  UiSpacer.smHorizontalSpace(),
                  //
                  VStack(
                    [
                      "Vendor Address".text.semiBold.make(),
                      "${vm.order.vendor?.address}".text.make()
                    ],
                  ).expand()
                ],
                crossAlignment: CrossAxisAlignment.start,
              ).py12(),
              // delivery address
              if (vm.order.deliveryAddress != null)
                Visibility(
                  visible: vm.order.deliveryAddress != null,
                  child: HStack(
                    [
                      //
                      Image.asset(
                        AppImages.dropoffLocation,
                        width: 15,
                        height: 15,
                      ),
                      UiSpacer.smHorizontalSpace(),
                      //
                      VStack(
                        [
                          "Delivery Address".text.semiBold.make(),
                          "${vm.order.deliveryAddress?.address}".text.make(),
                          "${vm.order.deliveryAddress?.name}"
                              .text
                              .color(Vx.gray400)
                              .sm
                              .light
                              .make(),
                        ],
                      ).expand(),
                    ],
                    crossAlignment: CrossAxisAlignment.start,
                  ),
                ),
            ],
          ),
        ),
        //else UiSpacer.emptySpace()
        ////////////////////////////////
      ],
    );
  }

  //
  List<Widget> stopsList() {
    List<Widget> stopViews = [];
    if (vm.order.orderStops != null && vm.order.orderStops!.length > 2) {
      stopViews = vm.order.orderStops!
          .sublist(1, vm.order.orderStops!.length - 1)
          .mapIndexed((stop, index) {
        return VStack(
          [
            ParcelOrderStopListView(
              "Stop".tr() + " ${index + 1}",
              stop,
              canCall: vm.order.canChatVendor,
            ),
          ],
        );
      }).toList();
    } else {
      stopViews.add(UiSpacer.emptySpace());
    }

    return stopViews;
  }
}
