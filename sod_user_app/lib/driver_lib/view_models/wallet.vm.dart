import 'package:flutter/material.dart';
import 'package:sod_user/driver_lib/models/wallet.dart';
import 'package:sod_user/driver_lib/models/wallet_transaction.dart';
import 'package:sod_user/driver_lib/requests/wallet.request.dart';
import 'package:sod_user/driver_lib/view_models/base.view_model.dart';
import 'package:sod_user/driver_lib/widgets/bottomsheets/wallet_amount_entry.bottomsheet.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:velocity_x/velocity_x.dart';

class WalletViewModel extends MyBaseViewModel {
  //
  WalletViewModel(BuildContext context) {
    this.viewContext = context;
  }

  //
  WalletRequest walletRequest = WalletRequest();
  RefreshController refreshController = RefreshController();
  TextEditingController transferAmountTEC = TextEditingController();
  Wallet? wallet;
  List<WalletTransaction> walletTransactions = [];
  int queryPage = 1;

  //
  initialise() async {
    await getWalletTransactions();
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
    setBusy(false);
  }

  getWalletTransactions({bool initialLoading = true}) async {
    //
    getWalletBalance();

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
  showAmountEntry() {
    showModalBottomSheet(
      context: viewContext,
      isScrollControlled: true,
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
      final link = await walletRequest.walletTopup(amount);
      openWebpageLink(link);
      clearErrors();
    } catch (error) {
      setError(error);
    }
    setBusy(false);
  }
}
