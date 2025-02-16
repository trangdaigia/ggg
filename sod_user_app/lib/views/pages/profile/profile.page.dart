import 'package:flutter/material.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_finance_settings.dart';
import 'package:sod_user/constants/app_images.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/constants/app_ui_settings.dart';
import 'package:sod_user/extensions/dynamic.dart';
import 'package:sod_user/resources/resources.dart';
import 'package:sod_user/services/app.service.dart';
import 'package:sod_user/services/auth.service.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/view_models/profile.vm.dart';
import 'package:sod_user/view_models/welcome.vm.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:sod_user/widgets/cards/profile.card.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:sod_user/constants/app_languages.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ViewModelBuilder<ProfileViewModel>.reactive(
      viewModelBuilder: () => ProfileViewModel(context),
      onViewModelReady: (model) => model.initialise(),
      disposeViewModel: false,
      builder: (context, model, child) => BasePage(
          body: SmartRefresher(
              controller: model.refreshController,
              enablePullDown: true,
              // enablePullUp: true,
              onRefresh: model.reloadPage,
              child: VStack(
                [
                  /////////////////////////////////////////////////
                  // Profile card section
                  ProfileCard(
                    model,
                    walletViewModel: model.walletViewModel,
                  ),

                  /////////////////////////////////////////////////

                  // Round border
                  if (model.authenticated)
                    Container(
                            decoration: BoxDecoration(
                              color: AppColor.faintBgColor,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            height: 28)
                        .backgroundColor(AppColor.primaryColor)
                  else
                    SizedBox(height: 28),

                  Builder(builder: (context) {
                    // Check how many items are visible
                    final visibleItemCount = [
                      AppFinanceSettings.enableLoyalty,
                      AppUISettings.allowWallet,
                      true,
                      true,
                      AppStrings.enableReferSystem
                    ].where((element) => element == true).length;
                    if (visibleItemCount == 0) return UiSpacer.emptySpace();

                    // Calculate the width of each item
                    final width =
                        MediaQuery.of(context).size.width / visibleItemCount;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Loyalty point
                        if (AppFinanceSettings.enableLoyalty &&
                            model.authenticated)
                          _buildIconItem(
                            context: context,
                            icon: AppIcons.loyaltyPoint,
                            title: "Points".tr(),
                            onPressed: model.openLoyaltyPoint,
                          ).w(width),

                        // Wallet
                        if (AppUISettings.allowWallet && model.authenticated)
                          _buildIconItem(
                            context: context,
                            title: "Wallet".tr(),
                            icon: AppIcons.wallet,
                            onPressed: model.openWallet,
                          ).w(width),

                        // Addresses
                        if (model.authenticated)
                          _buildIconItem(
                            context: context,
                            title: "Addresses".tr(),
                            icon: AppIcons.homeAddress,
                            onPressed: model.openDeliveryAddresses,
                          ).w(width),

                        // Favourites
                        if (model.authenticated)
                          _buildFutureIconItem(
                            context: context,
                            future: model.favourites(),
                            title: "Favourites".tr(),
                            icon: AppIcons.favourite,
                            onPressed: model.openFavourites,
                          ).w(width),

                        // Referral
                        if (AppStrings.enableReferSystem && model.authenticated)
                          _buildIconItem(
                            context: context,
                            title: "Referral".tr(),
                            icon: AppIcons.refer,
                            onPressed: model.openRefer,
                          ).w(width),
                      ],
                    );
                  }),

                  // Rental car management
                  if (model.authenticated)
                    ViewModelBuilder<WelcomeViewModel>.reactive(
                      viewModelBuilder: () => WelcomeViewModel(context),
                      onViewModelReady: (vmWC) => vmWC.initialise(),
                      disposeViewModel: false,
                      builder: (context, vmWC, child) {
                        if (vmWC.checkVendorHasSlug("shared ride") ||
                            vmWC.checkVendorHasSlug("car rental"))
                          return _buildLineItem(
                              title: "Vehicle Management".tr(),
                              icon: AppIcons.carManagement,
                              onPressed: model.openCarManagement,
                              isShow: vmWC.checkVendorHasSlug("shared ride") ||
                                  vmWC.checkVendorHasSlug("car rental"));
                        else
                          return UiSpacer.emptySpace();
                      },
                    ),

                  // Language
                  _buildLineItem(
                    title: "Language".tr(),
                    icon: AppIcons.translation,
                    onPressed: model.changeLanguage,
                    isShow: AppLanguages.canChangeLanguage,
                  ),

                  if (model.authenticated) ...[
                    Divider(color: Colors.grey.shade200, thickness: 8),
                    ///////////////////////////////////////////////////////////////
                    /// Support section

                    // Support
                    Text(
                      "Services".tr(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ).w(double.infinity).px(16).py(8),
                    ...buildDriverStateWidget(model: model)
                  ],

                  Divider(color: Colors.grey.shade300, thickness: 8),
                  ///////////////////////////////////////////////////////////////
                  /// Support section

                  // Support
                  Text(
                    "Support".tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ).w(double.infinity).px(16).py(8),

                  // Faqs
                  _buildLineItem(
                    title: "FAQs".tr(),
                    icon: AppIcons.faq,
                    onPressed: model.openFaqs,
                  ),

                  // Privacy Policy
                  _buildLineItem(
                    title: "Privacy Policy".tr(),
                    icon: AppIcons.privacyPolicy,
                    onPressed: model.openPrivacyPolicy,
                  ),

                  // Terms & Conditions
                  _buildLineItem(
                    title: "Terms & Conditions".tr(),
                    icon: AppIcons.termsAndConditions,
                    onPressed: model.openTerms,
                  ),

                  // Contact Us
                  _buildLineItem(
                    title: "Contact Us".tr(),
                    icon: AppIcons.contactUs,
                    onPressed: model.openContactUs,
                  ),

                  // Live Support
                  _buildLineItem(
                    title: "Live Support".tr(),
                    icon: AppIcons.onlineSupport,
                    onPressed: model.openLivesupport,
                  ),

                  // Rate & Review
                  _buildLineItem(
                    title: "Rate & Review".tr(),
                    icon: AppIcons.rankAndReview,
                    onPressed: model.openReviewApp,
                  ),

                  ///////////////////////////////////////////////////////////////
                  // Version and copy right section
                  ("Version".tr() + " - ${model.appVersionInfo}")
                      .text
                      .center
                      .sm
                      .makeCentered()
                      .py20(),
                  "Copyright ©%s %s all right reserved"
                      .tr()
                      .fill([
                        "${DateTime.now().year}",
                        AppStrings.companyName,
                      ])
                      .text
                      .center
                      .sm
                      .makeCentered()
                      .py20(),
                  //
                  UiSpacer.verticalSpace(space: context.percentHeight * 10),
                  //
                ],
              ).scrollVertical())),
    );
  }

  Widget _buildIconItem({
    required BuildContext context,
    required String title,
    required String icon,
    required Function() onPressed,
    bool isShow = true,
  }) {
    if (!isShow) return UiSpacer.emptySpace();
    return Container(
        child: Column(children: [
      Image.asset(icon, width: 35, height: 35).w(double.infinity),
      Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14),
      ).py(8)
    ])).onTap(onPressed);
  }

  Widget _buildFutureIconItem({
    required BuildContext context,
    required String title,
    required String icon,
    required Function() onPressed,
    required Future<bool> future,
    isShow = true,
  }) {
    if (!isShow) return UiSpacer.emptySpace();
    return FutureBuilder<bool>(
        future: future,
        builder: (context, snapshot) {
          final isDone = snapshot.connectionState == ConnectionState.done;
          bool hasData = snapshot.data ?? false;
          if (hasData)
            return Container(
                child: Column(children: [
              Image.asset(
                icon,
                color: isDone ? null : Colors.grey.withOpacity(0.3),
                width: 35,
                height: 35,
              ).w(double.infinity),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ).py(8).px(2)
            ])).onTap(() {
              if (isDone && hasData) {
                onPressed();
              }
            });
          else
            return UiSpacer.emptySpace();
        });
  }

  Widget _buildLineItem({
    required String title,
    required String icon,
    required Function() onPressed,
    bool isShow = true,
  }) {
    if (!isShow) return UiSpacer.emptySpace();
    return ListTile(
      leading: Image.asset(icon).wh(24, 24),
      title: Text(title),
      onTap: onPressed,
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Colors.black54,
        size: 20,
      ),
    );
  }

  Widget _buildWatingApproval() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/pending-document.png',
          width: 80,
          height: 80,
          fit: BoxFit.contain,
        ),
        //SizedBox(height: 16),
        Text(
          "Your documents are waiting for approval".tr(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ).py(16),
      ],
    ).wFull(context);
  }

  @override
  bool get wantKeepAlive => true;

  List<Widget> buildDriverStateWidget({required ProfileViewModel model}) {
    return [
      // Display waiting approval widget if the driver is waiting for approval
      if (model.isDriverWaitingApproval)
        _buildWatingApproval()

      // Show "Become a driver" button if the user is not a driver and their document request is not rejected
      else if (!AuthServices.isDriver() &&
          (AuthServices.currentUser?.documentRequest?.status != "rejected"))
        CustomButton(
          title: "Become a driver".tr(),
          color: AppColor.primaryColor,
          onPressed: model.openDriverRegister,
        ).pOnly(bottom: 16, left: 16, right: 16)

      // Show driver options if the user is a driver
      else if (AuthServices.isDriver()) ...[
        _buildLineItem(
          title:
              "${"Hoạt động".tr()} ${(AppService().driverIsOnline ? "- Đang hoạt động".tr() : "")}",
          icon: AppImages.appLogo,
          onPressed: model.openDriverOrders,
        ),
        _buildLineItem(
          title: "Quản Lý Dịch Vụ".tr(),
          icon: AppIcons.serviceManagement,
          onPressed: model.openVehiceManagement,
        ),
        _buildLineItem(
          title: "Đơn hàng".tr(),
          icon: AppIcons.order,
          onPressed: model.openOrderManagement,
        ),
        _buildLineItem(
          title: "Tài chính".tr(),
          icon: AppIcons.finance,
          onPressed: model.openFinance,
        ),
      ],
    ];
  }
}
