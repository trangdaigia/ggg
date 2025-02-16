import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_map_settings.dart';
import 'package:sod_user/models/delivery_address.dart';
import 'package:sod_user/models/order.dart';
import 'package:sod_user/models/payment_method.dart';
import 'package:sod_user/models/vehicle_type.dart';
import 'package:sod_user/requests/payment_method.request.dart';
import 'package:sod_user/requests/taxi.request.dart';
import 'package:sod_user/utils/map.utils.dart';
import 'package:sod_user/view_models/taxi_google_map.vm.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart' as vietMapGl;
import 'package:localize_and_translate/localize_and_translate.dart';
import '../services/alert.service.dart';

class TripTaxiViewModel extends TaxiGoogleMapViewModel {
//requests
  TaxiRequest taxiRequest = TaxiRequest();
  PaymentMethodRequest paymentOptionRequest = PaymentMethodRequest();
//
  Order? onGoingOrderTrip;
  double newTripRating = 3.0;
  TextEditingController tripReviewTEC = TextEditingController();
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  StreamSubscription? tripUpdateStream;
  StreamSubscription? driverLocationStream;

  LatLng? driverPosition;
  double driverPositionRotation = 0;

  //
  List<PaymentMethod> paymentMethods = [];
  PaymentMethod? selectedPaymentMethod;

  //vheicle types
  List<VehicleType> vehicleTypes = [];
  VehicleType? selectedVehicleType;

  //get current on going trip
  void getOnGoingTrip() async {
    //
    setBusyForObject(onGoingOrderTrip, true);
    try {
      onGoingOrderTrip = await taxiRequest.getOnGoingTrip();

      // Khi mở trang đặt xe, nếu có chuyến đi đang diễn ra
      // mà chưa tìm được tài xế trong 10 phút thì hủy chuyến
      if (onGoingOrderTrip != null && onGoingOrderTrip!.status == "pending") {
        final now = DateTime.now();
        final tripTime = onGoingOrderTrip!.createdAt;

        if (now.difference(tripTime).inMinutes >= 10) {
          taxiRequest.cancelTrip(onGoingOrderTrip!.id);
          onGoingOrderTrip = null;
          setCurrentStep(1);
          AlertService.warning(
            title: "Notifications".tr(),
            text: "The last trip has been canceled due to no driver being found"
                .tr(),
          );
        }
      }

      loadTripUIByOrderStatus(initial: true);
      //lấy vị trí tài xế mỗi 10 giây
      if (onGoingOrderTrip != null && onGoingOrderTrip!.driver != null) {
        Timer.periodic(Duration(seconds: 10), (timer) async {
          driverPosition = await getDriverPositionFromTrip();
          updateDriverMarkerPosition();
          notifyListeners();
        });
      }
    } catch (error) {
      print("trip ongoing error 111 ==> $error");
    }
    setBusyForObject(onGoingOrderTrip, false);
  }

  //cancel trip
  void cancelTrip() async {
    //vehicleTypes
    setBusyForObject(onGoingOrderTrip, true);
    try {
      final apiResponse = await taxiRequest.cancelTrip(onGoingOrderTrip!.id);
      //
      if (apiResponse.allGood) {
        toastSuccessful(
            apiResponse.message ?? "Trip cancelled successfully".tr());
        setCurrentStep(1);
        clearMapData();
      } else {
        toastError(apiResponse.message ?? "Failed to cancel trip".tr());
      }
    } catch (error) {
      print("trip ongoing error ==> $error");
    }
    setBusyForObject(onGoingOrderTrip, false);
  }

  //
  loadTripUIByOrderStatus({bool initial = false}) {
    //
    //
    if ((initial)) {
      //
      pickupLocation = DeliveryAddress(
        latitude: onGoingOrderTrip?.taxiOrder?.pickupLatitude.toDoubleOrNull(),
        longitude:
            onGoingOrderTrip?.taxiOrder?.pickupLongitude.toDoubleOrNull(),
        address: onGoingOrderTrip?.taxiOrder?.pickupAddress,
      );
      //
      dropoffLocation = DeliveryAddress(
        latitude: onGoingOrderTrip?.taxiOrder?.dropoffLatitude.toDoubleOrNull(),
        longitude:
            onGoingOrderTrip?.taxiOrder?.dropoffLongitude.toDoubleOrNull(),
        address: onGoingOrderTrip?.taxiOrder?.dropoffAddress,
      );
      //set the pickup and drop off locations
      drawTripPolyLines();
      startHandlingOnGoingTrip();
    } else if (onGoingOrderTrip != null) {
      switch (onGoingOrderTrip?.status) {
        case "pending":
          setCurrentStep(5);
          break;
        case "preparing":
          if (onGoingOrderTrip != null && onGoingOrderTrip!.driver != null) {
            setCurrentStep(6);
            startZoomFocusDriver();
          }
          break;
        case "ready":
          setCurrentStep(6);
          startZoomFocusDriver();
          break;
        case "enroute":
          setCurrentStep(6);
          startZoomFocusDriver();
          break;
        case "delivered":
          setCurrentStep(7);
          clearMapData();
          zoomToLocation(
            LatLng(
              onGoingOrderTrip?.taxiOrder?.dropoffLatitude.toDoubleOrNull() ??
                  0.0,
              onGoingOrderTrip?.taxiOrder?.dropoffLongitude.toDoubleOrNull() ??
                  0.0,
            ),
          );
          stopAllListeners();
          break;
        case "failed":
          setCurrentStep(1);
          clearMapData();
          stopAllListeners();
          closeOrderSummary();
          break;
        case "cancelled":
          setCurrentStep(1);
          clearMapData();
          stopAllListeners();
          closeOrderSummary();
          break;
        default:
      }
    } else if (onGoingOrderTrip == null) {
      setCurrentStep(1);
      clearMapData();
      stopAllListeners();
      closeOrderSummary();
    }
  }

//
  void startHandlingOnGoingTrip() async {
    //
    if (onGoingOrderTrip == null) {
      return;
    }
    //clear current UI step
    setCurrentStep(5);
    //set new on trip step
    tripUpdateStream = firebaseFirestore
        .collection("orders")
        .doc("${onGoingOrderTrip?.code}")
        .snapshots()
        .listen(
      (event) async {
        //once driver is assigned
        final driverId =
            event.data() != null ? event.data()!["driver_id"] ?? null : null;
        if (driverId == null) return;
        if (onGoingOrderTrip?.driverId == null) {
          onGoingOrderTrip?.driverId = event.data()!["driver_id"];
          onGoingOrderTrip?.driver = event.data()!["driver"] ?? null;
        }

        //
        if (onGoingOrderTrip?.driver == null) {
          await loadDriverDetails();
        }
        startDriverDetailsListener();
        print("Event status: ${event.data()?['status']}");
        //update the rest onGoingTrip details
        if (event.exists) {
          print("Document exist");
          onGoingOrderTrip?.status = event.data()?["status"] ?? "failed";
        }
        //
        notifyListeners();
        loadTripUIByOrderStatus();
      },
    );
    //start order details listening stream
  }

  //DRIVER SECTION
  loadDriverDetails() async {
    try {
      final mDriverId = onGoingOrderTrip?.driverId;
      if (mDriverId != null) {
        onGoingOrderTrip?.driver = await taxiRequest.getDriverInfo(mDriverId);
        // onGoingOrderTrip = await taxiRequest.getOnGoingTrip();
      }
      //loop until driver data is gotten
      if (onGoingOrderTrip?.driver == null) {
        await Future.delayed(Duration(seconds: 5));
        loadDriverDetails();
      }
      notifyListeners();
    } catch (error) {
      print("trip ongoing error ==> ${error}");
    }
  }

  //Start listening to driver location changes
  void startDriverDetailsListener() async {
    //
    driverLocationStream = firebaseFirestore
        .collection("drivers")
        .doc("${onGoingOrderTrip?.driverId}")
        .snapshots()
        .listen((event) {
      //
      if (!event.exists) {
        return;
      }
      //
      driverPosition = LatLng(event.data()?["lat"], event.data()?["long"]);
      driverPositionRotation = event.data()?["rotation"] ?? 0;
      updateDriverMarkerPosition();
      startZoomFocusDriver();
    });
  }

  //
  updateDriverMarkerPosition() {
    //
    if (!AppMapSettings.isUsingVietmap) {
      Marker? driverMarker = gMapMarkers.firstOrNullWhere(
        (e) => e.markerId.value == "driverMarker",
      );
      //
      if (driverMarker == null) {
        driverMarker = Marker(
          markerId: MarkerId('driverMarker'),
          position: driverPosition!,
          rotation: driverPositionRotation,
          icon: driverIcon!,
          anchor: Offset(0.5, 0.5),
        );
        gMapMarkers.add(driverMarker);
      } else {
        driverMarker = driverMarker.copyWith(
          positionParam: driverPosition,
          rotationParam: driverPositionRotation,
        );
        gMapMarkers.removeWhere((e) => e.markerId.value == "driverMarker");
        gMapMarkers.add(driverMarker);
      }

      notifyListeners();
    }
  }

  //
  startZoomFocusDriver() {
    //create bond between driver and
    if (driverPosition == null) {
      return;
    }

    if (onGoingOrderTrip == null) {
      return;
    }
    //check status to determine the latlng bound
    if (onGoingOrderTrip!.canZoomOnPickupLocation) {
      //zoom to driver and pickup latbound
      if (AppMapSettings.isUsingVietmap) {
        print("checkzoom");
        vietMapController!.animateCamera(vietMapGl.CameraUpdate.newLatLngBounds(
          MapUtils.targetBounds(
            driverPosition!,
            LatLng(
              pickupLocation!.latitude!,
              pickupLocation!.longitude!,
            ),
          ),
          top: 70,
          left: 70,
          right: 70,
          bottom: 160,
        ));
      } else {
        updateCameraLocation(
            driverPosition!,
            LatLng(
              pickupLocation!.latitude!,
              pickupLocation!.longitude!,
            ),
            googleMapController);
      }
    } else if (onGoingOrderTrip!.canZoomOnDropoffLocation) {
      //zoom to driver and dropoff latbound
      if (AppMapSettings.isUsingVietmap) {
        vietMapController!.animateCamera(vietMapGl.CameraUpdate.newLatLngBounds(
          MapUtils.targetBounds(
            driverPosition!,
            LatLng(
              dropoffLocation!.latitude!,
              dropoffLocation!.longitude!,
            ),
          ),
          top: 70,
          left: 70,
          right: 70,
          bottom: 160,
        ));
      } else {
        updateCameraLocation(
            driverPosition!,
            LatLng(
              dropoffLocation!.latitude!,
              dropoffLocation!.longitude!,
            ),
            googleMapController);
      }
    }
  }

  //
  stopAllListeners() {
    tripUpdateStream?.cancel();
    driverLocationStream?.cancel();
  }

  //when trip is ended
  dismissTripRating() async {
    tripReviewTEC.clear();
    setCurrentStep(1);
    zoomToCurrentLocation();
  }

  submitTripRating() async {
    //
    setBusyForObject(newTripRating, true);
    //
    final apiResponse = await taxiRequest.rateDriver(
      onGoingOrderTrip!.id,
      onGoingOrderTrip!.driverId!,
      newTripRating,
      tripReviewTEC.text,
    );
    //
    if (apiResponse.allGood) {
      toastSuccessful(apiResponse.message ?? "Trip rated successfully".tr());
      dismissTripRating();
    } else {
      toastError(apiResponse.message ?? "Failed to rate trip".tr());
    }
    setBusyForObject(newTripRating, false);
  }

  closeOrderSummary({bool clear = true}) {
    if (clear) {
      pickupLocation = null;
      dropoffLocation = null;
      pickupLocationTEC.clear();
      dropoffLocationTEC.clear();
      selectedVehicleType = null;
      selectedPaymentMethod = paymentMethods.firstOrNull;
      notifyListeners();
    }
    //
    clearMapData();
    setCurrentStep(1);
  }

  Future<LatLng?> getDriverPositionFromTrip() async {
    if (onGoingOrderTrip != null && onGoingOrderTrip!.driver != null) {
      // Nếu thông tin tài xế và vị trí tài xế có sẵn
      final driverDoc = await firebaseFirestore
          .collection("drivers")
          .doc("${onGoingOrderTrip?.driverId}")
          .get();

      if (!driverDoc.exists) {
        return null;
      }

      // Trả về LatLng từ dữ liệu Firestore
      double lat = driverDoc.data()?["lat"];
      double long = driverDoc.data()?["long"];

      print("lat: $lat, long: $long");
      return LatLng(lat, long);
    } else {
      // Nếu không có thông tin tài xế
      return null;
    }
  }
}
