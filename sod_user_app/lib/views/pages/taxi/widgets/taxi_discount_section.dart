import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_images.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:sod_user/widgets/custom_text_form_field.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class TaxiDiscountSection extends StatelessWidget {
  const TaxiDiscountSection(
    this.vm, {
    this.fullView = false,
    Key? key,
  }) : super(key: key);

  final dynamic vm;
  final bool fullView;

  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        //
        HStack(
          [
            Image.asset(
              width: 30.0, 
              height: 30.0, 
              fit: BoxFit.cover,
              AppImages.voucher,
            ),
            UiSpacer.hSpace(15),
            "Coupon".tr().text.make().expand(),
            UiSpacer.hSpace(5),
            UiSpacer.emptySpace(),

            // !fullView
            //     ? Icon(
            //         FlutterIcons.plus_ant,
            //         color: AppColor.primaryColor,
            //         size: 20,
            //       )
            //     : UiSpacer.emptySpace(),
          ],
          crossAlignment: CrossAxisAlignment.center,
          alignment: MainAxisAlignment.center,
        ).p(!fullView ? 10 : 0),
        Visibility(
          visible: fullView,
          child: UiSpacer.verticalSpace(space: 10),
        ),
        //
        Visibility(
          visible: fullView,
          child: HStack(
            [
              //
              CustomTextFormField(
                hintText: "Coupon Code".tr(),
                textEditingController: vm.couponTEC,
                errorText: vm.hasErrorForKey("coupon")
                    ? vm.error("coupon").toString()
                    : null,
                onChanged: vm.couponCodeChange,
              ).expand(flex: 2),
              //
              UiSpacer.horizontalSpace(space: 10),
              Column(
                children: [
                  CustomButton(
                    title: "Apply".tr(),
                    isFixedHeight: true,
                    loading: vm.busy("coupon"),
                    onPressed: vm.canApplyCoupon ? vm.applyCoupon : null,
                  ).h(Vx.dp48),
                  //
                  vm.hasErrorForKey("coupon")
                      ? UiSpacer.verticalSpace(space: 12)
                      : UiSpacer.verticalSpace(space: 1),
                ],
              ).expand(),
            ],
          ),
        ),
      ],
      crossAlignment: CrossAxisAlignment.center,
      alignment: MainAxisAlignment.center,
    );
  }
}
