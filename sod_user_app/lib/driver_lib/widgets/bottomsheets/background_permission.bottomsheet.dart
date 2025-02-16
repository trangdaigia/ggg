import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sod_user/driver_lib/utils/ui_spacer.dart';
import 'package:sod_user/driver_lib/widgets/buttons/custom_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/services/app.service.dart';
import 'package:velocity_x/velocity_x.dart';

class BackgroundPermissionDialog extends StatelessWidget {
  const BackgroundPermissionDialog({Key? key}) : super(key: key);

  //
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: VStack(
        [
          //title
          "Background Permission Request".tr().text.semiBold.xl.make().py12(),
          "This app requires your background permission to enable app receive new order notification even when app is in background. The application also need to run an overlay window on top of device for easy navigation"
              .tr()
              .text
              .make(),
          UiSpacer.verticalSpace(),
          CustomButton(
            title: "Next".tr(),
            onPressed: () {
              print(AppService().navigatorKey.currentContext);
              Navigator.pop(AppService().navigatorKey.currentContext!, true);
              ;
            },
          ).py12(),
          Visibility(
            visible: !Platform.isIOS,
            child: CustomButton(
              title: "Cancel".tr(),
              color: Colors.grey[400],
              onPressed: () {
                Navigator.pop(AppService().navigatorKey.currentContext!, false);
              },
            ),
          ),
        ],
      ).p20().wFull(context).scrollVertical(), //.hTwoThird(context),
    );
  }
}
