import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:sod_user/models/address.dart';
import 'package:sod_user/models/delivery_address.dart';
import 'package:sod_user/requests/delivery_address.request.dart';
import 'package:sod_user/utils/utils.dart';
import 'package:sod_user/view_models/delivery_address/base_delivery_addresses.vm.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class NewDeliveryAddressesViewModel extends BaseDeliveryAddressesViewModel {
  //
  DeliveryAddressRequest deliveryAddressRequest = DeliveryAddressRequest();
  TextEditingController nameTEC = TextEditingController();
  TextEditingController addressTEC = TextEditingController();
  TextEditingController descriptionTEC = TextEditingController();
  TextEditingController what3wordsTEC = TextEditingController();
  bool isDefault = false;
  DeliveryAddress? deliveryAddress = new DeliveryAddress();

  //
  NewDeliveryAddressesViewModel(BuildContext context) {
    this.viewContext = context;
  }

  //
  showAddressLocationPicker() async {
    dynamic result = await newPlacePicker();

    if (result is PickResult) {
      PickResult locationResult = result;
      addressTEC.text = locationResult.formattedAddress ?? "";
      deliveryAddress!.address = locationResult.formattedAddress;
      deliveryAddress!.latitude = locationResult.geometry?.location.lat;
      deliveryAddress!.longitude = locationResult.geometry?.location.lng;

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
      notifyListeners();
    } else if (result is Address) {
      Address locationResult = result;
      addressTEC.text = locationResult.addressLine ?? "";
      deliveryAddress!.address = locationResult.addressLine;
      deliveryAddress!.latitude = locationResult.coordinates?.latitude;
      deliveryAddress!.longitude = locationResult.coordinates?.longitude;
      deliveryAddress!.city = locationResult.locality;
      deliveryAddress!.state = locationResult.adminArea;
      deliveryAddress!.country = locationResult.countryName;
    }
  }

  //

  void toggleDefault(bool? value) {
    isDefault = value ?? false;
    deliveryAddress!.isDefault = isDefault ? 1 : 0;
    notifyListeners();
  }

  //
  saveNewDeliveryAddress() async {
    if (formKey.currentState!.validate()) {
      //
      deliveryAddress!.name = nameTEC.text;
      deliveryAddress!.description = descriptionTEC.text;
      //
      setBusy(true);
      //
      final forbiddenWord = Utils.checkForbiddenWordsInMap({
        'name': nameTEC.text,
        'description': descriptionTEC.text,
      });
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

      final apiRespose = await deliveryAddressRequest.saveDeliveryAddress(
        deliveryAddress!,
      );
      print("Work address saved: ${apiRespose.message}.");
      //
      CoolAlert.show(
        context: viewContext,
        type: apiRespose.allGood ? CoolAlertType.success : CoolAlertType.error,
        title: "New Address".tr(),
        text: apiRespose.message,
        onConfirmBtnTap: () {
          Navigator.pop(viewContext, true);
        },
      );
      //
      setBusy(false);
    }
  }

  Future<void> createDeliveryAddressWithoutUI() async {
    // DeliveryAddressesViewModel deliveryAddressesvm = new DeliveryAddressesViewModel(viewContext);
    // Tạo một đối tượng DeliveryAddress với giá trị cho trước
    DeliveryAddress deliveryHomeAddress = DeliveryAddress(
      name: "Home",
      // address: "",
      // description: "",
      // isDefault: 0,
      // latitude: 10.780152,
      // longitude: 106.677071,
      // Các giá trị khác
    );
    DeliveryAddress deliveryWorkAddress = DeliveryAddress(
      name: "Work",
      // address: "",
      // description: "",
      // isDefault: 0,
      // latitude: 10.780152,
      // longitude: 106.677071,
      // Các giá trị khác
    );
    // Gọi hàm tạo địa chỉ giao hàng từ request
    final apiResponse =
        await deliveryAddressRequest.saveDeliveryAddress(deliveryHomeAddress);
    final apiResponse1 =
        await deliveryAddressRequest.saveDeliveryAddress(deliveryWorkAddress);

    // Kiểm tra kết quả và in ra thông báo hoặc thực hiện các tác vụ khác
    if (apiResponse.allGood) {
      print("Delivery address created successfully.");
    } else {
      print("Failed to create delivery address. Error: ${apiResponse.message}");
      print(
          "Failed to create delivery address. Error: ${apiResponse1.message}");
    }
  }

  //
}
