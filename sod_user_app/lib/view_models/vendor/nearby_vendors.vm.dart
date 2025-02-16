import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_routes.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/models/vendor.dart';
import 'package:sod_user/models/vendor_type.dart';
import 'package:sod_user/requests/vendor.request.dart';
import 'package:sod_user/services/geocoder.service.dart';
import 'package:sod_user/services/location.service.dart';
import 'package:sod_user/view_models/base.view_model.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class NearbyVendorsViewModel extends MyBaseViewModel {
  NearbyVendorsViewModel(BuildContext context, this.vendorType) {
    this.viewContext = context;
  }

  //
  List<Vendor> vendors = [];
  VendorType? vendorType;
  int selectedType = 1;
  StreamSubscription<Address>? locationStreamSubscription;

  //
  VendorRequest _vendorRequest = VendorRequest();
  @override
  List<ListenableServiceMixin> get listenableServices => [_vendorRequest];
  //
  initialise() {
    //
    fetchTopVendors();

    //
    locationStreamSubscription = LocationService.currenctAddressSubject.listen(
      (value) {
        //
        fetchTopVendors();
      },
    );
  }

  //
  fetchTopVendors() async {
    if (LocationService.currenctAddress?.coordinates?.latitude == null) {
      return;
    } else {
      locationStreamSubscription?.cancel();
    }

    setBusy(true);
    try {
      //filter by location if user selects delivery address
      vendors = await _vendorRequest.nearbyVendorsRequest(
        byLocation: AppStrings.enableFatchByLocation,
        params: {
          "vendor_type_id": vendorType?.id,
        },
      );

      //
      if (selectedType == 2) {
        vendors = vendors.filter((e) => e.pickup == 1).toList();
      } else if (selectedType == 1) {
        vendors = vendors.filter((e) => e.delivery == 1).toList();
      }
      clearErrors();
    } catch (error) {
      setError(error);
    }
    setBusy(false);
  }

  //
  changeType(int type) {
    selectedType = type;
    fetchTopVendors();
  }

  vendorSelected(Vendor vendor) async {
    Navigator.of(viewContext).pushNamed(
      AppRoutes.vendorDetails,
      arguments: vendor,
    );
  }
}
