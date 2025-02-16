import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/view_models/real_estate_details.vm.dart';
import 'package:velocity_x/velocity_x.dart';

class RealEstateBottomSheet extends StatelessWidget {
  const RealEstateBottomSheet(this.model, {super.key});
  final RealEstateDetailsViewModel model;

  @override
  Widget build(BuildContext context) {
    return HStack([
      Container(
              child: HStack([
        Icon(Icons.perm_phone_msg_outlined, color: AppColor.inputFillColor)
            .pOnly(right: 4),
        "Call".tr().text.xl.extraBold.color(AppColor.inputFillColor).make(),
      ]).centered())
          .wOneForth(context)
          .hFull(context)
          .backgroundColor(AppColor.primaryColor),
      Container(
              child: VStack(
        [
          Icon(Icons.forum_outlined, color: AppColor.primaryColor).centered(),
          "Forum"
              .tr()
              .text
              .sm
              .normal
              .color(AppColor.primaryColor)
              .make()
              .centered()
        ],
      ).centered())
          .wOneForth(context),
      Container(
              child: InkWell(
        onTap: () => model.chatVendor(context: context),
        child: VStack([
          Icon(Icons.chat_bubble_outline, color: AppColor.primaryColor)
              .centered(),
          "Chat"
              .tr()
              .text
              .sm
              .normal
              .color(AppColor.primaryColor)
              .make()
              .centered()
        ]),
      ).centered())
          .wOneForth(context),
      Container(
              child: VStack(
        [
          Icon(Icons.call_made_outlined, color: AppColor.primaryColor)
              .centered(),
          "Consult"
              .tr()
              .text
              .sm
              .normal
              .color(AppColor.primaryColor)
              .make()
              .centered()
        ],
      ).centered())
          .wOneForth(context),
    ]).wFull(context).h(60);
  }
}
