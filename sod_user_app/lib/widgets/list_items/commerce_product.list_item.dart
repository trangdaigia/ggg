import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/extensions/string.dart';
import 'package:sod_user/models/product.dart';
import 'package:sod_user/views/pages/product/amazon_styled_commerce_product_details.page.dart';
// import 'package:sod_user/views/pages/product/commerce_product_details.page.dart';
import 'package:sod_user/widgets/cards/custom.visibility.dart';
import 'package:sod_user/widgets/currency_hstack.dart';
import 'package:sod_user/widgets/custom_image.view.dart';
import 'package:sod_user/widgets/tags/fav.positioned.dart';
import 'package:sod_user/widgets/tags/product_tags.dart';
import 'package:velocity_x/velocity_x.dart';

class CommerceProductListItem extends StatelessWidget {
  const CommerceProductListItem(
    this.product, {
    this.height,
    this.boxFit,
    Key? key,
  }) : super(key: key);

  final Product product;
  final double? height;
  final BoxFit? boxFit;

  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        //image and fav icon
        Stack(
          children: [
            //prouct first image
            CustomImage(
              imageUrl: "${product.photo}",
              width: double.infinity,
              height: height,
              boxFit: boxFit ?? BoxFit.contain,
            ).box.slate100.withRounded(value: 5).clip(Clip.antiAlias).make(),

            //fav icon
            FavPositiedView(product),
          ],
        ),

        //details
        VStack(
          [
            //name
            "${product.name}"
                .text
                .medium
                .size(10)
                .maxLines(2)
                .minFontSize(10)
                .maxFontSize(10)
                .ellipsis
                .make()
                .pOnly(top: 10),

            // "${product.vendor.name}".text.make(),
            Divider(),
            // price
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                //price
                CurrencyHStack(
                  [
                    AppStrings.currencySymbol.text.base.semiBold.make(),
                    product.sellPrice
                        .currencyValueFormat()
                        .text
                        .base
                        .bold
                        .make(),
                  ],
                  crossAlignment: CrossAxisAlignment.end,
                ),
                //discount
                CustomVisibilty(
                  visible: product.showDiscount,
                  child: CurrencyHStack(
                    [
                      AppStrings.currencySymbol.text.lineThrough.xs.make(),
                      product.price
                          .currencyValueFormat()
                          .text
                          .lineThrough
                          .xs
                          .medium
                          .make(),
                    ],
                  ).px4(),
                ),
              ],
            ),
          ],
        ).p8(),

        //
        ProductTags(product),
      ],
    )
        .onInkTap(
          () => openProductDetailsPage(context, product),
        )
        .material(color: context.theme.colorScheme.surface)
        .box
        .clip(Clip.antiAlias)
        // .border(
        //   color: context.theme.colorScheme.background,
        //   width: 2,
        // )
        .color(context.theme.colorScheme.surface)
        .withRounded(value: 5)
        .outerShadow
        .make();
  }

  openProductDetailsPage(BuildContext context, product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AmazonStyledCommerceProductDetailsPage(product: product),
      ),
    );
  }
}
