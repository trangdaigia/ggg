import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sod_user/models/user.dart';
import 'package:sod_user/requests/auth.request.dart';
import 'package:sod_user/view_models/base.view_model.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class ChangePasswordViewModel extends MyBaseViewModel {
  User? currentUser;
  //the textediting controllers
  TextEditingController currentPasswordTEC = new TextEditingController();
  TextEditingController newPasswordTEC = new TextEditingController();
  TextEditingController confirmNewPasswordTEC = new TextEditingController();

  //
  AuthRequest _authRequest = AuthRequest();
  final picker = ImagePicker();

  ChangePasswordViewModel(BuildContext context) {
    this.viewContext = context;
  }

  //
  processUpdate() async {
    //
    if (formKey.currentState!.validate()) {
      //
      setBusy(true);

      //
      final apiResponse = await _authRequest.updatePassword(
        password: currentPasswordTEC.text,
        new_password: newPasswordTEC.text,
        new_password_confirmation: confirmNewPasswordTEC.text,
      );

      //
      setBusy(false);

      //
      CoolAlert.show(
        context: viewContext,
        type: apiResponse.allGood ? CoolAlertType.success : CoolAlertType.error,
        title: "Change Password".tr(),
        text: apiResponse.message,
        onConfirmBtnTap: () {
          if (apiResponse.allGood) {
            Navigator.of(viewContext).pop(true);
          }
        }
      );
    }
  }
}
