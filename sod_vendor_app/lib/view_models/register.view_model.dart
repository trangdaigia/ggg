import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:sod_vendor/extensions/string.dart';
import 'package:sod_vendor/models/addresses.dart';
import 'package:sod_vendor/models/vendor_type.dart';
import 'package:sod_vendor/requests/auth.request.dart';
import 'package:sod_vendor/requests/vendor_type.request.dart';
import 'package:sod_vendor/services/alert.service.dart';
import 'package:sod_vendor/services/geocoder.service.dart';
import 'package:sod_vendor/traits/qrcode_scanner.trait.dart';
import 'package:sod_vendor/utils/utils.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import '../constants/app_text_styles.dart';
import 'base.view_model.dart';
import 'package:cool_alert/cool_alert.dart';

class RegisterViewModel extends MyBaseViewModel with QrcodeScannerTrait {
  //the textediting controllers
  TextEditingController nameTEC = new TextEditingController();
  TextEditingController bEmailTEC = new TextEditingController();
  TextEditingController bPhoneTEC = new TextEditingController();
  TextEditingController passwordTEC = new TextEditingController();
  TextEditingController addressTEC = new TextEditingController();
  List<VendorType> vendorTypes = [];
  List<File> selectedDocuments = [];
  bool hidePassword = true;
  Country? selectedVendorCountry;
  Country? selectedCountry;
  int? selectedVendorTypeId;
  //
  String? address;
  String? latitude;
  String? longitude;
  Addresses? deliveryAddresss;

  //
  AuthRequest _authRequest = AuthRequest();
  VendorTypeRequest _vendorTypeRequest = VendorTypeRequest();

  RegisterViewModel(BuildContext context) {
    this.viewContext = context;
    this.selectedVendorCountry = Country.parse("us");
    this.selectedCountry = Country.parse("us");
  }
  void initialise() async {
    fetchVendorTypes();
    String countryCode = await Utils.getCurrentCountryCode();
    this.selectedCountry = Country.parse(countryCode);
    this.selectedVendorCountry = Country.parse(countryCode);
    notifyListeners();
  }

  Future<List<Address>> searchAddress(String keyword) async {
    List<Address> addresses = [];
    try {
      addresses = await GeocoderService().findAddressesFromQuery(keyword);
    } catch (error) {
      toastError("$error");
    }

    //
    return addresses;
  }

  void useCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    final coordinates = Coordinates(position.latitude, position.longitude);
    final addresses = await GeocoderService().findAddressesFromCoordinates(
      coordinates,
    );
    if (addresses.length == 0) return;
    this.address = addresses.first.addressLine;
    this.latitude = position.latitude.toString();
    this.longitude = position.longitude.toString();
    this.addressTEC.text = addresses.first.addressLine.toString();
  }

  void handleChooseOnMap() async {
    //
    deliveryAddresss = await showDeliveryAddressPicker();
    //
    this.address = deliveryAddresss?.address;
    this.latitude = deliveryAddresss?.latitude.toString();
    this.longitude = deliveryAddresss?.longitude.toString();
    this.addressTEC.text = deliveryAddresss?.address ?? "";
    notifyListeners();
  }

  Future<Addresses> showDeliveryAddressPicker() async {
    //
    dynamic result = await newPlacePicker();

    if (result is PickResult) {
      PickResult locationResult = result;
      deliveryAddress = Addresses();
      deliveryAddress!.address = locationResult.formattedAddress!;
      deliveryAddress!.latitude = locationResult.geometry!.location.lat;
      deliveryAddress!.longitude = locationResult.geometry!.location.lng;

      if (locationResult.addressComponents != null &&
          locationResult.addressComponents!.isNotEmpty) {
        //fetch city, state and country from address components
        locationResult.addressComponents!.forEach((addressComponent) {
          if (addressComponent.types.contains("locality")) {
            deliveryAddress!.city = addressComponent.longName;
          }
          if (addressComponent.types.contains("administrative_area_level_1")) {
            deliveryAddress!.state = addressComponent.longName;
          }
          if (addressComponent.types.contains("country")) {
            deliveryAddress!.country = addressComponent.longName;
          }
        });
      } else {
        // From coordinates
        setBusy(true);
        deliveryAddress = await getLocationCityName(deliveryAddress!);
        setBusy(false);
      }
    } else if (result is Address) {
      Address locationResult = result;
      deliveryAddress = Addresses();
      deliveryAddress?.address = locationResult.addressLine!;
      deliveryAddress?.latitude = locationResult.coordinates!.latitude;
      deliveryAddress?.longitude = locationResult.coordinates!.longitude;
      deliveryAddress?.city = locationResult.locality!;
      deliveryAddress?.state = locationResult.adminArea!;
      deliveryAddress?.country = locationResult.countryName!;
      //
    }
    //

    return deliveryAddress ?? Addresses();
  }

  onAddressSelected(Address address) {
    this.address = address.addressLine;
    this.latitude = address.coordinates?.latitude.toString();
    this.longitude = address.coordinates?.longitude.toString();
    this.addressTEC.text = "${address.addressLine}";
    notifyListeners();
  }

  fetchVendorTypes() async {
    setBusyForObject(vendorTypes, true);
    try {
      vendorTypes = await _vendorTypeRequest.index();
      vendorTypes = vendorTypes
          .where(
            (e) => !e.slug.toLowerCase().contains("vendor"),
          )
          .toList();
    } catch (error) {
      toastError("$error");
    }
    setBusyForObject(vendorTypes, false);
  }

  showCountryDialPicker([bool vendorPhone = false]) {
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
      onSelect: (value) => countryCodeSelected(value, vendorPhone),
    );
  }

  countryCodeSelected(Country country, bool vendorPhone) {
    if (vendorPhone) {
      selectedVendorCountry = country;
    } else {
      selectedCountry = country;
    }
    notifyListeners();
  }

  changeSelectedVendorType(int? vendorTypeId) {
    selectedVendorTypeId = vendorTypeId;
    notifyListeners();
  }

  void onDocumentsSelected(List<File> documents) {
    selectedDocuments = documents;
    notifyListeners();
  }

  void processLogin() async {
    // Validate returns true if the form is valid, otherwise false.
    if (formBuilderKey.currentState!.saveAndValidate()) {
      //
      setBusy(true);

      Map<String, dynamic> params =
          Map.from(formBuilderKey.currentState!.value);
      String phone = params['phone'].toString().telFormat();
      params["phone"] = "+${selectedCountry?.phoneCode}${phone}";
      String vPhone = params['vendor_phone'].toString().telFormat();
      params["vendor_phone"] = "+${selectedVendorCountry?.phoneCode}${vPhone}";
      //add address and coordinates
      params["address"] = address;
      params["latitude"] = latitude;
      params["longitude"] = longitude;

      final forbiddenWord = Utils.checkForbiddenWordsInString(params["name"]);
      if (forbiddenWord != null) {
        await CoolAlert.show(
          context: viewContext,
          type: CoolAlertType.error,
          title: "Warning forbidden words".tr(),
          text: "Account information contains forbidden word".tr() +
              ": $forbiddenWord",
        );
        setBusy(false);
        return;
      }

      try {
        final apiResponse = await _authRequest.registerRequest(
          vals: params,
          docs: selectedDocuments,
        );

        if (apiResponse.allGood) {
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
}
