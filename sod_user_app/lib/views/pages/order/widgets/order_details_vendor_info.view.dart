import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_ui_settings.dart';
import 'package:sod_user/extensions/dynamic.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/view_models/order_details.vm.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class OrderDetailsVendorInfoView extends StatelessWidget {
  const OrderDetailsVendorInfoView(this.vm, {Key? key}) : super(key: key);
  final OrderDetailsViewModel vm;

  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        HStack(
          [
            //
            VStack(
              [
                (!vm.order.isSerice ? "Vendor" : "Service Provider")
                    .tr()
                    .text
                    .gray500
                    .medium
                    .make(),
                vm.order.vendor!.name.text.medium.xl
                    .make()
                    .py8()
                    .pOnly(bottom: Vx.dp4),
              ],
            ).expand(),
            //call
            Visibility(
              visible: vm.order.canChatVendor && AppUISettings.canCallVendor,
              child: CustomButton(
                icon: FlutterIcons.phone_call_fea,
                iconColor: Colors.white,
                color: AppColor.primaryColor,
                shapeRadius: Vx.dp20,
                onPressed: vm.callVendor,
              ).wh(Vx.dp64, Vx.dp40).p12(),
            ),
          ],
        ),

        //chat
        if (vm.order.canChatVendor)
          Visibility(
            visible: AppUISettings.canVendorChat,
            child: CustomButton(
              icon: FlutterIcons.chat_ent,
              iconColor: Colors.white,
              title: "Chat with %s".tr().fill(
                  [(!vm.order.isSerice ? "Vendor" : "Service Provider").tr()]),
              color: AppColor.primaryColor,
              onPressed: vm.chatVendor,
            ).h(Vx.dp48).pOnly(top: Vx.dp12, bottom: Vx.dp20),
          )
        else
          UiSpacer.emptySpace(),

        //rate vendor
        vm.order.canRateVendor
            ? CustomButton(
                icon: FlutterIcons.rate_review_mdi,
                iconColor: Colors.white,
                title: "Rate %s".tr().fill([
                  (!vm.order.isSerice ? "Vendor" : "Service Provider").tr()
                ]),
                color: AppColor.primaryColor,
                onPressed: vm.rateVendor,
              ).h(Vx.dp48).pOnly(top: Vx.dp12, bottom: Vx.dp20)
            : UiSpacer.emptySpace(),
      ],
    ).px(20);
  }
}
