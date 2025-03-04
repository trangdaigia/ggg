import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/view_models/base.view_model.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class ComplexVendorHeader extends StatelessWidget {
  const ComplexVendorHeader({
    Key? key,
    required this.model,
    this.searchShowType,
    required this.onrefresh,
    this.functionSeeAll = false,
  }) : super(key: key);

  final MyBaseViewModel model;
  final int? searchShowType;
  final Function onrefresh;
  final bool functionSeeAll;

  @override
  Widget build(BuildContext context) {
    if (!functionSeeAll) {
      return HStack(
        [
          //location icon
          Icon(
            FlutterIcons.location_pin_sli,
            size: 24,
          ).onInkTap(
            model.useUserLocation,
          ),

          //
          VStack(
            [
              //
              "Location".tr().text.lg.semiBold.make(),
              "${model.deliveryaddress != null ? model.deliveryaddress?.address : '---'}"
                  .text
                  .base
                  .maxLines(1)
                  .make(),
            ],
          )
              .onInkTap(() {
                model.pickDeliveryAddress(
                  vendorCheckRequired: false,
                  onselected: onrefresh,
                );
              })
              .px12()
              .expand(),

          //
          //
          Icon(
            FlutterIcons.search_fea,
            size: 24,
          )
              .p8()
              .onInkTap(() {
                model.openSearch(showType: searchShowType ?? 4);
              })
              .box
              .roundedSM
              .clip(Clip.antiAlias)
              .color(context.theme.colorScheme.background)
              .shadowXs
              .make(),
        ],
      ).p8().px16().py8();
    } else {
      return 'See All'
          .tr()
          .text
          .size(10)
          .color(AppColor.primaryColor)
          .make()
          .onInkTap(
        () {
          model.openSearch(showType: searchShowType ?? 4);
        },
      );
    }
  }
}
