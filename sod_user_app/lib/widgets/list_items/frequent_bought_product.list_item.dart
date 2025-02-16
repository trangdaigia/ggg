import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/extensions/string.dart';
import 'package:sod_user/models/product.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/utils/utils.dart';
import 'package:sod_user/views/pages/product/amazon_styled_commerce_product_details.page.dart';
import 'package:velocity_x/velocity_x.dart';

class FrequentBoughtProductListItem extends StatefulWidget {
  FrequentBoughtProductListItem({
    required this.product,
    required this.oncheckChange,
    this.selected = true,
    Key? key,
  }) : super(key: key);

  final Product product;
  final Function(bool) oncheckChange;
  final bool selected;
  @override
  State<FrequentBoughtProductListItem> createState() =>
      _FrequentBoughtProductListItemState();
}

class _FrequentBoughtProductListItemState
    extends State<FrequentBoughtProductListItem> {
  @override
  Widget build(BuildContext context) {
    return HStack(
      [
        //checkbox
        Checkbox(
          value: widget.selected,
          onChanged: (value) {
            widget.oncheckChange(value ?? false);
          },
        ).p8(),

        UiSpacer.hSpace(8),
        //
        HStack(
          [
            VStack(
              [
                "${widget.product.name}"
                    .text
                    .scale(1.2)
                    .maxLines(2)
                    .overflow(TextOverflow.ellipsis)
                    .make(),
                UiSpacer.vSpace(3),
                "${AppStrings.currencySymbol} ${widget.product.sellPrice}"
                    .currencyFormat()
                    .text
                    .color(AppColor.primaryColor)
                    .semiBold
                    .make(),
              ],
            ).expand(),
            //
            Icon(!Utils.isArabic
                ? FlutterIcons.chevron_right_fea
                : FlutterIcons.chevron_left_fea),
          ],
          crossAlignment: CrossAxisAlignment.center,
        ).p8().onInkTap(() {
          context.nextPage(
            AmazonStyledCommerceProductDetailsPage(
              product: widget.product,
            ),
          );
        }).expand(),
      ],
    );
  }
}
