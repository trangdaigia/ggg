import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/extensions/string.dart';
import 'package:sod_user/models/service.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/widgets/cards/custom.visibility.dart';
import 'package:sod_user/widgets/currency_hstack.dart';
import 'package:sod_user/widgets/custom_image.view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class ServiceListItem extends StatelessWidget {
  const ServiceListItem({
    required this.service,
    required this.onPressed,
    required this.imgW,
    required this.height,
    Key? key,
  }) : super(key: key);

  final Function(Service) onPressed;
  final Service service;
  final double? imgW;
  final double? height;
  @override
  Widget build(BuildContext context) {
    print(service.discountPrice);
    service.discountPrice = 0000;
    return HStack(
      [
        //service image
        CustomVisibilty(
          visible: service.photos != null && service.photos!.isNotEmpty,
          child: Hero(
            tag: service.heroTag ?? service.id,
            child: CustomImage(
              imageUrl: service.photos!.firstOrElse(() => ""),
              boxFit: BoxFit.cover,
              width: imgW ?? (height != null ? (height! * 2.2) : 75),
              height: height ?? 70,
            ).box.clip(Clip.antiAlias).make(),
          ),
        ).h(height ?? 70),
        // "${service.photos}".text.make(),

        VStack(
          [
            //name/title
            service.name.text.lg.semiBold.make(),
            //description
            CustomVisibilty(
              visible: service.description
                  .substring(3)
                  .replaceAll("</p>", "")
                  .isNotEmpty,
              child: service.description
                  .substring(3)
                  .replaceAll("</p>", "")
                  .text
                  .gray600
                  .base
                  .thin
                  .maxLines(1)
                  .overflow(TextOverflow.ellipsis)
                  .make(),
            ),
            Divider(),
            //price
            FittedBox(
              child: HStack(
                [
                  "${service.hasOptions ? "From".tr() : ""} ".text.sm.make(),
                  CurrencyHStack(
                    [
                      "${AppStrings.currencySymbol}"
                          .text
                          .base
                          .light
                          //.color(AppColor.primaryColor)
                          .make(),
                      UiSpacer.horizontalSpace(space: 5),
                      service.sellPrice
                          .currencyValueFormat()
                          .text
                          .lg
                          .semiBold
                          //.color(AppColor.primaryColor)
                          .xl
                          .make(),
                    ],
                  ),
                  " ${service.durationText}".text.medium.xs.make(),
                  //
                  UiSpacer.horizontalSpace(space: 10),
                  //dsicount
                  Visibility(
                    visible: service.showDiscount,
                    child: "- ${service.discountPercentage}%".text.sm.make(),
                  ),
                ],
              ),
            ),
          ],
        ).py4().px12().expand(),
      ],
    )
        .box
        .withRounded(value: 10)
        .color(context.cardColor)
        .outerShadowSm
        .clip(Clip.antiAlias)
        .makeCentered()
        .onInkTap(
          () => this.onPressed(this.service),
        );
  }
}
