import 'package:flutter/material.dart';
import 'package:sod_vendor/constants/app_colors.dart';
import 'package:sod_vendor/models/vendor.dart';
import 'package:sod_vendor/widgets/custom_image.view.dart';
import 'package:velocity_x/velocity_x.dart';

class ParcelVendorListItem extends StatelessWidget {
  const ParcelVendorListItem(
    this.vendor, {
    this.selected = false,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  final Vendor vendor;
  final bool selected;
  final Function onPressed;
  @override
  Widget build(BuildContext context) {
    return HStack(
      [
        //image
        CustomImage(
          imageUrl: vendor.logo,
        ).wh(Vx.dp56, Vx.dp56).pOnly(right: Vx.dp12),

        VStack(
          [
            //name
            vendor.name.text.semiBold.make(),
            //description
            vendor.description.text.sm.make(),
          ],
        ).expand(),
      ],
      crossAlignment: CrossAxisAlignment.start,
      // alignment: MainAxisAlignment.start,
    )
        .p12()
        .onInkTap(() => onPressed())
        .box
        // .color(context.cardColor)
        .roundedSM
        .border(
          color: selected ? AppColor.primaryColor : Colors.grey.shade300,
          width: selected ? 3 : 2,
        )
        .make();
  }
}
