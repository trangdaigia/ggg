import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_finance_settings.dart';
import 'package:sod_user/models/delivery_address.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class CheckoutDriverCashDeliveryNoticeView extends StatelessWidget {
  const CheckoutDriverCashDeliveryNoticeView(this.dAddress, {Key? key})
      : super(key: key);

  final DeliveryAddress dAddress;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: AppFinanceSettings.collectDeliveryFeeInCash,
      child: VxBox(
        child: "".richText.withTextSpanChildren(
          [
            "Note:".tr().textSpan.red500.extraBlack.size(14).make(),
            " ".textSpan.make(),
            "Irrespective of your selected payment method, it is required that you pay delivery fee in CASH to the delivery personal. Thank you"
                .tr()
                .textSpan
                .size(14)
                .make(),
          ],
        ).make(),
      ).p12.border(color: Colors.grey).roundedSM.make().py12(),
    );
  }
}
