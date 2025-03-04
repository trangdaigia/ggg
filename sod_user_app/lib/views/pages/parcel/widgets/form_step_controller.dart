import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_text_styles.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/widgets/busy_indicator.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class FormStepController extends StatelessWidget {
  const FormStepController({
    this.onPreviousPressed,
    this.onNextPressed,
    this.showPrevious = true,
    this.showNext = true,
    this.showLoadingNext = false,
    this.nextTitle,
    this.nextBtnWidth,
    Key? key,
  }) : super(key: key);

  final Function? onPreviousPressed;
  final bool showPrevious;
  final Function? onNextPressed;
  final bool showNext;
  final bool showLoadingNext;
  final String? nextTitle;
  final double? nextBtnWidth;
  @override
  Widget build(BuildContext context) {
    return HStack(
      [
        //prev
        showPrevious
            ? OutlinedButton(
                // height: Vx.dp40,
                child: "PREVIOUS"
                    .tr()
                    .text
                    .textStyle(
                      AppTextStyle.h4TitleTextStyle(
                        color: AppColor.primaryColor,
                        fontWeight: FontWeight.w900,
                      ),
                    )
                    .make(),
                onPressed: () => onPreviousPressed!() ?? () {},
              ).py20().w(context.percentWidth * 35)
            : UiSpacer.emptySpace(),
        Spacer(),
        //next
        showLoadingNext
            ? BusyIndicator().py20().px4()
            : showNext
                ? CustomButton(
                    height: Vx.dp40,
                    title: nextTitle ?? "NEXT".tr(),
                    onPressed: onNextPressed,
                  ).py20().w(nextBtnWidth ?? (context.percentWidth * 35))
                : UiSpacer.emptySpace(),
      ],
    );
  }
}
