import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/material.dart';
import 'package:sod_user/driver_lib/constants/app_strings.dart';
import 'package:sod_user/driver_lib/models/delivery_address.dart';
import 'package:sod_user/driver_lib/models/order.dart';
import 'package:sod_user/driver_lib/services/alert.service.dart';
import 'package:sod_user/driver_lib/services/location.service.dart';
import 'package:sod_user/driver_lib/services/taxi/taxi_polylines.service.dart';
import 'package:sod_user/driver_lib/services/taxi/taxi_trip_booking_code.service.dart';
import 'package:sod_user/driver_lib/view_models/taxi/taxi.vm.dart';
import 'package:sod_user/driver_lib/views/pages/taxi/widgets/statuses/arrived.view.dart';
import 'package:sod_user/driver_lib/views/pages/taxi/widgets/statuses/enroute.view.dart';
import 'package:sod_user/driver_lib/views/pages/taxi/widgets/statuses/pickup.view.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart' as vietMapGl;
import 'package:vietmap_flutter_plugin/vietmap_flutter_plugin.dart'
    as vietMapFlg;
import 'package:supercharged/supercharged.dart';

class OnGoingTaxiBookingService extends TaxiPolylinesService {
  TaxiViewModel taxiViewModel;
  OnGoingTaxiBookingService(this.taxiViewModel) : super(taxiViewModel);
  //
  FirebaseFirestore firebaseFireStore = FirebaseFirestore.instance;
  StreamSubscription? tripUpdateStream;
  StreamSubscription? locationStreamSubscription;

  //
  DeliveryAddress? pickupLocation;
  DeliveryAddress? dropoffLocation;
  LatLng? driverPosition;
  final pickupMarkerId = MarkerId('sourcePin');
  final dropoffMarkerId = MarkerId('destPin');

  //dispose
  void dispose() {
    tripUpdateStream?.cancel();
    locationStreamSubscription?.cancel();
  }

  //
  //get current on going trip
  Future<Order?> getOnGoingTrip() async {
    //
    Order? order;
    taxiViewModel.setBusy(true);
    try {
      order = await taxiViewModel.taxiRequest.getOnGoingTrip();
      loadTripUIByOrderStatus();
    } catch (error) {
      print("trip ongoing error ==> $error");
      taxiViewModel.setBusy(false);
    }
    taxiViewModel.setBusy(false);
    return order;
  }

  //Zoom to pickup location
  zoomToPickupLocation([LatLng? point]) async {
    //

    taxiViewModel.taxiMapManagerService.removeMapMarker(pickupMarkerId);
    taxiViewModel.taxiMapManagerService.gMapMarkers.add(
      Marker(
        markerId: pickupMarkerId,
        position: point ??
            LatLng(
              taxiViewModel.onGoingOrderTrip?.taxiOrder?.pickupLatitude
                      .toDouble() ??
                  0.0,
              taxiViewModel.onGoingOrderTrip?.taxiOrder?.pickupLongitude
                      .toDouble() ??
                  0.0,
            ),
        icon: taxiViewModel.taxiMapManagerService.sourceIcon!,
        anchor: Offset(0.5, 0.5),
      ),
    );
    //
    taxiViewModel.notifyListeners();
    //actually zoom now
    taxiViewModel.taxiMapManagerService.googleMapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: point ??
              LatLng(
                taxiViewModel.onGoingOrderTrip?.taxiOrder?.pickupLatitude
                        .toDouble() ??
                    0.0,
                taxiViewModel.onGoingOrderTrip?.taxiOrder?.pickupLongitude
                        .toDouble() ??
                    0.0,
              ),
          zoom: 16,
        ),
      ),
    );
  }

  //Zoom to dropoff location
  zoomToDropoffLocation() async {
    //
    taxiViewModel.taxiMapManagerService.removeMapMarker(dropoffMarkerId);
    taxiViewModel.taxiMapManagerService.gMapMarkers.add(
      Marker(
        markerId: dropoffMarkerId,
        position: LatLng(
          taxiViewModel.onGoingOrderTrip?.taxiOrder?.dropoffLatitude
                  .toDouble() ??
              0.00,
          taxiViewModel.onGoingOrderTrip?.taxiOrder?.dropoffLongitude
                  .toDouble() ??
              0.00,
        ),
        icon: taxiViewModel.taxiMapManagerService.destinationIcon!,
        anchor: Offset(0.5, 0.5),
      ),
    );
    //
    taxiViewModel.notifyListeners();
    //actually zoom now
    taxiViewModel.taxiMapManagerService.googleMapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            taxiViewModel.onGoingOrderTrip?.taxiOrder?.pickupLatitude
                    .toDouble() ??
                0.00,
            taxiViewModel.onGoingOrderTrip?.taxiOrder?.pickupLongitude
                    .toDouble() ??
                0.00,
          ),
          zoom: 16,
        ),
      ),
    );
  }

  //Zoom to bound within driver location & dropoff location
  zoomToTripBoundLocation() async {
    //
    locationStreamSubscription =
        LocationService().getNewLocationStream().listen(
      (event) {
        //
        driverPosition = LatLng(event.latitude, event.longitude);
        //zoom to driver and dropoff latbound
        updateCameraLocation(
          driverPosition!,
          LatLng(
            dropoffLocation?.latitude ?? 0.00,
            dropoffLocation?.longitude ?? 0.00,
          ),
          taxiViewModel.taxiMapManagerService.googleMapController!,
        );
      },
    );
  }

  //
  loadTripUIByOrderStatus({withMap = false}) {
    if (withMap) vietMapFlg.Vietmap.getInstance(AppStrings.vietMapMapApiKey);

    //
    taxiViewModel.newFormKey();
    //
    startHandlingOnGoingTrip();

    //
    Widget? tripUi = null;
    print("trip ongoing STATUS ==> ${taxiViewModel.onGoingOrderTrip?.status}");
    //
    switch (taxiViewModel.onGoingOrderTrip?.status) {
      case "pending":
        tripUi = PickupTaxiView(taxiViewModel);
        if (withMap) drawPolyLinesToPickup();
        break;
      case "preparing":
        tripUi = PickupTaxiView(taxiViewModel);
        if (withMap) drawPolyLinesToPickup();
        break;
      case "ready":
        tripUi = ArrivedTaxiView(taxiViewModel);
        break;
      case "enroute":
        tripUi = EnrouteTaxiView(taxiViewModel);
        if (withMap) drawTripPolyLines();
        break;
      case "delivered":
        if (withMap) taxiViewModel.taxiMapManagerService.clearMapData();
        // zoomToDropoffLocation();
        refreshSwipeBtnActionKey();
        tripUpdateStream?.cancel();
        taxiViewModel.notifyListeners();
        break;
      case "failed":
        refreshSwipeBtnActionKey();
        if (withMap) taxiViewModel.taxiMapManagerService.clearMapData();
        taxiViewModel.newTaxiBookingService.startNewOrderListener();
        break;
      case "cancelled":
        refreshSwipeBtnActionKey();
        if (withMap) taxiViewModel.taxiMapManagerService.clearMapData();
        taxiViewModel.newTaxiBookingService.startNewOrderListener();
        break;
      default:
        if (withMap) taxiViewModel.taxiMapManagerService.clearMapData();
        // zoomToDropoffLocation();
        refreshSwipeBtnActionKey();
        tripUpdateStream?.cancel();
        taxiViewModel.notifyListeners();
        break;
    }
    //
    taxiViewModel.uiStream.add(tripUi);
  }

  //
  String get getNewStateStatus {
    //
    String status = "Arrived";
    switch ((taxiViewModel.onGoingOrderTrip?.status ?? "").toLowerCase()) {
      case "pending":
        status = "Arrived";
        break;
      case "preparing":
        status = "Arrived";
        break;
      case "ready":
        status = "Start Trip";
        break;
      case "enroute":
        status = "End Trip";
        break;
      default:
        break;
    }
    return status;
  }

  //
  String getNextOrderStateStatus() {
    //
    String status = "ready";
    switch ((taxiViewModel.onGoingOrderTrip?.status ?? "").toLowerCase()) {
      case "preparing":
        status = "ready";
        break;
      case "ready":
        status = "enroute";
        break;
      case "enroute":
        status = "delivered";
        break;
      default:
        break;
    }
    return status;
  }

  //
  void startHandlingOnGoingTrip() async {
    //
    // tripUpdateStream?.cancel();
    if (!(tripUpdateStream?.isPaused ?? true)) {
      return;
    }
    //set new on trip step
    tripUpdateStream = firebaseFireStore
        .collection("orders")
        .doc("${taxiViewModel.onGoingOrderTrip?.code}")
        .snapshots()
        .listen(
      (event) async {
        //update the rest onGoingTrip details
        if (event.data() != null && event.data()!.containsKey("status")) {
          //assing the status
          final orderStatus = event.data()!["status"];
          taxiViewModel.onGoingOrderTrip?.status = orderStatus;
          //
          print("Order Status Update ==> YEAHHH!!!!!!");
          taxiViewModel.notifyListeners();
          loadTripUIByOrderStatus();
        } else {
          //change status to cancelled if the data has been deleted but still exists locally
          taxiViewModel.onGoingOrderTrip?.status = "cancelled";
        }
      },
    );
    //start order details listening stream
  }

  void startHandlingCompletedTrip(tripOrder) {
    taxiViewModel.notifyListeners();
    if (tripOrder != null) {
      taxiViewModel.showUserRating(tripOrder);
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  GlobalKey swipeBtnActionKey = new GlobalKey();
  Future<bool> processOrderStatusUpdate() async {
    //
    taxiViewModel.setBusy(true);
    try {
      //
      final nextOrderStatus = getNextOrderStateStatus();
      //bookign code collection is required
      await TaxiTripBookingCodeService.handle(
        taxiViewModel,
        nextOrderStatus,
      );

      Position? currentLocationData;
      try {
        currentLocationData = await _determinePosition();
      } catch (e) {
        print("location error ==> $e");
      }

      //allow
      try {
        taxiViewModel.onGoingOrderTrip =
            await taxiViewModel.orderRequest.updateOrder(
          id: taxiViewModel.onGoingOrderTrip!.id,
          status: nextOrderStatus,
          location: LatLng(
            currentLocationData?.latitude ?? 0.00,
            currentLocationData?.longitude ?? 0.00,
          ),
        );
      } catch (error) {
        taxiViewModel.onGoingOrderTrip =
            await taxiViewModel.orderRequest.updateOrder(
          id: taxiViewModel.onGoingOrderTrip!.id,
          status: nextOrderStatus,
        );
      }

      //show on order completed processes
      if (nextOrderStatus == "delivered") {
        startHandlingCompletedTrip(taxiViewModel.onGoingOrderTrip);
      }
      swipeBtnActionKey = new GlobalKey();
      taxiViewModel.notifyListeners();
      taxiViewModel.setBusy(false);
      loadTripUIByOrderStatus();
      return true;
    } catch (error) {
      taxiViewModel.setBusy(false);
      taxiViewModel.toastError("$error");
      return false;
    }
  }

  String get getCancelStateStatus {
    //
    String status = "cancelled";
    return status;
  }

  Future<bool> cancelOrderStatusUpdate() async {
    taxiViewModel.setBusy(true);
    try {
      await TaxiTripBookingCodeService.handle(
          taxiViewModel, getCancelStateStatus);

      Position? currentLocationData = await _determinePosition();

      taxiViewModel.onGoingOrderTrip =
          await taxiViewModel.orderRequest.updateOrder(
        id: taxiViewModel.onGoingOrderTrip!.id,
        status: getCancelStateStatus,
        location: LatLng(
          currentLocationData?.latitude ?? 0.00,
          currentLocationData?.longitude ?? 0.00,
        ),
      );
      return true;
    } catch (error) {
      taxiViewModel
          .toastError("Không thể hủy chuyến đi. Vui lòng thử lại: $error");
      return false;
    } finally {
      taxiViewModel.setBusy(false);
      loadTripUIByOrderStatus();
    }
  }

  //
  void refreshSwipeBtnActionKey() {
    swipeBtnActionKey = new GlobalKey();
    taxiViewModel.onGoingOrderTrip = null;
    taxiViewModel.notifyListeners();
  }
}
