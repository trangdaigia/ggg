import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/driver_lib/models/vehicle.dart';
import 'package:sod_user/driver_lib/models/vendor_type.dart';
import 'package:sod_user/driver_lib/requests/auth.request.dart';
import 'package:sod_user/driver_lib/requests/general.request.dart';
import 'package:sod_user/driver_lib/requests/vendor_type.request.dart';
import 'package:sod_user/driver_lib/requests/area.request.dart';
import 'package:sod_user/driver_lib/services/alert.service.dart';
import 'package:sod_user/driver_lib/traits/qrcode_scanner.trait.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/services/auth.service.dart';
import '../constants/app_text_styles.dart';
import 'base.view_model.dart';

class RegisterViewModel extends MyBaseViewModel with QrcodeScannerTrait {
  //the textediting controllers
  TextEditingController carMakeTEC = new TextEditingController();
  TextEditingController carModelTEC = new TextEditingController();
  List<String> types = ["Regular", "Taxi"];
  Map<String, List<Map<String, String>>> areas = {
    'countries': [],
    'states': [],
    'cities': [],
  };
  List<VehicleType> vehicleTypes = [];
  String selectedDriverType = "regular";
  List<CarMake> carMakes = [];
  List<CarModel> carModels = [];
  CarMake? selectedCarMake;
  CarModel? selectedCarModel;
  List<File> selectedDocuments = [];
  bool hidePassword = true;
  bool onlyReceiveBehalf = false;
  bool isShowSelectCountry = true;
  late Country selectedCountry;

  //
  AuthRequest _authRequest = AuthRequest();
  GeneralRequest _generalRequest = GeneralRequest();
  final _areaRequest = AreaRequest();

  RegisterViewModel(BuildContext context) {
    this.viewContext = context;
    selectedCountry = Country.parse(AppStrings.defaultCountryCode);
    notifyListeners();
  }

  @override
  void initialise() {
    super.initialise();
    fetchVehicleTypes();
    fetchCarMakes();
    setOnlyReceiveBehalf();
    fetchArea();
    //
  }

  // Nếu chỉ có môt enabledVendorType thuộc nhận hộ thì set onlyReceiveBehalf = true
  setOnlyReceiveBehalf() async {
    List<VendorType> vendorTypes = await VendorTypeRequest().index();
    if (vendorTypes.isNotEmpty &&
        vendorTypes.length == 1 &&
        vendorTypes.first.slug == AppStrings.receiveBehalfSlug) {
      onlyReceiveBehalf = true;
    }
  }

  showCountryDialPicker() {
    showCountryPicker(
      //Chỉnh lại textField tìm kiếm
      countryListTheme: CountryListThemeData(
        textStyle: AppTextStyle.h4TitleTextStyle(
          fontWeight: FontWeight.w400,
          color: Theme.of(viewContext).textTheme.bodyLarge!.color,
        ),
        // Optional. Sets the border radius for the bottomsheet.
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40.0),
          topRight: Radius.circular(40.0),
        ),
        searchTextStyle: AppTextStyle.h4TitleTextStyle(
          fontWeight: FontWeight.w400,
          color: Theme.of(viewContext).textTheme.bodyLarge!.color,
        ),
        // Optional. Styles the search field.
        inputDecoration: InputDecoration(
          labelText: 'Search',
          labelStyle: AppTextStyle.h5TitleTextStyle(
              color: Theme.of(viewContext).textTheme.bodyLarge!.color),
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(viewContext).textTheme.bodyLarge!.color!,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(viewContext).textTheme.bodyLarge!.color!,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(viewContext).textTheme.bodyLarge!.color!,
            ),
          ),
        ),
      ),
      context: viewContext,
      showPhoneCode: true,
      onSelect: (value) => countryCodeSelected(value),
    );
  }

  countryCodeSelected(Country country) {
    selectedCountry = country;
    notifyListeners();
  }

  void onDocumentsSelected(List<File> documents) {
    selectedDocuments = documents;
    notifyListeners();
  }

  void onSelectedDriverType(String? value) {
    selectedDriverType = value ?? "regular";
    notifyListeners();
  }

  onCarMakeSelected(CarMake value) {
    selectedCarMake = value;
    carMakeTEC.text = value.name;
    notifyListeners();
    fetchCarModel();
  }

  onCarModelSelected(CarModel value) {
    selectedCarModel = value;
    carModelTEC.text = value.name;
    notifyListeners();
  }

  void fetchVehicleTypes() async {
    setBusyForObject(vehicleTypes, true);
    try {
      vehicleTypes = await _generalRequest.getVehicleTypes();
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

  void processRegister() async {
    if (formBuilderKey.currentState!.saveAndValidate()) {
      //
      setBusy(true);

      try {
        Map<String, dynamic> mValues = formBuilderKey.currentState!.value;
        final user = await AuthServices.getCurrentUser();
        final driverData = {"id": user.id};
        final values = {...mValues, ...driverData};
        Map<String, dynamic> params = Map.from(values);
        final apiResponse = await _authRequest.registerRequest(
          vals: params,
          docs: selectedDocuments,
        );

        if (apiResponse.allGood) {
          user.documentRequested = true;
          user.pendingDocumentApproval = true;
          AuthServices.setIsDriverWaitingForApproval(true);
          notifyListeners();
          await AlertService.success(
            title: "Become a partner".tr(),
            text: "${apiResponse.message}",
          );
          //
        } else {
          toastError("${apiResponse.message}");
        }
      } catch (error) {
        toastError("$error");
      }

      setBusy(false);
    }
  }

  Future<void> fetchArea() async {
    areas['countries'] = await _areaRequest.getCountries();

    // Nếu có 1 quốc gia thì tự động chọn quốc gia đó
    if (areas['countries'] != null && areas['countries']!.length == 1) {
      isShowSelectCountry = false;
      final countryId = areas['countries']!.first['id'];
      formBuilderKey.currentState?.fields['country_id']?.didChange(countryId);
      onSelectedCountry(countryId);
    }

    notifyListeners();
  }

  Future<void> onSelectedCountry(String? countryId) async {
    if (countryId == null) return;

    // Đặt lại danh sách tỉnh và state_id và city_id
    areas['states'] = [];
    areas['cities'] = [];
    formBuilderKey.currentState?.fields['state_id']?.didChange(null);
    formBuilderKey.currentState?.fields['city_id']?.didChange(null);

    areas['states'] = await _areaRequest.getStates(countryId);

    notifyListeners();
  }

  Future<void> onSelectedState(String? stateId) async {
    if (stateId == null) return;

    // Đặt lại danh sách thành phố và city_id và giá trị city trong form về null
    areas['cities'] = [];
    formBuilderKey.currentState?.fields['city_id']?.didChange(null);

    areas['cities'] = await _areaRequest.getCities(stateId);

    notifyListeners();
  }

  void onSelectedCity(String? cityId) {
    if (cityId == null) return;

    notifyListeners();
  }
}
