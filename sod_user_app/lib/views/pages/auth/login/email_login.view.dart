import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_user/services/validator.service.dart';
import 'package:sod_user/view_models/login.view_model.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:sod_user/widgets/custom_text_form_field.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class EmailLoginView extends StatelessWidget {
  const EmailLoginView(this.model, {Key? key}) : super(key: key);

  final LoginViewModel model;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: model.formKey,
      child: VStack(
        [
          //
          CustomTextFormField(
            prefixIcon: Icon(
              MaterialIcons.mail_outline,
              color: //AppColor.primaryMaterialColorDark
                  Theme.of(context).textTheme.bodyLarge!.color,
            ),
            hintText: "Enter your email".tr(),
            keyboardType: TextInputType.emailAddress,
            textEditingController: model.emailTEC,
            validator: FormValidator.validateEmail,
            inputFormatters: [
              FilteringTextInputFormatter.deny(
                RegExp(' '),
              ),
            ],
          ).py12(),
          CustomTextFormField(
            prefixIcon: Icon(
              MaterialIcons.lock_outline,
              color: Theme.of(context).textTheme.bodyLarge!.color,
            ),
            hintText: "Enter your password".tr(),
            obscureText: true,
            textEditingController: model.passwordTEC,
            validator: FormValidator.validatePassword,
          ).py12(),

          //
          "Forgot Password ?".tr().text.underline.make().onInkTap(
                model.openForgotPassword,
              ),
          //
          CustomButton(
            title: "Login".tr(),
            loading: model.isBusy,
            onPressed: model.processLogin,
          ).centered().py12(),
        ],
        crossAlignment: CrossAxisAlignment.end,
      ),
    ).py20();
  }
}
