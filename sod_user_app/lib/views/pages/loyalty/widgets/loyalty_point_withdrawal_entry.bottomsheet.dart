import 'package:flutter/material.dart';
import 'package:sod_user/extensions/string.dart';
import 'package:sod_user/services/validator.service.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:sod_user/widgets/custom_text_form_field.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class LoyaltyPointWithdrawalEntryBottomSheet extends StatefulWidget {
  LoyaltyPointWithdrawalEntryBottomSheet({
    required this.onSubmit,
    Key? key,
  }) : super(key: key);

  final Function(String) onSubmit;
  @override
  _LoyaltyPointWithdrawalEntryBottomSheetState createState() =>
      _LoyaltyPointWithdrawalEntryBottomSheetState();
}

class _LoyaltyPointWithdrawalEntryBottomSheetState
    extends State<LoyaltyPointWithdrawalEntryBottomSheet> {
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
            "Loyalty Points".tr().text.xl2.semiBold.make(),
            "Enter points to withdraw to wallet".tr().text.make(),
            Form(
              key: formKey,
              child: CustomTextFormField(
                labelText: "Points".tr(),
                textEditingController: amountTEC,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) => FormValidator.validateEmpty(
                  value,
                  errorTitle: "Points".tr(),
                ),
                onChanged: (string) {
                  int selectionIndexFromRight =
                      string.length - amountTEC.selection.end;
                  string = formatTextFieldInputNumber(
                      cleanTextFieldInputNumber(string));
                  amountTEC.value = TextEditingValue(
                      text: string,
                      selection: TextSelection.collapsed(
                          offset: string.length - selectionIndexFromRight));
                },
              ),
            ).py12(),
            //
            CustomButton(
              title: "Withdraw".tr(),
              onPressed: () {
                //
                if (formKey.currentState!.validate()) {
                  widget.onSubmit(cleanTextFieldInputNumber(amountTEC.text));
                }
              },
            ),
          ],
        )
            .p20()
            .scrollVertical()
            .hOneThird(context)
            .pOnly(bottom: context.mq.viewInsets.bottom));
  }
}
