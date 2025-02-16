import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:sod_user/driver_lib/extensions/dynamic.dart';
import 'package:sod_user/driver_lib/widgets/cards/amount_tile.dart';
import 'package:sod_user/driver_lib/constants/app_strings.dart';
import 'package:sod_user/driver_lib/models/order.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class ReceiveBehalfOrderDetailsSummary extends StatelessWidget {
  const ReceiveBehalfOrderDetailsSummary(this.order, {Key? key})
      : super(key: key);
  final Order order;

  @override
  Widget build(BuildContext context) {
    final currencySymbol = AppStrings.currencySymbol;
    return VStack(
      [
        "Order Summary".tr().text.semiBold.xl.make().pOnly(bottom: Vx.dp12),
        AmountTile(
                "Order value".tr(),
                (order.receiveBehalfOrder!.orderValue ?? 0)
                    .currencyValueFormat())
            .py2(),
        AmountTile(
          "Serive Fee".tr(),
          "+ " +
              "$currencySymbol ${order.receiveBehalfOrder!.serviceFee ?? 0}"
                  .currencyFormat(),
        ).py2(),
        AmountTile(
          "Payment Fee".tr(),
          "+ " +
              "$currencySymbol ${order.receiveBehalfOrder!.paymentFee ?? 0}"
                  .currencyFormat(),
        ).py2(),
        DottedLine(dashColor: context.textTheme.bodyLarge!.color!).py8(),
        AmountTile(
          "Total Amount".tr(),
          "$currencySymbol ${order.total ?? 0}".currencyFormat(),
        ),
      ],
    );
  }
}
