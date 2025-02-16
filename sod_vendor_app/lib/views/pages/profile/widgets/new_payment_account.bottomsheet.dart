import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:sod_vendor/services/custom_form_builder_validator.service.dart';
import 'package:sod_vendor/utils/ui_spacer.dart';
import 'package:sod_vendor/view_models/payment_accounts.vm.dart';
import 'package:sod_vendor/widgets/buttons/custom_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';

class NewPaymentAccountBottomSheet extends StatefulWidget {
  NewPaymentAccountBottomSheet(this.vm, {Key? key}) : super(key: key);

  final PaymentAccountsViewModel vm;

  @override
  State<NewPaymentAccountBottomSheet> createState() =>
      _NewPaymentAccountBottomSheetState();
}

class _NewPaymentAccountBottomSheetState
    extends State<NewPaymentAccountBottomSheet> {
  GlobalKey<FormBuilderState> formBuilderKey = GlobalKey<FormBuilderState>();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    //
    final inputDec = InputDecoration(
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
        color: AppColor.cancelledColor,
      )),
      focusedBorder: OutlineInputBorder(
          //Chỉnh màu cho border khi nhấn vào
          borderSide: BorderSide(
        color: AppColor.cancelledColor,
        //
      )),
      //Đổi cỡ chữ hintText
      hintStyle: AppTextStyle.hintStyle(),
      labelStyle: AppTextStyle.h5TitleTextStyle(fontWeight: FontWeight.w600),
      //
    );
    //Chỉnh màu
    final textStyle = AppTextStyle.h5TitleTextStyle(
      fontWeight: FontWeight.w600,
    );
    return VStack(
      [
        //
        UiSpacer.formVerticalSpace(),
        "New Payment Account".tr().text.semiBold.xl2.make(),
        UiSpacer.formVerticalSpace(),
        UiSpacer.formVerticalSpace(),
        //
        FormBuilder(
          key: formBuilderKey,
          child: VStack(
            [
              //
              FormBuilderTextField(
                name: 'name',
                decoration: inputDec.copyWith(
                  hintText: "Enter account name".tr(),
                  labelText: "Account Name".tr(),
                ),
                style: textStyle,
                onChanged: (value) {},
                validator: CustomFormBuilderValidator.required,
                textInputAction: TextInputAction.next,
              ),
              UiSpacer.formVerticalSpace(),
              FormBuilderTextField(
                name: 'number',
                decoration: inputDec.copyWith(
                  hintText: "Enter account number".tr(),
                  labelText: "Account Number".tr(),
                ),
                style: textStyle,
                onChanged: (value) {},
                validator: CustomFormBuilderValidator.required,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
              ),
              UiSpacer.formVerticalSpace(),
              FormBuilderTextField(
                name: 'instructions',
                minLines: 4,
                maxLines: 5,
                decoration: inputDec.copyWith(
                    labelText: 'Instructions'.tr(),
                    hintText: "Enter instructions".tr()),
                style: textStyle,
                onChanged: (value) {},
                textInputAction: TextInputAction.next,
              ),
              UiSpacer.formVerticalSpace(),
              FormBuilderCheckbox(
                name: 'is_active',
                title: "Active".tr().text.make(),
                onChanged: (value) {},
              ),
              UiSpacer.formVerticalSpace(),
              CustomButton(
                loading: isLoading,
                title: "Save".tr(),
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  final result =
                      await widget.vm.saveNewPaymentAccount(formBuilderKey);
                  setState(() {
                    isLoading = false;
                  });

                  //
                  if (result) {
                    Navigator.pop(context);
                  }
                },
              ).wFull(context),
              UiSpacer.formVerticalSpace(),
            ],
          ),
        ),
      ],
    ).p20().scrollVertical().hThreeForth(context).pOnly(
          bottom: context.mq.viewInsets.bottom,
        );
  }
}
