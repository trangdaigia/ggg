import 'package:flutter/material.dart';
import 'package:sod_user/driver_lib/constants/app_images.dart';
import 'package:sod_user/driver_lib/widgets/states/empty.state.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class EmptyPaymentAccount extends StatelessWidget {
  const EmptyPaymentAccount({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      imageUrl: AppImages.paymentAccount,
      title: "Payment Account Not Found".tr(),
      description:
          "Please create a new payment account. This can be use to receive earning from the platform"
              .tr(),
    ).p20().centered();
  }
}
