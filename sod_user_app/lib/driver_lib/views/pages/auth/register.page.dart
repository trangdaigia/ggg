import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_text_styles.dart';
import 'package:sod_user/driver_lib/constants/api.dart';
import 'package:sod_user/driver_lib/constants/app_page_settings.dart';
import 'package:sod_user/driver_lib/services/custom_form_builder_validator.service.dart';
import 'package:sod_user/driver_lib/utils/utils.dart';
import 'package:sod_user/driver_lib/view_models/register.view_model.dart';
import 'package:sod_user/driver_lib/widgets/base.page.dart';
import 'package:sod_user/driver_lib/widgets/buttons/custom_button.dart';
import 'package:sod_user/driver_lib/widgets/cards/document_selection.view.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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

    //Chỉnh màu cho label
    final labelStyle = AppTextStyle.h5TitleTextStyle(
        color: Theme.of(context).textTheme.bodyLarge!.color,
        fontWeight: FontWeight.w600);
    final style = AppTextStyle.h5TitleTextStyle(
      color: Theme.of(context).textTheme.bodyLarge!.color,
      fontWeight: FontWeight.w600,
    );
    return ViewModelBuilder<RegisterViewModel>.reactive(
      viewModelBuilder: () => RegisterViewModel(context),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        return BasePage(
          isLoading: vm.isBusy,
          body: FormBuilder(
            key: vm.formBuilderKey,
            autoFocusOnValidationFailure: true,
            child: VStack(
              [
                //appbar
                SafeArea(
                  child: Row(
                    children: [
                      Icon(
                        FlutterIcons.close_ant,
                        size: 24,
                        color: Utils.textColorByTheme(),
                      ).p8().onInkTap(() => Navigator.pop(context)).p12(),
                      VStack(
                        [
                          "Become a partner"
                              .tr()
                              .text
                              .xl3
                              .color(Utils.textColorByTheme())
                              .bold
                              .textStyle(style)
                              .make(),
                          "Fill form below to continue"
                              .tr()
                              .text
                              .light
                              .color(Utils.textColorByTheme())
                              .make(),
                        ],
                      ).pOnly(bottom: 16, top: 16, right: 16).expand(),
                    ],
                  ),
                ).box.color(AppColor.primaryColor).make().wFull(context),

                //
                VStack(
                  [
                    //form

                    //
                    // FormBuilderTextField(
                    //   style: style,
                    //   cursorColor: AppColor.cursorColor,
                    //   name: "name",
                    //   validator: CustomFormBuilderValidator.required,
                    //   decoration: inputDec.copyWith(
                    //     prefixIcon: Icon(
                    //       MaterialIcons.person_outline,
                    //       color:
                    //           Theme.of(context).textTheme.bodyLarge!.color,
                    //     ),
                    //     hintText: "Enter your name".tr(),
                    //     labelText: "Name".tr(),
                    //     labelStyle: labelStyle,
                    //   ),
                    // ),
                    // FormBuilderTextField(
                    //   style: style,
                    //   cursorColor: AppColor.cursorColor,
                    //   name: "email",
                    //   keyboardType: TextInputType.emailAddress,
                    //   validator: (value) =>
                    //       CustomFormBuilderValidator.compose(
                    //     [
                    //       CustomFormBuilderValidator.required(value),
                    //       CustomFormBuilderValidator.email(value),
                    //     ],
                    //   ),
                    //   decoration: inputDec.copyWith(
                    //     prefixIcon: Icon(
                    //       MaterialIcons.mail_outline,
                    //       color:
                    //           Theme.of(context).textTheme.bodyLarge!.color,
                    //     ),
                    //     hintText: "Enter your email".tr(),
                    //     labelText: "Email".tr(),
                    //     labelStyle: labelStyle,
                    //   ),
                    // ).py20(),
                    // FormBuilderTextField(
                    //   style: style,
                    //   cursorColor: AppColor.cursorColor,
                    //   name: "phone",
                    //   keyboardType: TextInputType.phone,
                    //   validator: CustomFormBuilderValidator.required,
                    //   decoration: inputDec.copyWith(
                    //     hintText: "Enter your phone number".tr(),
                    //     labelText: "Phone".tr(),
                    //     labelStyle: labelStyle,
                    //     prefixIcon: HStack(
                    //       [
                    //         //icon/flag
                    //         Flag.fromString(
                    //           vm.selectedCountry.countryCode,
                    //           width: 20,
                    //           height: 20,
                    //         ),
                    //         UiSpacer.horizontalSpace(space: 5),
                    //         //text
                    //         ("+" + vm.selectedCountry.phoneCode)
                    //             .text
                    //             .textStyle(style)
                    //             .make(),
                    //       ],
                    //     ).px8().onInkTap(vm.showCountryDialPicker),
                    //   ),
                    // ),
                    // FormBuilderTextField(
                    //   style: style,
                    //   cursorColor: AppColor.cursorColor,
                    //   name: "password",
                    //   obscureText: vm.hidePassword,
                    //   validator: CustomFormBuilderValidator.required,
                    //   decoration: inputDec.copyWith(
                    //     prefixIcon: Icon(
                    //       MaterialIcons.lock_outline,
                    //       color:
                    //           Theme.of(context).textTheme.bodyLarge!.color,
                    //     ),
                    //     hintText: "Enter your password".tr(),
                    //     labelText: "Password".tr(),
                    //     labelStyle: labelStyle,
                    //     suffixIcon: Icon(
                    //       vm.hidePassword
                    //           ? FlutterIcons.ios_eye_ion
                    //           : FlutterIcons.ios_eye_off_ion,
                    //       color: labelStyle.color,
                    //     ).onInkTap(() {
                    //       vm.hidePassword = !vm.hidePassword;
                    //       vm.notifyListeners();
                    //     }),
                    //   ),
                    // ).py20(),

                    // Form Chọn quốc gia
                    if (vm.isShowSelectCountry)
                      FormBuilderDropdown(
                        style: style,
                        name: 'country_id',
                        decoration: inputDec.copyWith(
                          prefixIcon: Icon(
                            MaterialIcons.location_city,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                          labelText: "Country".tr(),
                          labelStyle: labelStyle,
                        ),
                        enabled: vm.areas['countries']!.isNotEmpty,
                        validator: CustomFormBuilderValidator.required,
                        items: vm.areas['countries']!
                            .map(
                              (area) => DropdownMenuItem(
                                value: area['id'],
                                child: '${area['name']}'.tr().text.make(),
                              ),
                            )
                            .toList(),
                        onChanged: vm.onSelectedCountry,
                      ).pOnly(bottom: 20),

                    // Form Chọn tỉnh
                    FormBuilderDropdown(
                      style: style,
                      name: 'state_id',
                      decoration: inputDec.copyWith(
                        prefixIcon: Icon(
                          MaterialIcons.location_city,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                        labelText: "Province".tr(),
                        labelStyle: labelStyle,
                      ),
                      enabled: (vm.areas['states']!.isNotEmpty),
                      validator: CustomFormBuilderValidator.required,
                      items: vm.areas['states']!
                          .map(
                            (area) => DropdownMenuItem(
                              value: area['id'],
                              child: '${area['name']}'.tr().text.make(),
                            ),
                          )
                          .toList(),
                      onChanged: vm.onSelectedState,
                    ).pOnly(bottom: 20),

                    // Form Chọn thành phố
                    FormBuilderDropdown(
                      style: style,
                      name: 'city_id',
                      decoration: inputDec.copyWith(
                        prefixIcon: Icon(
                          MaterialIcons.location_city,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                        labelText: "District".tr(),
                        labelStyle: labelStyle,
                      ),
                      enabled: (vm.areas['cities']!.isNotEmpty),
                      validator: CustomFormBuilderValidator.required,
                      items: vm.areas['cities']!
                          .map(
                            (area) => DropdownMenuItem(
                              value: area['id'],
                              child: '${area['name']}'.tr().text.make(),
                            ),
                          )
                          .toList(),
                      onChanged: vm.onSelectedCity,
                    ).pOnly(bottom: 20),

                    FormBuilderTextField(
                      style: style,
                      cursorColor: AppColor.cursorColor,
                      name: "tax_code",
                      validator: CustomFormBuilderValidator.required,
                      decoration: inputDec.copyWith(
                        prefixIcon: Icon(
                          MaterialIcons.code,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                        hintText: "Enter tax code".tr(),
                        labelText: "Tax Code".tr(),
                        labelStyle: labelStyle,
                      ),
                    ),

                    // FormBuilderTextField(
                    //   style: style,
                    //   cursorColor: AppColor.cursorColor,
                    //   name: "referal_code",
                    //   decoration: inputDec.copyWith(
                    //     prefixIcon: Icon(
                    //       MaterialIcons.code,
                    //       color:
                    //           Theme.of(context).textTheme.bodyLarge!.color,
                    //     ),
                    //     hintText: "Enter referral code".tr(),
                    //     labelText: "Referral Code".tr(),
                    //     labelStyle: labelStyle,
                    //   ),
                    // ).py20(),
                    //
                    // UiSpacer.divider().py20(),
                    //
                    // Visibility(
                    //   visible: !vm.onlyReceiveBehalf,
                    //   child: VStack(
                    //     [
                    //       FormBuilderDropdown(
                    //         style: style,
                    //         name: 'driver_type',
                    //         decoration: inputDec.copyWith(
                    //           prefixIcon: Icon(
                    //             MaterialIcons.person,
                    //             color: Theme.of(context)
                    //                 .textTheme
                    //                 .bodyLarge!
                    //                 .color,
                    //           ),
                    //           labelText: "Driver Type".tr(),
                    //           hintText: 'Select Driver Type'.tr(),
                    //           labelStyle: labelStyle,
                    //         ),
                    //         validator: CustomFormBuilderValidator.required,
                    //         items: vm.types
                    //             .map(
                    //               (type) => DropdownMenuItem(
                    //                 value: type.toLowerCase(),
                    //                 child: '${type}'.tr().text.make(),
                    //               ),
                    //             )
                    //             .toList(),
                    //         onChanged: vm.onSelectedDriverType,
                    //       ),

                    //       //vehicle details
                    //       CustomVisibilty(
                    //         visible: vm.selectedDriverType == "taxi",
                    //         child: VStack(
                    //           [
                    //             UiSpacer.divider().py8(),
                    //             "Vehicle Details"
                    //                 .tr()
                    //                 .text
                    //                 .semiBold
                    //                 .xl
                    //                 .make()
                    //                 .py12(),
                    //             UiSpacer.vSpace(10),
                    //             CustomLoadingStateView(
                    //               loading: vm.busy(vm.carMakes),
                    //               child: CustomTypeAheadField<CarMake>(
                    //                 textEditingController: vm.carMakeTEC,
                    //                 title: "Car Make".tr(),
                    //                 hint: "Enter the car company".tr(),
                    //                 items: vm.carMakes,
                    //                 itemBuilder: (context, suggestion) {
                    //                   return ListTile(
                    //                     title: Text(
                    //                       "${suggestion.name}",
                    //                       style: style,
                    //                     ),
                    //                   );
                    //                 },
                    //                 suggestionsCallback: (value) async {
                    //                   return vm.carMakes
                    //                       .where(
                    //                         (e) => e.name
                    //                             .toLowerCase()
                    //                             .contains(value.toLowerCase()),
                    //                       )
                    //                       .toList();
                    //                 },
                    //                 onSuggestionSelected: vm.onCarMakeSelected,
                    //               ),
                    //             ),
                    //             CustomLoadingStateView(
                    //               loading: vm.busy(vm.carModels),
                    //               child: CustomTypeAheadField<CarModel>(
                    //                 hint: "Enter vehicle model".tr(),
                    //                 textEditingController: vm.carModelTEC,
                    //                 title: "Car Model".tr(),
                    //                 items: vm.carModels,
                    //                 itemBuilder: (context, suggestion) {
                    //                   return ListTile(
                    //                     title: Text(
                    //                       "${suggestion.name}",
                    //                       style: style,
                    //                     ),
                    //                   );
                    //                 },
                    //                 suggestionsCallback: (value) async {
                    //                   return vm.carModels
                    //                       .where(
                    //                         (e) => e.name
                    //                             .toLowerCase()
                    //                             .contains(value.toLowerCase()),
                    //                       )
                    //                       .toList();
                    //                 },
                    //                 onSuggestionSelected: vm.onCarModelSelected,
                    //               ).py20(),
                    //             ),

                    //             //
                    //             CustomLoadingStateView(
                    //               loading: vm.busy(vm.vehicleTypes),
                    //               child: FormBuilderDropdown(
                    //                 style: style,
                    //                 name: 'vehicle_type_id',
                    //                 decoration: inputDec.copyWith(
                    //                   prefixIcon: Icon(
                    //                     MaterialIcons.directions_car,
                    //                     color: Theme.of(context)
                    //                         .textTheme
                    //                         .bodyLarge!
                    //                         .color,
                    //                   ),
                    //                   labelText: "Vehicle Type".tr(),
                    //                   hintText: 'Select Vehicle Type'.tr(),
                    //                   labelStyle: labelStyle,
                    //                 ),
                    //                 validator:
                    //                     CustomFormBuilderValidator.required,
                    //                 items: vm.vehicleTypes
                    //                     .map(
                    //                       (type) => DropdownMenuItem(
                    //                         value: type.id,
                    //                         child: '${type.name}'.text.make(),
                    //                       ),
                    //                     )
                    //                     .toList(),
                    //               ),
                    //             ),

                    //             //
                    //             FormBuilderTextField(
                    //               style: style,
                    //               cursorColor: AppColor.cursorColor,
                    //               name: "reg_no",
                    //               validator:
                    //                   CustomFormBuilderValidator.required,
                    //               decoration: inputDec.copyWith(
                    //                 prefixIcon: Icon(
                    //                   MaterialIcons.format_list_numbered,
                    //                   color: Theme.of(context)
                    //                       .textTheme
                    //                       .bodyLarge!
                    //                       .color,
                    //                 ),
                    //                 hintText:
                    //                     "Enter your registration number".tr(),
                    //                 labelText: "Registration Number".tr(),
                    //                 labelStyle: labelStyle,
                    //               ),
                    //             ).py20(),
                    //             FormBuilderTextField(
                    //               style: style,
                    //               cursorColor: AppColor.cursorColor,
                    //               name: "color",
                    //               validator:
                    //                   CustomFormBuilderValidator.required,
                    //               decoration: inputDec.copyWith(
                    //                 prefixIcon: Icon(
                    //                   MaterialIcons.color_lens,
                    //                   color: Theme.of(context)
                    //                       .textTheme
                    //                       .bodyLarge!
                    //                       .color,
                    //                 ),
                    //                 hintText: "Enter vehicle color".tr(),
                    //                 labelText: "Color".tr(),
                    //                 labelStyle: labelStyle,
                    //               ),
                    //             ),
                    //             10.heightBox,
                    //             UiSpacer.divider(),
                    //           ],
                    //         ),
                    //       ),

                    //       //business documents
                    //       DocumentSelectionView(
                    //         title: "Documents".tr(),
                    //         instruction:
                    //             AppPageSettings.driverDocumentInstructions,
                    //         max: AppPageSettings.maxDriverDocumentCount,
                    //         onSelected: vm.onDocumentsSelected,
                    //       ).py(12),

                    //       UiSpacer.divider(),
                    //     ],
                    //   ),
                    // ),
                    //business documents
                    DocumentSelectionView(
                      title: "Documents".tr(),
                      instruction: AppPageSettings.driverDocumentInstructions,
                      max: AppPageSettings.maxDriverDocumentCount,
                      onSelected: vm.onDocumentsSelected,
                    ).py(12),

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
                      activeColor: AppColor.primaryColor,
                      validator: (value) => CustomFormBuilderValidator.required(
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
                      onPressed: vm.processRegister,
                    ).centered().py20(),
                  ],
                )
                    .wFull(context)
                    .p(20)
                    .scrollVertical()
                    .box
                    .color(context.cardColor)
                    .make()
                    .pOnly(bottom: context.mq.viewInsets.bottom)
                    .expand(),
              ],
            ),
          ),
        );
      },
    );
  }
}
