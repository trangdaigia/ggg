import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/extensions/dynamic.dart';
import 'package:sod_user/services/app.service.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class CameraPermissionDialog extends StatelessWidget {
  const CameraPermissionDialog({
    Key? key,
    required this.onResult,
  }) : super(key: key);

  //
  final Function(bool) onResult;

  //
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: VStack(
        [
          //title
          "Camera Permission Request".tr().text.semiBold.xl.make().py12(),
          "Thank you for using %s. To provide you with the best experience possible, our app needs access to your camera. We use your picture to make order detail information."
              .tr()
              .fill([AppStrings.appName])
              .text
              .make(),
          UiSpacer.verticalSpace(),
          CustomButton(
            title: "Next".tr(),
            onPressed: () {
              onResult(true);
              Navigator.pop(AppService().navigatorKey.currentContext!);
            },
          ).py12(),
          Visibility(
            visible: !Platform.isIOS,
            child: CustomButton(
              title: "Cancel".tr(),
              color: Colors.grey[400],
              onPressed: () {
                onResult(false);
                Navigator.pop(AppService().navigatorKey.currentContext!);
              },
            ),
          ),
        ],
      ).p20().wFull(context).scrollVertical(), //.hTwoThird(context),
    );
  }
}
