import 'dart:io';

import 'package:cool_alert/cool_alert.dart';
import 'package:custom_faqs/custom_faqs.dart';
import 'package:flutter/material.dart';
import 'package:sod_user/driver_lib/models/vendor_type.dart';
import 'package:sod_user/driver_lib/requests/vendor_type.request.dart';
import 'package:sod_user/driver_lib/views/pages/chat/chat.page.dart';
import 'package:sod_user/driver_lib/views/pages/notification/notifications.page.dart';
import 'package:sod_user/driver_lib/views/pages/payment_account/payment_account.page.dart';
import 'package:sod_user/driver_lib/views/pages/profile/account_delete.page.dart';
import 'package:sod_user/driver_lib/views/pages/profile/profile_detail.page.dart';
import 'package:sod_user/driver_lib/views/pages/splash.page.dart';
import 'package:sod_user/driver_lib/widgets/bottomsheets/earning.bottomsheet.dart';
import 'package:sod_user/driver_lib/constants/api.dart';
import 'package:sod_user/driver_lib/constants/app_routes.dart';
import 'package:sod_user/driver_lib/constants/app_strings.dart';
import 'package:sod_user/driver_lib/models/user.dart';
import 'package:sod_user/driver_lib/requests/auth.request.dart';
import 'package:sod_user/models/driver.dart';
import 'package:sod_user/services/auth.service.dart';
import 'package:sod_user/driver_lib/view_models/base.view_model.dart';
import 'package:sod_user/driver_lib/widgets/cards/api_url.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:package_info/package_info.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

import 'package:sod_user/widgets/cards/language_selector.view.dart';

class ProfileViewModel extends MyBaseViewModel {
  //
  String appVersionInfo = "";
  Driver? currentUser;

  //
  AuthRequest _authRequest = AuthRequest();

  ProfileViewModel(BuildContext context) {
    this.viewContext = context;
  }
  List<VendorType> vendorTypes = [];
  void initialise() async {
    //
    vendorTypes = await VendorTypeRequest().index();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    ShorebirdCodePush shorebirdCodePush = ShorebirdCodePush();
    String versionName = packageInfo.version;
    String versionCode = packageInfo.buildNumber;
    int? patchNumber = await shorebirdCodePush.currentPatchNumber();

    appVersionInfo = "$versionName.$versionCode" +
        (patchNumber != null ? ".$patchNumber" : "");
    setBusy(true);
    currentUser = await AuthServices.getCurrentDriver();
    setBusy(false);
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

  /**
   * Delivery addresses
   */
  openDeliveryAddresses() {
    Navigator.of(viewContext).pushNamed(
      AppRoutes.deliveryAddressesRoute,
    );
  }

  //
  openFavourites() {
    Navigator.of(viewContext).pushNamed(
      AppRoutes.favouritesRoute,
    );
  }

  bool checkVendorHasSlug(String slug) {
    for (var i = 0; i < vendorTypes.length; i++) {
      if (vendorTypes[i].slug == slug) {
        return true;
      }
    }
    return false;
  }

  bool checkSlugIsActive() {
    List<VendorType> list = [];
    for (var i = 0; i < vendorTypes.length; i++) {
      if (vendorTypes[i].slug != "receive behalf") {
        list.add(vendorTypes[i]);
      }
    }
    if (list.length == 0) {
      return false;
    } else {
      return true;
    }
  }

  //Earning
  showEarning() async {
    showModalBottomSheet(
      context: viewContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: EarningBottomSheet(),
        );
      },
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
        Navigator.pop(viewContext);
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

    if (!apiResponse.allGood) {
      //
      CoolAlert.show(
        context: viewContext,
        type: CoolAlertType.error,
        title: "Logout",
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

  openWallet() async {
    Navigator.of(viewContext).pushNamed(
      AppRoutes.walletRoute,
    );
  }

  openPaymentAccounts() async {
    Navigator.push(viewContext,
        MaterialPageRoute(builder: (context) => PaymentAccountPage()));
  }

  openNotification() async {
    // Navigator.of(viewContext).pushNamed(
    //   AppRoutes.notificationsRoute,
    // );
    Navigator.push(viewContext,
        MaterialPageRoute(builder: (context) => NotificationsPage()));
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

  openFaqs() {
    viewContext.nextPage(
      CustomFaqPage(
        title: 'Faqs'.tr(),
        link: Api.baseUrl + Api.faqs,
      ),
    );
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
    showModalBottomSheet(
      context: viewContext,
      builder: (context) {
        return AppLanguageSelector();
      },
    );
  }

  deleteAccount() {
    viewContext.nextPage(AccountDeletePage());
  }

  openApiUrl() {
    viewContext.nextPage(ChangeApiUrl());
  }

  openMessages() {
    viewContext.nextPage(ChatPage());
  }
}
