import 'package:flutter/material.dart';
import 'package:sod_vendor/services/validator.service.dart';
import 'package:sod_vendor/view_models/change_password.vm.dart';
import 'package:sod_vendor/widgets/base.page.dart';
import 'package:sod_vendor/widgets/buttons/custom_button.dart';
import 'package:sod_vendor/widgets/custom_text_form_field.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ChangePasswordViewModel>.reactive(
      viewModelBuilder: () => ChangePasswordViewModel(context),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return BasePage(
          showLeadingAction: true,
          showAppBar: true,
          title: "Change Password".tr(),
          body: SafeArea(
              top: true,
              bottom: false,
              child:
                  //
                  VStack(
                [
                  //form
                  Form(
                    key: model.formKey,
                    child: VStack(
                      [
                        //
                        CustomTextFormField(
                          labelText: "Current Password".tr(),
                          obscureText: true,
                          textEditingController: model.currentPasswordTEC,
                          validator: FormValidator.validatePassword,
                        ).py12(),
                        //
                        CustomTextFormField(
                          labelText: "New Password".tr(),
                          obscureText: true,
                          textEditingController: model.newPasswordTEC,
                          validator: FormValidator.validatePassword,
                        ).py12(),
                        //
                        CustomTextFormField(
                          labelText: "Confirm New Password".tr(),
                          obscureText: true,
                          textEditingController: model.confirmNewPasswordTEC,
                          validator: FormValidator.validatePassword,
                        ).py12(),

                        //
                        CustomButton(
                          title: "Update Password".tr(),
                          loading: model.isBusy,
                          onPressed: model.processUpdate,
                        ).centered().py12(),
                      ],
                    ),
                  ),
                ],
              ).p20().scrollVertical()),
        );
      },
    );
  }
}
