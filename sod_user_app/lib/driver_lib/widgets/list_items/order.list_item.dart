import 'package:flutter/material.dart';
import 'package:sod_user/driver_lib/constants/app_colors.dart';
import 'package:sod_user/driver_lib/extensions/dynamic.dart';
import 'package:sod_user/driver_lib/models/order.dart';
import 'package:sod_user/driver_lib/constants/app_strings.dart';
import 'package:sod_user/driver_lib/widgets/custom_image.view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class OrderListItem extends StatelessWidget {
  const OrderListItem({
    required this.order,
    this.onPayPressed,
    required this.orderPressed,
    Key? key,
    this.onLongPressed,
  }) : super(key: key);

  final Order order;
  final Function? onPayPressed;
  final Function orderPressed;
  final Function? onLongPressed;
  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        HStack(
          [
            //vendor image
            CustomImage(
              imageUrl: order.vendor?.featureImage ?? order.photo!,
              width: context.percentWidth * 20,
              boxFit: BoxFit.cover,
              height: context.percentHeight * 12,
            ).cornerRadius(5),

            //
            VStack(
              [
                //
                "#${order.code}".text.xl.medium.make(),
                //amount and total products
                HStack(
                  [
                    (order.isPackageDelivery
                            ? "${order.packageType?.name}"
                            : "%s Product(s)"
                                .tr()
                                .fill([order.orderProducts?.length]))
                        .text
                        .medium
                        .make()
                        .expand(),
                    "${AppStrings.currencySymbol} ${(order.total ?? 0) + (order.tip ?? 0)}"
                        .currencyFormat()
                        .text
                        .xl
                        .semiBold
                        .make(),
                  ],
                ),
                //time & status
                HStack(
                  [
                    //time
                    order.formattedDate.text.sm.make().expand(),
                    "${order.status.tr().capitalized}"
                        .text
                        .lg
                        .color(
                          AppColor.getStausColor(order.status),
                        )
                        .medium
                        .make(),
                  ],
                ),
              ],
            ).px12().expand(),
          ],
        ),
      ],
    )
        .onInkTap(() => orderPressed())
        .onInkLongPress(() {
          if (onLongPressed != null) onLongPressed!();
        })
        .card
        .elevation(0.5)
        .clip(Clip.antiAlias)
        .roundedSM
        .make();
  }
}
