import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/models/payment_account.dart';
import 'package:sod_user/requests/payment_accounts.request.dart';
import 'package:sod_user/view_models/base.view_model.dart';

class EditPaymentAccountViewModel extends MyBaseViewModel {
  //
  EditPaymentAccountViewModel(BuildContext context, this.paymentAccount) {
    this.viewContext = context;
  }

  //
  PaymentAccountRequest paymentAccountRequest = PaymentAccountRequest();
  TextEditingController bankNameTEC = TextEditingController();
  TextEditingController nameTEC = TextEditingController();
  TextEditingController numberTEC = TextEditingController();
  TextEditingController instructionsTEC = TextEditingController();
  bool isActive = true;
  PaymentAccount paymentAccount;

  //
  void initialise() {
    bankNameTEC.text = paymentAccount.bankName;
    nameTEC.text = paymentAccount.name;
    numberTEC.text = paymentAccount.number;
    instructionsTEC.text = paymentAccount.instructions;
    isActive = paymentAccount.isActive;
    notifyListeners();
  }

  //
  processSave() async {
    if (formKey.currentState!.validate()) {
      //
      setBusy(true);
      //
      final apiResponse = await paymentAccountRequest.updatePaymentAccount(
        paymentAccount.id,
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
        title: "Edit Payment Account".tr(),
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
