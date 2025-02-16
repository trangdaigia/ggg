import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/extensions/dynamic.dart';
import 'package:sod_user/models/service.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/utils/utils.dart';
import 'package:sod_user/widgets/cards/vendor_info.view.dart';
import 'package:sod_user/widgets/custom_image.view.dart';
import 'package:sod_user/widgets/states/alternative.view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class ServiceGridViewItem extends StatelessWidget {
  const ServiceGridViewItem({
    required this.service,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  final Function(Service) onPressed;
  final Service service;

  //
  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        Stack(
          children: [
            AlternativeView(
              ismain: (service.photos != null && service.photos!.isNotEmpty),
              main: CustomImage(
                imageUrl: (service.photos != null && service.photos!.isNotEmpty)
                    ? service.photos!.first
                    : "",
                width: double.infinity,
                height: 160,
              ),
              alt: Container(
                color: Vx.randomOpaqueColor.withAlpha(50),
                width: double.infinity,
                height: 60,
                child: "${service.name}"
                    .text
                    .color(Vx.randomOpaqueColor.withOpacity(0.1))
                    .center
                    .make()
                    .centered()
                    .p12(),
              ),
            ).pOnly(bottom: 10),

            //price
            Positioned(
              bottom: 0,
              right: !Utils.isArabic ? 20 : null,
              left: Utils.isArabic ? 20 : null,
              child: ((service.hasOptions ? "From".tr() : "") +
                      " " +
                      "${AppStrings.currencySymbol} ${service.sellPrice}"
                          .currencyFormat() +
                      " ${service.durationText}")
                  .text
                  .sm
                  .color(Utils.textColorByTheme())
                  .make()
                  .px8()
                  .py2()
                  .box
                  .roundedLg
                  .border(
                    width: 1.6,
                    color: Utils.textColorByTheme(),
                  )
                  .color(AppColor.primaryColor)
                  .make(),
            ),

            //discount
            Visibility(
              visible: service.showDiscount,
              child: "%s Off"
                  .tr()
                  .fill(["${service.discountPercentage}%"])
                  .text
                  .sm
                  .white
                  .semiBold
                  .make()
                  .p2()
                  .px4()
                  .box
                  .red500
                  .withRounded(value: 7)
                  .make(),
            ),
          ],
        ),

        //
        VStack(
          axisSize: MainAxisSize.min,
          [
            // Tên dịch vụ
            "${service.name}".text.lg.semiBold.maxLines(2).ellipsis.make(),

            // Ngăn cách
            UiSpacer.divider(thickness: 0.50, height: 0.3).py2().px4(),

            // Thông tin nhà cung cấp
            VendorInfoView(service.vendor).pOnly(bottom: 10),
          ],
        ).px12(),
      ],
    )
        .wFull(context)
        .h(260)
        .box
        .withRounded(value: 8)
        .color(context.cardColor)
        .outerShadowSm
        .clip(Clip.antiAlias)
        .makeCentered()
        .p8()
        .onInkTap(
          () => this.onPressed(this.service),
        );
  }
}
