import 'package:flutter/material.dart';
import 'package:sod_user/driver_lib/extensions/dynamic.dart';
import 'package:sod_user/driver_lib/models/order_product.dart';
import 'package:sod_user/driver_lib/constants/app_strings.dart';
import 'package:sod_user/driver_lib/utils/ui_spacer.dart';
import 'package:sod_user/driver_lib/widgets/custom_image.view.dart';
import 'package:velocity_x/velocity_x.dart';

class OrderProductListItem extends StatelessWidget {
  const OrderProductListItem({
    required this.orderProduct,
    Key? key,
  }) : super(key: key);

  final OrderProduct orderProduct;
  @override
  Widget build(BuildContext context) {
    return HStack(
      [
        //vendor image
        CustomImage(
          imageUrl: orderProduct.product?.photo ?? "",
          width: context.percentWidth * 20,
          boxFit: BoxFit.cover,
          height: context.percentHeight * 12,
        ),

        //
        VStack(
          [
            //
            "${orderProduct.product?.name}".text.xl.medium.make(),
            orderProduct.options != null
                ? "${orderProduct.options}".text.sm.gray500.medium.make()
                : UiSpacer.emptySpace(),
            "${AppStrings.currencySymbol}${orderProduct.price}"
                .currencyFormat()
                .text
                .lg
                .make(),
          ],
        ).p12().expand(),

        //qty
        "x ${orderProduct.quantity}".text.xl.medium.make().px12(),
      ],
    ).card.elevation(1).clip(Clip.antiAlias).roundedSM.make();
  }
}
