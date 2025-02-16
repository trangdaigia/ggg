import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:sod_vendor/constants/api.dart';
import 'package:sod_vendor/constants/app_colors.dart';
import 'package:sod_vendor/constants/app_page_settings.dart';
import 'package:sod_vendor/constants/app_strings.dart';
import 'package:sod_vendor/models/address.dart';
import 'package:sod_vendor/services/custom_form_builder_validator.service.dart';
import 'package:sod_vendor/utils/ui_spacer.dart';
import 'package:sod_vendor/utils/utils.dart';
import 'package:sod_vendor/view_models/register.view_model.dart';
import 'package:sod_vendor/widgets/base.page.dart';
import 'package:sod_vendor/widgets/buttons/custom_button.dart';
import 'package:sod_vendor/widgets/cards/document_selection.view.dart';
import 'package:sod_vendor/widgets/states/custom_loading.state.dart';
import 'package:sod_vendor/widgets/menu_item.dart';
import 'package:sod_vendor/view_models/profile.vm.dart';

import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import '../../../constants/app_text_styles.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    ProfileViewModel pvm = ProfileViewModel(context);

    //
    final inputDec = InputDecoration(
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
          color: AppColor.cancelledColor,
        )),
        focusedBorder: OutlineInputBorder(
            //Chỉnh màu cho border khi nhấn vào
            borderSide: BorderSide(
          color: AppColor.cancelledColor,
          //
        )),
        //Đổi cỡ chữ hintText
        hintStyle: AppTextStyle.hintStyle()
        //
        );
    //Chỉnh màu
    final labelStyle =
        AppTextStyle.h5TitleTextStyle(fontWeight: FontWeight.w600);
    final style = AppTextStyle.h5TitleTextStyle(
      fontWeight: FontWeight.w600,
    );
    //
    return ViewModelBuilder<RegisterViewModel>.reactive(
      viewModelBuilder: () => RegisterViewModel(context),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        return BasePage(
          isLoading: vm.isBusy,
          body: FormBuilder(
            key: vm.formBuilderKey,
            child: VStack(
              [
                //appbar
                SafeArea(
                  child: HStack(
                    [
                      Icon(
                        FlutterIcons.close_ant,
                        size: 24,
                        color: Utils.textColorByTheme(),
                      ).p8().onInkTap(() {
                        Navigator.pop(context);
                      }).p12(),
                    ],
                  ),
                ).box.color(AppColor.primaryColor).make().wFull(context),
                Align(
                  alignment: Alignment.centerRight,
                  child: MenuItem(
                    title: "Language".tr(),
                    isExpanded: false,
                    divider: false,
                    textColor: Colors.white,
                    borderColor: Colors.white,
                    suffix: Icon(
                      FlutterIcons.language_ent,
                      color: Colors.white,
                    ),
                    onPressed: pvm.changeLanguage,
                  ),
                )
                    .pOnly(right: 20)
                    .box
                    .color(AppColor.primaryColor)
                    .make()
                    .wFull(context),
                //
                VStack(
                  [
                    //
                    VStack(
                      [
                        "Become a partner"
                            .tr()
                            .text
                            .xl3
                            .color(Utils.textColorByTheme())
                            .textStyle(style)
                            .bold
                            .make(),
                        "Fill form below to continue"
                            .tr()
                            .text
                            .light
                            .color(Utils.textColorByTheme())
                            .make(),
                      ],
                    )
                        .p20()
                        .box
                        .color(AppColor.primaryColor)
                        .make()
                        .wFull(context),

                    //form
                    VStack(
                      [
                        //
                        "Business Information"
                            .tr()
                            .text
                            .underline
                            .xl
                            .semiBold
                            .make(),
                        UiSpacer.vSpace(30),
                        //
                        FormBuilderTextField(
                          name: "vendor_name",
                          style: style,
                          cursorColor: AppColor.cursorColor,
                          validator: CustomFormBuilderValidator.required,
                          decoration: inputDec.copyWith(
                            prefixIcon: Icon(
                              MaterialIcons.person_outline,
                            ),
                            hintText: "Enter your name".tr(),
                            labelText: "Name".tr(),
                            labelStyle: labelStyle,
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
                            ),
                          ),
                        ),

                        //
                        20.heightBox,
                        //address
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(),
                            GestureDetector(
                              onTap: () {
                                vm.useCurrentLocation();
                              },
                              child: Container(
                                margin: EdgeInsets.only(bottom: 5),
                                child: Text(
                                  "Use Current Location",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        TypeAheadField<Address>(
                          hideOnLoading: false,
                          hideSuggestionsOnKeyboardHide: false,
                          minCharsForSuggestions: 3,
                          debounceDuration: const Duration(seconds: 1),
                          textFieldConfiguration: TextFieldConfiguration(
                            style: style,
                            cursorColor: AppColor.cursorColor,
                            autofocus: false,
                            controller: vm.addressTEC,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                MaterialIcons.location_on,
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColor.cancelledColor,
                                ),
                              ),
                              hintText: "Address".tr(),
                              hintStyle: AppTextStyle.hintStyle(),
                              labelText: "Address".tr(),
                              labelStyle: labelStyle,
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColor.cancelledColor,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColor.cancelledColor,
                                ),
                              ),
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  vm.handleChooseOnMap();
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Icon(
                                    MaterialIcons.map,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          suggestionsCallback: vm.searchAddress,
                          itemBuilder: (context, Address? suggestion) {
                            if (suggestion == null) {
                              return Divider();
                            }
                            //
                            return VStack(
                              [
                                "${suggestion.addressLine ?? ''}"
                                    .text
                                    .semiBold
                                    .lg
                                    .make()
                                    .px(12),
                                Divider(),
                              ],
                            );
                          },
                          onSuggestionSelected: vm.onAddressSelected,
                        ),

                        //
                        CustomLoadingStateView(
                          loading: vm.busy(vm.vendorTypes),
                          child: FormBuilderDropdown(
                            style: style,
                            name: 'vendor_type_id',
                            decoration: inputDec.copyWith(
                              prefixIcon: Icon(
                                MaterialIcons.store,
                              ),
                              labelText: "Vendor Type".tr(),
                              labelStyle: labelStyle,
                              hintText: 'Select Vendor Type'.tr(),
                            ),
                            initialValue: vm.selectedVendorTypeId,
                            onChanged: vm.changeSelectedVendorType,
                            validator: CustomFormBuilderValidator.required,
                            items: vm.vendorTypes
                                .map(
                                  (vendorType) => DropdownMenuItem(
                                    value: vendorType.id,
                                    child: '${vendorType.name}'.text.make(),
                                  ),
                                )
                                .toList(),
                          ),
                        ).py20(),

                        FormBuilderTextField(
                          style: style,
                          cursorColor: AppColor.cursorColor,
                          name: "vendor_email",
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) =>
                              CustomFormBuilderValidator.compose(
                            [
                              CustomFormBuilderValidator.required(value),
                              CustomFormBuilderValidator.email(value),
                            ],
                          ),
                          decoration: inputDec.copyWith(
                            prefixIcon: Icon(
                              MaterialIcons.mail_outline,
                            ),
                            hintText: "Enter your email".tr(),
                            labelText: "Email".tr(),
                            labelStyle: labelStyle,
                          ),
                        ),
                        FormBuilderTextField(
                          style: style,
                          cursorColor: AppColor.cursorColor,
                          name: "tax_code",
                          keyboardType: TextInputType.text,
                          validator: (value) =>
                              CustomFormBuilderValidator.compose(
                            [
                              CustomFormBuilderValidator.required(value),
                            ],
                          ),
                          decoration: inputDec.copyWith(
                            prefixIcon: Icon(
                              Icons.attach_money_outlined,
                            ),
                            hintText: "Enter your tax code".tr(),
                            labelText: "Tax code".tr(),
                            labelStyle: labelStyle,
                          ),
                        ).py20(),

                        FormBuilderTextField(
                          style: style,
                          cursorColor: AppColor.cursorColor,
                          name: "vendor_phone",
                          keyboardType: TextInputType.phone,
                          validator: CustomFormBuilderValidator.required,
                          decoration: inputDec.copyWith(
                            hintText: "Enter your phone number".tr(),
                            labelText: "Phone".tr(),
                            labelStyle: labelStyle,
                            prefixIcon: HStack(
                              [
                                //icon/flag
                                Flag.fromString(
                                  vm.selectedVendorCountry?.countryCode ?? "us",
                                  width: 20,
                                  height: 20,
                                ),
                                UiSpacer.horizontalSpace(space: 5),
                                //text
                                ("+" +
                                        (vm.selectedVendorCountry?.phoneCode ??
                                            "1"))
                                    .text
                                    .textStyle(style)
                                    .make(),
                              ],
                            )
                                .px8()
                                .onInkTap(() => vm.showCountryDialPicker(true)),
                          ),
                        ).py20(),

                        //business documents
                        DocumentSelectionView(
                          title: "Documents".tr(),
                          instruction:
                              AppPageSettings.vendorDocumentInstructions,
                          max: AppPageSettings.maxVendorDocumentCount,
                          onSelected: vm.onDocumentsSelected,
                        ),

                        UiSpacer.divider().py12(),
                        "Personal Information"
                            .tr()
                            .text
                            .underline
                            .xl
                            .semiBold
                            .make(),
                        UiSpacer.vSpace(30),

                        FormBuilderTextField(
                          style: style,
                          cursorColor: AppColor.cursorColor,
                          name: "name",
                          validator: CustomFormBuilderValidator.required,
                          decoration: inputDec.copyWith(
                            prefixIcon: Icon(
                              MaterialIcons.person_outline,
                            ),
                            hintText: "Enter your name".tr(),
                            labelText: "Name".tr(),
                            labelStyle: labelStyle,
                          ),
                        ),
                        if (AppStrings.enableEmailLogin)
                          FormBuilderTextField(
                            style: style,
                            cursorColor: AppColor.cursorColor,
                            name: "email",
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) =>
                                CustomFormBuilderValidator.compose(
                              [
                                CustomFormBuilderValidator.email(value ?? "example@gmail.com"),
                              ],
                            ),
                            decoration: inputDec.copyWith(
                              prefixIcon: Icon(
                                MaterialIcons.mail_outline,
                              ),
                              hintText: "Enter your email".tr(),
                              labelText: "Email".tr(),
                              labelStyle: labelStyle,
                            ),
                          ).py20(),

                        FormBuilderTextField(
                          style: style,
                          cursorColor: AppColor.cursorColor,
                          name: "phone",
                          keyboardType: TextInputType.phone,
                          validator: CustomFormBuilderValidator.required,
                          decoration: inputDec.copyWith(
                            hintText: "Enter your phone number".tr(),
                            labelText: "Phone".tr(),
                            labelStyle: labelStyle,
                            prefixIcon: HStack(
                              [
                                //icon/flag
                                Flag.fromString(
                                  vm.selectedCountry!.countryCode,
                                  width: 20,
                                  height: 20,
                                ),
                                UiSpacer.horizontalSpace(space: 5),
                                //text
                                ("+" + vm.selectedCountry!.phoneCode)
                                    .text
                                    .textStyle(style)
                                    .make(),
                              ],
                            ).px8().onInkTap(vm.showCountryDialPicker),
                          ),
                        ),

                        FormBuilderTextField(
                          style: style,
                          cursorColor: AppColor.cursorColor,
                          name: "password",
                          obscureText: vm.hidePassword,
                          validator: CustomFormBuilderValidator.required,
                          decoration: inputDec.copyWith(
                            prefixIcon: Icon(
                              MaterialIcons.lock_outline,
                            ),
                            hintText: "Enter your password".tr(),
                            labelText: "Password".tr(),
                            labelStyle: labelStyle,
                            suffixIcon: Icon(
                              vm.hidePassword
                                  ? FlutterIcons.ios_eye_ion
                                  : FlutterIcons.ios_eye_off_ion,
                              color: labelStyle.color,
                            ).onInkTap(() {
                              vm.hidePassword = !vm.hidePassword;
                              vm.notifyListeners();
                            }),
                          ),
                        ).py20(),

                        FormBuilderCheckbox(
                          name: "agreed",
                          title: "I agree with"
                              .tr()
                              .richText
                              .semiBold
                              .withTextSpanChildren(
                            [
                              " ".textSpan.make(),
                              "terms and conditions"
                                  .tr()
                                  .textSpan
                                  .underline
                                  .semiBold
                                  .tap(() {
                                    vm.openWebpageLink(Api.terms);
                                  })
                                  .color(AppColor.primaryColor)
                                  .make(),
                            ],
                          ).make(),
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
                          title: "Sign Up".tr(),
                          loading: vm.isBusy,
                          onPressed: vm.processLogin,
                        ).centered().py20(),
                      ],
                    ).p20(),
                  ],
                )
                    .wFull(context)
                    .scrollVertical()
                    .box
                    .color(AppColor.onboarding1Color)
                    .make()
                    .pOnly(
                      bottom: context.mq.viewInsets.bottom,
                    )
                    .expand(),
              ],
            ),
          ),
        );
      },
    );
  }
}
