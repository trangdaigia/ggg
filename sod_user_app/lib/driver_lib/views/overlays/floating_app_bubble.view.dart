import 'package:app_to_foreground/app_to_foreground.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:sod_user/driver_lib/constants/app_images.dart';
import 'package:sod_user/driver_lib/models/new_order.dart';
import 'package:sod_user/driver_lib/models/new_taxi_order.dart';
import 'package:velocity_x/velocity_x.dart';

class FloatingAppBubble extends StatefulWidget {
  const FloatingAppBubble({Key? key}) : super(key: key);

  @override
  State<FloatingAppBubble> createState() => _FloatingAppBubbleState();
}

class _FloatingAppBubbleState extends State<FloatingAppBubble> {
  NewOrder? newOrder;
  NewTaxiOrder? newTaxiOrder;
  Widget currentWidget = SizedBox.shrink();

  @override
  void initState() {
    super.initState();
    // FlutterOverlayWindow.overlayListener.listen(
    //   (event) {
    //     print("event: $event");
    //     //
    //   },
    // );
  }

  @override
  Widget build(BuildContext context) {
    bool trigerLongPress = true;
    return Container(
      child: Column(
        children: [
          Image.asset(AppImages.appLogo, fit: BoxFit.fill)
              .h(60)
              .w(60)
              .box
              .roundedFull
              .clip(Clip.antiAlias)
              .make()
              .onTap(
            () async {
              AppToForeground.appToForeground();
              await Future.delayed(Duration(milliseconds: 1000));
              await FlutterOverlayWindow.resizeOverlay(0, 0, false);
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FloatingAppBubble(),
                ),
              );
            },
          ).onLongPress(() async {
            if (trigerLongPress) {
              AppToForeground.appToForeground();

              await Future.delayed(Duration(milliseconds: 1000));
              await FlutterOverlayWindow.resizeOverlay(0, 0, false);
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FloatingAppBubble(),
                ),
              );
            }
            trigerLongPress = false;
            await Future.delayed(Duration(milliseconds: 500));
          }, widget.key)
        ],
      ),
    );
  }
}
