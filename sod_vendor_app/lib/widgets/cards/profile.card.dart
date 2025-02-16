import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_vendor/constants/api.dart';
import 'package:sod_vendor/constants/app_colors.dart';
import 'package:sod_vendor/constants/app_images.dart';
import 'package:sod_vendor/view_models/profile.vm.dart';
import 'package:sod_vendor/views/pages/profile/paymet_accounts.page.dart';
import 'package:sod_vendor/widgets/busy_indicator.dart';
import 'package:sod_vendor/widgets/menu_item.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import '../../constants/app_text_styles.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard(this.model, {Key? key}) : super(key: key);

  final ProfileViewModel model;
  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        //profile card
        (model.isBusy || model.currentUser == null)
            ? BusyIndicator().centered().p20()
            : HStack(
                [
                  //
                  CachedNetworkImage(
                    imageUrl: model.currentUser!.photo,
                    progressIndicatorBuilder: (context, imageUrl, progress) {
                      return BusyIndicator();
                    },
                    errorWidget: (context, imageUrl, progress) {
                      return Image.asset(
                        AppImages.user,
                      );
                    },
                  )
                      .wh(Vx.dp64, Vx.dp64)
                      .box
                      .roundedFull
                      .clip(Clip.antiAlias)
                      .make(),

                  //
                  VStack(
                    [
                      //name
                      model.currentUser!.name.text.xl.semiBold.make(),
                      //email
                      model.currentUser!.email.text.light.make(),
                    ],
                  ).px20().expand(),

                  //
                ],
              ).p12(),

        //
        Visibility(
          visible: !Platform.isIOS,
          child: MenuItem(
            title: "Backend".tr(),
            onPressed: () async {
              try {
                final url = await Api.redirectAuth(Api.backendUrl);
                model.openExternalWebpageLink(url);
              } catch (error) {
                model.toastError("$error");
              }
            },
            topDivider: true,
            suffix: Icon(
            FlutterIcons.web_mco,
            color: Vx.black,
            size: 16,
          ),
          ),
        ),
        //
        MenuItem(
          child: "Payment Accounts".tr().text.bold.lg.make(),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => PaymentAccountsPage(),
              ),
              );
              },
          suffix: Icon(
            FlutterIcons.wallet_ant,
            size: 16,
            color: Vx.black,
          ),
        ),
        //
        MenuItem(
          child: "Edit Profile".tr().text.bold.lg.make(),
          onPressed: model.openEditProfile,
          suffix: Icon(
            FlutterIcons.setting_ant,
            size: 16,
            color: Vx.black,
          ),
        ),
        //change password
        MenuItem(
          child: "Change Password".tr().text.bold.lg.make(),
          onPressed: model.openChangePassword,
          suffix: Icon(
            FlutterIcons.key_ent,
            size: 16,
            color: Vx.black,
          ),
        ),
        //
        MenuItem(
          child: "Logout".tr().text.bold.lg.make(),
          onPressed: model.logoutPressed,
          suffix: Icon(
            FlutterIcons.logout_ant,
            size: 16,
            color: Vx.black,
          ),
        ),
        MenuItem(
            child: "Delete Account"
                .tr()
                .text
                .bold
                .red500
                .make(),
            onPressed: model.deleteAccount,
            divider: false,
            suffix: Icon(
              FlutterIcons.x_circle_fea,
              size: 17,
              color: Vx.red600,
            )),
      ],
    )
        .wFull(context)
        .box
        // .border(color: Theme.of(context).cardColor)
        // .color(Theme.of(context).cardColor)
        .color(Theme.of(context).colorScheme.surface)
        .outerShadow
        .withRounded(value: 5)
        .make();
  }
}
