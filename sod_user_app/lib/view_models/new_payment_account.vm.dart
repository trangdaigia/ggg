import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/models/payment_account.dart';
import 'package:sod_user/requests/payment_accounts.request.dart';
import 'package:sod_user/view_models/base.view_model.dart';
import 'package:sod_user/utils/utils.dart';

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
      final forbiddenWord = Utils.checkForbiddenWordsInMap({
        "bank_name": bankNameTEC.text,
        "name": nameTEC.text,
        "instructions": instructionsTEC.text,
      });
      if (forbiddenWord != null) {
        await CoolAlert.show(
          context: viewContext,
          type: CoolAlertType.error,
          title: "Warning forbidden words".tr(),
          text: "Payment account information contains forbidden word".tr() +
              ": $forbiddenWord",
        );
        setBusy(false);
        return;
      }

      final apiResponse = await paymentAccountRequest.newPaymentAccount(
        {
          "bank_name": bankNameTEC.text,
          "name": nameTEC.text,
          "number": numberTEC.text,
          "instructions": instructionsTEC.text,
          "is_active": isActive ? "1" : "0",
        },
      );
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
