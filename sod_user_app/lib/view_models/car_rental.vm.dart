import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:sod_user/models/delivery_address.dart';
import 'package:sod_user/models/vendor.dart';
import 'package:sod_user/models/vendor_type.dart';
import 'package:sod_user/requests/vendor.request.dart';
import 'package:sod_user/services/auth.service.dart';
import 'package:sod_user/services/location.service.dart';
import 'package:sod_user/view_models/base.view_model.dart';

import '../models/user.dart';

class CarRentalViewModel extends MyBaseViewModel {
  CarRentalViewModel(BuildContext context, VendorType vendorType) {
    this.viewContext = context;
    this.vendorType = vendorType;
  }

  User? currentUser;
  StreamSubscription? currentLocationChangeStream;
  VendorRequest vendorRequest = VendorRequest();
  RefreshController refreshController = RefreshController();
  List<Vendor> vendors = [];

  void initialise() async {
    if (AuthServices.authenticated()) {
      currentUser = await AuthServices.getCurrentUser(force: true);
      notifyListeners();
    }

    currentLocationChangeStream =
        LocationService.currenctAddressSubject.stream.listen(
      (location) {
        deliveryaddress ??= DeliveryAddress();
        deliveryaddress?.address = location.addressLine;
        deliveryaddress?.latitude = location.coordinates?.latitude;
        deliveryaddress?.longitude = location.coordinates?.longitude;
        notifyListeners();
      },
    );

    getVendors();
  }

  @override
  void dispose() {
    currentLocationChangeStream?.cancel();
    super.dispose();
  }

  getVendors() async {
    setBusyForObject(vendors, true);
    try {
      vendors = await vendorRequest.nearbyVendorsRequest(
        params: {
          "vendor_type_id": vendorType?.id,
        },
      );
    } catch (error) {
      print("Error ==> $error");
    }
    setBusyForObject(vendors, false);
  }
}
