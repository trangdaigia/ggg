import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sod_user/models/vendor_type.dart';
import 'package:sod_user/requests/vendor_type.request.dart';
import 'package:sod_user/services/auth.service.dart';
import 'package:sod_user/view_models/base.view_model.dart';
import 'package:sod_user/view_models/delivery_address/delivery_addresses.vm.dart';

class WelcomeViewModel extends MyBaseViewModel {
  //
  WelcomeViewModel(BuildContext context) {
    this.viewContext = context;
  }

  Widget? selectedPage;
  List<VendorType> vendorTypes = [];
  VendorTypeRequest vendorTypeRequest = VendorTypeRequest();
  bool showGrid = true;
  StreamSubscription? authStateSub;
  DeliveryAddressesViewModel? deliveryAddressesViewModel;

  //
  //
  initialise({bool initial = true}) async {
    //
    deliveryAddressesViewModel = new DeliveryAddressesViewModel(viewContext);
    deliveryAddressesViewModel!.fetchDeliveryAddresses();
    if (refreshController.isRefresh) {
      refreshController.refreshCompleted();
    }

    if (!initial) {
      pageKey = GlobalKey();
      notifyListeners();
    }

    await getVendorTypes();
    listenToAuth();
  }

  listenToAuth() {
    authStateSub = AuthServices.listenToAuthState().listen((event) {
      genKey = GlobalKey();
      notifyListeners();
    });
  }

  checkVendorHasService() {
    for (var i = 0; i < vendorTypes.length; i++) {
      if (vendorTypes[i].slug == "service" ||
          vendorTypes[i].slug == "pharmacy" ||
          vendorTypes[i].slug == "food") return true;
    }
    return false;
  }

  bool checkVendorHasSlug(String slug) {
    for (var i = 0; i < vendorTypes.length; i++) {
      if (vendorTypes[i].slug == slug) {
        return true;
      }
    }
    return false;
  }

  getVendorTypes() async {
    setBusy(true);
    try {
      vendorTypes = await vendorTypeRequest.index();
      clearErrors();
    } catch (error) {
      setError(error);
    }
    setBusy(false);
  }

  Future<void> init() async {
    if (refreshController.isRefresh) {
      refreshController.refreshCompleted();
    }
    pageKey = GlobalKey();
    notifyListeners();

    await getVendorTypes();
    listenToAuth();
  }
}
