import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sod_user/driver_lib/constants/app_images.dart';
import 'package:sod_user/services/auth.service.dart';
import 'package:sod_user/driver_lib/view_models/profile.vm.dart';
import 'package:sod_user/driver_lib/views/pages/profile/manage_account.page.dart';
import 'package:sod_user/driver_lib/widgets/busy_indicator.dart';
import 'package:velocity_x/velocity_x.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard(this.model, {Key? key}) : super(key: key);

  final ProfileViewModel model;
  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        //profile card
        (model.isBusy)
            ? BusyIndicator().centered().p20()
            : HStack(
                [
                  //
                  CachedNetworkImage(
                    imageUrl: model.currentUser?.user.photo ?? "",
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
                      "${model.currentUser?.user.name}".text.xl.semiBold.make(),
                      "${model.currentUser?.user.email}".text.light.make(),
                    ],
                  ).px20().expand(),

                  //
                ],
              ).p12().onTap(() {
                context.nextPage(ManageAccountPage());
              }),
      ],
    ).wFull(context);
  }
}
