import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:sod_user/extensions/string.dart';
import 'package:sod_user/models/payment_account.dart';
import 'package:sod_user/requests/payment_accounts.request.dart';
import 'package:sod_user/view_models/base.view_model.dart';
import 'package:sod_user/views/pages/payment_account/edit_payment_account.page.dart';
import 'package:sod_user/views/pages/payment_account/new_payment_account.page.dart';

class PaymentAccountViewModel extends MyBaseViewModel {
  //
  PaymentAccountViewModel(BuildContext context) {
    this.viewContext = context;
  }

  //
  // PaymentAccountRequest paymentAccountRequest = PaymentAccountRequest();
  RefreshController refreshController = RefreshController();
  PaymentAccountRequest paymentAccountRequest = PaymentAccountRequest();
  PaymentAccount? selectedPaymentAccount;

  List<PaymentAccount> paymentAccounts = [];
  int queryPage = 1;

  //
  initialise() async {
    await getPaymentAccounts();
  }

  getPaymentAccounts({bool initialLoading = true}) async {
    //
    if (initialLoading) {
      setBusyForObject(paymentAccounts, true);
      refreshController.refreshCompleted();
      queryPage = 1;
    } else {
      queryPage = queryPage + 1;
    }

    try {
      //
      final mWalletTransactions = await paymentAccountRequest.paymentAccounts(
        page: queryPage,
      );
      
      if (initialLoading) {
        paymentAccounts = mWalletTransactions;
      } else {
        paymentAccounts.addAll(mWalletTransactions);
        refreshController.loadComplete();
      }
      clearErrors();
    } catch (error) {
      print("paymentAccounts error ==> $error");
      setErrorForObject(paymentAccounts, error);
    }
    setBusyForObject(paymentAccounts, false);
  }

  //

  void openNewPaymentAccount() async {
    final result = await Navigator.push(
        viewContext,
        MaterialPageRoute(
          builder: (context) => NewPaymentAccountPage(),
        ));

    //
    if (result != null && result is PaymentAccount) {
      paymentAccounts.insert(0, result);
      notifyListeners();
    }
  }
  void openEditPaymentAccount(PaymentAccount paymentAccount) async {
    final result = await Navigator.push(
        viewContext,
        MaterialPageRoute(
          builder: (context) => EditPaymentAccountPage(paymentAccount),
        ));

    // //
    if (result != null && result is PaymentAccount) {
      //
      final index = paymentAccounts.indexWhere(
        (element) => paymentAccount.id == element.id,
      );
      paymentAccounts[index] = result;
      notifyListeners();
    }
  }

  void editPaymentAccount(PaymentAccount paymentAccount) async {
    // final result = await Navigator.push(
    //     viewContext,
    //     MaterialPageRoute(
    //       builder: (context) => EditPaymentAccountPage(paymentAccount),
    //     ));

    // //
    // if (result != null && result is PaymentAccount) {
    //   //
    //   final index = paymentAccounts.indexWhere(
    //     (element) => paymentAccount.id == element.id,
    //   );
    //   paymentAccounts[index] = result;
    //   notifyListeners();
    // }
  }

processPayoutRequest(dynamic amountTEC) async {
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
        text: apiResponse.allGood ? "Successful".tr() : "${apiResponse.message}",
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
