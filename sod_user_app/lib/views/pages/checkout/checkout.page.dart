import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/extensions/string.dart';
import 'package:sod_user/models/checkout.dart';
import 'package:sod_user/models/delivery_address.dart';
import 'package:sod_user/models/fee.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/view_models/checkout.vm.dart';
import 'package:sod_user/views/pages/checkout/widgets/driver_cash_delivery_note.view.dart';
import 'package:sod_user/views/pages/checkout/widgets/order_delivery_address.view.dart';
import 'package:sod_user/views/pages/checkout/widgets/payment_methods.view.dart';
import 'package:sod_user/views/pages/checkout/widgets/schedule_order.view.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:sod_user/widgets/cards/order_summary.dart';
import 'package:sod_user/widgets/custom_text_form_field.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter/services.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({
    required this.checkout,
    Key? key,
  }) : super(key: key);

  final CheckOut checkout;
  List<Fee> checkIfAddressHasHCM(List<Fee> feeList, DeliveryAddress? address) {
    bool hasHCMC = true;
    if (address == null) {
      feeList.forEach((element) {
        if (element.id == 2 && element.value == 20000) {
          element.value = element.value - 20000;
        }
      });
      return feeList;
    }
    if (feeList.length > 0) {
      for (var fee in feeList) {
        if (fee.id == 2 &&
            (address.address!.contains("Ho Chi Minh") ||
                address.address!.contains("Hồ Chí Minh"))) {
          feeList.forEach((element) {
            if (element.id == 2 && element.value == 0) {
              element.value = element.value + 20000;
            }
          });
          return feeList;
        } else if (fee.id == 2) {
          hasHCMC = false;
          break;
        }
      }
      if (hasHCMC == false) {
        feeList.forEach((element) {
          if (element.id == 2 && element.value == 20000) {
            element.value = element.value - 20000;
          }
        });
      }
      return feeList;
    }
    return feeList;
  }

  double checkOutsideHCMC(
      List<Fee> feeList, DeliveryAddress? address, double amount) {
    if (address == null) {
      return amount - 20000;
    }
    if (feeList.length > 0) {
      for (var fee in feeList) {
        if (fee.id == 2 &&
            (address.address!.contains("Ho Chi Minh") ||
                address.address!.contains("Hồ Chí Minh"))) {
        } else if (fee.id == 2) {
          return amount - 20000;
        }
      }
    }
    return amount;
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CheckoutViewModel>.reactive(
      viewModelBuilder: () => CheckoutViewModel(context, checkout),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        return BasePage(
          showAppBar: true,
          showLeadingAction: true,
          title: "Checkout".tr(),
          body: VStack(
            [
              //
              UiSpacer.verticalSpace(),
              Visibility(
                visible: !vm.isPickup,
                child: CustomTextFormField(
                  labelText:
                      "Driver Tip".tr() + " (${AppStrings.currencySymbol})",
                  suffixIcon: HStack(
                    axisSize: MainAxisSize.min,
                    alignment: MainAxisAlignment.center,
                    crossAlignment: CrossAxisAlignment.center,
                    [AppStrings.currencySymbol.text.bold.size(16).make()],
                  ),
                  textEditingController: vm.driverTipTEC,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onFieldSubmitted: (value) => vm.updateTotalOrderSummary(),
                  onChanged: (string) {
                    int selectionIndexFromRight =
                        string.length - vm.driverTipTEC.selection.end;
                    string = formatTextFieldInputNumber(
                        cleanTextFieldInputNumber(string));
                    vm.driverTipTEC.value = TextEditingValue(
                        text: string,
                        selection: TextSelection.collapsed(
                            offset: string.length - selectionIndexFromRight));
                  },
                ).pOnly(bottom: Vx.dp20),
              ),
              //
              CustomTextFormField(
                labelText: "Note".tr(),
                textEditingController: vm.noteTEC,
              ),

              //note
              Divider(thickness: 3).py12(),

              //pickup time slot
              ScheduleOrderView(vm),

              //its pickup
              OrderDeliveryAddressPickerView(vm),

              //payment options
              Visibility(
                visible: vm.canSelectPaymentOption,
                child: PaymentMethodsView(vm),
              ),

              //order final price preview
              OrderSummary(
                subTotal: vm.checkout!.subTotal,
                discount: (vm.checkout!.coupon?.for_delivery ?? false)
                    ? null
                    : vm.checkout!.discount,
                deliveryDiscount: (vm.checkout!.coupon?.for_delivery ?? false)
                    ? vm.checkout!.deliveryDiscount
                    : null,
                deliveryFee: vm.checkout!.deliveryFee,
                tax: vm.checkout!.tax,
                vendorTax: vm.vendor!.tax,
                driverTip: double.tryParse(
                        "${cleanTextFieldInputNumber(vm.driverTipTEC.text)}") ??
                    0.00,
                total: checkOutsideHCMC(vm.vendor!.fees, vm.deliveryAddress,
                    vm.checkout!.totalWithTip),
                fees: checkIfAddressHasHCM(vm.vendor!.fees, vm.deliveryAddress),
              ),

              //show notice it driver should be paid in cash
              if (vm.checkout!.deliveryAddress != null)
                CheckoutDriverCashDeliveryNoticeView(
                  vm.checkout!.deliveryAddress!,
                ),
              //
              CustomButton(
                title: "PLACE ORDER".tr().padRight(14),
                icon: FlutterIcons.credit_card_fea,
                onPressed: vm.placeOrder,
                loading: vm.isBusy,
              ).centered().py16(),
            ],
          ).p20().scrollVertical().pOnly(bottom: context.mq.viewInsets.bottom),
        );
      },
    );
  }
}
