import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sod_user/services/app.service.dart';
import 'package:sod_user/widgets/bottomsheets/contacts_permission.bottomsheet.dart';

class ContactsPermissionService {
  static Future<bool> permissionRequest() async {
    PermissionStatus status = await Permission.contacts.status;
    if (status.isDenied){
      bool allow = await showRequestDialog();
      if(allow){
        await openAppSettings();
        status = await Permission.contacts.request();
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
        return ContactsPermissionDialog(onResult: (result) {
          requestResult = result;
        });
      },
    );

    //
    return requestResult;
  }
}
