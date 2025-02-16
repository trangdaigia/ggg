import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_images.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/view_models/profile.vm.dart';
import 'package:sod_user/view_models/wallet.vm.dart';
import 'package:sod_user/extensions/string.dart';
import 'package:sod_user/widgets/busy_indicator.dart';
import 'package:sod_user/widgets/states/empty.state.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class ProfileCard extends StatefulWidget {
  const ProfileCard(this.model, {super.key, this.walletViewModel});

  final ProfileViewModel model;
  final WalletViewModel? walletViewModel;
  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  @override
  Widget build(BuildContext context) {
    return widget.model.authenticated
        ? ViewModelBuilder<WalletViewModel>.reactive(
            viewModelBuilder: () =>
                widget.walletViewModel ?? WalletViewModel(context),
            onViewModelReady: (viewModel) => viewModel.initialise(),
            disposeViewModel: false,
            builder: (context, vm, child) {
              final balance = vm.wallet != null
                  ? "${AppStrings.currencySymbol} ${vm.wallet?.balance}"
                      .currencyFormat()
                  : null;
              final earningBalance =
                  "${AppStrings.currencySymbol} ${vm.earnigBalance}"
                      .currencyFormat();
              return Container(
                // Padding status bar
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                  bottom: 16,
                  left: 16,
                ),
                //color: AppColor.primaryColor,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.topRight,
                    colors: [
                      AppColor.primaryColor,
                      AppColor.primaryColor.withOpacity(0.78),
                    ],
                  ),
                ),
                child: Column(children: [
                  Row(children: [
                    Spacer(),
                    // Notification
                    IconButton(
                      icon: Icon(Icons.notifications, size: 28),
                      color: Colors.white,
                      onPressed: widget.model.openNotification,
                    ),

                    // Chat
                    IconButton(
                      icon: Icon(Icons.chat, size: 28),
                      color: Colors.white,
                      onPressed: widget.model.openChat,
                    ),

                    // Setting
                    IconButton(
                      icon: Icon(Icons.settings, size: 28),
                      color: Colors.white,
                      onPressed: widget.model.openSettingProfile,
                    ),
                    SizedBox(width: 8),
                  ]),
                  Row(children: [
                    // Avatar
                    CachedNetworkImage(
                      imageUrl: widget.model.currentUser?.photo ?? "",
                      progressIndicatorBuilder: (context, imageUrl, progress) =>
                          BusyIndicator(),
                      errorWidget: (context, imageUrl, progress) =>
                          Image.asset(AppImages.user),
                      fit: BoxFit.cover,
                    ).wh(60, 60).box.roundedFull.clip(Clip.antiAlias).make(),

                    //
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name
                          Text(
                            widget.model.currentUser?.name ?? "User".tr(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Wrap(
                            children: [
                              if (balance != null)
                                Text('Ví: $balance',
                                    style: TextStyle(color: Colors.white)),
                              SizedBox(width: 16),
                              Text('Ví dịch vụ: $earningBalance',
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ]).px20().expand(),
                    // AppStrings.enableReferSystem
                    //     ? "Share referral code"
                    //         .tr()
                    //         .text
                    //         .lg
                    //         .white
                    //         .make()
                    //         .box
                    //         .px4
                    //         .roundedSM
                    //         .border(color: Colors.white)
                    //         .make()
                    //         .onInkTap(widget.model.shareReferralCode)
                    //         .py4()
                    //     : UiSpacer.emptySpace(),
                    // //
                  ]),
                ]).onTap(widget.model.openProfileDetail),
              );
            })
        : EmptyState(
            auth: true,
            showAction: true,
            actionPressed: widget.model.openLogin,
          ).pOnly(top: MediaQuery.of(context).padding.top);
  }
}
