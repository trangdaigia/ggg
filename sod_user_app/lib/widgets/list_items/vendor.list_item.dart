import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/models/vendor.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/widgets/buttons/route.button.dart';
import 'package:sod_user/widgets/currency_hstack.dart';
import 'package:sod_user/widgets/custom_image.view.dart';
import 'package:sod_user/widgets/tags/delivery.tag.dart';
import 'package:sod_user/widgets/tags/time.tag.dart';
import 'package:sod_user/widgets/tags/pickup.tag.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class VendorListItem extends StatelessWidget {
  const VendorListItem({
    required this.vendor,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  final Vendor vendor;
  final Function(Vendor) onPressed;
  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        //
        Stack(
          children: [
            Hero(
              tag: vendor.heroTag ?? vendor.id,
              child: CustomImage(
                imageUrl: vendor.featureImage,
                boxFit: BoxFit.fitWidth,
              ).wFull(context).h(100),
            ),

            //location routing
            (!vendor.latitude.isEmptyOrNull && !vendor.longitude.isEmptyOrNull)
                ? Positioned(
                    child: RouteButton(
                      vendor,
                      size: 12,
                    ),
                    bottom: 5,
                    right: 10,
                  )
                : UiSpacer.emptySpace(),

            //
            Positioned(
              child: VStack(
                [
                  TimeTag(vendor.prepareTime,
                      iconData: FlutterIcons.clock_outline_mco),
                  UiSpacer.verticalSpace(space: 5),
                  TimeTag(
                    vendor.deliveryTime,
                    iconData: FlutterIcons.ios_bicycle_ion,
                  ),
                ],
              ),
              left: 10,
              bottom: 5,
            ),

            //closed
            Positioned(
              child: Visibility(
                visible: !vendor.isOpen,
                child: VxBox(
                  child: "Closed".tr().text.lg.white.bold.makeCentered(),
                )
                    .color(
                      AppColor.closeColor.withOpacity(0.6),
                    )
                    .make(),
              ),
              bottom: 0,
              right: 0,
              left: 0,
              top: 0,
            ),
          ],
        ),

        //name
        vendor.name.text.sm.medium
            .maxLines(1)
            .overflow(TextOverflow.ellipsis)
            .make()
            .px8()
            .pOnly(top: Vx.dp8),
        //
        UiSpacer.verticalSpace(space: 5),
        //description
        "${vendor.description}"
            .text
            .gray400
            .minFontSize(9)
            .size(9)
            .maxLines(1)
            .overflow(TextOverflow.ellipsis)
            .make()
            .px8(),
        UiSpacer.verticalSpace(space: 5),
        //words
        Wrap(
          spacing: Vx.dp12,
          children: [
            //rating
            HStack(
              [
                "${vendor.rating.numCurrency} "
                    .text
                    .minFontSize(6)
                    .size(10)
                    .color(AppColor.ratingColor)
                    .medium
                    .make(),
                Icon(
                  FlutterIcons.star_ent,
                  color: AppColor.ratingColor,
                  size: 10,
                ),
              ],
            ),

            //
            //
            Visibility(
              visible: vendor.distance != null,
              child: HStack(
                [
                  Icon(
                    FlutterIcons.direction_ent,
                    color: AppColor.primaryColor,
                    size: 10,
                  ),
                  " ${vendor.distance?.numCurrency}km"
                      .text
                      .minFontSize(6)
                      .size(10)
                      .make(),
                ],
              ),
            ),
          ],
        ).px8(),
        UiSpacer.verticalSpace(space: 5),

        //delivery fee && time
        Wrap(
          spacing: Vx.dp12,
          children: [
            //
            Visibility(
              visible: vendor.minOrder != null,
              child: CurrencyHStack(
                [
                  "${AppStrings.currencySymbol}"
                      .text
                      .minFontSize(6)
                      .size(10)
                      .gray600
                      .medium
                      .maxLines(1)
                      .make(),
                  //
                  Visibility(
                    visible: vendor.minOrder != null,
                    child: "${vendor.minOrder}"
                        .text
                        .minFontSize(6)
                        .size(10)
                        .gray600
                        .medium
                        .maxLines(1)
                        .make(),
                  ),
                  //
                  Visibility(
                    visible: vendor.minOrder != null && vendor.maxOrder != null,
                    child: " - "
                        .text
                        .minFontSize(6)
                        .size(10)
                        .gray600
                        .medium
                        .maxLines(1)
                        .make(),
                  ),
                  //
                  Visibility(
                    visible: vendor.maxOrder != null,
                    child: "${vendor.maxOrder} "
                        .text
                        .minFontSize(6)
                        .size(10)
                        .gray600
                        .medium
                        .maxLines(1)
                        .make(),
                  ),
                ],
              ),
            ),
          ],
        ).px8(),

        //
        HStack(
          [
            //can deliver
            vendor.delivery == 1
                ? DeliveryTag().pOnly(right: 10)
                : UiSpacer.emptySpace(),

            //can pickup
            vendor.pickup == 1
                ? PickupTag().pOnly(right: 10)
                : UiSpacer.emptySpace(),
          ],
          crossAlignment: CrossAxisAlignment.end,
        ).p8()
      ],
    )
        .onInkTap(
          () => this.onPressed(this.vendor),
        )
        .w(175)
        .box
        .outerShadow
        .color(context.theme.colorScheme.background)
        .clip(Clip.antiAlias)
        .withRounded(value: 5)
        .make()
        .pOnly(bottom: Vx.dp8);
  }
}
