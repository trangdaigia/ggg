import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/extensions/string.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/view_models/taxi.vm.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:sod_user/widgets/currency_hstack.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class OrderTaxiButton extends StatefulWidget {
  const OrderTaxiButton(this.vm, {Key? key}) : super(key: key);

  final TaxiViewModel vm;

  @override
  State<OrderTaxiButton> createState() => _OrderTaxiButtonState();
}

class _OrderTaxiButtonState extends State<OrderTaxiButton> {
  @override
  Widget build(BuildContext context) {
    //
    final currencySymbol = (widget.vm.selectedVehicleType?.currency != null
        ? widget.vm.selectedVehicleType?.currency?.symbol
        : AppStrings.currencySymbol);
    //
    return CustomButton(
        loading: widget.vm.isBusy,
        child: HStack(
          [
            "Order Now".tr().text.bold.white.xl.center.makeCentered(),
            UiSpacer.hSpace(10),
            CurrencyHStack(
              [
                "${currencySymbol} ".text.semiBold.xl.white.make(),
                Visibility(
                  visible: (widget.vm.subTotal > widget.vm.total),
                  child: HStack(
                    [
                      "${widget.vm.subTotal.currencyValueFormat()}"
                          .text
                          .medium
                          .lineThrough
                          .white
                          .make(),
                      "${widget.vm.total.currencyValueFormat()}"
                          .text
                          .semiBold
                          .xl
                          .white
                          .make(),
                    ],
                  ),
                ),
                Visibility(
                  visible: !(widget.vm.subTotal > widget.vm.total),
                  child: "${widget.vm.total.currencyValueFormat()}"
                      .text
                      .semiBold
                      .xl
                      .white
                      .make(),
                ),
              ],
            ),
          ],
          alignment: MainAxisAlignment.center,
        ),
        onPressed: widget.vm.selectedVehicleType != null ? widget.vm.processNewOrder : null,
      ).wFull(context);
    //);
  }
}
