import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sod_user/services/app.service.dart';
import 'package:sod_user/widgets/bottomsheets/camera_permission.bottomsheet.dart';

class CameraService {
  static Future<bool> permissionRequest() async {
    PermissionStatus status = await Permission.camera.status;
    if (status.isDenied){
      bool allow = await showRequestDialog();
      if(allow){
        await openAppSettings();
        //await Permission.camera.request().isGranted;
        status = await Permission.camera.request();
      }
    }
    return status.isGranted;
  }

  static Future<bool> showRequestDialog() async {
    //
    var requestResult = false;
    //
    await showDialog(
      context: AppService().navigatorKey.currentContext!,
      builder: (context) {
        return CameraPermissionDialog(onResult: (result) {
          requestResult = result;
        });
      },
    );

    //
    return requestResult;
  }
}
