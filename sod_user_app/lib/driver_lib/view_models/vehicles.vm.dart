import 'package:flutter/material.dart';
import 'package:sod_user/driver_lib/extensions/iterable.dart';
import 'package:sod_user/driver_lib/models/api_response.dart';
import 'package:sod_user/driver_lib/models/vehicle.dart';
import 'package:sod_user/driver_lib/models/vendor_type.dart';
import 'package:sod_user/requests/vehicle.request.dart';
import 'package:sod_user/driver_lib/services/alert.service.dart';
import 'package:sod_user/services/auth.service.dart';
import 'package:sod_user/driver_lib/views/pages/vehicle/new_vehicle.page.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import '../requests/vendor_type.request.dart';
import 'base.view_model.dart';

class VehiclesViewModel extends MyBaseViewModel {
  List<Vehicle> vehicles = [];
  List<VendorType> serviceType = [];

  List<Vehicle> verifiedVehicles = [];
  List<Vehicle> unverifiedVehicles = [];
  bool isLoading = true;

  RefreshController verifiedRefreshController = RefreshController();
  RefreshController unverifiedRefreshController = RefreshController();
  //
  VehicleRequest vehicleRequest = VehicleRequest();

  VehiclesViewModel(BuildContext context) {
    this.viewContext = context;
  }

  get diableVehicle => null;

  void initialise() async {
    final vendorTypes = await VendorTypeRequest().index();
    serviceType = vendorTypes
        .where((e) => ["taxi", "shipping", "rental driver"].contains(e.slug))
        .toList();
    fetchVehicles();
  }

  void fetchVehicles() async {
    isLoading = true;
    setBusy(true);
    try {
      vehicles = await vehicleRequest.vehicles();
      vehicles.sort((a, b) {
        if (a.verified! && !b.verified!) {
          return -1;
        } else if (!a.verified! && b.verified!) {
          return 1;
        } else {
          return 0;
        }
      });
      verifiedVehicles.clear();
      verifiedVehicles = vehicles.where((e) => e.verified ?? false).toList();
      verifiedVehicles = verifiedVehicles.map((e) {
        final service =
            serviceType.firstWhere((a) => a.id == e.vehicleType?.vendorTypeId);
        e.service = service;
        return e;
      }).toList();
      unverifiedVehicles.clear();
      unverifiedVehicles = vehicles.where((e) => !e.verified!).toList();
      unverifiedVehicles = unverifiedVehicles.map((e) {
        final service =
            serviceType.firstWhere((a) => a.id == e.vehicleType?.vendorTypeId);
        e.service = service;
        return e;
      }).toList();
      verifiedRefreshController.refreshCompleted();
      unverifiedRefreshController.refreshCompleted();

      notifyListeners();
    } catch (error) {
      print("Error when fetching vehicle data: $error");
      verifiedRefreshController.refreshFailed();
      unverifiedRefreshController.refreshFailed();
    }

    isLoading = false;
    setBusy(false);
  }

  newVehicleCreate() async {
    await Navigator.of(viewContext).push(
      MaterialPageRoute(builder: (context) => NewVehiclePage()),
    );
    fetchVehicles();
  }

  makeVehicleCurrent(Vehicle vehicle) async {
    AlertService.showLoading();
    try {
      VendorType? vendorType = serviceType.firstWhere(
        (e) => e.id == (vehicle.service?.id ?? 0),
      );
      String type;
      switch (vendorType.slug) {
        case "rental driver":
          type = "book_driver";
          break;
        case "shipping":
          type = "ship";
          break;
        case "taxi":
          type = "taxi";
          break;
        default:
          type = "";
      }

      if (vehicle.color != null &&
          vehicle.carModel != null &&
          vehicle.vehicleType != null) {
        // Deactivate các phương tiện khác cùng loại
        for (var e in vehicles) {
          final currentVendorType = serviceType.firstWhereOrNull(
            (type) => type.id == (e.service?.id ?? 0),
          );
          if (currentVendorType == null) continue;
          if (currentVendorType.slug == vendorType.slug && e.isActive == 1) {
            e.isActive = 0;
            await vehicleRequest.makeDeactive(e.id!, type);
          }
        }
        // Kích hoạt phương tiện được chọn
        await vehicleRequest.makeActive(vehicle.id!, type);

        // Đánh dấu phương tiện được chọn là active
        vehicles.where((e) => e.id == vehicle.id).first.isActive = 1;

        await AuthServices.saveVehicle(vehicle.toJson());
        await AuthServices.saveVehicleType(vehicle.toJson(), vendorType.slug);
      }

      await AuthServices.getDriverVehicle(force: true);
      AlertService.stopLoading();
      notifyListeners();
    } catch (error) {
      AlertService.stopLoading();
      toastError("$error");
    }
  }

  disableVehicle(Vehicle vehicle) async {
    AlertService.showLoading();
    try {
      final vendorType = serviceType.firstWhere(
        (e) => e.id == vehicle.vehicleType?.vendorTypeId,
      );
      String type;
      switch (vendorType.slug) {
        case "rental driver":
          type = "book_driver";
          break;
        case "shipping":
          type = "ship";
          break;
        case "taxi":
          type = "taxi";
          break;
        default:
          type = "";
      }
      // Deactivate phương tiện được chọn
      await vehicleRequest.makeDeactive(vehicle.id!, type);
      // Đánh dấu phương tiện được chọn là disable
      vehicles.where((e) => e.id == vehicle.id).first.isActive = 0;

      await AuthServices.getDriverVehicle(force: true);
      AlertService.stopLoading();
      notifyListeners();
    } catch (error) {
      AlertService.stopLoading();
      toastError("$error");
    }
  }
}
