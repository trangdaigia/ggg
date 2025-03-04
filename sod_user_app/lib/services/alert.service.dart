import 'dart:async';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:sod_user/services/app.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class AlertService {
  //

  static Future<bool> showConfirm({
    String? title,
    String? text,
    String cancelBtnText = "Cancel",
    String confirmBtnText = "Ok",
    Function? onConfirm,
  }) async {
    //
    bool result = false;

    await CoolAlert.show(
        context: AppService().navigatorKey.currentContext!,
        type: CoolAlertType.confirm,
        title: title,
        text: text,
        cancelBtnText: cancelBtnText.tr(),
        confirmBtnText: confirmBtnText.tr(),
        closeOnConfirmBtnTap: false,
        onConfirmBtnTap: () {
          if (onConfirm == null) {
            result = true;
            Navigator.pop(AppService().navigatorKey.currentContext!);
          } else {
            onConfirm();
          }
        });

    //
    return result;
  }

  static Future<bool> success({
    String? title,
    String? text,
    String cancelBtnText = "Cancel",
    String confirmBtnText = "Ok",
  }) async {
    //
    bool result = false;

    await CoolAlert.show(
        context: AppService().navigatorKey.currentContext!,
        type: CoolAlertType.success,
        title: title,
        text: text,
        confirmBtnText: confirmBtnText.tr(),
        cancelBtnText: cancelBtnText.tr(),
        closeOnConfirmBtnTap: true,
        onConfirmBtnTap: () {
          result = true;
        });

    //
    return result;
  }

  static Future<bool> error({
    String? title,
    String? text,
    String confirmBtnText = "Ok",
  }) async {
    //
    bool result = false;

    await CoolAlert.show(
        context: AppService().navigatorKey.currentContext!,
        type: CoolAlertType.error,
        title: title,
        text: text,
        confirmBtnText: confirmBtnText.tr(),
        closeOnConfirmBtnTap: true,
        onConfirmBtnTap: () {
          result = true;
        });

    //
    return result;
  }

  static Future<bool> warning({
    String? title,
    String? text,
    String confirmBtnText = "Ok",
  }) async {
    //
    bool result = false;

    await CoolAlert.show(
        context: AppService().navigatorKey.currentContext!,
        type: CoolAlertType.warning,
        title: title,
        text: text,
        confirmBtnText: confirmBtnText.tr(),
        closeOnConfirmBtnTap: true,
        onConfirmBtnTap: () {
          result = true;
        });

    //
    return result;
  }

  static void showLoading() {
    CoolAlert.show(
      context: AppService().navigatorKey.currentContext!,
      type: CoolAlertType.loading,
      title: "".tr(),
      text: "Processing. Please wait...".tr(),
      barrierDismissible: false,
    );
  }

  static void stopLoading() {
    Navigator.pop(AppService().navigatorKey.currentContext!);
  }
}
