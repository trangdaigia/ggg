import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:velocity_x/velocity_x.dart';

class TaxiOrderTypeTitle extends StatelessWidget {
  const TaxiOrderTypeTitle(this.orderType, {Key? key})
      : super(key: key);

  final String orderType;
  @override
  Widget build(BuildContext context) {
    return HStack(
      [
        //
        VxCapsule(
          child: Container(
            alignment: Alignment.center,
            child: orderType.tr().text.fontWeight(FontWeight.bold).color(Colors.white).center.make(),
          ),
          width: 120,
          height: 36,
          backgroundColor: AppColor.primaryColor,
        ),
        UiSpacer.horizontalSpace(),
      ],
    );
  }
}
