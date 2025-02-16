import 'package:flutter/material.dart';
import 'package:sod_vendor/view_models/vendor_details.view_model.dart';
import 'package:sod_vendor/widgets/buttons/custom_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class RequestPayoutButton extends StatelessWidget {
  const RequestPayoutButton({
    required this.vm,
    Key? key,
  }) : super(key: key);

  final VendorDetailsViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: vm.totalEarning > 0,
      child: CustomButton(
        title: "Request Payout".tr(),
        onPressed: vm.requestPayout,
      ).py12(),
    );
  }
}
