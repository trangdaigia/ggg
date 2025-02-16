import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_user/constants/app_text_styles.dart';
import 'package:sod_user/services/custom_form_builder_validator.service.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/utils/utils.dart';
import 'package:sod_user/view_models/account_delete.vm.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/widgets/custom_text_form_field.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

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
          //backgroundColor: context.theme.colorScheme.background,
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
                    .textStyle(AppTextStyle.h4TitleTextStyle(
                        fontWeight: FontWeight.w400))
                    .light
                    .make(),
                UiSpacer.vSpace(12),
                /*
                UiSpacer.divider(),
                UiSpacer.vSpace(12),

                //
                "Reasons:".tr().text.make(),
                UiSpacer.vSpace(5),
                FormBuilderRadioGroup(
                  wrapDirection: Axis.vertical,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  name: "reason",
                  validator: FormBuilderValidators.required(context),
                  options: vm.reasons.map(
                    (e) {
                      return FormBuilderFieldOption<String>(
                        value: e,
                        child: "$e".tr().text.make().wFull(context),
                      );
                    },
                  ).toList(),
                  onChanged: vm.onReasonChange,
                ),
                CustomVisibilty(
                  visible: vm.otherReason,
                  child: VStack(
                    [
                      UiSpacer.vSpace(5),
                      FormBuilderTextField(
                        name: "reason",
                        decoration: InputDecoration(
                          hintText: "Other reason".tr(),
                        ),
                      ),
                      UiSpacer.vSpace(10),
                    ],
                  ),
                ),
                */
                UiSpacer.divider(),
                UiSpacer.vSpace(),
                //verification section
                "Enter you account password to confirm account deletion"
                    .tr()
                    .text
                    .textStyle(AppTextStyle.h4TitleTextStyle(
                        fontWeight: FontWeight.w400))
                    .light
                    .make(),

                //verification coe input
                UiSpacer.vSpace(10),
                // FormBuilderTextField(
                //   name: "password",
                //   obscureText: true,
                //   decoration: InputDecoration(
                //     hintText: "Password".tr(),
                //     border: OutlineInputBorder(),
                //   ),
                //   validator: CustomFormBuilderValidator.required,
                // ),
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
