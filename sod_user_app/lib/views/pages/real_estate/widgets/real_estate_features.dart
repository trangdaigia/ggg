import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/models/real_estate.dart';
import 'package:velocity_x/velocity_x.dart';

class RealEstateFeatures extends StatelessWidget {
  const RealEstateFeatures(this.realEstate, {super.key});
  final RealEstate realEstate;

  @override
  Widget build(BuildContext context) {
    return HStack(
      [
        VStack([
          "${"Status".tr()}: ${realEstate.status.tr()}".text.sm.normal.make(),
          "${"Bedroom".tr()}: ${realEstate.bedroom}".text.sm.normal.make(),
        ]),
        VStack([
          "${"Area".tr()}: ${realEstate.area} ${realEstate.areaUnit}"
              .text
              .sm
              .normal
              .make(),
          "${"Price".tr()}/${realEstate.areaUnit}: ${realEstate.priceByArea}"
              .text
              .sm
              .normal
              .make()
        ]).pOnly(left: 20)
      ],
      alignment: MainAxisAlignment.spaceBetween,
    );
  }
}
