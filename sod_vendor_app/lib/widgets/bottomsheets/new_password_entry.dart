import 'package:flutter/material.dart';
import 'package:sod_vendor/services/validator.service.dart';
import 'package:sod_vendor/view_models/forgot_password.view_model.dart';
import 'package:sod_vendor/widgets/buttons/custom_button.dart';
import 'package:sod_vendor/widgets/custom_text_form_field.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class NewPasswordEntry extends StatefulWidget {
  const NewPasswordEntry({
    required this.onSubmit,
    required this.vm,
    this.canSkip = false,
    Key? key,
  }) : super(key: key);

  final Function(String) onSubmit;
  final ForgotPasswordViewModel vm;
  final bool canSkip;
  @override
  _NewPasswordEntryState createState() => _NewPasswordEntryState();
}

class _NewPasswordEntryState extends State<NewPasswordEntry> {
  final resetFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    //

    return Form(
      key: resetFormKey,
      child: VStack(
        [
          //
          "New Password".tr().text.bold.xl2.makeCentered(),
          "Please enter account new password".tr().text.makeCentered(),
          //pin code
          CustomTextFormField(
            labelText: "New Password".tr(),
            textEditingController: widget.vm.passwordTEC,
            validator: FormValidator.validatePassword,
            obscureText: true,
          ).py12(),
          //submit
          CustomButton(
            title: "Reset Password".tr(),
            onPressed: () {
              if (resetFormKey.currentState!.validate()) {
                widget.onSubmit(widget.vm.passwordTEC.text);
              }
            },
          ),
          4.heightBox,
          CustomButton(
            title: "Keep the current password".tr(),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ).p20(),
    );
  }
}
