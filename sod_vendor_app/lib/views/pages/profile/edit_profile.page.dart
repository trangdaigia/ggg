import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_vendor/constants/app_colors.dart';
import 'package:sod_vendor/constants/app_images.dart';
import 'package:sod_vendor/services/validator.service.dart';
import 'package:sod_vendor/view_models/edit_profile.vm.dart';
import 'package:sod_vendor/widgets/base.page.dart';
import 'package:sod_vendor/widgets/busy_indicator.dart';
import 'package:sod_vendor/widgets/buttons/custom_button.dart';
import 'package:sod_vendor/widgets/custom_text_form_field.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import '../../../constants/app_text_styles.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextStyle style = AppTextStyle.h5TitleTextStyle(
      fontWeight: FontWeight.w600,
    );

    return ViewModelBuilder<EditProfileViewModel>.reactive(
      viewModelBuilder: () => EditProfileViewModel(context),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return BasePage(
          showLeadingAction: true,
          showAppBar: true,
          title: "Edit Profile".tr(),
          backgroundColor: AppColor.onboarding3Color,
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
                                imageUrl: model.currentUser?.photo ?? "",
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
                Form(
                  key: model.formKey,
                  child: VStack(
                    [
                      //
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
                      CustomTextFormField(
                        //labelText: "Name".tr(),
                        textEditingController: model.nameTEC,
                        validator: FormValidator.validateName,
                      ).py12(),
                      //
                      Text(
                        "Email",
                        style: style,
                      ),
                      CustomTextFormField(
                        //labelText: "Email",
                        keyboardType: TextInputType.emailAddress,
                        textEditingController: model.emailTEC,
                        validator: FormValidator.validateEmail,
                      ).py12(),
                      //
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
                        //labelText: "Phone",
                        keyboardType: TextInputType.phone,
                        textEditingController: model.phoneTEC,
                        validator: FormValidator.validatePhone,
                      ).py12(),

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
            ).p20().hFull(context).pOnly(bottom: 200).scrollVertical(),
          ),
        );
      },
    );
  }
}
