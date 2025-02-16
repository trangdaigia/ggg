import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/api.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_images.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/constants/app_text_styles.dart';
import 'package:sod_user/resources/resources.dart';
import 'package:sod_user/services/custom_form_builder_validator.service.dart';
import 'package:sod_user/services/validator.service.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/view_models/register.view_model.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:sod_user/widgets/custom_text_form_field.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:sod_user/widgets/menu_item.dart';
import 'package:sod_user/view_models/profile.vm.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({
    this.email,
    this.name,
    this.phone,
    Key? key,
  }) : super(key: key);

  final String? email;
  final String? name;
  final String? phone;
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    ProfileViewModel vm = ProfileViewModel(context);

    return ViewModelBuilder<RegisterViewModel>.reactive(
      viewModelBuilder: () => RegisterViewModel(context),
      onViewModelReady: (model) {
        model.nameTEC.text = widget.name ?? "";
        model.emailTEC.text = widget.email ?? "";
        model.phoneTEC.text = widget.phone ?? "";
        model.initialise();
      },
      builder: (context, model, child) {
        //
        final style = AppTextStyle.h5TitleTextStyle(
          color: Theme.of(context).textTheme.bodyLarge!.color,
          fontWeight: FontWeight.w600,
        );
        return BasePage(
          showLeadingAction: true,
          showAppBar: true,
          body: SafeArea(
            top: true,
            bottom: false,
            child: Padding(
              padding: EdgeInsets.only(bottom: context.mq.viewInsets.bottom),
              child: VStack(
                [
                  //
                  VStack(
                    [
                      //
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              "Join Us".tr().text.xl2.semiBold.make(),
                              "Create an account now".tr().text.light.make(),
                            ],
                          ),
                          MenuItem(
                            title: "Language".tr(),
                            divider: false,
                            isExpanded: false,
                            ic: AppIcons.translation,
                            showSuffix: false,
                            onPressed: vm.changeLanguage,
                            padV: 7,
                          ),
                        ],
                      ),

                      //form
                      Form(
                        key: model.formKey,
                        child: VStack(
                          [
                            //
                            CustomTextFormField(
                              hintText: "Enter your name".tr(),
                              labelText: "Name".tr(),
                              textEditingController: model.nameTEC,
                              validator: FormValidator.validateName,
                            ).py12(),
                            //
                            Visibility(
                              visible: AppStrings.enableEmailLogin,
                              child: CustomTextFormField(
                                hintText: "Enter your email".tr(),
                                labelText: "Email".tr(),
                                keyboardType: TextInputType.emailAddress,
                                textEditingController: model.emailTEC,
                                validator: FormValidator.validateEmail,
                                //remove space
                                inputFormatters: [
                                  FilteringTextInputFormatter.deny(
                                    RegExp(' '),
                                  ), // removes spaces
                                ],
                              ),
                            ),
                            //
                            HStack(
                              [
                                CustomTextFormField(
                                  prefixIcon: HStack(
                                    [
                                      //icon/flag
                                      Flag.fromString(
                                        model.selectedCountry?.countryCode ??
                                            "vi",
                                        width: 20,
                                        height: 20,
                                      ),
                                      UiSpacer.horizontalSpace(space: 5),
                                      //text
                                      ("+" +
                                              (model.selectedCountry
                                                      ?.phoneCode ??
                                                  "84"))
                                          .text
                                          .textStyle(style)
                                          .make(),
                                    ],
                                  ).px8().onInkTap(model.showCountryDialPicker),
                                  labelText: "Phone".tr(),
                                  hintText: "Enter your phone number".tr(),
                                  keyboardType: TextInputType.phone,
                                  textEditingController: model.phoneTEC,
                                  validator: FormValidator.validatePhone,
                                  //remove space
                                  inputFormatters: [
                                    FilteringTextInputFormatter.deny(
                                      RegExp(' '),
                                    ), // removes spaces
                                  ],
                                ).expand(),
                              ],
                            ).py12(),
                            //
                            CustomTextFormField(
                              labelText: "Password".tr(),
                              hintText: "Enter your password".tr(),
                              obscureText: true,
                              textEditingController: model.passwordTEC,
                              validator: FormValidator.validatePassword,
                              //remove space
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(
                                  RegExp(' '),
                                ), // removes spaces
                              ],
                            ).py12(),
                            //
                            AppStrings.enableReferSystem
                                ? CustomTextFormField(
                                    hintText: "Enter referral code".tr(),
                                    labelText: "Referral Code(optional)".tr(),
                                    textEditingController:
                                        model.referralCodeTEC,
                                  ).py12()
                                : UiSpacer.emptySpace(),

                            //terms
                            // HStack(
                            //   [
                            //     Checkbox(
                            //       value: model.agreed,
                            //       onChanged: (value) {
                            //         model.agreed = value ?? false;
                            //         model.notifyListeners();
                            //       },
                            //     ),
                            //     //
                            //     "I agree with".tr().text.make(),
                            //     UiSpacer.horizontalSpace(space: 2),
                            //     "Terms & Conditions"
                            //         .tr()
                            //         .text
                            //         .color(AppColor.primaryColor)
                            //         .bold
                            //         .underline
                            //         .make()
                            //     .onInkTap(model.openTerms)
                            //         .expand(),
                            //   ],
                            // ),
                            FormBuilderCheckbox(
                              onChanged: (value) {
                                model.agreed = value ?? false;
                                model.notifyListeners();
                              },
                              name: "agreed",
                              title: "I agree with"
                                  .tr()
                                  .richText
                                  .semiBold
                                  .withTextSpanChildren(
                                [
                                  " ".textSpan.make(),
                                  "Terms & Conditions"
                                      .tr()
                                      .textSpan
                                      .underline
                                      .semiBold
                                      .tap(() {
                                        model.openWebpageLink(Api.terms);
                                      })
                                      .color(AppColor.primaryColor)
                                      .make(),
                                ],
                              ).make(),
                              activeColor: AppColor.primaryColor,
                              validator: (value) =>
                                  CustomFormBuilderValidator.required(
                                value,
                                errorTitle:
                                    "Please confirm you have accepted our terms and conditions"
                                        .tr(),
                              ),
                            ),
                            //
                            CustomButton(
                              title: "Create Account".tr(),
                              loading: model.isBusy,
                              onPressed: model.processRegister,
                            ).centered().py12(),

                            //register
                            "OR".tr().text.light.makeCentered(),
                            "Already have an Account"
                                .tr()
                                .text
                                .semiBold
                                .makeCentered()
                                .py12()
                                .onInkTap(model.openLogin),
                          ],
                          crossAlignment: CrossAxisAlignment.end,
                        ),
                      ).py20(),
                    ],
                  ).wFull(context).p20(),

                  //
                ],
              ).scrollVertical(),
            ),
          ),
        );
      },
    );
  }
}
