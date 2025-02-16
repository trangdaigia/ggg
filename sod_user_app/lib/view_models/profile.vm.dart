import 'dart:async';
import 'dart:io';

import 'package:cool_alert/cool_alert.dart';
import 'package:custom_faqs/custom_faqs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sod_user/driver_lib/view_models/home.vm.dart';
import 'package:sod_user/driver_lib/views/pages/order/assigned_orders.page.dart';
import 'package:sod_user/driver_lib/views/pages/order/orders.page.dart';
import 'package:sod_user/driver_lib/views/pages/permission/permission.page.dart';
import 'package:sod_user/driver_lib/views/pages/wallet/wallet.page.dart';
import 'package:sod_user/extensions/dynamic.dart';
import 'package:sod_user/flavors.dart';
import 'package:sod_user/models/driver.dart';
import 'package:sod_user/view_models/payment.view_model.dart';
import 'package:sod_user/view_models/wallet.vm.dart';
import 'package:sod_user/view_models/welcome.vm.dart';
import 'package:sod_user/views/pages/chat/chat.page.dart';
import 'package:sod_user/views/pages/loyalty/loyalty_point.page.dart';
import 'package:sod_user/views/pages/profile/account_delete.page.dart';
import 'package:sod_user/views/pages/profile/setting_account.page.dart';
import 'package:sod_user/views/pages/splash.page.dart';
import 'package:sod_user/constants/api.dart';
import 'package:sod_user/constants/app_routes.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/models/user.dart';
import 'package:sod_user/requests/auth.request.dart';
import 'package:sod_user/services/auth.service.dart';
import 'package:sod_user/views/pages/profile/profile_detail.page.dart';
import 'package:sod_user/widgets/bottomsheets/referral.bottomsheet.dart';
import 'package:sod_user/widgets/cards/language_selector.view.dart';
import 'package:sod_user/views/pages/profile/api_url.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:share/share.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'package:sod_user/driver_lib/views/pages/auth/register.page.dart';

import '../driver_lib/views/pages/vehicle/vehicles.page.dart';
// import 'package:sod_user/driver/views/pages/auth/register.page.dart';

class ProfileViewModel extends PaymentViewModel {
  //
  String appVersionInfo = "";
  bool authenticated = false;
  User? currentUser;
  Driver? currentDriver;

  //
  AuthRequest _authRequest = AuthRequest();
  StreamSubscription? authStateListenerStream;
  late WalletViewModel walletViewModel;
  ProfileViewModel(BuildContext context) {
    this.viewContext = context;
    walletViewModel = WalletViewModel(context);
  }

  Future<bool> favourites() async {
    WelcomeViewModel welcomeViewModel = WelcomeViewModel(viewContext);

    // Wait for the completion of the asynchronous operation
    await welcomeViewModel.init();

    // Now you can safely use the result of initialise()
    return welcomeViewModel.vendorTypes
        .where((vendorType) =>
            vendorType.slug == "food" ||
            vendorType.slug == "grocery" ||
            vendorType.slug == 'commerce' ||
            vendorType.slug == 'pharmacy')
        .toList()
        .isNotEmpty;
  }

  void initialise() async {
    //
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      ShorebirdCodePush shorebirdCodePush = ShorebirdCodePush();
      String versionName = packageInfo.version;
      String versionCode = packageInfo.buildNumber;
      int? patchNumber = await shorebirdCodePush.currentPatchNumber();
      walletViewModel.initialise();
      appVersionInfo = "$versionName.$versionCode" +
          (patchNumber != null ? ".$patchNumber" : "");
      authenticated = await AuthServices.authenticated();
      isDriverWaitingApproval =
          await AuthServices.getIsDriverWaitingForApproval() ?? false;
      if (authenticated) {
        currentUser = await AuthServices.getCurrentUser(force: true);
        if (AuthServices.isDriver())
          currentDriver = await AuthServices.getCurrentDriver();
      } else {
        listenToAuthChange();
      }
    } catch (error) {
      print("Error ====> ${error}.");
      print("Stacktrace: ${(error as Error).stackTrace}");
    } finally {
      notifyListeners();
    }
  }

  dispose() {
    super.dispose();
    authStateListenerStream?.cancel();
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

  //open setting profile
  openSettingProfile() {
    viewContext
        .nextPage(SettingAccountPage(model: ProfileViewModel(viewContext)));
  }

  /**
   * Edit Profile
   */

  openEditProfile() async {
    final result = await Navigator.of(viewContext).pushNamed(
      AppRoutes.editProfileRoute,
    );

    if (result != null && result is bool && result) {
      initialise();
    }
  }

  void openProfileDetail() async {
    Navigator.of(viewContext).push(
      MaterialPageRoute(
        builder: (context) => ProfileDetailPage(),
      ),
    );
  }

  /**
   * Change Password
   */

  openChangePassword() async {
    Navigator.of(viewContext).pushNamed(
      AppRoutes.changePasswordRoute,
    );
  }

//
  openRefer() async {
    await showModalBottomSheet(
      context: viewContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReferralBottomsheet(this),
    );
  }

  //
  openLoyaltyPoint() {
    viewContext.nextPage(LoyaltyPointPage());
  }

  openWallet() {
    Navigator.of(viewContext).pushNamed(
      AppRoutes.walletRoute,
    );
  }

  /**
   * Delivery addresses
   */
  openDeliveryAddresses() {
    Navigator.of(viewContext).pushNamed(
      AppRoutes.deliveryAddressesRoute,
    );
    //viewContext.nextPage(DeliveryAddressesPage());
  }

  //
  openFavourites() {
    Navigator.of(viewContext).pushNamed(
      AppRoutes.favouritesRoute,
    );
  }

  //
  openCarManagement() {
    Navigator.of(viewContext).pushNamed(
      AppRoutes.carManagement,
    );
  }

  /**
   * Logout
   */
  logoutPressed() async {
    CoolAlert.show(
      context: viewContext,
      type: CoolAlertType.confirm,
      title: "Logout".tr(),
      text: "Are you sure you want to logout?".tr(),
      onConfirmBtnTap: () {
        processLogout();
      },
    );
  }

  void processLogout() async {
    //
    CoolAlert.show(
      context: viewContext,
      type: CoolAlertType.loading,
      title: "Logout".tr(),
      text: "Logging out Please wait...".tr(),
      barrierDismissible: false,
    );

    //
    final apiResponse = await _authRequest.logoutRequest();

    //
    Navigator.pop(viewContext);

    if (!apiResponse.allGood && apiResponse.code != 401) {
      //
      CoolAlert.show(
        context: viewContext,
        type: CoolAlertType.error,
        title: "Logout".tr(),
        text: apiResponse.message,
      );
    } else {
      //
      await AuthServices.logout();
      Navigator.of(viewContext).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => SplashPage()),
        (route) => false,
      );
    }
  }

  openNotification() async {
    Navigator.of(viewContext).pushNamed(
      AppRoutes.notificationsRoute,
    );
  }

  /**
   * App Rating & Review
   */
  openReviewApp() async {
    final InAppReview inAppReview = InAppReview.instance;
    if (Platform.isAndroid) {
      inAppReview.openStoreListing(appStoreId: AppStrings.appStoreId);
    } else if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    } else {
      inAppReview.openStoreListing(appStoreId: AppStrings.appStoreId);
    }
  }

  //
  openPrivacyPolicy() async {
    final url = Api.privacyPolicy;
    openWebpageLink(url);
  }

  openTerms() {
    final url = Api.terms;
    openWebpageLink(url);
  }

  openFaqs() {
    viewContext.nextPage(
      CustomFaqPage(
        title: "FAQs".tr(),
        link: Api.baseUrl + Api.faqs,
      ),
    );
  }

  //
  openContactUs() async {
    final url = Api.contactUs;
    openWebpageLink(url);
  }

  openLivesupport() async {
    final url = Api.inappSupport;
    openWebpageLink(url);
  }

  //
  changeLanguage() async {
    final result = await showModalBottomSheet(
      context: viewContext,
      builder: (context) {
        return AppLanguageSelector();
      },
    );

    //
    if (result != null) {
      //pop all screen and open splash screen
      Navigator.of(viewContext).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => SplashPage()),
        (route) => false,
      );
    }
  }

  openLogin() async {
    await Navigator.of(viewContext).pushNamed(
      AppRoutes.loginRoute,
    );
    //
    initialise();
  }

  void shareReferralCode() {
    Share.share(
      "%s is inviting you to join %s via this referral code: %s".tr().fill(
            [
              currentUser!.name,
              AppStrings.appName,
              currentUser!.code,
            ],
          ) +
          "\n" +
          AppStrings.androidDownloadLink +
          "\n" +
          AppStrings.iOSDownloadLink +
          "\n",
    );
  }

  //
  deleteAccount() {
    viewContext.nextPage(AccountDeletePage());
  }

  openApiUrl() {
    viewContext.nextPage(ChangeApiUrl());
  }

  void openChat() {
    Navigator.of(viewContext).push(
      MaterialPageRoute(builder: (context) => const ChatPage()),
    );
  }

  bool isDriverWaitingApproval = false;

  void openDriverRegister() async {
    await Navigator.of(viewContext).push(
      MaterialPageRoute(builder: (context) => RegisterPage()),
    );
    isDriverWaitingApproval =
        (await AuthServices.getIsDriverWaitingForApproval()) ??
            isDriverWaitingApproval;
    notifyListeners();
  }

  void openDriverOrders() async {
    var inUseStatus = await Permission.locationWhenInUse.status;
    var alwaysUseStatus = F.appFlavor == Flavor.sob_express
        ? true
        : await Permission.locationAlways.status.isGranted;
    final bgPermissinGranted =
        Platform.isIOS ? true : await FlutterBackground.hasPermissions;

    if (inUseStatus.isGranted && alwaysUseStatus && bgPermissinGranted) {
      Navigator.of(viewContext).push(MaterialPageRoute(
        builder: (context) => ViewModelBuilder<HomeViewModel>.reactive(
          viewModelBuilder: () => HomeViewModel(context),
          onViewModelReady: (vm) => vm.initialise(),
          disposeViewModel: false,
          builder: (context, vm, child) => AssignedOrdersPage(homeVm: vm),
        ),
      ));
    } else {
      viewContext.nextPage(PermissionPage());
    }
  }

  void openOrderManagement() {
    Navigator.of(viewContext).push(MaterialPageRoute(
      builder: (context) => OrdersPage(),
    ));
  }

  void openVehiceManagement() {
    Navigator.of(viewContext).push(
      MaterialPageRoute(builder: (context) => VehiclesPage()),
    );
  }

  openFinance() {
    Navigator.of(viewContext).push(
      MaterialPageRoute(builder: (context) => WalletPage()),
    );
  }
}
