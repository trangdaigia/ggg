import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sod_user/driver_lib/constants/app_strings.dart';
import 'package:sod_user/driver_lib/models/new_order.dart';
import 'package:sod_user/driver_lib/models/vendor_type.dart';
import 'package:sod_user/driver_lib/requests/auth.request.dart';
import 'package:sod_user/driver_lib/requests/vendor_type.request.dart';
import 'package:sod_user/driver_lib/services/app.service.dart';
import 'package:sod_user/driver_lib/services/appbackground.service.dart';
import 'package:sod_user/driver_lib/services/firebase_token.service.dart';
import 'package:sod_user/driver_lib/services/local_storage.service.dart';
import 'package:sod_user/driver_lib/services/location.service.dart';
import 'package:sod_user/driver_lib/services/order_assignment.service.dart';
import 'package:sod_user/driver_lib/services/order_manager.service.dart';
import 'package:sod_user/driver_lib/services/taxi_background_order.service.dart';
import 'package:sod_user/driver_lib/services/update.service.dart';
import 'package:sod_user/driver_lib/view_models/base.view_model.dart';
import 'package:sod_user/driver_lib/view_models/taxi/taxi.vm.dart';
import 'package:sod_user/driver_lib/widgets/bottomsheets/new_order_alert.bottomsheet.dart';
import 'package:sod_user/models/driver.dart';
import 'package:sod_user/models/vehicle.dart';
import 'package:sod_user/services/auth.service.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:georange/georange.dart';

import '../views/pages/shared/widgets/home_menu.view.dart';

class HomeViewModel extends MyBaseViewModel with UpdateService {
  //
  HomeViewModel(BuildContext context) {
    this.viewContext = context;
    taxiViewModel = TaxiViewModel(context);
  }

  //
  // bool isOnline = true;
  int currentIndex = 0;
  Driver? currentUser;
  Vehicle? driverVehicle;
  PageController pageViewController = PageController(initialPage: 0);
  StreamSubscription? homePageChangeStream;
  StreamSubscription? locationReadyStream;
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  GeoRange georange = GeoRange();
  StreamSubscription? newOrderStream;
  AuthRequest authRequest = AuthRequest();
  List<VendorType> vendorTypes = [];
  TaxiViewModel? taxiViewModel;
  StreamSubscription? tripUpdateStream;
  @override
  void initialise() async {
    //
    handleAppUpdate(viewContext);
    //
    currentUser = await AuthServices.getCurrentDriver();
    driverVehicle = currentUser?.vehicle;
    //
    AppService().driverIsOnline =
        LocalStorageService.prefs!.getBool(AppStrings.onlineOnApp) ?? false;
    notifyListeners();
    vendorTypes = await VendorTypeRequest().index();
    //
    await OrderManagerService().monitorOnlineStatusListener();
    TaxiBackgroundOrderService().taxiViewModel = taxiViewModel;
    notifyListeners();

    //
    locationReadyStream = LocationService().locationDataAvailable.stream.listen(
      (event) {
        if (event) {
          print("abut call ==> listenToNewOrders");
          listenToNewOrders();
        }
      },
    );

    //
    homePageChangeStream = AppService().homePageIndex.stream.listen(
      (index) {
        //
        onTabChange(index);
      },
    );

    //INCASE OF previous driver online state
    handleNewOrderServices();
  }

  //
  dispose() {
    super.dispose();
    cancelAllListeners();
  }

  bool checkVendorHasSlug(String slug) {
    for (var i = 0; i < vendorTypes.length; i++) {
      if (vendorTypes[i].slug == slug) {
        return true;
      }
    }
    return false;
  }

  cancelAllListeners() async {
    homePageChangeStream?.cancel();
    newOrderStream?.cancel();
  }

  //
  onPageChanged(int index) {
    currentIndex = index;
    notifyListeners();
  }

  //
  onTabChange(int index) {
    currentIndex = index;
    pageViewController.animateToPage(
      currentIndex,
      duration: Duration(microseconds: 5),
      curve: Curves.bounceInOut,
    );
    notifyListeners();
  }

  void toggleOnlineStatus() async {
    setBusy(true);
    try {
      await AuthServices.toggleDriverStatus(taxiViewModel!, this);
      notifyListeners();
    } catch (error) {
      viewContext.showToast(msg: "$error", bgColor: Colors.red);
    }
    setBusy(false);
  }

  handleNewOrderServices() {
    if (AppService().driverIsOnline) {
      listenToNewOrders();
      AppbackgroundService().startBg();
    } else {
      //
      // LocationService().clearLocationFromFirebase();
      cancelAllListeners();
      AppbackgroundService().stopBg();
    }
  }

  //NEW ORDER STREAM
  listenToNewOrders() async {
    //close any previous listener
    newOrderStream?.cancel();
    //start the background service
    startNewOrderBackgroundService();
  }

  NewOrder? showingNewOrder;
  void showNewOrderAlert(NewOrder newOrder) async {
    //

    if (showingNewOrder == null || showingNewOrder!.docRef != newOrder.docRef) {
      showingNewOrder = newOrder;
      print("called showNewOrderAlert");
      final result = await showModalBottomSheet(
        context: AppService().navigatorKey.currentContext!,
        isDismissible: false,
        enableDrag: false,
        builder: (context) {
          return NewOrderAlertBottomSheet(newOrder);
        },
      );

      //
      if (result is bool && result) {
        AppService().refreshAssignedOrders.add(true);
      } else {
        await OrderAssignmentService.releaseOrderForotherDrivers(
          newOrder.toJson(),
          newOrder.docRef!,
        );
      }
    }
  }

  void openMenuBottomSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return HomeMenuView().h(context.percentHeight * 90);
      },
    ).then((value) => {notifyListeners()});
  }
}
