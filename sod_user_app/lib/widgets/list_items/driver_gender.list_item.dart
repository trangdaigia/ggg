import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/models/payment_method.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/view_models/taxi.vm.dart';
import 'package:velocity_x/velocity_x.dart';

class DriverGenderOptionListItem extends StatelessWidget {
  const DriverGenderOptionListItem(
    this.vm,
    this.gender,
    this.borderCorlor,
    this.borderWidth, {
    Key? key,
  }) : super(key: key);

  final TaxiViewModel vm;
  final String gender;
  final Color borderCorlor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return HStack(
      [
        gender.tr().text.make(),
        UiSpacer.horizontalSpace(),
      ],
    )
        .p12()
        .box
        .roundedSM
        .border(color: borderCorlor, width: borderWidth)
        .make()
        .onInkTap(
          () => Navigator.pop(context, gender),
        );
  }
}
