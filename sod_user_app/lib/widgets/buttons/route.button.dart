import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/models/vendor.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:velocity_x/velocity_x.dart';

class RouteButton extends StatelessWidget {
  const RouteButton(
    this.vendor, {
    this.size,
    Key? key,
  }) : super(key: key);

  final Vendor vendor;
  final double? size;
  @override
  Widget build(BuildContext context) {
    return Icon(
      FlutterIcons.navigation_fea,
      size: size ?? 24,
      color: Colors.white,
    ).p8().box.color(AppColor.primaryColor).roundedSM.make().onInkTap(() async {
      //
      if (await MapLauncher.isMapAvailable(MapType.google) ?? false) {
        await MapLauncher.showDirections(
          mapType: MapType.google,
          destination: Coords(
            double.parse(vendor.latitude),
            double.parse(vendor.longitude),
          ),
          destinationTitle: vendor.name,
        );
      }
    });
  }
}
