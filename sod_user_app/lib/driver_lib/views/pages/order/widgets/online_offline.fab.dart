import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/driver_lib/utils/ui_spacer.dart';
import 'package:sod_user/driver_lib/view_models/home.vm.dart';
import 'package:sod_user/driver_lib/widgets/busy_indicator.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/driver_lib/widgets/buttons/on_off.button.dart';
import 'package:sod_user/services/app.service.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class OnlineOfflineFab extends StatelessWidget {
  const OnlineOfflineFab({Key? key, required this.homeVm}) : super(key: key);
  final HomeViewModel homeVm;
  @override
  Widget build(BuildContext context) {
    //

    final stateColor = AppService().driverIsOnline
        ? AppColor.deliveredColor
        : AppColor.cancelledColor;
    //
    return HStack(
      [
        HStack(
          [
            Icon(
              AppService().driverIsOnline
                  ? FlutterIcons.location_on_mdi
                  : FlutterIcons.location_off_mdi,
              size: 20,
              color: stateColor,
            ),
            UiSpacer.hSpace(5),
            (AppService().driverIsOnline
                    ? "You're waiting for order"
                    : "You are resting")
                .tr()
                .text
                .color(stateColor)
                .medium
                .make(),
          ],
        ).expand(),
        //action buttons
        homeVm.isBusy
            ? BusyIndicator(color: stateColor).p(15)
            : OnOffButton(
                stateColor: stateColor,
                homeVm: homeVm,
              )
        // : (!AppService().driverIsOnline ? "GO" : "OFF")
        //     .tr()
        //     .text
        //     .white
        //     .bold
        //     .xl2
        //     .make()
        //     .p(10)
        //     .box
        //     .shadowSm
        //     .roundedFull
        //     .color(reverseStateColor)
        //     .make()
        //     .onInkTap(homeVm.toggleOnlineStatus),
      ],
    ).py(0);

    // FloatingActionButton.extended(
    //     icon: Icon(
    //       !AppService().driverIsOnline
    //           ? FlutterIcons.location_off_mdi
    //           : FlutterIcons.location_on_mdi,
    //       color: Colors.white,
    //     ),
    //     label: (AppService().driverIsOnline
    //             ? "You are Online"
    //             : "You are Offline")
    //         .tr()
    //         .text
    //         .white
    //         .make(),
    //     backgroundColor:
    //         (AppService().driverIsOnline ? Colors.green : Colors.red),
    //     onPressed: homeVm.toggleOnlineStatus,
    //   );
  }
}
