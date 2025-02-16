import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sod_user/driver_lib/flavors.dart';
import 'package:sod_user/driver_lib/widgets/bottomsheets/background_location_permission.bottomsheet.dart';
import 'package:sod_user/driver_lib/widgets/bottomsheets/background_permission.bottomsheet.dart';
import 'package:sod_user/driver_lib/widgets/bottomsheets/regular_location_permission.bottomsheet.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sod_user/services/app.service.dart';

class AppPermissionHandlerService {
  //MANAGE BACKGROUND SERVICE PERMISSION
  Future<bool> handleBackgroundRequest() async {
    //check for permission
    bool hasPermissions = await FlutterBackground.hasPermissions;
    bool overlayPermission = await Permission.systemAlertWindow.isGranted;
    if (!(hasPermissions && overlayPermission)) {
      //background app service permission
      final result = await showDialog(
        barrierDismissible: false,
        context: AppService().navigatorKey.currentContext!,
        builder: (context) {
          return BackgroundPermissionDialog();
        },
      );
      //
      if (result != null && (result is bool) && result) {
        hasPermissions = result;
      }
    }

    return hasPermissions;
  }

  //MANAGE LOCATION PERMISSION
  Future<bool> isLocationGranted() async {
    var status = await Permission.locationWhenInUse.status;
    return status.isGranted;
  }

  Future<bool> handleLocationRequest() async {
    var status = await Permission.locationWhenInUse.status;
    //check if location permission is not granted
    if (!status.isGranted) {
      final requestResult = await showDialog(
        barrierDismissible: false,
        context: AppService().navigatorKey.currentContext!,
        builder: (context) {
          return RegularLocationPermissionDialog();
        },
      );
      //check if dialog was accepted or not
      if (requestResult == null || (requestResult is bool && !requestResult)) {
        return false;
      }

      //
      PermissionStatus status = await Permission.locationWhenInUse.request();
      if (status.isGranted) {
        //
        final requestResult = await showDialog(
          barrierDismissible: false,
          context: AppService().navigatorKey.currentContext!,
          builder: (context) {
            return BackgroundLocationPermissionDialog();
          },
        );
        //check if dialog was accepted or not
        if (requestResult == null ||
            (requestResult is bool && !requestResult)) {
          return false;
        }

        //request for alway in use location
        if (F.appFlavor == Flavor.sob_express_admin) {
          return true;
        }
        status = await Permission.locationAlways.request();
        if (!status.isGranted) {
          permissionDeniedAlert();
        }
      } else {
        permissionDeniedAlert();
      }

      if (status.isPermanentlyDenied) {
        //When the user previously rejected the permission and select never ask again
        //Open the screen of settings
        await openAppSettings();
      }
    }
    //location permission is granted
    else {
      //In use is available, check the always in use
      if (F.appFlavor == Flavor.sob_express_admin) {
        return true;
      }
      var status = await Permission.locationAlways.status;
      if (!status.isGranted) {
        final requestResult = await showDialog(
          barrierDismissible: false,
          context: AppService().navigatorKey.currentContext!,
          builder: (context) {
            return BackgroundLocationPermissionDialog();
          },
        );
        //check if dialog was accepted or not
        if (requestResult == null ||
            (requestResult is bool && !requestResult)) {
          return false;
        }

        //request for alway in use location
        var status = await Permission.locationAlways.request();
        print("Status: $status");
        if (status.isGranted) {
          //Do some stuff
        } else {
          var status = await Permission.locationAlways.status;
          if (!status.isGranted) {
            permissionDeniedAlert();
          }
        }
      } else {
        //previously available, do some stuff or nothing
        return true;
      }
    }
    return true;
  }

  //
  void permissionDeniedAlert() async {
    //The user deny the permission
    await Fluttertoast.showToast(
      msg: "Permission denied".tr(),
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
