import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flag/flag_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_vendor/constants/app_images.dart';
import 'package:sod_vendor/constants/app_strings.dart';
import 'package:sod_vendor/services/validator.service.dart';
import 'package:sod_vendor/utils/ui_spacer.dart';
import 'package:sod_vendor/view_models/login.view_model.dart';
import 'package:sod_vendor/view_models/profile.vm.dart';
import 'package:sod_vendor/widgets/base.page.dart';
import 'package:sod_vendor/widgets/buttons/custom_button.dart';
import 'package:sod_vendor/widgets/menu_item.dart';

import 'package:sod_vendor/widgets/custom_text_form_field.dart';

import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../widgets/buttons/custom_text_button.dart';
import 'login/scan_login.view.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool useOTP = AppStrings.enableOTPLogin;

  bool _isPasswordLogin = true;

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyle.h5TitleTextStyle(
      fontWeight: FontWeight.w600,
    );
    ProfileViewModel vm = ProfileViewModel(context);

    return ViewModelBuilder<LoginViewModel>.reactive(
      viewModelBuilder: () => LoginViewModel(context),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return BasePage(
          isLoading: model.isBusy,
          body: SafeArea(
            top: true,
            bottom: false,
            child: VStack([
              UiSpacer.vSpace(5 * context.percentHeight),
              //
              Align(
                alignment: Alignment.centerRight,
                child: MenuItem(
                  title: "Language".tr(),
                  isExpanded: false,
                  divider: false,
                  suffix: Icon(
                    FlutterIcons.language_ent,
                    color: Colors.black,
                  ),
                  onPressed: vm.changeLanguage,
                ),
              ),
              SizedBox(height: 10),
              HStack(
                [
                  VStack(
                    [
                      "Welcome Back"
                          .tr()
                          .text
                          .xl2
                          .semiBold
                          .size(17)
                          .textStyle(style)
                          .make(),
                      "Login to continue"
                          .tr()
                          .text
                          .light
                          .textStyle(AppTextStyle.h6TitleTextStyle(
                              fontWeight: FontWeight.w400))
                          .make(),
                    ],
                  ).expand(),
                  UiSpacer.hSpace(),
                  Image.asset(AppImages.appLogo)
                      .wh(70, 70)
                      .box
                      .roundedFull
                      .clip(Clip.antiAlias)
                      .make()
                      .p12(),
                ],
                crossAlignment: CrossAxisAlignment.center,
                alignment: MainAxisAlignment.center,
              ),
              if (AppStrings.enableEmailLogin && AppStrings.enableOTPLogin)
                CustomSlidingSegmentedControl<int>(
                  isStretch: true,
                  initialValue: 1,
                  children: {
                    1: Text("Phone Number".tr(),
                        style: AppTextStyle.h4TitleTextStyle(
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                          fontWeight: FontWeight.w600,
                        )),
                    2: Text("Email Address".tr(),
                        style: AppTextStyle.h4TitleTextStyle(
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                          fontWeight: FontWeight.w600,
                        )),
                  },
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.background,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.fromBorderSide(
                      BorderSide(
                        color: AppColor.primaryColor,
                        width: 1.5,
                      ),
                    ),
                  ),
                  thumbDecoration: BoxDecoration(
                    color: context.theme.colorScheme.background,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.primaryColor.withOpacity(.4),
                        blurRadius: 5.0,
                        spreadRadius: 1.5,
                        offset: Offset(
                          0.0,
                          2.0,
                        ),
                      ),
                    ],
                  ),
                  duration: Duration(milliseconds: 300),
                  // customSegmentSettings: CustomSegmentSettings(
                  //   highlightColor: Colors.red,
                  //   splashColor: Colors.green,
                  // ),
                  curve: Curves.easeInToLinear,
                  onValueChanged: (value) {
                    setState(() {
                      useOTP = value == 1;
                    });
                  },
                ).centered(),
              //form
              useOTP
                  ? Form(
                      key: model.formKey,
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
                                      model.selectedCountry?.countryCode ??
                                          "vi",
                                      width: 20,
                                      height: 20,
                                    ),
                                    UiSpacer.horizontalSpace(space: 5),
                                    // Text
                                    ("+" +
                                            (model.selectedCountry?.phoneCode ??
                                                "84"))
                                        .text
                                        .textStyle(style)
                                        .make(),
                                  ],
                                ).px8().onInkTap(model.showCountryDialPicker),
                                hintText: "Enter your phone number".tr(),
                                keyboardType: TextInputType.phone,
                                textEditingController: model.phoneTEC,
                                validator: FormValidator.validatePhone,
                              ).expand(),
                            ],
                          ).py12(),

                          // Password input (conditionally visible)
                          if (_isPasswordLogin ||
                              AppStrings.otpGateway == "none")
                            CustomTextFormField(
                              labelText: "Password".tr(),
                              hintText: "Enter your password".tr(),
                              obscureText: true,
                              textEditingController: model.passwordTEC,
                              validator: FormValidator.validatePassword,
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(
                                  RegExp(' '),
                                ), // Removes spaces
                              ],
                            ).py12(),
                          Visibility(
                            visible: _isPasswordLogin &&
                                AppStrings.otpGateway == "none",
                            child: "Forgot Password?"
                                .tr()
                                .text
                                .underline
                                .make()
                                .onInkTap(
                                  model.openForgotPassword,
                                ),
                          ),
                          // Login button
                          CustomButton(
                            title: "Login".tr(),
                            loading: model.isBusy || model.busy(model.otpLogin),
                            onPressed: () => model.processOTPLogin(
                                withPassword: _isPasswordLogin),
                          ).centered().py12(),
                        ],
                        crossAlignment: CrossAxisAlignment.end,
                      ),
                    ).py20()
                  : Form(
                      key: model.formKey,
                      child: VStack(
                        [
                          //
                          CustomTextFormField(
                            prefixIcon: Icon(
                              MaterialIcons.mail_outline,
                            ),
                            hintText: "Enter your email".tr(),
                            keyboardType: TextInputType.emailAddress,
                            textEditingController: model.emailTEC,
                            validator: FormValidator.validateEmail,
                          ).py12(),
                          CustomTextFormField(
                            prefixIcon: Icon(
                              MaterialIcons.lock_outline,
                            ),
                            hintText: "Enter your password".tr(),
                            obscureText: true,
                            textEditingController: model.passwordTEC,
                            validator: FormValidator.validatePassword,
                          ).py12(),
                          //
                          "Forgot Password ?"
                              .tr()
                              .text
                              .underline
                              .make()
                              .onInkTap(
                                model.openForgotPassword,
                              ),
                          //
                          CustomButton(
                            title: "Login".tr(),
                            loading: model.isBusy,
                            onPressed: model.processLogin,
                          ).centered().py12(),
                          ScanLoginView(model),
                        ],
                        crossAlignment: CrossAxisAlignment.end,
                      ),
                    ).py20(),
              //registration link
              Visibility(
                visible: AppStrings.partnersCanRegister,
                child: CustomTextButton(
                  title: "Become a partner".tr(),
                  onPressed: model.openRegistrationlink,
                )
                    .wFull(context)
                    .box
                    .roundedSM
                    .border(color: AppColor.primaryColor)
                    .make(),
              ),
            ])
                .wFull(context)
                .p20()
                .scrollVertical()
                .pOnly(bottom: context.mq.viewInsets.bottom),
          ),
        );
      },
    );
  }
}
