import 'package:sod_user/driver_lib/extensions/dynamic.dart';
import 'package:sod_user/driver_lib/models/order.dart';
import 'package:sod_user/driver_lib/models/order_fee.dart';
import 'package:sod_user/driver_lib/widgets/cards/amount_tile.dart';
import 'package:sod_user/driver_lib/extensions/dynamic.dart';
import 'package:sod_user/driver_lib/models/order_fee.dart';
import 'package:sod_user/driver_lib/widgets/cards/amount_tile.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:sod_user/driver_lib/constants/app_strings.dart';
import 'package:sod_user/driver_lib/widgets/cards/custom.visibility.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class OrderSummary extends StatelessWidget {
  const OrderSummary({
    required this.order,
    this.subTotal,
    this.discount,
    this.deliveryFee,
    this.tax,
    this.vendorTax,
    required this.total,
    this.driverTip = 0.00,
    this.mCurrencySymbol,
    this.fees = const [],
    Key? key,
  }) : super(key: key);

  final double? subTotal;
  final double? discount;
  final double? deliveryFee;
  final double? tax;
  final String? vendorTax;
  final double total;
  final double? driverTip;
  final String? mCurrencySymbol;
  final List<OrderFee> fees;
  final Order order;

  @override
  Widget build(BuildContext context) {
    final currencySymbol =
        mCurrencySymbol != null ? mCurrencySymbol : AppStrings.currencySymbol;
    return VStack(
      [
        "Order Summary".tr().text.semiBold.xl.make().pOnly(bottom: Vx.dp12),

        if (order.taxiOrder != null && order.taxiOrder!.type == "ship")
          VStack([
            if (order.taxiOrder!.shipPackage!.photo != null &&
                order.taxiOrder!.shipPackage!.photo != "")
              Image.network(order.taxiOrder!.shipPackage!.photo!)
                  .h(200)
                  .wFull(context),
            AmountTile("Ship package type".tr(),
                    order.taxiOrder!.shipPackage!.shipPackageType.tr())
                .py2(),
            AmountTile(
                    "Floor / building number".tr(),
                    order.taxiOrder!.shipPackage?.floorNumberOrBuildingNumber ??
                        "")
                .py2(),
            AmountTile("Contact name".tr(),
                    order.taxiOrder!.shipPackage?.contactName ?? "")
                .py2(),
            AmountTile("Contact number".tr(),
                    order.taxiOrder!.shipPackage?.contactNumber ?? "")
                .py2(),
            AmountTile("Note for driver".tr(),
                    order.taxiOrder!.shipPackage?.noteForDrier ?? "")
                .py2(),
          ]),

        DottedLine(dashColor: context.textTheme.bodyLarge!.color!).py8(),
        AmountTile(
          "Subtotal".tr(),
          "$currencySymbol ${subTotal}".currencyFormat(),
        ).py2(),
        AmountTile(
          "Discount".tr(),
          "- " + "$currencySymbol ${discount}".currencyFormat(),
        ).py2(),
        //
        CustomVisibilty(
          visible: deliveryFee != null,
          child: AmountTile(
            "Delivery Fee".tr(),
            "+ " + "$currencySymbol ${deliveryFee ?? 0.00}".currencyFormat(),
          ).py2(),
        ),

        //tax
        CustomVisibilty(
          visible: tax != null,
          child: AmountTile(
            "Tax (%s)".tr().fill([vendorTax ?? 0]),
            "+ " + "$currencySymbol ${tax ?? 0.00}".currencyFormat(),
          ).py2(),
        ),
        Visibility(
          visible: fees.isNotEmpty,
          child: VStack(
            [
              ...((fees).map((fee) {
                return AmountTile(
                  "${fee.name}".tr(),
                  "+ " + " $currencySymbol ${fee.amount}".currencyFormat(),
                ).py2();
              }).toList()),
              DottedLine(dashColor: context.textTheme.bodyLarge!.color!).py8(),
            ],
          ),
        ),

        DottedLine(dashColor: context.textTheme.bodyLarge!.color!).py8(),
        Visibility(
          visible: driverTip != null,
          child: VStack(
            [
              AmountTile(
                "Driver Tip".tr(),
                "+ " + "$currencySymbol ${driverTip ?? 0.00}".currencyFormat(),
              ).py2(),
              DottedLine(dashColor: context.textTheme.bodyLarge!.color!).py8(),
            ],
          ),
        ),
        AmountTile(
          "Total Amount".tr(),
          "$currencySymbol ${(total) + (driverTip ?? 0.00)}".currencyFormat(),
        ),
      ],
    );
  }
}
