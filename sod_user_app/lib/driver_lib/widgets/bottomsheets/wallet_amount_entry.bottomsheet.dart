import 'package:flutter/material.dart';
import 'package:sod_user/driver_lib/constants/app_strings.dart';
import 'package:sod_user/driver_lib/extensions/string.dart';
import 'package:sod_user/driver_lib/services/validator.service.dart';
import 'package:sod_user/driver_lib/widgets/buttons/custom_button.dart';
import 'package:sod_user/driver_lib/widgets/custom_text_form_field.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class WalletAmountEntryBottomSheet extends StatefulWidget {
  WalletAmountEntryBottomSheet({
    required this.onSubmit,
    Key? key,
  }) : super(key: key);

  final Function(String) onSubmit;
  @override
  _WalletAmountEntryBottomSheetState createState() =>
      _WalletAmountEntryBottomSheetState();
}

class _WalletAmountEntryBottomSheetState
    extends State<WalletAmountEntryBottomSheet> {
  //
  final formKey = GlobalKey<FormState>();
  final amountTEC = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(bottom: context.mq.viewPadding.bottom),
        child: VStack(
          [
            //
            "Top-Up Wallet".tr().text.xl2.semiBold.make(),
            "Enter amount to top-up wallet with".tr().text.make(),
            Form(
              key: formKey,
              child: CustomTextFormField(
                labelText: "Amount".tr(),
                textEditingController: amountTEC,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                suffixIcon: HStack(
                  axisSize: MainAxisSize.min,
                  alignment: MainAxisAlignment.center,
                  crossAlignment: CrossAxisAlignment.center,
                  [AppStrings.currencySymbol.text.bold.size(16).make()],
                ),
                validator: (value) => FormValidator.validateEmpty(
                  value,
                  errorTitle: "Amount".tr(),
                ),
                onChanged: (value) {
                  int selectionIndexFromRight =
                      value.length - amountTEC.selection.end;
                  value = formatTextFieldInputNumber(
                      cleanTextFieldInputNumber(value));
                  amountTEC.value = TextEditingValue(
                      text: value,
                      selection: TextSelection.collapsed(
                          offset: value.length - selectionIndexFromRight));
                },
              ),
            ).py12(),
            //
            CustomButton(
              title: "TOP-UP".tr(),
              onPressed: () {
                //
                if (formKey.currentState!.validate()) {
                  widget.onSubmit(cleanTextFieldInputNumber(amountTEC.text));
                }
              },
            ),
          ],
        )
            .hOneThird(context)
            .p20()
            .pOnly(
              bottom: context.mq.viewInsets.bottom,
            )
            .scrollVertical());
  }
}
