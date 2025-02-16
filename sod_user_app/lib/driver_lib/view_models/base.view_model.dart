import 'dart:io';

import 'package:firestore_chat/firestore_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sod_user/driver_lib/constants/app_strings.dart';
import 'package:sod_user/driver_lib/global/service.registry.dart';
import 'package:sod_user/driver_lib/models/delivery_address.dart';
import 'package:sod_user/driver_lib/services/location.service.dart';
import 'package:sod_user/driver_lib/services/toast.service.dart';
import 'package:sod_user/driver_lib/views/pages/payment/custom_webview.page.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:velocity_x/velocity_x.dart';

class MyChromeSafariBrowser extends ChromeSafariBrowser {
  @override
  void onOpened() {
    print("ChromeSafari browser opened");
  }

  @override
  void onCompletedInitialLoad(bool? success) {
    print("ChromeSafari browser initial load completed");
  }

  @override
  void onClosed() {
    print("ChromeSafari browser closed");
  }
}

class MyBaseViewModel extends ReactiveViewModel {
  //
  late BuildContext viewContext;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final formBuilderKey = GlobalKey<FormBuilderState>();
  final currencySymbol = AppStrings.currencySymbol;
  DeliveryAddress deliveryaddress = DeliveryAddress();
  String? firebaseVerificationId;
  ChatEntity? chatEntity;

  //
  @override
  List<ListenableServiceMixin> get listenableServices =>
      ServiceRegistry.services;
  //
  void initialise() {
    // FirestoreRepository();
  }

  newFormKey() {
    formKey = GlobalKey<FormState>();
    notifyListeners();
  }

  //
  void startNewOrderBackgroundService() {
    WidgetsFlutterBinding.ensureInitialized();

    //
    //try sending location to fcm
    print("Resending fcm location");
    if (LocationService().currentLocationData == null) {
      return;
    }
    //
    LocationService().syncLocationWithFirebase(
      LocationService().currentLocationData!,
    );
  }

  //
  // openWebpageLink(String url) async {
  //   //
  //   ChromeSafariBrowser browser = new MyChromeSafariBrowser();
  //   await browser.open(
  //     url: Uri.parse(url),
  //     options: ChromeSafariBrowserClassOptions(
  //       android: AndroidChromeCustomTabsOptions(
  //         addDefaultShareMenuItem: false,
  //         enableUrlBarHiding: true,
  //         toolbarBackgroundColor: AppColor.primaryColor,
  //       ),
  //       ios: IOSSafariOptions(
  //         barCollapsingEnabled: true,
  //         preferredBarTintColor: AppColor.primaryColor,
  //       ),
  //     ),
  //   );

  // }
  openWebpageLink(String url, {bool external = false}) async {
    if (Platform.isIOS || external) {
      await launchUrlString(url);
      return;
    }
    await Navigator.push(
      viewContext,
      MaterialPageRoute(
        builder: (context) => CustomWebviewPage(
          selectedUrl: url,
        ),
      ),
    );
  }

  Future<dynamic> openExternalWebpageLink(String url) async {
    try {
      await launchUrlString(
        url,
        webViewConfiguration: WebViewConfiguration(),
      );
      return;
    } catch (error) {
      ToastService.toastError("$error");
    }
  }

  //show toast
  toastSuccessful(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  toastError(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }
}
