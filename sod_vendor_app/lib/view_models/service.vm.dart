import 'package:flutter/material.dart';
import 'package:sod_vendor/models/service.dart';
import 'package:sod_vendor/requests/service.request.dart';
import 'package:sod_vendor/services/auth.service.dart';
import 'package:sod_vendor/view_models/base.view_model.dart';
import 'package:sod_vendor/views/pages/service/new_service.page.dart';
import 'package:sod_vendor/views/pages/service/service_details.page.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:velocity_x/velocity_x.dart';
// import 'package:sod_vendor/translations/service.tr().dart';

class ServiceViewModel extends MyBaseViewModel {
  //
  ServiceViewModel(BuildContext context) {
    this.viewContext = context;
  }

  //
  ServiceRequest _serviceRequest = ServiceRequest();
  List<Service> services = [];
  RefreshController refreshController = RefreshController();
  int queryPage = 1;

  void initialise() {
    fetchMyServices();
  }

  //
  fetchMyServices({bool initialLoading = true}) async {
    if (initialLoading) {
      queryPage = 1;
      setBusy(true);
    } else {
      queryPage += 1;
    }
    refreshController.refreshCompleted();

    try {
      final mServices = await _serviceRequest.getServices(
        queryParams: {
          "vendor_id": await AuthServices.currentVendor?.id,
        },
        page: queryPage,
        forceRefresh: true,
      );

      //
      if (initialLoading) {
        services = mServices;
      } else {
        services.addAll(mServices);
        refreshController.loadComplete();
      }
      clearErrors();
    } catch (error) {
      print("Package Type Pricing Error ==> $error");
      setError(error);
    }

    setBusy(false);
  }

  openServiceDetails(Service service) async {
    final result = await Navigator.push(
      viewContext,
      MaterialPageRoute(builder: (context) => ServiceDetailsPage(service)),
    );
    if (result != null && result) {
      services.removeWhere((e) => e.id == service.id);
    } else if (result != null && result is Service) {
      final index = services.indexWhere((e) => e.id == service.id);
      if (index >= 0) {
        services[index] = result;
      }
    }
    notifyListeners();
  }

  void newPackageTypePricing() async {
    final result = await Navigator.push(
      viewContext,
      MaterialPageRoute(builder: (context) => NewServicePage()),
    );
    if (result != null) {
      fetchMyServices();
    }
  }
}
