import 'package:flutter/material.dart';
import 'package:sod_vendor/constants/app_text_styles.dart';
import 'package:sod_vendor/extensions/dynamic.dart';
import 'package:sod_vendor/models/order_product.dart';
import 'package:sod_vendor/constants/app_strings.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../constants/app_colors.dart';

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
        //qty
        "${orderProduct.quantity}x"
            .text
            .textStyle(
                AppTextStyle.h5TitleTextStyle(fontWeight: FontWeight.w600))
            .make(),
        VStack(
          [
            //Chỉnh style chữ
            "${orderProduct.product?.name}"
                .text
                .textStyle(AppTextStyle.h5TitleTextStyle(
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).textTheme.bodyLarge!.color))
                .make(),
            Visibility(
              visible: orderProduct.options != null &&
                  orderProduct.options!.isNotEmpty,
              child:
                  "${orderProduct.options ?? ''}".text.sm.gray500.medium.make(),
            ),
          ],
        ).px12().expand(),
        "${AppStrings.currencySymbol}${orderProduct.price}"
            .currencyFormat()
            .text
            .textStyle(AppTextStyle.h6TitleTextStyle(
                color: AppColor.cancelledColor, fontWeight: FontWeight.w400))
            .make(),
        //
      ],
    );
  }
}
