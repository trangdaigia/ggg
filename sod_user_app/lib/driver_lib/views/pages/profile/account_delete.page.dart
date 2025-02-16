import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_user/driver_lib/constants/app_text_styles.dart';
import 'package:sod_user/driver_lib/services/custom_form_builder_validator.service.dart';
import 'package:sod_user/driver_lib/utils/ui_spacer.dart';
import 'package:sod_user/driver_lib/utils/utils.dart';
import 'package:sod_user/driver_lib/view_models/account_delete.vm.dart';
import 'package:sod_user/driver_lib/widgets/base.page.dart';
import 'package:sod_user/driver_lib/widgets/buttons/custom_button.dart';
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
          backgroundColor: context.theme.colorScheme.background,
          body: FormBuilder(
            key: vm.formBuilderKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: VStack(
              [
                UiSpacer.vSpace(5),
                //description
                "You are about to delete your profile, please select an option below on why you are deleting your profile/account"
                    .tr()
                    .text
                    .medium
                    .make(),
                UiSpacer.vSpace(12),
                UiSpacer.divider(),
                UiSpacer.vSpace(),
                //verification section
                "Enter you account password to confirm account deletion"
                    .tr()
                    .text
                    .medium
                    .make(),

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
                ).py12(),
                //
                // FormBuilderTextField(
                //   name: "password",
                //   obscureText: true,
                //   decoration: InputDecoration(
                //     hintText: "Password".tr(),
                //     border: OutlineInputBorder()
                //   ),
                //   validator: CustomFormBuilderValidator.required,
                // ),
                //
                //submit btn
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
