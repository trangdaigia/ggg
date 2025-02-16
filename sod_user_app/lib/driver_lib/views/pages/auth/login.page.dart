import 'package:flutter/material.dart';
import 'package:sod_user/driver_lib/constants/app_colors.dart';
import 'package:sod_user/driver_lib/constants/app_images.dart';
import 'package:sod_user/driver_lib/constants/app_strings.dart';
import 'package:sod_user/driver_lib/utils/ui_spacer.dart';
import 'package:sod_user/driver_lib/view_models/login.view_model.dart';
import 'package:sod_user/driver_lib/views/pages/auth/login/compain_login_type.view.dart';
import 'package:sod_user/driver_lib/views/pages/auth/login/email_login.view.dart';
import 'package:sod_user/driver_lib/views/pages/auth/login/otp_login.view.dart';
import 'package:sod_user/driver_lib/widgets/base.page.dart';
import 'package:sod_user/driver_lib/widgets/buttons/custom_text_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/driver_lib/widgets/menu_item.dart';
import 'package:sod_user/driver_lib/view_models/profile.vm.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../constants/app_text_styles.dart';
import 'login/scan_login.view.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final style = AppTextStyle.h5TitleTextStyle(
      color: Theme.of(context).textTheme.bodyLarge!.color,
      fontWeight: FontWeight.w600,
    );
    ProfileViewModel vm = ProfileViewModel(context);

    return ViewModelBuilder<LoginViewModel>.reactive(
      viewModelBuilder: () => LoginViewModel(context),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return BasePage(
          backgroundColor: context.theme.colorScheme.background,
          body: VStack(
            [
              UiSpacer.vSpace(10 * context.percentHeight),
              //
              Align(
                alignment: Alignment.centerRight,
                child: MenuItem(
                  title: "Language".tr(),
                  isExpanded: false,
                  divider: false,
                  suffix: Icon(
                    FlutterIcons.language_ent,
                  ),
                  onPressed: vm.changeLanguage,
                ),
              ),
              SizedBox(height: 5),
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
                              color:
                                  Theme.of(context).textTheme.bodyLarge!.color,
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

              //form
              //LOGIN Section
              //both login type
              if (AppStrings.enableOTPLogin && AppStrings.enableEmailLogin)
                CombinedLoginTypeView(model),
              //only email login
              if (AppStrings.enableEmailLogin && !AppStrings.enableOTPLogin)
                EmailLoginView(model),
              //only otp login
              if (AppStrings.enableOTPLogin && !AppStrings.enableEmailLogin)
                OTPLoginView(model),

              ScanLoginView(model),
              20.heightBox,

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

              //
            ],
            crossAlignment: CrossAxisAlignment.end,
          ).wFull(context).p20().scrollVertical().pOnly(
                bottom: context.mq.viewInsets.bottom,
              ),
        );
      },
    );
  }
}
