import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/extensions/string.dart';
import 'package:sod_user/services/auth.service.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/utils/utils.dart';
import 'package:sod_user/view_models/wallet.vm.dart';
import 'package:sod_user/widgets/busy_indicator.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class BalanceWalletUser extends StatefulWidget {
  const BalanceWalletUser({
    this.viewmodel,
    Key? key,
  }) : super(key: key);

  final WalletViewModel? viewmodel;

  @override
  State<BalanceWalletUser> createState() => _WalletManagementViewState();
}

class _WalletManagementViewState extends State<BalanceWalletUser>
    with WidgetsBindingObserver {
  late WalletViewModel mViewmodel;
  @override
  void initState() {
    super.initState();
    mViewmodel = widget.viewmodel ?? WalletViewModel(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mViewmodel.initialise();
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    mViewmodel.dispose();
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      mViewmodel.initialise();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = Colors.grey.shade300;
    final textColor = Utils.textColorByColor(bgColor);
    //
    return ViewModelBuilder<WalletViewModel>.reactive(
      viewModelBuilder: () => mViewmodel,
      disposeViewModel: widget.viewmodel == null,
      builder: (context, vm, child) {
        return StreamBuilder(
          stream: AuthServices.listenToAuthState(),
          builder: (ctx, snapshot) {
            //
            if (!snapshot.hasData) {
              return UiSpacer.emptySpace();
            }
            //view
            return VStack(
              [
                //
                Visibility(
                  visible: vm.isBusy,
                  child: BusyIndicator(),
                ),

                VStack(
                  [
                    //name of the wallet
                    "Ví của bạn"
                        .tr()
                        .text
                        .color(textColor)
                        .xl
                        .makeCentered(),
                    //
                    GestureDetector(
                      onTap: () => vm.openWallet(),
                      child:
                          "${AppStrings.currencySymbol} ${vm.wallet != null ? vm.wallet?.balance : 0.00}"
                              .currencyFormat()
                              .text
                              .color(textColor)
                              .xl3
                              .semiBold
                              .makeCentered(),
                    ),
                    UiSpacer.verticalSpace(space: 5),
                    "Wallet Balance"
                        .tr()
                        .text
                        .color(textColor)
                        .xl
                        .makeCentered(),
                  ],
                ),
                UiSpacer.vSpace(10),
                //buttons
              ],
            )
                .p12()
                .box
                .shadowSm
                .color(bgColor)
                .withRounded(value: 15)
                .withDecoration(
                BoxDecoration(                  //shadow
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 7,
                      offset: const Offset(3, 3), // changes position of shadow
                    ),
                  ],
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.shade500, // Màu xanh dương đậm
                      Colors.green.shade300, // Màu xanh dương nhạt
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15), // Bo góc
                ),
              )
                .make()
                .wFull(context);
          },
        );
      },
    );
  }
}
