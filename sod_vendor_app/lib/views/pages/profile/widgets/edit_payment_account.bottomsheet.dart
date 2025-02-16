import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:sod_vendor/models/payment_account.dart';
import 'package:sod_vendor/services/custom_form_builder_validator.service.dart';
import 'package:sod_vendor/utils/ui_spacer.dart';
import 'package:sod_vendor/view_models/payment_accounts.vm.dart';
import 'package:sod_vendor/widgets/buttons/custom_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class EditPaymentAccountBottomSheet extends StatefulWidget {
  EditPaymentAccountBottomSheet(
    this.vm, {
    required this.paymentAccount,
    Key? key,
  }) : super(key: key);

  final PaymentAccountsViewModel vm;
  final PaymentAccount paymentAccount;

  @override
  State<EditPaymentAccountBottomSheet> createState() =>
      _EditPaymentAccountBottomSheetState();
}

class _EditPaymentAccountBottomSheetState
    extends State<EditPaymentAccountBottomSheet> {
  GlobalKey<FormBuilderState> formBuilderKey = GlobalKey<FormBuilderState>();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    //
    return VStack(
      [
        //
        UiSpacer.formVerticalSpace(),
        "Edit Payment Account".tr().text.semiBold.xl2.make(),
        UiSpacer.formVerticalSpace(),
        UiSpacer.formVerticalSpace(),
        //
        FormBuilder(
          key: formBuilderKey,
          initialValue: {
            ...widget.paymentAccount.toJson(),
            "is_active": widget.paymentAccount.isActive,
          },
          child: VStack(
            [
              //
              FormBuilderTextField(
                name: 'name',
                decoration: InputDecoration(
                  labelText: 'Account Name'.tr(),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {},
                validator: CustomFormBuilderValidator.required,
                textInputAction: TextInputAction.next,
              ),
              UiSpacer.formVerticalSpace(),
              FormBuilderTextField(
                name: 'number',
                decoration: InputDecoration(
                  labelText: 'Account Number'.tr(),
                  border: OutlineInputBorder(),
                ),
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
                decoration: InputDecoration(
                  labelText: 'Instructions'.tr(),
                  border: OutlineInputBorder(),
                ),
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
                  //proces request
                  final result = await widget.vm.processPaymentAccountUpdate(
                    formBuilderKey,
                    widget.paymentAccount,
                  );
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
