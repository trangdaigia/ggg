import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:sod_vendor/constants/app_colors.dart';
import 'package:sod_vendor/models/payment_account.dart';
import 'package:sod_vendor/requests/payment_account.request.dart';
import 'package:sod_vendor/services/alert.service.dart';
import 'package:sod_vendor/services/auth.service.dart';
import 'package:sod_vendor/view_models/base.view_model.dart';
import 'package:sod_vendor/views/pages/profile/widgets/edit_payment_account.bottomsheet.dart';
import 'package:sod_vendor/views/pages/profile/widgets/new_payment_account.bottomsheet.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:sod_vendor/utils/utils.dart';
import 'package:cool_alert/cool_alert.dart';

class PaymentAccountsViewModel extends MyBaseViewModel {
  //
  PaymentAccountRequest paymentAccountRequest = PaymentAccountRequest();
  //the textediting controllers
  TextEditingController nameTEC = new TextEditingController();
  TextEditingController numberTEC = new TextEditingController();
  TextEditingController instructionsTEC = new TextEditingController();
  List<PaymentAccount> paymentAccounts = [];
  int queryPage = 1;
  RefreshController refreshController = RefreshController();

  PaymentAccountsViewModel(BuildContext context) {
    this.viewContext = context;
  }

  void initialise() async {
    fetchPaymentAccounts();
  }

  //
  fetchPaymentAccounts([bool intialLoading = true]) async {
    if (intialLoading) {
      setBusyForObject(paymentAccounts, true);
      refreshController.refreshCompleted();
      queryPage = 1;
    } else {
      queryPage += 1;
    }

    try {
      final mData = await paymentAccountRequest.paymentAccounts(
        page: queryPage,
      );

      //
      if (!intialLoading) {
        refreshController.loadComplete();
        paymentAccounts.addAll(mData);
      } else {
        paymentAccounts = mData;
      }
    } catch (error) {
      toastError("$error");
    }
    setBusyForObject(paymentAccounts, false);
  }

  void newPaymentAccount() async {
    //
    showModalBottomSheet(
      context: viewContext,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: AppColor.onboarding1Color,
      builder: (ctx) {
        return new NewPaymentAccountBottomSheet(this);
      },
    );
  }

  //saving the new payment account
  Future<bool> saveNewPaymentAccount(
    GlobalKey<FormBuilderState> formBuilderKey,
  ) async {
    if (formBuilderKey.currentState!.saveAndValidate()) {
      bool result = true;
      final params = formBuilderKey.currentState!.value;

      final forbiddenWord = Utils.checkForbiddenWordsInMap(params);
      if (forbiddenWord != null) {
        await CoolAlert.show(
          context: viewContext,
          type: CoolAlertType.error,
          title: "Warning forbidden words".tr(),
          text: "Payment account information contains forbidden word".tr() +
              ": $forbiddenWord",
        );
        return false;
      }

      try {
        final newPaymentAccount =
            await paymentAccountRequest.newPaymentAccount({
          ...params,
          "vendor_id": AuthServices.currentVendor!.id,
        });
        //
        paymentAccounts.insert(0, newPaymentAccount);
        toastSuccessful("New Payment Account Created successfully".tr());
      } catch (error) {
        toastError("$error");
        result = false;
      }
      //
      return result;
    }

    return false;
  }

  editPaymentAccount(PaymentAccount paymentAccount) {
    //
    showModalBottomSheet(
      context: viewContext,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: AppColor.onboarding1Color,
      builder: (ctx) {
        return new EditPaymentAccountBottomSheet(
          this,
          paymentAccount: paymentAccount,
        );
      },
    );
  }

  //
  Future<bool> processPaymentAccountUpdate(
    GlobalKey<FormBuilderState> formBuilderKey,
    PaymentAccount paymentAccount,
  ) async {
    if (formBuilderKey.currentState!.saveAndValidate()) {
      bool result = true;
      final params = formBuilderKey.currentState!.value;

      final forbiddenWord = Utils.checkForbiddenWordsInMap(params);
      if (forbiddenWord != null) {
        await CoolAlert.show(
          context: viewContext,
          type: CoolAlertType.error,
          title: "Warning forbidden words".tr(),
          text: "Payment account information contains forbidden word".tr() +
              ": $forbiddenWord",
        );
        return false;
      }

      try {
        final apiResponse = await paymentAccountRequest.updatePaymentAccount(
          paymentAccount.id,
          params,
        );
        //
        if (apiResponse.allGood) {
          fetchPaymentAccounts();
          toastSuccessful("Payment Account updated successfully".tr());
        } else {
          toastError("Payment account updated failed".tr());
        }
      } catch (error) {
        toastError("Payment account updated failed".tr());
        result = false;
      }
      //
      return result;
    }

    return false;
  }

  //
  togglePaymentAccountStatus(PaymentAccount paymentAccount) async {
    //
    final confirmed = await AlertService.showConfirm(
      title: paymentAccount.isActive ? "Disable".tr() : "Enable".tr(),
      text:
          "Are you sure you want to ${paymentAccount.isActive ? 'disable' : 'enable'} this payment account?"
              .tr(),
      confirmBtnText: "Yes".tr(),
    );
    //
    if (confirmed) {
      //toggle status
      paymentAccount.isActive = !paymentAccount.isActive;
      //show loading
      AlertService.showLoading();
      //
      final apiResponse = await paymentAccountRequest.updatePaymentAccount(
        paymentAccount.id,
        paymentAccount.toJson(),
      );

      //
      if (apiResponse.allGood) {
        //
        final index = paymentAccounts.indexWhere(
          (e) => e.id == paymentAccount.id,
        );
        paymentAccounts[index] = paymentAccount;
        notifyListeners();
        //
        toastSuccessful("Payment account updated successful".tr());
      } else {
        toastError("Payment account updated failed".tr());
      }
      AlertService.stopLoading();
    }
  }
}
