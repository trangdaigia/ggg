import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:sod_user/driver_lib/extensions/string.dart';
import 'package:sod_user/driver_lib/models/currency.dart';
import 'package:sod_user/driver_lib/models/earning.dart';
import 'package:sod_user/driver_lib/models/payment_account.dart';
import 'package:sod_user/driver_lib/requests/earning.request.dart';
import 'package:sod_user/driver_lib/requests/payment_account.request.dart';
import 'package:sod_user/driver_lib/view_models/base.view_model.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class EarningViewModel extends MyBaseViewModel {
  //
  EarningRequest earningRequest = EarningRequest();
  PaymentAccountRequest paymentAccountRequest = PaymentAccountRequest();
  Currency? currency;
  Earning? earning;
  bool showPayout = false;
  List<PaymentAccount> paymentAccounts = [];
  PaymentAccount? selectedPaymentAccount;
  TextEditingController amountTEC = TextEditingController();

  EarningViewModel(BuildContext context) {
    this.viewContext = context;
  }

  void initialise() async {
    //
    fetchEarning();
  }

  fetchEarning() async {
    setBusy(true);
    try {
      final results = await earningRequest.getEarning();
      currency = results[0];
      earning = results[1];
      clearErrors();
    } catch (error) {
      setError(error);
    }
    setBusy(false);
  }

  //
  void requestEarningPayout() async {
    showPayout = true;
    notifyListeners();
    //
    if (paymentAccounts.isNotEmpty) {
      return;
    }
    //
    setBusyForObject(paymentAccounts, true);
    try {
      paymentAccounts = (await paymentAccountRequest.paymentAccounts(page: 0))
          .filter((e) => e.isActive)
          .toList();
    } catch (error) {
      print("paymentAccounts error ==> $error");
    }
    setBusyForObject(paymentAccounts, false);
  }

  processPayoutRequest() async {
    //
    if (selectedPaymentAccount == null) {
      toastError("Please select payment account".tr());
      //
    } else if (formKey.currentState!.validate()) {
      setBusyForObject(selectedPaymentAccount, true);
      //
      final apiResponse = await paymentAccountRequest.requestPayout(
        {
          "amount": cleanTextFieldInputNumber(amountTEC.text),
          "payment_account_id": selectedPaymentAccount?.id,
        },
      );
      //
      CoolAlert.show(
        context: viewContext,
        type: apiResponse.allGood ? CoolAlertType.success : CoolAlertType.error,
        title: "Request Payout".tr(),
        text:
            apiResponse.allGood ? "Successful".tr() : "${apiResponse.message}",
        onConfirmBtnTap: apiResponse.allGood
            ? () {
                Navigator.pop(viewContext);
                Navigator.pop(viewContext);
              }
            : null,
      );

      setBusyForObject(selectedPaymentAccount, false);
    }
  }
}
