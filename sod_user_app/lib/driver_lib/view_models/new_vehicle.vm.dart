import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geocoding_platform_interface/geocoding_platform_interface.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sod_user/driver_lib/models/vehicle.dart';
import 'package:sod_user/driver_lib/models/vendor_type.dart';
import 'package:sod_user/driver_lib/requests/general.request.dart';
import 'package:sod_user/requests/vehicle.request.dart';
import 'package:sod_user/driver_lib/requests/vendor_type.request.dart';
import 'package:sod_user/driver_lib/services/alert.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'base.view_model.dart';
import 'package:velocity_x/velocity_x.dart';

class NewVehicleViewModel extends MyBaseViewModel {
  //the textediting controllers
  TextEditingController carMakeTEC = new TextEditingController();
  TextEditingController carModelTEC = new TextEditingController();
  TextEditingController carRegNoTEC = new TextEditingController();
  TextEditingController carColorTEC = new TextEditingController();
  TextEditingController carPrice1TEC = new TextEditingController();
  TextEditingController carPrice2TEC = new TextEditingController();
  TextEditingController utilitiesTEC = new TextEditingController();
  TextEditingController requirementsTEC = new TextEditingController();
  TextEditingController yearMadeTEC = new TextEditingController();
  TextEditingController addressTEC = new TextEditingController();
  List<String>? utilities = [];
  List<String>? requirements = [];
  int discountThreeDays = 0;
  int discountSevenDays = 0;
  List<String> types = ["Regular", "Taxi"];
  List<VendorType> serviceType = [];
  List<VehicleType> vehicleTypes = [];
  List<VehicleType> filledVehicleTypes = [];
  String selectedDriverType = "regular";
  List<CarMake> carMakes = [];
  List<CarModel> carModels = [];
  CarMake? selectedCarMake;
  CarModel? selectedCarModel;
  int serviceValue = -1;
  List<File> selectedDocuments = [];
  List<String> colorList = [
    'Trắng',
    'Đen',
    'Đỏ',
    'Xám',
    'Vàng',
    'Bạc',
    'Nâu',
    'Xanh',
  ];
  GeneralRequest _generalRequest = GeneralRequest();
  VehicleRequest vehicleRequest = VehicleRequest();
  double? latitude;
  double? longitude;
  VehicleType? selectedVehicleType;
  bool isLoading = true;

  NewVehicleViewModel(BuildContext context) {
    this.viewContext = context;
  }

  void initialise() async {
    final vendorTypes = await VendorTypeRequest().index();
    serviceType = vendorTypes
        .where((e) => ["taxi", "shipping", "rental driver"].contains(e.slug))
        .toList();
    isLoading = false;
    notifyListeners();
    yearMadeTEC.text = DateTime.now().year.toString();
    fetchVehicleTypes();
    fetchCarMakes();
  }

  void fetchVehicleTypes() async {
    setBusyForObject(vehicleTypes, true);
    try {
      vehicleTypes = await _generalRequest.getVehicleTypes();
      filledVehicleTypes = vehicleTypes;
    } catch (error) {
      toastError("$error");
    }
    setBusyForObject(vehicleTypes, false);
  }

  void fetchCarMakes() async {
    setBusyForObject(carMakes, true);
    try {
      carMakes = await _generalRequest.getCarMakes();
    } catch (error) {
      toastError("$error");
    }
    setBusyForObject(carMakes, false);
  }

  void fetchCarModel() async {
    setBusyForObject(carModels, true);
    try {
      carModels = await _generalRequest.getCarModels(
        carMakeId: selectedCarMake?.id,
      );
    } catch (error) {
      toastError("$error");
    }
    setBusyForObject(carModels, false);
  }

  void onDocumentsSelected(List<File> documents) {
    selectedDocuments = documents;
    notifyListeners();
  }

  onCarMakeSelected(CarMake value) {
    selectedCarMake = value;
    carMakeTEC.text = value.name;
    notifyListeners();
    fetchCarModel();
  }

  onCarColorSelected(String value) {
    carColorTEC.text = value;
    notifyListeners();
  }

  onCarModelSelected(CarModel value) {
    selectedCarModel = value;
    carModelTEC.text = value.name;
    notifyListeners();
  }

  onCarYearMadeSelected(String value) {
    yearMadeTEC.text = value;
    notifyListeners();
  }

  onUtilitiesSelected(List<String> newUtilities) {
    utilities = newUtilities;
    utilitiesTEC.text = utilities!.join(',');
    notifyListeners();
  }

  onRequirementSelected(List<String> newRequirement) {
    requirements = newRequirement;
    requirementsTEC.text = requirements!.join(',');
    notifyListeners();
  }

  processSave() async {
    // Validate returns true if the form is valid, otherwise false.
    if (isRentalDriver(serviceValue.toString())) {
      if (formBuilderKey.currentState!.saveAndValidate() &&
          selectedDocuments.isNotEmpty) {
        setBusy(true);
        try {
          Map<String, dynamic> mValues = formBuilderKey.currentState!.value;
          final carData = {
            "vehicle_type_id": selectedVehicleType!.id,
          };

          final values = {...mValues, ...carData};
          Map<String, dynamic> params = Map.from(values);

          final apiResponse = await vehicleRequest.newVehicleRequest(
            vals: params,
            docs: selectedDocuments,
          );

          if (apiResponse.allGood) {
            await AlertService.success(
              title: "New Vehicle".tr(),
              text: "${apiResponse.message}",
            );
            Navigator.pop(viewContext, true);
            //
          } else {
            print("Lỗi ${apiResponse.message}");
            toastError("${apiResponse.message}");
            print("ERROR: ${apiResponse.message}");
          }
        } catch (error) {
          print(error);
          toastError("$error");
        }
        setBusy(false);
        return;
      }
      await AlertService.error(
        title: "New Vehicle".tr(),
        text: "Bạn cần điền đủ thông tin".tr(),
      );
      return;
    }

    if (formBuilderKey.currentState!.saveAndValidate() &&
        selectedCarModel != null &&
        selectedCarMake != null &&
        selectedVehicleType != null &&
        carColorTEC.text.isNotEmpty &&
        selectedDocuments.isNotEmpty) {
      AlertService.showLoading();

      setBusy(true);
      try {
        Map<String, dynamic> mValues = formBuilderKey.currentState!.value;
        final carData = {
          "car_make_id": selectedCarMake?.id,
          "car_model_id": selectedCarModel?.id,
          "reg_no": carRegNoTEC.text,
          "color": carColorTEC.text,
          // "price_monday_friday": carPrice1TEC.text,
          // "price_saturday_sunday": carPrice2TEC.text,
          // "discount_three_days": discountThreeDays,
          // "discount_seven_days": discountSevenDays,
          // "utilities": jsonEncode(utilities),
          // "requirements_for_rent": jsonEncode(requirements),
          //"year_made": yearMadeTEC.text,
          // "latitude": latitude,
          // "longitude": longitude,
          "vehicle_type_id": selectedVehicleType!.id,
        };

        final values = {...mValues, ...carData};
        Map<String, dynamic> params = Map.from(values);

        final apiResponse = await vehicleRequest.newVehicleRequest(
          vals: params,
          docs: selectedDocuments,
        );

        if (apiResponse.allGood) {
          AlertService.stopLoading();

          await AlertService.success(
            title: "New Vehicle".tr(),
            text: "${apiResponse.message}",
          );
          Navigator.pop(viewContext, true);
          //
        } else {
          AlertService.stopLoading();
          print("Lỗi ${apiResponse.message}");
          toastError("${apiResponse.message}");
          print("ERROR: ${apiResponse.message}");
        }
      } catch (error) {
        AlertService.stopLoading();
        print(error);
        toastError("$error");
      }
      setBusy(false);
    } else {
      final String informText;
      if (selectedCarModel == null) {
        informText = "Bạn cần chọn mẫu xe";
      } else if (selectedCarMake == null) {
        informText = "Bạn cần chọn hãng xe";
      } else if (selectedVehicleType == null) {
        informText = "Bạn cần chọn loại xe";
      } else if (carColorTEC.text.isEmpty) {
        informText = "Bạn cần nhập màu xe";
      } else if (selectedDocuments.isEmpty) {
        informText = "Bạn cần chọn hình ảnh bằng lái và các giấy tờ xe";
      } else {
        informText = "Bạn cần điền đủ thông tin";
      }

      await AlertService.error(
        title: "New Vehicle".tr(),
        text: informText.tr(),
      );
    }
  }

  onServiceTypeChange(int classification) {
    formBuilderKey.currentState!.fields["vehicle_type_id"]!.reset();
    serviceValue = classification;
    filledVehicleTypes =
        vehicleTypes.where((e) => e.vendorTypeId == classification).toList();
    notifyListeners();
  }

  onVehicleTypeSelected(int vehicleTypeID) {
    print('Nhấn chọn vehicle type');
    selectedVehicleType =
        filledVehicleTypes.where((e) => e.id == vehicleTypeID).toList().first;
    print('Name: ${selectedVehicleType!.name}');
    notifyListeners();
  }

  Future<void> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    longitude = position.longitude;
    latitude = position.latitude;
    print("Longitude: ${position.longitude} - Latitude: ${position.latitude}");
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks[0];
    addressTEC.text =
        '${place.name}, ${place.thoroughfare}, ${place.subAdministrativeArea}, ${place.administrativeArea}, ${place.country}';
  }

  Future<void> getLongLatFromAddress(String address) async {
    try {
      setBusy(true);
      List<Location> locations = await locationFromAddress(address);
      longitude = locations.first.longitude;
      latitude = locations.first.latitude;
      addressTEC.text = address;
      print('Kinh độ: ${locations.first.longitude}');
      print('Vĩ độ: ${locations.first.latitude}');
      setBusy(false);
    } catch (e) {
      print('Lỗi: $e');
    }
  }

  String getVendorTypeById(int vendorTypeId) {
    try {
      final vendorType = serviceType.firstWhere((e) => e.id == vendorTypeId);
      switch (vendorType.slug) {
        case "taxi":
          return "Taxi";
        case "shipping":
          return "Shipping";
        case "rental driver":
          return "Rental driver";
        default:
          return "Unknown";
      }
    } catch (e) {
      return "Unknown";
    }
  }

  bool isRentalDriver(String? vendorTypeId) {
    if (vendorTypeId == null) return false;
    final vendorType =
        serviceType.firstWhere((e) => e.id.toString() == vendorTypeId);

    return vendorType.slug.contains("rental driver");
  }
}
