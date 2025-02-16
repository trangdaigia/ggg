import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_vendor/models/vendor.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:velocity_x/velocity_x.dart';

class CallButton extends StatelessWidget {
  const CallButton(this.vendor, {Key? key}) : super(key: key);

  final Vendor vendor;
  @override
  Widget build(BuildContext context) {
    return Icon(
      FlutterIcons.phone_ant,
      size: 24,
      color: Colors.white,
    ).p8().box.color(Colors.green).roundedFull.make().onInkTap(() {
      launchUrlString("tel://${vendor.phone}");
    });
  }
}
