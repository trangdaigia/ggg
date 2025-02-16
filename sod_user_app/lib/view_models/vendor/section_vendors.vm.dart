import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_routes.dart';
import 'package:sod_user/models/search.dart';
import 'package:sod_user/models/vendor.dart';
import 'package:sod_user/models/vendor_type.dart';
import 'package:sod_user/requests/vendor.request.dart';
import 'package:sod_user/view_models/base.view_model.dart';
import 'package:stacked/stacked.dart';

class SectionVendorsViewModel extends MyBaseViewModel {
  SectionVendorsViewModel(
    BuildContext context,
    this.vendorType, {
    this.type = SearchFilterType.you,
    this.byLocation = false,
  }) {
    this.viewContext = context;
  }

  //
  List<Vendor> vendors = [];

  VendorType? vendorType;
  SearchFilterType type;
  bool? byLocation;
  VendorRequest _vendorRequest = VendorRequest();

  @override
  List<ListenableServiceMixin> get listenableServices => [_vendorRequest];
  //
  initialise() {
    fetchVendors();
  }

  //
fetchVendors() async {
    setBusy(true);
    try {
      //filter by location if user selects delivery address

      vendors = await _vendorRequest.vendorsRequest(
        byLocation: byLocation ?? true,
        params: {
          "vendor_type_id": vendorType?.id,
          "type": type.name,
        },
      );
      clearErrors();
      //
    } catch (error) {
      print("error loading vendors ==> $error");
      setError(error);
    }
    setBusy(false);
  }

  vendorSelected(Vendor vendor) async {
    Navigator.of(viewContext).pushNamed(
      AppRoutes.vendorDetails,
      arguments: vendor,
    );
  }
}
