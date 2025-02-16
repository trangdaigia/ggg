import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:sod_user/driver_lib/models/payment_account.dart';
import 'package:sod_user/driver_lib/requests/payment_account.request.dart';
import 'package:sod_user/driver_lib/view_models/base.view_model.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class NewPaymentAccountViewModel extends MyBaseViewModel {
  //
  NewPaymentAccountViewModel(BuildContext context) {
    this.viewContext = context;
  }

  //
  PaymentAccountRequest paymentAccountRequest = PaymentAccountRequest();
  TextEditingController nameTEC = TextEditingController();
  TextEditingController bankNameTEC = TextEditingController();
  TextEditingController numberTEC = TextEditingController();
  TextEditingController instructionsTEC = TextEditingController();
  bool isActive = true;

  //
  processSave() async {
    if (formKey.currentState!.validate()) {
      //
      setBusy(true);
      //
      final apiResponse = await paymentAccountRequest.newPaymentAccount(
        {
          "bank_name": bankNameTEC.text,
          "name": nameTEC.text,
          "number": numberTEC.text,
          "instructions": instructionsTEC.text,
          "is_active": isActive ? "1" : "0",
        },
      );

      //
      CoolAlert.show(
        context: viewContext,
        type: apiResponse.allGood ? CoolAlertType.success : CoolAlertType.error,
        title: "New Payment Account".tr(),
        text:
            apiResponse.allGood ? "Successful".tr() : "${apiResponse.message}",
        onConfirmBtnTap: apiResponse.allGood
            ? () {
                //cool
                final newPaymentAccount = PaymentAccount.fromJson(
                  apiResponse.body["data"],
                );
                //
                Navigator.pop(viewContext);
                Navigator.pop(viewContext, newPaymentAccount);
              }
            : null,
      );
      setBusy(false);
    }
  }
}
