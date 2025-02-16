import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_vendor/constants/app_colors.dart';
import 'package:sod_vendor/services/custom_form_builder_validator.service.dart';
import 'package:sod_vendor/utils/ui_spacer.dart';
import 'package:sod_vendor/utils/utils.dart';
import 'package:sod_vendor/view_models/account_delete.vm.dart';
import 'package:sod_vendor/widgets/base.page.dart';
import 'package:sod_vendor/widgets/buttons/custom_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../widgets/custom_text_form_field.dart';

class AccountDeletePage extends StatelessWidget {
  const AccountDeletePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AccountDeleteViewModel>.reactive(
      viewModelBuilder: () => AccountDeleteViewModel(context),
      disposeViewModel: false,
      builder: (context, vm, child) {
        return BasePage(
          showAppBar: true,
          showLeadingAction: true,
          elevation: 0,
          title: "Delete Account".tr(),
          appBarItemColor: Utils.textColorByTheme(),
          backgroundColor: AppColor.onboarding3Color,
          body: FormBuilder(
            key: vm.formBuilderKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: VStack(
              [
                UiSpacer.vSpace(5),
                //description
                // "We're sorry to see you go, but we understand that sometimes things change. If you're sure you want to delete your account, we want to make the process as simple and straightforward as possible."
                //     .tr()
                //     .text
                //     .make(),
                //verification section
                "Deleting your account is permanent, and it cannot be undone."
                    .tr()
                    .text
                    .semiBold
                    .make()
                    .py(10),

                "This means all your data, including profile information, preferences, and activity history, will be permanently removed from our system. You won't be able to recover any of this information once the account deletion is complete."
                    .tr()
                    .text
                    .make(),

                UiSpacer.divider().py(15),
                "Enter you account password to confirm account deletion"
                    .tr()
                    .text
                    .make(),
                UiSpacer.vSpace(5),

                //verification coe input
                UiSpacer.vSpace(10),
                CustomTextFormField(
                  prefixIcon: Icon(
                    MaterialIcons.lock_outline,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                  //labelText: "Password".tr(),
                  hintText: "Enter your password".tr(),
                  obscureText: true,
                  validator: CustomFormBuilderValidator.required,
                ).py12(), //submit btn
                UiSpacer.vSpace(10),
                CustomButton(
                  title: "Submit".tr(),
                  loading: vm.isBusy,
                  onPressed: vm.processAccountDeletion,
                ).wFull(context)
              ],
            ),
          ).scrollVertical(
            padding: EdgeInsets.fromLTRB(
              Vx.dp20,
              Vx.dp20,
              Vx.dp20,
              context.mq.viewInsets.bottom + Vx.dp20,
            ),
          ),
        );
      },
    );
  }
}
