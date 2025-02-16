import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_user/constants/app_ui_settings.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/view_models/wallet.vm.dart';
import 'package:sod_user/views/pages/wallet/widgets/balance_wallet_user.dart';
import 'package:sod_user/views/pages/wallet/widgets/service_wallet_user.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:sod_user/widgets/custom_list_view.dart';
import 'package:sod_user/widgets/list_items/wallet_transaction.list_item.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> with WidgetsBindingObserver {
  //
  WalletViewModel? vm;
  int _selectedIndex = 0;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onScroll() {
    // Width of each item + spacing
    double itemWidth = MediaQuery.of(context).size.width * 0.70 + 40;

    // Calculate index based on current scroll position
    int currentIndex = (_scrollController.offset / itemWidth).round();

    if (currentIndex != _selectedIndex) {
      setState(() {
        _selectedIndex = currentIndex;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      vm?.initialise();
    }
  }

  @override
  Widget build(BuildContext context) {
    //
    vm ??= WalletViewModel(context);

    //
    return BasePage(
      title: "Wallet".tr(),
      showLeadingAction: true,
      showAppBar: true,
      body: ViewModelBuilder<WalletViewModel>.reactive(
        viewModelBuilder: () => vm!,
        onViewModelReady: (vm) => vm.initialise(),
        builder: (context, vm, child) {
          return SmartRefresher(
            controller: vm.refreshController,
            enablePullDown: true,
            enablePullUp: true,
            onRefresh: vm.loadWalletData,
            onLoading: () => vm.getWalletTransactions(initialLoading: false),
            child: VStack(
              [
                //
                SingleChildScrollView(
                  controller: _scrollController,
                  clipBehavior: Clip.antiAlias,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment
                        .center, // Căn giữa các phần tử trong Row
                    children: [
                      Container(
                        padding: EdgeInsets.only(bottom: 20),
                        width: MediaQuery.of(context).size.width * 0.70,
                        child: BalanceWalletUser(viewmodel: vm),
                      ),
                      SizedBox(width: 40),
                      Container(
                        padding: EdgeInsets.only(bottom: 20),
                        width: MediaQuery.of(context).size.width * 0.70,
                        child: ServiceWalletUser(viewmodel: vm),
                      ),
                    ],
                  ),
                ),
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(
                            0.0, 0.1), // Vị trí bắt đầu (trượt từ dưới lên)
                        end: Offset.zero, // Vị trí kết thúc
                      ).animate(animation),
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child: _selectedIndex == 0
                      ?
                      //nút rút về ví
                      Container(
                        key: ValueKey(0),
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => vm.showTransferToServiceWallet(),
                            child: Text("Rút về ví dịch vụ"),
                          ),
                        )
                      : SizedBox(key: ValueKey(1)),
                ),
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(
                            0.0, 0.1), // Vị trí bắt đầu (trượt từ dưới lên)
                        end: Offset.zero, // Vị trí kết thúc
                      ).animate(animation),
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child: _selectedIndex == 0
                      ? Column(
                          key : ValueKey(0),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              //margin top
                              margin: EdgeInsets.only(top: 20),
                              child: Visibility(
                                visible: !vm.isBusy,
                                child: HStack(
                                  [
                                    //topup button
                                    CustomButton(
                                      shapeRadius: 12,
                                      onPressed: vm.showAmountEntry,
                                      child: FittedBox(
                                        fit: BoxFit.none,
                                        child: HStack(
                                          [
                                            Icon(
                                              // Icons.add,
                                              FlutterIcons.plus_ant,
                                              color: Vx.white,
                                            )..wh(24, 24),
                                            UiSpacer.hSpace(5),
                                            //
                                            "Top-Up"
                                                .tr()
                                                .text
                                                .semiBold
                                                .lg
                                                .white
                                                .make(),
                                          ],
                                          crossAlignment:
                                              CrossAxisAlignment.center,
                                          alignment: MainAxisAlignment.center,
                                        ).py8(),
                                      ),
                                    ).expand(),
                                    Visibility(
                                      visible: AppUISettings.allowWalletTransfer,
                                      child: UiSpacer.horizontalSpace(space: 5),
                                    ),
                                    //tranfer button
                                    Visibility(
                                      visible: AppUISettings.allowWalletTransfer,
                                      child: CustomButton(
                                        shapeRadius: 12,
                                        onPressed: vm.showWalletTransferEntry,
                                        child: FittedBox(
                                          fit: BoxFit.none,
                                          child: HStack(
                                            [
                                              Icon(
                                                FlutterIcons.upload_fea,
                                                color: Vx.white,
                                              ).wh(24, 24),
                                              UiSpacer.hSpace(5),
                                              //
                                              "Send"
                                                  .tr()
                                                  .text
                                                  .semiBold
                                                  .lg
                                                  .white
                                                  .make(),
                                            ],
                                            crossAlignment:
                                                CrossAxisAlignment.center,
                                            alignment: MainAxisAlignment.center,
                                          ).py8(),
                                        ),
                                      ).expand(),
                                    ),
                                    Visibility(
                                      visible: AppUISettings.allowWalletTransfer,
                                      child: UiSpacer.horizontalSpace(space: 5),
                                    ),
                                    //tranfer button
                                    Visibility(
                                      visible: AppUISettings.allowWalletTransfer,
                                      child: CustomButton(
                                        shapeRadius: 12,
                                        onPressed: vm.showMyWalletAddress,
                                        loading: vm.busy(vm.showMyWalletAddress),
                                        child: FittedBox(
                                          fit: BoxFit.none,
                                          child: HStack(
                                            [
                                              Icon(
                                                FlutterIcons.download_fea,
                                                color: Vx.white,
                                              ).wh(24, 24),
                                              UiSpacer.hSpace(5),
                                              //
                                              "Receive"
                                                  .tr()
                                                  .text
                                                  .semiBold
                                                  .lg
                                                  .white
                                                  .make(),
                                            ],
                                            crossAlignment:
                                                CrossAxisAlignment.center,
                                            alignment: MainAxisAlignment.center,
                                          ).py8(),
                                        ),
                                      ).expand(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            //nút rút về ví dịch vụ
                          ],
                        )
                      : Container(
                          margin: EdgeInsets.only(top: 20),
                          child: Visibility(
                            visible: !vm.isBusy,
                            child: HStack(
                              [
                                //topup button
                                CustomButton(
                                  shapeRadius: 12,
                                  onPressed: vm.showWithdrawToBank,
                                  // onPressed: vm.getEarningTransactions,
                                  child: FittedBox(
                                    fit: BoxFit.none,
                                    child: HStack(
                                      [
                                        Icon(
                                          // Icons.add,
                                          FlutterIcons.download_fea,
                                          color: Vx.white,
                                        )..wh(24, 24),
                                        UiSpacer.hSpace(5),
                                        //
                                        "Withdraw"
                                            .tr()
                                            .text
                                            .semiBold
                                            .lg
                                            .white
                                            .make(),
                                      ],
                                      crossAlignment: CrossAxisAlignment.center,
                                      alignment: MainAxisAlignment.center,
                                    ).py8(),
                                  ),
                                ).expand(),
                                Visibility(
                                  visible: AppUISettings.allowWalletTransfer,
                                  child: UiSpacer.horizontalSpace(space: 5),
                                ),
                                //tranfer button
                                Visibility(
                                  visible: AppUISettings.allowWalletTransfer,
                                  child: CustomButton(
                                    shapeRadius: 12,
                                    onPressed: vm.showLinkedAccounts,
                                    child: FittedBox(
                                      fit: BoxFit.none,
                                      child: HStack(
                                        [
                                          Icon(
                                            FlutterIcons.upload_fea,
                                            color: Vx.white,
                                          ).wh(24, 24),
                                          UiSpacer.hSpace(5),
                                          //
                                          "Linked Accounts"
                                              .tr()
                                              .text
                                              .semiBold
                                              .lg
                                              .white
                                              .make(),
                                        ],
                                        crossAlignment: CrossAxisAlignment.center,
                                        alignment: MainAxisAlignment.center,
                                      ).py8(),
                                    ),
                                  ).expand(),
                                ),
                                //tranfer button
                              ],
                            ),
                          ),
                        ),
                ),
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(
                            0.0, 0.1), // Vị trí bắt đầu (trượt từ dưới lên)
                        end: Offset.zero, // Vị trí kết thúc
                      ).animate(animation),
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child: _selectedIndex == 0
                      ? Column(
                          key: ValueKey(0),
                          children: [
                            "Wallet Transactions".tr().text.bold.xl.make().py12(),
                            CustomListView(
                              noScrollPhysics: true,
                              isLoading: vm.busy(vm.walletTransactions),
                              onRefresh: vm.getWalletTransactions,
                              onLoading: () =>
                                  vm.getWalletTransactions(initialLoading: false),
                              dataSet: vm.walletTransactions,
                              itemBuilder: (context, index) {
                                return WalletTransactionListItem(
                                    vm.walletTransactions[index]);
                              },
                            ),
                          ],
                        )
                      : Column(
                          key: ValueKey(1),
                          children: [
                            "Service Wallet Transactions"
                                .tr()
                                .text
                                .bold
                                .xl
                                .make()
                                .py12(),
                            CustomListView(
                              noScrollPhysics: true,
                              isLoading: vm.busy(vm.walletTransactions),
                              onRefresh: vm.getEarningTransactions,
                              onLoading: () => vm.getEarningTransactions(),
                              dataSet: vm.earningTransactions,
                              itemBuilder: (context, index) {
                                return WalletTransactionListItem(
                                    vm.walletTransactions[index]);
                              },
                            ),
                          ],
                        ),
                ),
              ],
            ).p20().scrollVertical(),
          );
        },
      ),
    );
  }
}
