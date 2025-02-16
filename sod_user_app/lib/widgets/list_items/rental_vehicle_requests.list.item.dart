import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/extensions/dynamic.dart';
import 'package:sod_user/models/order.dart';
import 'package:sod_user/constants/app_strings.dart';

import 'package:jiffy/jiffy.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class RentalVehicleRequestsListItem extends StatelessWidget {
  const RentalVehicleRequestsListItem({
    required this.order,
    required this.onPayPressed,
    required this.orderPressed,
    Key? key,
  }) : super(key: key);

  final Order order;
  final Function onPayPressed;
  final Function orderPressed;
  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        HStack(
          [
            //
            VStack(
              [
                //
                HStack(
                  [
                    "#${order.code}".text.medium.make().expand(),
                    "${AppStrings.currencySymbol} ${order.total}"
                        .currencyFormat()
                        .text
                        .lg
                        .semiBold
                        .make(),
                  ],
                ),
                Divider(height: 4),
                //
                HStack([
                  "Rental vehicle order".tr().text.lg.make().py(4).expand(),
                  "${order.rentalVehicleRequests!.status!.toLowerCase() == 'in progress' && order.rentalVehicleRequests!.deposit! == false ? 'Waiting for deposit'.tr() : order.rentalVehicleRequests!.status!.tr()}"
                     .capitalized
                      .text
                      .medium
                      .make(),
                ]),
                //amount
                HStack(
                  [
                    "${order.paymentStatus}"
                        .tr()
                        .capitalized
                        .text
                        .color(AppColor.getStausColor(order.status))
                        .medium
                        .make(),
                  ],
                ),
                //time & status
                HStack(
                  [
                    //time
                    Visibility(
                      visible: order.paymentMethod != null,
                      child: "${order.paymentMethod?.name}".text.medium.make(),
                    ).expand(),
                    VxTextBuilder(Jiffy(order.createdAt).format('dd E, MMM y'))
                        .sm
                        .make(),
                    //EEEE dd MMM yyyy
                  ],
                ),
              ],
            ).p12().expand(),
          ],
        ),
      ],
    )
        .box
        .border(color: Colors.grey.shade200)
        .make()
        .card
        .elevation(0.5)
        .clip(Clip.antiAlias)
        .roundedSM
        .make()
        .onInkTap(() => orderPressed());
  }
}
