import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/view_models/taxi_new_order_summary.vm.dart';
import 'package:sod_user/widgets/custom_image.view.dart';
import 'package:sod_user/widgets/directional_chevron.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NewTaxiOrderDriverGenderSelectionView extends StatelessWidget {
  const NewTaxiOrderDriverGenderSelectionView({
    required this.vm,
    Key? key,
  }) : super(key: key);

  final NewTaxiOrderSummaryViewModel vm;
  @override
  Widget build(BuildContext context) {
    return HStack(
      [
        "Driver gender".tr()
            .text
            .make()
            .px12()
            .expand(),
        vm.taxiViewModel.requestDriverGenderMan ? "Male".tr().text.make() : "Female".tr().text.make(),
        VxBox().width(12).make(),
        Icon(FontAwesomeIcons.exchangeAlt, weight: 100, color: Colors.grey[500], size: 20)
      ],
    )
        .onInkTap(
          vm.openDriverGenderSelection,
        )
        .box
        .roundedSM
        .gray200
        .px8
        .make();
  }
}
