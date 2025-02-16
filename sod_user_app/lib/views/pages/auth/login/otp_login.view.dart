import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/services/validator.service.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/view_models/login.view_model.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:sod_user/widgets/custom_text_form_field.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../../constants/app_text_styles.dart';

class OTPLoginView extends StatefulWidget {
  const OTPLoginView(this.model, {Key? key}) : super(key: key);

  final LoginViewModel model;

  @override
  State<OTPLoginView> createState() => _OTPLoginViewState();
}

class _OTPLoginViewState extends State<OTPLoginView> {
  bool _isPasswordLogin = true; // Tracks whether password login is enabled

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyle.h5TitleTextStyle(
      color: Theme.of(context).textTheme.bodyLarge!.color,
      fontWeight: FontWeight.w600,
    );

    return Form(
      key: widget.model.formKey,
      child: VStack(
        [
          // Toggle button styled like Apple's login UI
          Visibility(
            visible: AppStrings.otpGateway != "none",
            child: Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isPasswordLogin = !_isPasswordLogin;
                  });
                },
                child: (_isPasswordLogin
                        ? "Login without password"
                        : "Login with password")
                    .tr()
                    .text
                    .color(Theme.of(context).primaryColor)
                    .semiBold
                    .make()
                    .p8(),
              ),
            ),
          ),

          // Phone number input
          HStack(
            [
              CustomTextFormField(
                prefixIcon: HStack(
                  [
                    // Icon/flag
                    Flag.fromString(
                      widget.model.selectedCountry?.countryCode ?? "vi",
                      width: 20,
                      height: 20,
                    ),
                    UiSpacer.horizontalSpace(space: 5),
                    // Text
                    ("+" + (widget.model.selectedCountry?.phoneCode ?? "84"))
                        .text
                        .textStyle(style)
                        .make(),
                  ],
                ).px8().onInkTap(widget.model.showCountryDialPicker),
                hintText: "Enter your phone number".tr(),
                keyboardType: TextInputType.phone,
                textEditingController: widget.model.phoneTEC,
                validator: FormValidator.validatePhone,
              ).expand(),
            ],
          ).py12(),

          // Password input (conditionally visible)
          if (_isPasswordLogin || AppStrings.otpGateway == "none")
            CustomTextFormField(
              labelText: "Password".tr(),
              hintText: "Enter your password".tr(),
              obscureText: true,
              textEditingController: widget.model.passwordTEC,
              validator: FormValidator.validatePassword,
              inputFormatters: [
                FilteringTextInputFormatter.deny(
                  RegExp(' '),  
                ), // Removes spaces
              ],
            ).py12(),
          Visibility(
            visible: _isPasswordLogin && AppStrings.otpGateway == "none",
            child: "Forgot Password?".tr().text.underline.make().onInkTap(
                  widget.model.openForgotPassword,
                ),
          ),
          // Login button
          CustomButton(
            title: "Login".tr(),
            loading:
                widget.model.isBusy || widget.model.busy(widget.model.otpLogin),
            onPressed: () =>
                widget.model.processOTPLogin(withPassword: _isPasswordLogin),
          ).centered().py12(),
        ],
        crossAlignment: CrossAxisAlignment.end,
      ),
    ).py20();
  }
}
