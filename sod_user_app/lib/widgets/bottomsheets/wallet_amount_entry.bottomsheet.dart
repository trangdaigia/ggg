import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/extensions/string.dart';
import 'package:sod_user/services/validator.service.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:sod_user/widgets/custom_text_form_field.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class WalletAmountEntryBottomSheet extends StatefulWidget {
  WalletAmountEntryBottomSheet({
    required this.onSubmit,
    Key? key,
  }) : super(key: key);

  final Function(String) onSubmit;
  @override
  _WalletAmountEntryBottomSheetState createState() => _WalletAmountEntryBottomSheetState();
}

class _WalletAmountEntryBottomSheetState extends State<WalletAmountEntryBottomSheet> {
  //
  final formKey = GlobalKey<FormState>();
  final _amountTEC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.mq.viewInsets.bottom),
      child: VStack(
        [
          //
          10.heightBox,
          //
          "Top-Up Wallet".tr().text.xl3.semiBold.make().pOnly(bottom: 10),
          "Enter amount to top-up wallet".tr().text.make().pOnly(bottom: 10),
          Form(
            key: formKey,
            child: CustomTextFormField(
              hintText: "Enter the amount".tr(),
              labelText: "Amount".tr(),
              textEditingController: _amountTEC,
              suffixIcon: HStack(
                axisSize: MainAxisSize.min,
                alignment: MainAxisAlignment.center,
                crossAlignment: CrossAxisAlignment.center,
                [AppStrings.currencySymbol.text.bold.size(16).make()],
              ),
              onChanged: (string) {
                int selectionIndexFromRight = string.length - _amountTEC.selection.end;
                string = formatTextFieldInputNumber(cleanTextFieldInputNumber(string));
                _amountTEC.value =
                    TextEditingValue(text: string, selection: TextSelection.collapsed(offset: string.length - selectionIndexFromRight));
              },
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) => FormValidator.validateEmpty(
                value,
                errorTitle: "Amount".tr(),
              ),
            ),
          ).py12(),
          //
          CustomButton(
            title: "TOP-UP".tr(),
            onPressed: () {
              //
              if (formKey.currentState!.validate()) {
                widget.onSubmit(cleanTextFieldInputNumber(_amountTEC.text));
              }
            },
          ),
          //
          20.heightBox,
        ],
      ).p20().scrollVertical().hOneThird(context).box.color(context.theme.colorScheme.background).topRounded().make(),
    );
  }
}
