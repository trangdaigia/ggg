import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_routes.dart';
import 'package:sod_user/models/delivery_address.dart';
import 'package:sod_user/requests/delivery_address.request.dart';
import 'package:sod_user/services/geocoder.service.dart';
import 'package:sod_user/view_models/base.view_model.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/view_models/delivery_address/new_delivery_addresses.vm.dart';
import 'package:velocity_x/velocity_x.dart';

class DeliveryAddressesViewModel extends MyBaseViewModel {
  //
  DeliveryAddressRequest deliveryAddressRequest = DeliveryAddressRequest();
  List<DeliveryAddress> deliveryAddresses = [];
  //
  DeliveryAddressesViewModel(BuildContext context) {
    this.viewContext = context;
  }

  //
  void initialise() {
    //
    fetchDeliveryAddresses();
  }

  bool isFetching = false;

  Future<void> fetchDeliveryAddresses() async {
    // Nếu đang fetch, không thực hiện lại
    if (isFetching) return;

    // Đặt trạng thái là đang fetch
    isFetching = true;
    setBusyForObject(deliveryAddresses, true);
    try {
      NewDeliveryAddressesViewModel newDeliveryAddressesViewModel =
          NewDeliveryAddressesViewModel(viewContext);
      deliveryAddresses = await deliveryAddressRequest.getDeliveryAddresses();

      print(deliveryAddresses.toString());
      print(deliveryAddresses.any((address) =>
          address.name?.toString().toLowerCase() == "work" ||
          deliveryAddresses.any(
              (address) => address.name?.toString().toLowerCase() == "home")));

      if (deliveryAddresses.any((address) =>
          address.name?.toString().toLowerCase() == "work" &&
          deliveryAddresses.any(
              (address) => address.name?.toString().toLowerCase() == "home"))) {
        // Find addresses with names "home" and "work"
        final homeAddress = deliveryAddresses.firstWhere(
          (address) => address.name?.toString().toLowerCase() == "home",
        );

        final workAddress = deliveryAddresses.firstWhere(
          (address) => address.name?.toString().toLowerCase() == "work",
        );
        //
        homeAddress.address?.toString() == "a"
            ? {
                await updateDeliveryAddress(homeAddress),
                fetchDeliveryAddresses()
              }
            : {};
        workAddress.address?.toString() == "a"
            ? {
                await updateDeliveryAddress(workAddress),
                fetchDeliveryAddresses()
              }
            : {};
        // Remove existing "home" and "work" addresses from the list
        deliveryAddresses.remove(homeAddress);
        deliveryAddresses.remove(workAddress);

        // Insert "home" and "work" addresses at indices 1 and 2
        deliveryAddresses.insert(0, homeAddress);
        deliveryAddresses.insert(1, workAddress);
      } else {
        await newDeliveryAddressesViewModel.createDeliveryAddressWithoutUI();
        fetchDeliveryAddresses();
        print("tao home va work");
      }

      clearErrors();
    } catch (error) {
      setError(error);
    }
    notifyListeners();
    isFetching = false;
    setBusyForObject(deliveryAddresses, false);
  }

  //
  newDeliveryAddressPressed() async {
    await Navigator.of(viewContext).pushNamed(
      AppRoutes.newDeliveryAddressesRoute,
    );
    fetchDeliveryAddresses();
  }

//
  getAddresstoNewOrder() async {
    String? address;

    return address;
  }

  //
  editDeliveryAddress(DeliveryAddress deliveryAddress) async {
    await Navigator.of(viewContext).pushNamed(
      AppRoutes.editDeliveryAddressesRoute,
      arguments: deliveryAddress,
    );
    fetchDeliveryAddresses();
  }

  //
  deleteDeliveryAddress(DeliveryAddress deliveryAddress) async {
    print("delete");
    //
    deliveryAddresses.remove(deliveryAddress);
    CoolAlert.show(
        context: viewContext,
        type: CoolAlertType.confirm,
        title: "Delete Address".tr(),
        text: "Are you sure you want to delete this address?".tr(),
        confirmBtnText: "Delete".tr(),
        onConfirmBtnTap: () {
          fetchDeliveryAddresses();
          processDeliveryAddressDeletion(deliveryAddress);
        });
  }

  //
  processDeliveryAddressDeletion(DeliveryAddress deliveryAddress) async {
    setBusy(true);
    //
    final apiResponse = await deliveryAddressRequest.deleteDeliveryAddress(
      deliveryAddress,
    );

    //remove from list
    if (apiResponse.allGood) {
      deliveryAddresses.remove(deliveryAddress);
    }

    setBusy(false);

    CoolAlert.show(
      context: viewContext,
      type: apiResponse.allGood ? CoolAlertType.success : CoolAlertType.error,
      title: "Delete Address".tr(),
      text: apiResponse.message,
    );
    fetchDeliveryAddresses();
  }

  Future<void> updateDeliveryAddressWithoutUI(
      DeliveryAddress deliveryAddress) async {
    deliveryAddress.description = null;
    deliveryAddress.address = null;
    print("update");
    final apiResponse =
        await deliveryAddressRequest.updateDeliveryAddress(deliveryAddress);
    CoolAlert.show(
      context: viewContext,
      type: apiResponse.allGood ? CoolAlertType.success : CoolAlertType.error,
      title: "Delete Address".tr(),
      text: apiResponse.message,
    );

    if (apiResponse.allGood) {
      await fetchDeliveryAddresses();
    }
  }

  Future<void> updateDeliveryAddress(DeliveryAddress deliveryAddress) async {
    deliveryAddress.description = null;
    deliveryAddress.address = null;
    print("update");
    final apiResponse =
        await deliveryAddressRequest.updateDeliveryAddress(deliveryAddress);
    if (apiResponse.allGood) {
      await fetchDeliveryAddresses();
    }
  }
}
