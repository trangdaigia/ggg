import 'package:flutter/material.dart';
import 'package:sod_user/models/real_estate.dart';
import 'package:sod_user/utils/utils.dart';
import 'package:velocity_x/velocity_x.dart';

class RealEstateOverview extends StatelessWidget {
  const RealEstateOverview(this.realEstate, {super.key});
  final RealEstate realEstate;

  @override
  Widget build(BuildContext context) {
    final categoryCombined = realEstate.categories.fold("", (acc, item) {
      return '$acc - ${item.name}';
    });
    print(realEstate.categories);
    return VStack([
      realEstate.name.text.uppercase.xl.semiBold.make(),
      "${realEstate.area} ${realEstate.areaUnit} - ${realEstate.bedroom} ${"room"} ${categoryCombined}"
          .text
          .sm
          .normal
          .make(),
      HStack([
        Icon(
          Icons.pin_drop_outlined,
          size: 15,
        ).pOnly(right: 3),
        (realEstate.address ?? "Unknown").text.sm.normal.make()
      ]),
      realEstate.createdAt == null
          ? SizedBox.shrink()
          : HStack([
              Icon(
                Icons.schedule_outlined,
                size: 15,
              ).pOnly(right: 3),
              Utils.timeDifference(realEstate.createdAt!).text.sm.normal.make()
            ]),
    ]);
  }
}
