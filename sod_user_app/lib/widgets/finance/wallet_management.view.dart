import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/constants/app_ui_settings.dart';
import 'package:sod_user/extensions/string.dart';
import 'package:sod_user/services/auth.service.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/utils/utils.dart';
import 'package:sod_user/view_models/wallet.vm.dart';
import 'package:sod_user/widgets/busy_indicator.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class WalletManagementView extends StatefulWidget {
  const WalletManagementView({
    this.viewmodel,
    Key? key,
  }) : super(key: key);

  final WalletViewModel? viewmodel;

  @override
  State<WalletManagementView> createState() => _WalletManagementViewState();
}

class _WalletManagementViewState extends State<WalletManagementView>
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
                VStack(
                  [
                    vm.wallet?.balance == null
                        ? BusyIndicator().centered().p(12)
                        : GestureDetector(
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

                Visibility(
                  visible: vm.isBusy && vm.wallet?.balance != null,
                  child: BusyIndicator().centered().wFull(context).p(12),
                ),

                UiSpacer.vSpace(10),
                //buttons
                Visibility(
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
                              "Top-Up".tr().text.semiBold.lg.white.make(),
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
                                "Send".tr().text.semiBold.lg.white.make(),
                              ],
                              crossAlignment: CrossAxisAlignment.center,
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
                                "Receive".tr().text.semiBold.lg.white.make(),
                              ],
                              crossAlignment: CrossAxisAlignment.center,
                              alignment: MainAxisAlignment.center,
                            ).py8(),
                          ),
                        ).expand(),
                      ),
                    ],
                  ),
                ),
              ],
              
            )
                .p12()
                .box
                .shadowSm
                .color(bgColor)
                .withRounded(value: 15)
                .make()
                .wFull(context);
          },
        );
      },
    );
  }

  
}
