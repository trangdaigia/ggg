import 'dart:async';

import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_routes.dart';
import 'package:sod_user/extensions/string.dart';
import 'package:sod_user/global/global_variable.dart';
import 'package:sod_user/models/api_response.dart';
import 'package:sod_user/models/payment_method.dart';
import 'package:sod_user/models/trip.dart';
import 'package:sod_user/models/user.dart';
import 'package:sod_user/models/wallet.dart';
import 'package:sod_user/models/wallet_transaction.dart';
import 'package:sod_user/requests/payment_accounts.request.dart';
import 'package:sod_user/requests/payment_method.request.dart';
import 'package:sod_user/requests/wallet.request.dart';
import 'package:sod_user/services/app.service.dart';
import 'package:sod_user/services/auth.service.dart';
import 'package:sod_user/view_models/payment.view_model.dart';
import 'package:sod_user/views/pages/payment_account/payment_account.page.dart';
import 'package:sod_user/views/pages/wallet/wallet_transfer.page.dart';
import 'package:sod_user/views/pages/wallet/widgets/modal_change_balance.dart';
import 'package:sod_user/widgets/bottomsheets/wallet_amount_entry.bottomsheet.dart';
import 'package:sod_user/widgets/bottomsheets/withdraw_to_bank.bottomsheet.dart';
import 'package:sod_user/widgets/finance/wallet_address.bottom_sheet.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import '../models/payment_account.dart';

class WalletViewModel extends PaymentViewModel {
  //
  WalletViewModel(BuildContext context) {
    this.viewContext = context;
  }

  //
  WalletRequest walletRequest = WalletRequest();
  Wallet? wallet;
  RefreshController refreshController = RefreshController();
  List<WalletTransaction> walletTransactions = [];
  int queryPage = 1;
  StreamSubscription<bool>? refreshWalletBalanceSub;
  //paymentAccounts
  List<PaymentAccount> paymentAccounts = [];
  PaymentAccountRequest paymentAccountRequest = PaymentAccountRequest();
  PaymentMethodRequest paymentMethodRequest = PaymentMethodRequest();
  PaymentAccount? selectedPaymentAccount;
  List<PaymentMethod> paymentMethods = [];
  PaymentMethod? selectedPaymentMethod;
  User? currentUser;
  bool authenticated = false;
  StreamSubscription? authStateListenerStream;
  dynamic earning;
  int earnigBalance = 0;
  List<WalletTransaction> earningTransactions = [];

  //
  initialise() async {
    authenticated = await AuthServices.authenticated();

    await getPaymentMethod();
    refreshWalletBalanceSub = AppService().refreshWalletBalance.listen(
      (value) {
        loadWalletData();
      },
    );

    if (authenticated) {
      await loadWalletData(); // authentiction required
      getPaymentAccounts(); // authentiction required
      getEarning(); // authentiction required
      getEarningTransactions(); // authentiction required
      await getPaymentAccounts(); // authentiction required
      currentUser = await AuthServices.getCurrentUser(force: true);
    } else {
      listenToAuthChange();
    }
  }

  listenToAuthChange() {
    authStateListenerStream?.cancel();
    authStateListenerStream =
        AuthServices.listenToAuthState().listen((event) async {
      if (event != null && event) {
        authenticated = event;
        currentUser = await AuthServices.getCurrentUser(force: true);
        notifyListeners();
        authStateListenerStream?.cancel();
      }
    });
  }

  dispose() {
    super.dispose();
    refreshWalletBalanceSub?.cancel();
  }

  //
  loadWalletData() async {
    GlobalVariable.refreshCache = true;
    if (refreshController.isRefresh) {
      refreshController.refreshCompleted();
    }
    getWalletBalance();
    getWalletTransactions();
  }

  //
  getWalletBalance() async {
    setBusy(true);
    try {
      wallet = await walletRequest.walletBalance();
      clearErrors();
    } catch (error) {
      setError(error);
    }
    notifyListeners();
    setBusy(false);
  }

  getWalletTransactions({bool initialLoading = true}) async {
    //
    if (initialLoading) {
      setBusyForObject(walletTransactions, true);
      refreshController.refreshCompleted();
      queryPage = 1;
    } else {
      queryPage = queryPage + 1;
    }

    try {
      //
      final mWalletTransactions = await walletRequest.walletTransactions(
        page: queryPage,
      );
      //
      if (initialLoading) {
        walletTransactions = mWalletTransactions;
      } else {
        walletTransactions.addAll(mWalletTransactions);
        refreshController.loadComplete();
      }
      clearErrors();
    } catch (error) {
      print("Wallet transactions error ==> $error");
      setErrorForObject(walletTransactions, error);
    }
    notifyListeners();
    setBusyForObject(walletTransactions, false);
  }

  //
  showAmountEntry() async {
    await showModalBottomSheet(
      context: viewContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return WalletAmountEntryBottomSheet(
          onSubmit: (String amount) {
            Navigator.pop(viewContext);
            initiateWalletTopUp(amount);
          },
        );
      },
    );
  }

  //
  initiateWalletTopUp(String amount) async {
    setBusy(true);

    try {
      final link = await walletRequest.walletTopup(amount) as String;
      await openWebpageLink(link);

      print('openWebpageLink() done, refreshing wallet data');
      await loadWalletData();
      await getPaymentAccounts();

      clearErrors();
    } catch (error) {
      setError(error);
      toastError("$error");
      print("error >> $error");
    }
    setBusy(false);
  }

  //Wallet transfer
  showWalletTransferEntry(
      [String? phone, String? deposit_price, Trip? trip]) async {
    //
    if (phone == null && deposit_price == null) {
      await getWalletBalance();
      getWalletTransactions();

      final result = await Navigator.push(
        viewContext,
        MaterialPageRoute(
          builder: (context) => WalletTransferPage(wallet!, null, null, null),
        ),
      );
      //
      if (result == null) {
        return;
      } else {
        await loadWalletData();
        return;
      }
    } else {
      await getWalletBalance();
      getWalletTransactions();

      final result = await Navigator.push(
        viewContext,
        MaterialPageRoute(
          builder: (context) =>
              WalletTransferPage(wallet!, phone, deposit_price, trip),
        ),
      );
      //
      if (result == null) {
        return;
      } else {
        await loadWalletData();
        return true;
      }
    }
  }

  showMyWalletAddress() async {
    setBusyForObject(showMyWalletAddress, true);
    final apiResponse = await walletRequest.myWalletAddress();
    //
    if (apiResponse.allGood) {
      showModalBottomSheet(
        isScrollControlled: true,
        context: viewContext,
        isDismissible: false,
        backgroundColor: Colors.transparent,
        builder: (ctx) => WalletAddressBottomSheet(apiResponse),
      );
    } else {
      toastError(apiResponse.message ?? "Error loading wallet address".tr());
    }
    setBusyForObject(showMyWalletAddress, false);
  }

  //open modal for withdrawal to bank
  showWithdrawToBank() async {
    await showModalBottomSheet(
      context: viewContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return WithdrawToBankBottomSheet(
          onSubmit: (String amount, String bankAccount) {
            Navigator.pop(viewContext);
            processPayoutRequest(amount);
          },
          bankAccounts: paymentAccounts
              .map((e) => "${e.bankName} - ${e.name} - ${e.number}")
              .toList(),
        );
      },
    );
  }

  withDrawToBank() async {
    setBusyForObject(withDrawToBank, true);
    final apiResponse = new ApiResponse();
    //
    if (apiResponse.allGood) {
      toastSuccessful(apiResponse.message ?? "Withdrawal request sent".tr());
    } else {
      toastError(
          apiResponse.message ?? "Failed to send withdrawal request".tr());
    }
    setBusyForObject(withDrawToBank, false);
  }

  openWallet() {
    Navigator.of(viewContext).pushNamed(
      AppRoutes.walletRoute,
    );
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
      //
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

  getPaymentMethod() async {
    final apiResponse = await paymentMethodRequest.getPaymentMethod();
    if (apiResponse.length > 0) {
      paymentMethods = apiResponse;
      selectedPaymentMethod = paymentMethods.firstWhere(
        (element) => element.slug == "vnpay",
        orElse: () => paymentMethods[0],
      );
    } else {
      toastError("Error loading payment methods".tr());
    }
  }

  showLinkedAccounts() {
    Navigator.of(viewContext).push(
      MaterialPageRoute(
        builder: (context) => PaymentAccountPage(),
      ),
    );
  }

  processPayoutRequest(dynamic amountTEC) async {
    //
    print('currentUser ==> $currentUser');
    selectedPaymentAccount = await paymentAccounts[0];
    print("selectedPaymentAccount ==> $selectedPaymentAccount");
    print("amountTEC ==> $amountTEC");
    if (selectedPaymentAccount == null) {
      toastError("Please select payment account".tr());
      //
    } else {
      setBusyForObject(selectedPaymentAccount, true);
      //
      final apiResponse = await paymentAccountRequest.requestPayout(
        {
          "amount": cleanTextFieldInputNumber(amountTEC),
          "payment_account_id": selectedPaymentAccount?.id,
          "payment_method_id": selectedPaymentMethod?.id,
          "user_id": currentUser?.id,
          "earning": 10000,
          "is_credit": 0
        },
      );

      print("apiResponse ==> $apiResponse");
      CoolAlert.show(
        context: viewContext,
        type: apiResponse.allGood ? CoolAlertType.success : CoolAlertType.error,
        title: "Request Payout".tr(),
        text:
            apiResponse.allGood ? "Successful".tr() : "${apiResponse.message}",
        onConfirmBtnTap: apiResponse.allGood
            ? () {
                Navigator.pop(viewContext);
              }
            : null,
      );
      setBusyForObject(selectedPaymentAccount, false);
    }
  }

  //getearning
  getEarning() async {
    setBusyForObject(wallet, true);
    final apiResponse = await paymentAccountRequest.getEarning();
    if (apiResponse.allGood) {
      earning = apiResponse.body;
      earnigBalance = earning["earning"]["amount"] ?? 0;
    } else {
      toastError(apiResponse.message ?? "Error loading wallet data".tr());
    }
    setBusyForObject(wallet, false);
  }

  //getEarningTransactions
  getEarningTransactions() async {
    print("getEarningTransactions");
    setBusyForObject(walletTransactions, true);
    final apiResponse = await paymentAccountRequest.getEarningTransactions();
    if (apiResponse.allGood) {
      earningTransactions =
          apiResponse.data.map((e) => WalletTransaction.fromJson(e)).toList();
      print("earningTransactions ==> $earningTransactions");
    } else {
      toastError(apiResponse.message ?? "Error loading wallet data".tr());
    }
    setBusyForObject(walletTransactions, false);
  }

  //chuyển đổi tiền
  changeBalanceToServiceWallet(String amount) async {
    setBusyForObject(changeBalanceToServiceWallet, true);
    final apiResponse =
        await paymentAccountRequest.changeBalanceToServiceWallet(
      {
        "amount": cleanTextFieldInputNumber(amount),
      },
    );
    if (apiResponse.allGood) {
      toastSuccessful(apiResponse.message ?? "Balance transferred".tr());
    } else {
      toastError(apiResponse.message ?? "Failed to transfer balance".tr());
    }
    setBusyForObject(changeBalanceToServiceWallet, false);
  }

  //phương thức chuyển tiền sang ví dịch vụ
  showTransferToServiceWallet() async {
    await showModalBottomSheet(
      context: viewContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ModalChangeBalance(
          onSubmit: (String amount) {
            Navigator.pop(viewContext);
            changeBalanceToServiceWallet(amount);
          },
        );
      },
    );
  }
}
