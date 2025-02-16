import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_routes.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/models/delivery_address.dart';
import 'package:sod_user/requests/delivery_address.request.dart';
import 'package:sod_user/services/app.service.dart';
import 'package:sod_user/services/cart.service.dart';
import 'package:sod_user/services/geocoder.service.dart';
import 'package:sod_user/view_models/base.view_model.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';

class DeliveryAddressPickerViewModel extends MyBaseViewModel {
  //
  DeliveryAddressRequest deliveryAddressRequest = DeliveryAddressRequest();
  List<DeliveryAddress> deliveryAddresses = [];
  List<DeliveryAddress> unFilterDeliveryAddresses = [];
  final Function(DeliveryAddress) onSelectDeliveryAddress;
  bool vendorCheckRequired;

  //
  DeliveryAddressPickerViewModel(
    BuildContext context,
    this.onSelectDeliveryAddress,
    this.vendorCheckRequired,
  ) {
    this.viewContext = context;
    if (vendorCheckRequired) {
      vendorCheckRequired = true;
    }
  }

  //
  void initialise() {
    //
    fetchDeliveryAddresses();
  }

  //
  fetchDeliveryAddresses() async {
    //
    int? vendorId = CartServices.productsInCart.isNotEmpty
        ? CartServices.productsInCart.first.product?.vendor.id
        : AppService().vendorId ?? null;

    List<int>? vendorIds = (CartServices.productsInCart.isNotEmpty &&
            AppStrings.enableMultipleVendorOrder)
        ? CartServices.productsInCart
            .map((e) => e.product!.vendorId)
            .toList()
            .toSet()
            .toList()
        : null;
    //send null value to api, so address will not be filtered
    if (!vendorCheckRequired) {
      vendorIds = null;
      vendorId = null;
    }

    setBusy(true);
    try {
      unFilterDeliveryAddresses =
          deliveryAddresses = await deliveryAddressRequest.getDeliveryAddresses(
        vendorId: vendorId,
        vendorIds: vendorIds,
      );
      clearErrors();
    } catch (error) {
      setError(error);
    }
    setBusy(false);
  }

  //
  newDeliveryAddressPressed() async {
    await Navigator.of(viewContext)
        .pushNamed(AppRoutes.newDeliveryAddressesRoute);
    fetchDeliveryAddresses();
  }

  //
  void pickFromMap() async {
    //
    dynamic result = await newPlacePicker();
    DeliveryAddress deliveryAddress = DeliveryAddress();

    if (result is PickResult) {
      PickResult locationResult = result;
      deliveryAddress.address = locationResult.formattedAddress;
      deliveryAddress.latitude = locationResult.geometry?.location.lat;
      deliveryAddress.longitude = locationResult.geometry?.location.lng;

      if (locationResult.addressComponents != null &&
          locationResult.addressComponents!.isNotEmpty) {
        //fetch city, state and country from address components
        locationResult.addressComponents!.forEach((addressComponent) {
          if (addressComponent.types.contains("locality")) {
            deliveryAddress.city = addressComponent.longName;
          }
          if (addressComponent.types.contains("administrative_area_level_1")) {
            deliveryAddress.state = addressComponent.longName;  
          }
          if (addressComponent.types.contains("country")) {
            deliveryAddress.country = addressComponent.longName;
          }
        });
      } else {
        // From coordinates
        setBusy(true);
        final coordinates = new Coordinates(
          deliveryAddress.latitude!,
          deliveryAddress.longitude!,
        );
        //
        final addresses = await GeocoderService().findAddressesFromCoordinates(
          coordinates,
        );
        deliveryAddress.city = addresses.first.locality;
        setBusy(false);
      }
      //
      this.onSelectDeliveryAddress(deliveryAddress);
    } else if (result is Address) {
      Address locationResult = result;
      deliveryAddress.address = locationResult.addressLine;
      deliveryAddress.latitude = locationResult.coordinates?.latitude;
      deliveryAddress.longitude = locationResult.coordinates?.longitude;
      deliveryAddress.city = locationResult.locality;
      deliveryAddress.state = locationResult.adminArea;
      deliveryAddress.country = locationResult.countryName;
      //
      this.onSelectDeliveryAddress(deliveryAddress);
    }
  }

  filterResult(String keyword) {
    deliveryAddresses = unFilterDeliveryAddresses.where((e) {
      //
      String name = e.name ?? "";
      String address = e.address ?? "";
      //
      return name.toLowerCase().contains(keyword) ||
          address.toLowerCase().contains(keyword);
    }).toList();
    notifyListeners();
  }
}
