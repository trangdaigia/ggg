import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:sod_vendor/constants/app_images.dart';
import 'package:sod_vendor/constants/app_strings.dart';
import 'package:sod_vendor/services/validator.service.dart';
import 'package:sod_vendor/utils/ui_spacer.dart';

import 'package:sod_vendor/view_models/forgot_password.view_model.dart';
import 'package:sod_vendor/widgets/base.page.dart';
import 'package:sod_vendor/widgets/buttons/custom_button.dart';
import 'package:sod_vendor/widgets/custom_text_form_field.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import '../../../constants/app_text_styles.dart';

class ForgotPasswordPage extends StatefulWidget {
  ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  @override
  Widget build(BuildContext context) {
    final style = AppTextStyle.h5TitleTextStyle(
      color: Theme.of(context).textTheme.bodyLarge!.color,
      fontWeight: FontWeight.w600,
    );
    return ViewModelBuilder<ForgotPasswordViewModel>.reactive(
      viewModelBuilder: () => ForgotPasswordViewModel(context),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return BasePage(
          showLeadingAction: true,
          showAppBar: true,
          title: "Forgot Password".tr(),
          body: SafeArea(
            top: true,
            bottom: false,
            child: VStack(
              [
                Image.asset(
                  AppImages.onboarding1,
                ).hOneForth(context).centered(),
                //
                VStack(
                  [
                    //
                    "Forgot Password".tr().text.xl2.semiBold.make(),

                    //form
                    Form(
                      key: model.formKey,
                      child: VStack(
                        [
                          //
                                 // check if enable otp is enable
                          if (AppStrings.enableEmailLogin &&
                              !AppStrings.enableOtp)
                            CustomTextFormField(
                              hintText: "Enter your email address".tr(),
                              keyboardType: TextInputType.emailAddress,
                              textEditingController: model.emailTEC,
                              validator: FormValidator.validateEmail,
                            ).py12()
                          else
                          CustomTextFormField(
                            prefixIcon: HStack(
                              [
                                //icon/flag
                                Flag.fromString(
                                  model.selectedCountry.countryCode,
                                  width: 20,
                                  height: 20,
                                ),
                                UiSpacer.horizontalSpace(space: 5),
                                //text
                                ("+" + model.selectedCountry.phoneCode)
                                    .text
                                    .textStyle(style)
                                    .make(),
                              ],
                            ).px8().onInkTap(model.showCountryDialPicker),
                            //labelText: "Phone Number".tr(),
                            hintText: "Enter your phone number".tr(),
                            keyboardType: TextInputType.phone,
                            textEditingController: model.phoneTEC,
                            validator: FormValidator.validatePhone,
                          ).py12(),
                          //
                          CustomButton(
                            title: "Send OTP".tr(),
                            loading: model.isBusy,
                            onPressed: model.processForgotPassword,
                          ).h(Vx.dp48).centered().py12(),
                        ],
                        crossAlignment: CrossAxisAlignment.end,
                      ),
                    ).py20(),
                  ],
                )
                    .wFull(context)
                    .p20()
                    .scrollVertical()
                    .box
                    .color(context.cardColor)
                    .make()
                    .expand(),

                //
              ],
            ),
          ),
        );
      },
    );
  }
}
