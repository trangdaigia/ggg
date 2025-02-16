import 'package:flutter/material.dart';
import 'package:sod_user/models/vendor.dart';
import 'package:sod_user/widgets/custom_image.view.dart';
import 'package:velocity_x/velocity_x.dart';

class RealEstateVendor extends StatelessWidget {
  const RealEstateVendor(this.vendor, {super.key});
  final Vendor vendor;

  @override
  Widget build(BuildContext context) {
    return HStack([
      Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          clipBehavior: Clip.antiAlias,
          child: CustomImage(
            imageUrl: vendor.logo,
            boxFit: BoxFit.contain,
            canZoom: true,
          )).pOnly(right: 8),
      VStack([
        vendor.name.text.medium.bold.make(),
        "${vendor.rating} (${vendor.reviews_count})".text.sm.semiBold.make(),
        vendor.description.text.sm.normal.make()
      ]).wThreeForth(context),
    ]);
  }
}
