import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/extensions/dynamic.dart';
import 'package:sod_user/models/service.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/widgets/currency_hstack.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class ServiceDetailsPriceSectionView extends StatelessWidget {
  const ServiceDetailsPriceSectionView(
    this.service, {
    this.onlyPrice = false,
    this.showDiscount = false,
    Key? key,
  }) : super(key: key);

  final Service service;
  final bool onlyPrice;
  final bool showDiscount;

  @override
  Widget build(BuildContext context) {
    return HStack(
      [
        CurrencyHStack(
          [
            "${AppStrings.currencySymbol}"
                .text
                .medium
                .color(AppColor.primaryColor)
                .make(),
            service.sellPrice
                .currencyValueFormat()
                .text
                .semiBold
                .color(AppColor.primaryColor)
                .lg
                .make(),
          ],
        ),

        " ${service.durationText}".text.medium.xl.make(),
        UiSpacer.horizontalSpace(space: 5),
        //discount
        Visibility(
          visible: !onlyPrice || showDiscount,
          child: service.showDiscount
              ? "${"Off".tr()} ${service.discountPercentage}%"
                  .text
                  .white
                  .xs
                  .semiBold
                  .make()
                  .p2()
                  .px4()
                  .box
                  .red500
                  .roundedLg
                  .make()
              : UiSpacer.emptySpace(),
        ),
        //
        UiSpacer.emptySpace().expand(),
        //rating

        service.vendor.reviews_count >= 5
            ? Visibility(
                visible: !onlyPrice,
                child: VxRating(
                  value: double.parse((service.vendor.rating).toString()),
                  maxRating: 5.0,
                  isSelectable: false,
                  onRatingUpdate: (value) {},
                  selectionColor: AppColor.ratingColor,
                  normalColor: Colors.grey,
                  size: 18,
                ),
              )
            : Visibility(
                visible: !onlyPrice,
                child: VxRating(
                  value: 0,
                  maxRating: 5.0,
                  isSelectable: false,
                  onRatingUpdate: (value) {},
                  selectionColor: AppColor.ratingColor,
                  normalColor: Colors.grey,
                  size: 18,
                )),
      ],
    );
  }
}
