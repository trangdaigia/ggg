import 'package:flutter/cupertino.dart';
import 'package:sod_user/driver_lib/constants/app_colors.dart';
import 'package:sod_user/driver_lib/utils/utils.dart';
import 'package:velocity_x/velocity_x.dart';

class CustomLeading extends StatelessWidget {
  const CustomLeading({
    this.size,
    this.color,
    this.padding,
    this.bgColor,
    Key? key,
  }) : super(key: key);

  final double? size;
  final Color? color;
  final Color? bgColor;
  final double? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 14),
      child: Icon(
        Utils.isArabic
            ? CupertinoIcons.chevron_right
            : CupertinoIcons.chevron_left,
        size: size ?? 20,
        color: color,
      )
          .p(padding ?? 4)
          .onInkTap(() {
            Navigator.pop(context);
          })
          .box
          .shadowSm
          .roundedFull
          .clip(Clip.antiAlias)
          .color(bgColor ?? AppColor.primaryColor)
          .make(),
    );
  }
}
