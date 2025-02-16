import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:sod_user/driver_lib/services/app.service.dart';
import 'package:sod_user/driver_lib/services/toast.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/driver_lib/views/overlays/floating_app_bubble.view.dart';

class OverlayService {
  //
  Future<void> showFloatingBubble() async {
    //
    //
    /// check if overlay permission is granted
    bool status = await FlutterOverlayWindow.isPermissionGranted();

    /// request overlay permission
    /// it will open the overlay settings page and return `true` once the permission granted.
    if (!status) {
      status = await FlutterOverlayWindow.requestPermission() ?? false;
    }

    /// Open overLay content
    if (status) {
      //if there is previous overlay, close it
      await closeFloatingBubble();
      //
      await FlutterOverlayWindow.showOverlay(
        enableDrag: true,
        height: 400,
        width: 400,
        alignment: OverlayAlignment.topLeft,
        positionGravity: PositionGravity.auto,
        startPosition: OverlayPosition(0, 50),
        overlayTitle: "Awaiting New Order".tr(),
        overlayContent: "You will be notified when there is a new order".tr(),
        // visibility: NotificationVisibility.visibilityPublic,
      ); //
    } else {
      ToastService.toastError("Permission for overlay is not granted".tr());
      //show as regular notification
    }
  }

  /// Close the overlay
  closeFloatingBubble() async {
    //if is not android, return
    if (!Platform.isAndroid) {
      return;
    }
    final isOpen = await FlutterOverlayWindow.isActive();

    if (isOpen) {
      await FlutterOverlayWindow.closeOverlay();
    }
  }
}
