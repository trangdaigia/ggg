import 'package:flutter/material.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:sod_user/widgets/buttons/custom_text_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class ParcelLocationPickerOptionBottomSheet extends StatelessWidget {
  const ParcelLocationPickerOptionBottomSheet();

  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        //
        UiSpacer.swipeIndicator().py12(),
        "Where to pick delivery address from?".tr().text.semiBold.make(),
        UiSpacer.verticalSpace(),
        //filter result
        CustomButton(
          title: "Delivery Address List".tr(),
          onPressed: () {
            Navigator.pop(context, 0);
          },
        ),
        UiSpacer.verticalSpace(),
        CustomTextButton(
          title: "Directly from map".tr(),
          onPressed: () {
            Navigator.pop(context, 1);
          },
        ).wFull(context),
      ],
    )
        .p20()
        .box
        .color(context.theme.colorScheme.surface)
        .topRounded()
        .clip(Clip.antiAlias)
        .make();
  }
}
