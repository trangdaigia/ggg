import 'package:flutter/material.dart';
import 'package:sod_user/driver_lib/constants/app_strings.dart';
import 'package:sod_user/driver_lib/extensions/string.dart';
import 'package:sod_user/driver_lib/models/order.dart';
import 'package:sod_user/driver_lib/services/validator.service.dart';
import 'package:sod_user/driver_lib/utils/ui_spacer.dart';
import 'package:sod_user/driver_lib/view_models/wallet_transfer.vm.dart';
import 'package:sod_user/driver_lib/widgets/buttons/custom_button.dart';
import 'package:sod_user/driver_lib/widgets/custom_text_form_field.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class WalletTransferDialog extends StatelessWidget {
  const WalletTransferDialog(this.order, {Key? key}) : super(key: key);

  final Order order;
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<WalletTransferViewModel>.reactive(
      viewModelBuilder: () => WalletTransferViewModel(context, order: order),
      builder: (context, vm, child) {
        return Form(
          key: vm.formKey,
          child: VStack(
            [
              "Topup Customer Wallet".tr().text.semiBold.xl.make(),
              "Please enter amount to transfer from your account to customer wallet"
                  .tr()
                  .text
                  .medium
                  .sm
                  .make()
                  .py4(),
              UiSpacer.verticalSpace(),
              CustomTextFormField(
                labelText: "Amount".tr(),
                textEditingController: vm.transferAmountTEC,
                suffixIcon: HStack(
                  axisSize: MainAxisSize.min,
                  alignment: MainAxisAlignment.center,
                  crossAlignment: CrossAxisAlignment.center,
                  [AppStrings.currencySymbol.text.bold.size(16).make()],
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) => FormValidator.validateCustom(
                  value,
                  name: "Amount".tr(),
                ),
                onChanged: (value) {
                  int selectionIndexFromRight =
                      value.length - vm.transferAmountTEC.selection.end;
                  value = formatTextFieldInputNumber(
                      cleanTextFieldInputNumber(value));
                  vm.transferAmountTEC.value = TextEditingValue(
                      text: value,
                      selection: TextSelection.collapsed(
                          offset: value.length - selectionIndexFromRight));
                },
              ),
              UiSpacer.verticalSpace(),
              CustomButton(
                title: "Transfer".tr(),
                loading: vm.busy(vm.transferAmountTEC),
                onPressed: vm.initiateWalletTransfer,
              ).wFull(context),
              CustomButton(
                title: "Cancel".tr(),
                color: Colors.grey,
                loading: vm.busy(vm.transferAmountTEC),
                onPressed: () {
                  Navigator.pop(context);
                },
              ).wFull(context).py8(),
            ],
          ).p20().scrollVertical().pOnly(bottom: context.mq.viewInsets.bottom),
        );
      },
    );
  }
}
