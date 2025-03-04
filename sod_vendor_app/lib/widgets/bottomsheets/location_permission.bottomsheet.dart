import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sod_vendor/constants/app_strings.dart';
import 'package:sod_vendor/extensions/dynamic.dart';
import 'package:sod_vendor/services/app.service.dart';
import 'package:sod_vendor/utils/ui_spacer.dart';
import 'package:sod_vendor/widgets/buttons/custom_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class LocationPermissionDialog extends StatelessWidget {
  const LocationPermissionDialog({
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
          "Location Permission Request".tr().text.semiBold.xl.make().py12(),
          "Thank you for using %s. To provide you with the best experience possible, our app needs access to your location. We use your location data to show you nearby vendors, enable you to set up a delivery address or location during checkout, and provide live tracking of your order and delivery persons. Your privacy is important to us, and we will never share your location data with third parties."
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
