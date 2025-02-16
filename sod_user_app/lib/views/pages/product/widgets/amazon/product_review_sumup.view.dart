import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/extensions/dynamic.dart';
import 'package:sod_user/models/product.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:intl/intl.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class ProductReviewSumupView extends StatelessWidget {
  const ProductReviewSumupView(this.product, {Key? key}) : super(key: key);
  final Product product;

  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        //review summary
        "Customer reviews".tr().text.extraBold.xl2.make(),
        UiSpacer.vSpace(12),
        product.reviewsCount == 0
            ? "This product has not been reviewed yet"
                .tr()
                .text
                .color(AppColor.primaryColor)
                .make()
            : HStack(
                [
                  VxRating(
                    size: 20,
                    maxRating: 5.0,
                    value: product.rating ?? 0.0,
                    isSelectable: false,
                    onRatingUpdate: (value) {},
                    selectionColor: AppColor.ratingColor,
                  ),
                  UiSpacer.hSpace(10),
                  "%s on %s"
                      .tr()
                      .fill([
                        double.parse(
                            (product.rating ?? 0).toStringAsExponential(1)),
                        5
                      ])
                      .text
                      .color(AppColor.primaryColor)
                      .make(),
                ],
              ),
        UiSpacer.vSpace(8),
        "%s total rating"
            .tr()
            .fill([NumberFormat('#,###').format(product.reviewsCount)])
            .text
            .color(AppColor.primaryColor)
            .make(),
      ],
    );
  }
}
