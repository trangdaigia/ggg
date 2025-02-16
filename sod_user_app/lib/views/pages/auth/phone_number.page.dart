import 'package:flag/flag_widget.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_text_styles.dart';
import 'package:sod_user/services/validator.service.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/view_models/login.view_model.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:sod_user/widgets/custom_text_form_field.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class PhoneNumberInputPage extends StatefulWidget {
  const PhoneNumberInputPage({Key? key, required this.model}) : super(key: key);
  final LoginViewModel model;

  @override
  _PhoneNumberInputPageState createState() => _PhoneNumberInputPageState();
}

class _PhoneNumberInputPageState extends State<PhoneNumberInputPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyle.h5TitleTextStyle(
      color: Theme.of(context).textTheme.bodyLarge!.color,
      fontWeight: FontWeight.w600,
    );

    return ViewModelBuilder.reactive(
      viewModelBuilder: () => widget.model,
      disposeViewModel: false,
      builder: (context, viewModel, child) => BasePage(
        showLeadingAction: true,
        showAppBar: true,
        onBackPressed: () => {Navigator.pop(context, false)},
        appBarColor: Colors.transparent,
        title: "Register Phone Number".tr(),
        elevation: 0,
        isLoading: widget.model.isBusy,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: VStack(
                [
                  "Input a phone number you'd like to add to your account"
                      .tr()
                      .text
                      .lg
                      .color(Theme.of(context).textTheme.bodyLarge!.color)
                      .make(),
                  UiSpacer.verticalSpace(space: 20),
                  HStack(
                    [
                      CustomTextFormField(
                        prefixIcon: HStack(
                          [
                            Flag.fromString(
                              widget.model.selectedCountry?.countryCode ?? "vi",
                              width: 20,
                            height: 20,
                            ),
                            UiSpacer.horizontalSpace(space: 5),
                            ("+" +
                                    (widget.model.selectedCountry?.phoneCode ??
                                        "84"))
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
                  CustomButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final result = await widget.model.verifyPhoneNumber();
                        if (result) Navigator.of(context).pop(true);
                      }
                    },
                    title: "Continue".tr(),
                    loading: widget.model.isBusy,
                  ).centered().py12(),
                ],
              ).scrollVertical(),
            ),
          ),
        ),
      ),
    );
  }
}
