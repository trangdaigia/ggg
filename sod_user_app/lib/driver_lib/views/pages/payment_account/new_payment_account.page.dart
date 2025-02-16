import 'package:flutter/material.dart';
import 'package:sod_user/driver_lib/services/validator.service.dart';
import 'package:sod_user/driver_lib/view_models/new_payment_account.vm.dart';
import 'package:sod_user/driver_lib/widgets/base.page.dart';
import 'package:sod_user/driver_lib/widgets/buttons/custom_button.dart';
import 'package:sod_user/driver_lib/widgets/custom_text_form_field.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class NewPaymentAccountPage extends StatelessWidget {
  const NewPaymentAccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //
    return BasePage(
      title: "New Payment Account".tr(),
      showLeadingAction: true,
      showAppBar: true,
      body: ViewModelBuilder<NewPaymentAccountViewModel>.reactive(
        viewModelBuilder: () => NewPaymentAccountViewModel(context),
        onViewModelReady: (vm) => vm.initialise(),
        builder: (context, vm, child) {
          return VStack(
            [
              //
              Form(
                key: vm.formKey,
                child: VStack(
                  [
                    //
                    CustomTextFormField(
                      hintText: "Enter bank name".tr(),
                      labelText: "Bank Name".tr(),
                      textEditingController: vm.bankNameTEC,
                      validator: FormValidator.validateName,
                    ).py12(),
                    CustomTextFormField(
                      hintText: "Enter account name".tr(),
                      labelText: "Account Name".tr(),
                      textEditingController: vm.nameTEC,
                      validator: FormValidator.validateName,
                    ).py12(),
                    CustomTextFormField(
                      hintText: "Enter account number".tr(),
                      labelText: "Account Number".tr(),
                      keyboardType: TextInputType.number,
                      textEditingController: vm.numberTEC,
                      validator: (value) => FormValidator.validateCustom(value),
                    ).py12(),
                    CustomTextFormField(
                      hintText: "Enter instructions".tr(),
                      labelText: "Instructions".tr(),
                      keyboardType: TextInputType.multiline,
                      textEditingController: vm.instructionsTEC,
                    ).py12(),
                    //
                    HStack(
                      [
                        Checkbox(
                          value: vm.isActive,
                          onChanged: (value) {
                            vm.isActive = value ?? false;
                            vm.notifyListeners();
                          },
                        ),
                        "Active".tr().text.make().expand(),
                      ],
                    ).py12(),

                    CustomButton(
                      title: "Save".tr(),
                      loading: vm.isBusy,
                      onPressed: vm.processSave,
                    ).centered().py12(),
                  ],
                  crossAlignment: CrossAxisAlignment.end,
                ),
              )
            ],
          ).p20().scrollVertical();
        },
      ),
    );
  }
}
