import 'package:flutter/material.dart';
import 'package:sod_user/extensions/string.dart';
import 'package:sod_user/models/product.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/widgets/cards/custom.visibility.dart';
import 'package:sod_user/widgets/currency_hstack.dart';
import 'package:sod_user/widgets/custom_image.view.dart';
import 'package:sod_user/widgets/tags/product_tags.dart';
import 'package:velocity_x/velocity_x.dart';

class FoodHorizontalProductListItem extends StatelessWidget {
  //
  const FoodHorizontalProductListItem(
    this.product, {
    this.onPressed,
    required this.qtyUpdated,
    this.height,
    Key? key,
  }) : super(key: key);

  //
  final Product product;
  final Function(Product)? onPressed;
  final Function(Product, int)? qtyUpdated;
  final double? height;
  @override
  Widget build(BuildContext context) {
    //
    final currencySymbol = AppStrings.currencySymbol;

    //
    Widget widget = HStack(
      [
        //
        CustomImage(
          imageUrl: product.photo,
          width: height != null ? (height! / 1.6) : height,
          height: MediaQuery.of(context).size.height / 5, //height,
        ).box.clip(Clip.antiAlias).roundedSM.make(),

        //Details
        VStack(
          [
            //name
            product.name.text.xl.semiBold
                .maxLines(1)
                .overflow(TextOverflow.ellipsis)
                .make(),
            //description
            //hide this if there is an overflow

            "${product.vendor.name}"
                .text
                .lg
                .light
                .gray600
                .maxLines(1)
                .ellipsis
                .make(),
            Divider(),
            //price
            Wrap(
              children: [
                //price
                CurrencyHStack(
                  [
                    currencySymbol.text.sm.make(),
                    (product.showDiscount
                            ? product.discountPrice.currencyValueFormat()
                            : product.price.currencyValueFormat())
                        .text
                        .lg
                        .semiBold
                        .make(),
                  ],
                  crossAlignment: CrossAxisAlignment.end,
                ),
                5.widthBox,
                //discount price
                CustomVisibilty(
                  visible: product.showDiscount,
                  child: CurrencyHStack(
                    [
                      currencySymbol.text.lineThrough.xs.make(),
                      product.price
                          .currencyValueFormat()
                          .text
                          .lineThrough
                          .lg
                          .medium
                          .make(),
                    ],
                  ),
                ),
              ],
            ),
            //Tag
            ProductTags(product),
          ],
        ).px8().expand(),
      ],
    ).onInkTap(
      onPressed == null ? null : () => onPressed!(product),
    );

    //height set
    // if (height != null) {
    //   widget = widget.h(height!);
    // }

    //
    return widget
        .h(MediaQuery.of(context).size.height / 5)
        .box
        //.height(MediaQuery.of(context).size.height / 5)
        // .p4
        .roundedSM
        .color(context.cardColor)
        .outerShadow
        .makeCentered()
        .p8();
  }
}
