import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/extensions/string.dart';
import 'package:sod_user/models/product.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/utils/utils.dart';
import 'package:sod_user/widgets/currency_hstack.dart';
import 'package:sod_user/widgets/custom_image.view.dart';
import 'package:sod_user/widgets/states/product_stock.dart';
import 'package:velocity_x/velocity_x.dart';

class GridViewProductListItem extends StatelessWidget {
  const GridViewProductListItem({
    required this.product,
    required this.onPressed,
    required this.qtyUpdated,
    this.showStepper = false,
    Key? key,
  }) : super(key: key);

  final Function(Product) onPressed;
  final Function(Product, int) qtyUpdated;
  final Product product;
  final bool showStepper;
  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        //
        //product image
        Stack(
          children: [
            //
            Hero(
              tag: product.heroTag ?? product.id,
              child: CustomImage(
                imageUrl: product.photo,
                boxFit: BoxFit.contain,
                width: double.infinity,
                height: Vx.dp64 * 1.2,
              ),
            ),
            //
            //price tag
            Positioned(
              left: !Utils.isArabic ? 10 : null,
              right: !Utils.isArabic ? null : 10,
              child: Visibility(
                visible: product.showDiscount,
                child: VxBox(
                  child: "-${product.discountPercentage}%"
                      .text
                      .xs
                      .semiBold
                      .white
                      .make(),
                )
                    .p4
                    .bottomRounded(value: 5)
                    .color(AppColor.primaryColor)
                    .make(),
              ),
            ),
          ],
        ),

        //
        VStack(
          [
            product.name.text.xl.semiBold
                .minFontSize(10)
                .maxLines(1)
                .overflow(TextOverflow.ellipsis)
                .make(),
            product.vendor.name.text.lg
                .maxLines(1)
                .overflow(TextOverflow.ellipsis)
                .make(),
            Divider(),
            //
            HStack(
              [
                //price
                CurrencyHStack(
                  [
                    AppStrings.currencySymbol.text.xs.make(),
                    " ".text.make(),
                    product.sellPrice
                        .currencyValueFormat()
                        .text
                        .lg
                        .semiBold
                        .make(),
                  ],
                ), //.expand(),
                //plus/min icon here
                showStepper
                    ? ProductStockState(product, qtyUpdated: qtyUpdated)
                    : UiSpacer.emptySpace(),
              ],
            ),
          ],
        ).p8(),
      ],
    )
        .material()
        .box
        .withRounded(value: 1)
        .color(context.theme.colorScheme.background)
        .clip(Clip.antiAlias)
        .outerShadow
        .makeCentered()
        .onInkTap(
          () => this.onPressed(this.product),
        );
  }
}
