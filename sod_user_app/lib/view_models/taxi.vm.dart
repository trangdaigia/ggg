import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:firestore_chat/firestore_chat.dart';
import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_routes.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/constants/app_ui_settings.dart';
import 'package:sod_user/models/checkout.dart';
import 'package:sod_user/models/coupon.dart';
import 'package:sod_user/models/order.dart';
import 'package:sod_user/models/payment_method.dart';
import 'package:sod_user/models/taxi_ship_package_type.dart';
import 'package:sod_user/models/vehicle_type.dart';
import 'package:sod_user/models/vendor_type.dart';
import 'package:sod_user/requests/cart.request.dart';
import 'package:sod_user/requests/payment_method.request.dart';
import 'package:sod_user/requests/taxi.request.dart';
import 'package:sod_user/services/alert.service.dart';
import 'package:sod_user/services/auth.service.dart';
import 'package:sod_user/services/chat.service.dart';
import 'package:sod_user/services/firebase.service.dart';
import 'package:sod_user/services/location.service.dart';
import 'package:sod_user/utils/translate_for_flavor.utils.dart';
import 'package:sod_user/view_models/trip_taxi.vm.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/views/pages/chat/chat_detail.page.dart';
import 'package:velocity_x/velocity_x.dart';

class TaxiViewModel extends TripTaxiViewModel {
  //
  TaxiViewModel(
    BuildContext context,
    this.vendorType,
  ) {
    this.viewContext = context;
  }

//requests
  CartRequest cartRequest = CartRequest();
  TaxiRequest taxiRequest = TaxiRequest();
  PaymentMethodRequest paymentOptionRequest = PaymentMethodRequest();
  ScrollController vehicleListScrollController = ScrollController();
//

  VendorType? vendorType;
  //coupons
  bool canApplyCoupon = false;
  bool canScheduleTaxiOrder = false;
  Coupon? coupon;
  TextEditingController couponTEC = TextEditingController();
  //
  CheckOut? checkout = CheckOut();
  double subTotal = 0.0;
  double total = 0.0;
  double tip = 0.0;

  File? shipPackagePhoto;
  int? packageWeight;
  TextEditingController addressController = TextEditingController();
  TextEditingController floorNumberOrBuildingNumberController =
      TextEditingController();
  TextEditingController contactName = TextEditingController();
  TextEditingController contactNumber = TextEditingController();
  TextEditingController noteForDriver = TextEditingController();
  TextEditingController searchContactController = TextEditingController();

  TaxiShipPackageType? selectedPackageType;
  bool requestDriverGenderMan = true;
  bool twoWay = false;

  //functions
  void initialise() async {
    //
    fetchTaxiPaymentOptions();
    //
    getOnGoingTrip();
    //set current location as pickup location
    setupCurrentLocationAsPickuplocation();
    //get driverPosition
    getDriverPositionFromTrip();
  }

  //
  bool currentStep(int step) {
    return step == currentOrderStep;
  }

  isSelected(PaymentMethod paymentMethod) {
    return paymentMethod.id == selectedPaymentMethod?.id;
  }

  couponCodeChange(String code) {
    canApplyCoupon = code.isNotBlank;
    notifyListeners();
  }

  toggleScheduleTaxiOrder(bool enabled) {
    if (!enabled) {
      checkout?.pickupDate = null;
      checkout?.pickupTime = null;
    }

    canScheduleTaxiOrder = enabled;
    notifyListeners();
  }

  //
  applyCoupon() async {
    //
    setBusyForObject("coupon", true);
    try {
      coupon = await cartRequest.fetchCoupon(
        couponTEC.text,
        vendorTypeId: vendorType?.id,
      );
      if (coupon == null) {
        throw "Coupon not found".tr();
      }
      //
      if (coupon!.useLeft <= 0) {
        coupon = null;
        throw "Coupon use limit exceeded".tr();
      } else if (coupon!.expired) {
        coupon = null;
        throw "Coupon has expired".tr();
      }
      clearErrors();

      //
      calculateTotalAmount();
    } catch (error) {
      print("error ==> $error");
      setErrorForObject("coupon", error);
    }
    setBusyForObject("coupon", false);
  }

  //after locations has been selected
  proceedToStep2() async {
    //validate user has selected both pickup and drop off location
    if (dropoffLocation == null) {
      toastError("Please select pickup and drop-off location".tr());
    } else if (canScheduleTaxiOrder &&
        (checkout!.pickupDate == null || checkout!.pickupTime == null)) {
      toastError("Please select pickup date and pickup time".tr());
    } else {
      checkLocationAvailabilityForStep2();
    }
  }

  //checking if taxi booking is enabled in the given location
  checkLocationAvailabilityForStep2() async {
    setBusy(true);
    final apiResponse = await taxiRequest.locationAvailable(
      pickupLocation?.latitude ?? 0.00,
      pickupLocation?.longitude ?? 0.00,
    );
    if (apiResponse.allGood) {
      prepareStep2();
    } else {
      setCurrentStep(0);
    }
    setBusy(false);
  }

  //
  void prepareStep2() async {
    setCurrentStep(2);

    try {
      await drawTripPolyLines();
      await fetchVehicleTypes();
    } catch (error) {
      print("Error in prepareStep2 ==> $error");
      // Xử lý lỗi nếu cần thiết
    }
  }

  checkTwoWayShipping(bool value) {
    twoWay = value;
    notifyListeners();
  }

  //vehicle types
  fetchVehicleTypes() async {
    setBusyForObject(vehicleTypes, true);
    try {
      vehicleTypes = await taxiRequest.getVehicleTypePricing(
          pickupLocation!, dropoffLocation!,
          countryCode: LocationService.currenctAddress?.countryCode,
          vendorTypeId: vendorType!.id);

      vehicleTypes =
          vehicleTypes.where((e) => e.vendorTypeId == vendorType!.id).toList();
    } catch (error) {
      print("Error getting vehicleTypes ==> $error");
    }
    setBusyForObject(vehicleTypes, false);
  }

  resortVehicleTypes() {
    vehicleTypes.removeWhere((e) => e.id == selectedVehicleType?.id);
    vehicleTypes.insert(0, selectedVehicleType!);
  }

  //
  changeSelectedVehicleType(VehicleType vehicleType) {
    selectedVehicleType = vehicleType;
    //resortVehicleTypes();
    calculateTotalAmount();
  }

  //
  calculateTotalAmount() {
    //
    subTotal = selectedVehicleType!.total;
    print("subTotal ==> ${subTotal}");

    // two way shipping fee is equal to 80% of subTotal
    if (twoWay == true) {
      print("two way fee ==> ${subTotal * 0.8}");
      subTotal *= 1.8;
    }

    //
    if (coupon != null) {
      if (coupon!.percentage == 1) {
        checkout!.discount = (coupon!.discount / 100) * subTotal;
      } else {
        checkout!.discount = coupon!.discount;
      }
    } else {
      checkout!.discount = 0;
    }
    print("discount ==> ${checkout!.discount}");
    total = subTotal - (checkout?.discount ?? 0);

    print("total ==> ${total}");
    notifyListeners();
  }

  //
  processNewOrder() async {
    //
    final params = {
      "payment_method_id": selectedPaymentMethod?.id,
      "vehicle_type_id": selectedVehicleType?.id,
      "pickup": {
        "lat": pickupLocation!.latitude,
        "lng": pickupLocation!.longitude,
        "address": pickupLocation!.address,
      },
      "dropoff": {
        "lat": dropoffLocation!.latitude,
        "lng": dropoffLocation!.longitude,
        "address": dropoffLocation!.address,
      },
      "sub_total": subTotal,
      "total": total,
      "discount": checkout!.discount,
      "tip": tip,
      "coupon_code": coupon?.code,
      "vehicle_type": selectedVehicleType?.encrypted,
      "pickup_date": checkout!.pickupDate,
      "pickup_time": checkout!.pickupTime,
    };

    if (isShipOrder()) {
      params["taxi_order_type"] = "ship";

      params["package"] = {
        "weight": packageWeight,
        "ship_package_type": selectedPackageType!.name,
        "contact_number": contactNumber.text,
        "contact_name": contactName.text,
        "floor_number_or_building_number":
            floorNumberOrBuildingNumberController.text,
        "note_for_driver": noteForDriver.text,
        "return_ship_package_type": "none",
        "return_weight": 0,
      };

      params["package_photo"] = shipPackagePhoto != null
          ? await MultipartFile.fromFile(shipPackagePhoto!.path)
          : null;
    } else if (isBookDriverOrder()) {
      params["taxi_order_type"] = "book_driver";
      params["request_driver_gender"] =
          requestDriverGenderMan ? "male" : "female";
    } else {
      params["taxi_order_type"] = "taxi";
    }

    //log vehicle_type
    print("vehicle_type ==> ${selectedVehicleType?.encrypted}");

    setBusy(true);
    final apiResponse = await taxiRequest.placeNeworder(
      params: params,
    );
    setBusy(false);

    //if there was an issue placing the order
    if (!apiResponse.allGood) {
      AlertService.error(
        title: "Order failed".tr(),
        text: apiResponse.message,
      );
    } else {
      //
      onGoingOrderTrip = Order.fromJson(apiResponse.body["order"]);
      //payment
      String paymentLink = apiResponse.body["link"];
      if (paymentLink.isNotBlank) {
        await openWebpageLink(paymentLink);
      }
      //
      if (checkout!.pickupDate == null || !canScheduleTaxiOrder) {
        startHandlingOnGoingTrip();
      } else {
        closeOrderSummary();
      }
    }
  }

  //
  openTripChat() {
    openChat(onGoingOrderTrip?.driver?.id);
    return;

    // Old chat
    // Map<String, PeerUser> peers = {
    //   '${onGoingOrderTrip!.userId}': PeerUser(
    //     id: '${onGoingOrderTrip!.userId}',
    //     name: onGoingOrderTrip!.user.name,
    //     image: onGoingOrderTrip!.user.photo,
    //   ),
    //   '${onGoingOrderTrip?.driver?.id}': PeerUser(
    //       id: "${onGoingOrderTrip?.driver?.id}",
    //       name: onGoingOrderTrip?.driver?.name ?? "Driver".tr(),
    //       image: onGoingOrderTrip?.driver?.photo),
    // };
    // //
    // final chatEntity = ChatEntity(
    //   onMessageSent: ChatService.sendChatMessage,
    //   mainUser: peers['${onGoingOrderTrip?.userId}']!,
    //   peers: peers,
    //   //don't translate this
    //   path: 'orders/' + onGoingOrderTrip!.code + "/customerDriver/chats",
    //   title: TranslateUtils.getTranslateForFlavor("Chat with driver").tr(),
    //   supportMedia: AppUISettings.canCustomerChatSupportMedia,
    // );
    // //
    // Navigator.of(viewContext).pushNamed(
    //   AppRoutes.chatRoute,
    //   arguments: chatEntity,
    // );
  }

  void openChat(int? otherUserId) async {
    if (otherUserId == null) return;

    final currentUser = await AuthServices.getCurrentUser();
    final currentUserId = currentUser.id;
    final otherUser = await FirebaseService().getUserById(otherUserId);
    final chatId =
        await FirebaseService().createChat(currentUserId, otherUserId);

    Navigator.of(viewContext).push(MaterialPageRoute(builder: (context) {
      return ChatDetailPage(
        chatId: chatId,
        currentUserId: currentUserId,
        otherUser: otherUser,
      );
    }));
  }

  changeRequestDriverGender(String driverGender) {
    requestDriverGenderMan = driverGender == "Male";
    notifyListeners();
  }

  isShipOrder() {
    return vendorType!.slug == "shipping";
  }

  isBookDriverOrder() {
    return vendorType!.slug == "rental driver";
  }

  void onPackageWeightChange(int? value) {
    packageWeight = value;
    notifyListeners();
    Navigator.of(viewContext).pop();
  }

  //tính thời gian dự kiến xe sẽ đến truyền vào lng lat của tài xế, lng lat pickup, và vận tốc trung bình
  int calculateEstimatedTimeOfArrival(dynamic pickupLat, dynamic pickupLng) {
    double driverLat = this.driverPosition!.latitude;
    double driverLng = this.driverPosition!.longitude;
    //tính khoảng cách giữa tài xế và điểm đón
    double distance =
        calculateDistance(driverLat, driverLng, pickupLat, pickupLng);
    //cập nhật lại màn hình khi thời gian dự kiến thay đổi
    // notifyListeners();
    final averageSpeed = AppStrings.drivingSpeed.toDouble();
    return ((distance / averageSpeed) * 60).floor();
  }

  //tính khoảng cách giữa 2 điểm truyền vào lng lat của 2 điểm
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Bán kính Trái Đất tính bằng km
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = R * c; // Khoảng cách tính bằng km

    return distance;
  }

  //đổi độ sang radian
  double _degToRad(double deg) {
    return deg * (pi / 180);
  }
}
