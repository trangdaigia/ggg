import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_user/driver_lib/constants/app_colors.dart';
import 'package:sod_user/driver_lib/constants/app_images.dart';
import 'package:sod_user/driver_lib/constants/app_text_styles.dart';
import 'package:sod_user/driver_lib/services/custom_form_builder_validator.service.dart';
import 'package:sod_user/driver_lib/services/validator.service.dart';
import 'package:sod_user/driver_lib/view_models/edit_profile.vm.dart';
import 'package:sod_user/driver_lib/widgets/base.page.dart';
import 'package:sod_user/driver_lib/widgets/busy_indicator.dart';
import 'package:sod_user/driver_lib/widgets/buttons/custom_button.dart';
import 'package:sod_user/driver_lib/widgets/custom_text_form_field.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textThemeColor = Theme.of(context).textTheme.bodyLarge!.color;
    final TextStyle style = AppTextStyle.h5TitleTextStyle(
      fontWeight: FontWeight.w600,
      color: textThemeColor,
    );
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

    Widget _buildLabel(String text) => Row(
          children: [
            Text(
              text.tr(),
              style: style,
            ),
            Text(
              "*",
              style: style.copyWith(
                color: Colors.red,
              ),
            )
          ],
        );
    return ViewModelBuilder<EditProfileViewModel>.reactive(
      viewModelBuilder: () => EditProfileViewModel(context),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return BasePage(
          showLeadingAction: true,
          showAppBar: true,
          title: "Edit Profile".tr(),
          body: SafeArea(
            top: true,
            bottom: false,
            child:
                //
                VStack(
              [
                //
                Stack(
                  children: [
                    //
                    model.currentUser == null
                        ? BusyIndicator()
                        : model.newPhoto == null
                            ? CachedNetworkImage(
                                imageUrl: model.currentUser?.user.photo ?? "",
                                progressIndicatorBuilder:
                                    (context, url, progress) {
                                  return BusyIndicator();
                                },
                                errorWidget: (context, imageUrl, progress) {
                                  return Image.asset(
                                    AppImages.user,
                                  );
                                },
                                fit: BoxFit.cover,
                              )
                                .wh(
                                  Vx.dp64 * 1.3,
                                  Vx.dp64 * 1.3,
                                )
                                .box
                                .rounded
                                .clip(Clip.antiAlias)
                                .make()
                            : Image.file(
                                model.newPhoto!,
                                fit: BoxFit.cover,
                              )
                                .wh(
                                  Vx.dp64 * 1.3,
                                  Vx.dp64 * 1.3,
                                )
                                .box
                                .rounded
                                .clip(Clip.antiAlias)
                                .make(),

                    //
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Icon(
                        FlutterIcons.camera_ant,
                        size: 16,
                      )
                          .p8()
                          .box
                          .color(context.theme.colorScheme.background)
                          .roundedFull
                          .shadow
                          .make()
                          .onInkTap(model.changePhoto),
                    ),
                  ],
                ).box.makeCentered(),

                //form
                FormBuilder(
                  key: model.formBuilderKey,
                  autoFocusOnValidationFailure: true,
                  child: VStack(
                    [
                      //
                      HStack([
                        RadioListTile(
                          title: Text(
                            'Male'.tr(),
                            style: AppTextStyle.h4TitleTextStyle(
                              fontWeight: FontWeight.w600,
                              color: textThemeColor,
                            ),
                          ),
                          value: "male",
                          groupValue: model.genderSelected,
                          onChanged: (gender) {
                            model.changeGender(gender);
                          },
                        ).expand(),
                        RadioListTile(
                          title: Text(
                            'Female'.tr(),
                            style: AppTextStyle.h4TitleTextStyle(
                              fontWeight: FontWeight.w600,
                              color: textThemeColor,
                            ),
                          ),
                          value: "female",
                          groupValue: model.genderSelected,
                          onChanged: (gender) {
                            model.changeGender(gender);
                          },
                        ).expand(),
                      ]),
                      //Thêm label
                      Row(
                        children: [
                          Text(
                            "Full name".tr(),
                            style: style,
                          ),
                          Text(
                            "*",
                            style: style.copyWith(
                              color: Colors.red,
                            ),
                          )
                        ],
                      ),
                      //
                      CustomTextFormField(
                        //labelText: "Name".tr(),
                        textEditingController: model.nameTEC,
                        validator: FormValidator.validateName,
                      ).py12(),
                      //
                      //Thêm label
                      Text(
                        "Email",
                        style: style,
                      ),
                      CustomTextFormField(
                        //labelText: "Email".tr(),
                        keyboardType: TextInputType.emailAddress,
                        textEditingController: model.emailTEC,
                        validator: FormValidator.validateEmail,
                      ).py12(),
                      //
                      //Thêm label
                      Row(
                        children: [
                          Text(
                            "Phone number".tr(),
                            style: style,
                          ),
                          Text(
                            "*",
                            style: style.copyWith(
                              color: Colors.red,
                            ),
                          )
                        ],
                      ),
                      CustomTextFormField(
                        //labelText: "Phone".tr(),
                        keyboardType: TextInputType.phone,
                        textEditingController: model.phoneTEC,
                        validator: FormValidator.validatePhone,
                      ).py12(),

                      // Form Chọn quốc gia
                      _buildLabel('Country'),
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
                        enabled: model.areas['countries']!.isNotEmpty,
                        validator: CustomFormBuilderValidator.required,
                        items: model.areas['countries']!
                            .map(
                              (area) => DropdownMenuItem(
                                value: area['id'],
                                child: '${area['name']}'.tr().text.make(),
                              ),
                            )
                            .toList(),
                        onChanged: model.onSelectedCountry,
                      ).py(12),

                      // Form Chọn tỉnh
                      _buildLabel('State'),
                      FormBuilderDropdown(
                        style: style,
                        name: 'state_id',
                        decoration: inputDec.copyWith(
                          prefixIcon: Icon(
                            MaterialIcons.location_city,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                          labelText: "State".tr(),
                          labelStyle: labelStyle,
                        ),
                        enabled: (model.areas['states']!.isNotEmpty),
                        validator: CustomFormBuilderValidator.required,
                        items: model.areas['states']!
                            .map(
                              (area) => DropdownMenuItem(
                                value: area['id'],
                                child: '${area['name']}'.tr().text.make(),
                              ),
                            )
                            .toList(),
                        onChanged: model.onSelectedState,
                      ).py(12),

                      // Form Chọn thành phố
                      _buildLabel('City'),
                      FormBuilderDropdown(
                        style: style,
                        name: 'city_id',
                        decoration: inputDec.copyWith(
                          prefixIcon: Icon(
                            MaterialIcons.location_city,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                          labelText: "City".tr(),
                          labelStyle: labelStyle,
                        ),
                        enabled: (model.areas['cities']!.isNotEmpty),
                        validator: CustomFormBuilderValidator.required,
                        items: model.areas['cities']!
                            .map(
                              (area) => DropdownMenuItem(
                                value: area['id'],
                                child: '${area['name']}'.tr().text.make(),
                              ),
                            )
                            .toList(),
                        onChanged: model.onSelectedCity,
                      ).py(12),

                      //
                      CustomButton(
                        title: "Update Profile".tr(),
                        loading: model.isBusy,
                        onPressed: model.processUpdate,
                      ).centered().py12(),
                    ],
                  ),
                ).py20(),
              ],
              //Chỉnh lại cuộn màn hình
            ).p20().pOnly(bottom: 200).scrollVertical(),
          ),
        );
      },
    );
  }
}
