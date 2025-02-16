import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_user/driver_lib/constants/app_strings.dart';
import 'package:sod_user/driver_lib/utils/ui_spacer.dart';
import 'package:sod_user/driver_lib/view_models/login.view_model.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class ScanLoginView extends StatelessWidget {
  const ScanLoginView(
    this.model, {
    Key? key,
  }) : super(key: key);

  final LoginViewModel model;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: AppStrings.qrcodeLogin,
      child: HStack(
        [
          "Scan to login".tr().text.make(),
          UiSpacer.horizontalSpace(space: 10),
          Icon(
            FlutterIcons.qrcode_ant,
          ),
        ],
      ).centered().px24().onInkTap(model.initateQrcodeLogin),
    );
  }
}
