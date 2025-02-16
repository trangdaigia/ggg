import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_images.dart';
import 'package:sod_user/constants/app_map_settings.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/models/distance_matrix_googlemap/distance_matrix_googlemap.dart';
import 'package:sod_user/models/distance_matrix_vietmap.dart';
import 'package:sod_user/models/order.dart';
import 'package:sod_user/requests/matrix_eta.request.dart';
import 'package:sod_user/view_models/base.view_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart' as vietMapGl;
import 'package:vietmap_flutter_plugin/vietmap_flutter_plugin.dart'
    as vietMapFlg;
import 'package:vietmap_gl_platform_interface/vietmap_gl_platform_interface.dart'
    as vietMapInterface;
import 'package:url_launcher/url_launcher_string.dart';

class OrderTrackingViewModel extends MyBaseViewModel {
  //
  Order order;
  vietMapGl.VietmapController? vietMapController;
  GoogleMapController? controller;
  Set<Marker>? mapMarkers;
  LatLng? pickupLatLng;
  LatLng? destinationLatLng;
  LatLng? driverLatLng;
  PolylinePoints polylinePoints = PolylinePoints();
  Map<PolylineId, Polyline> polylines = {};
  DistanceMatrixVietMap? distanceMatrixVietMap;
  DistanceMatrixGoogleMap? distanceMatrixGoogleMap;
  MatrixETARequest matrixETARequest = MatrixETARequest();
  DateTime? d_eta;

  //
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  StreamSubscription? driverLocationStream;

  //
  OrderTrackingViewModel(BuildContext context, this.order) {
    this.viewContext = context;
  }

  //
  void setMapController(GoogleMapController mController) {
    controller = mController;
    notifyListeners();

    //zoom map camera to bound
    zoomToLatLngBound();
  }

  void setVietMapController(vietMapGl.VietmapController controller) {
    vietMapController = controller;

    //zoom map camera
    vietMapZoomToLatLngBound();
    notifyListeners();
  }

  //
  initialise() async {
    pickupLatLng = LatLng(
        order.isPackageDelivery
            ? order.pickupLocation!.latitude!
            : double.parse(order.vendor!.latitude),
        order.isPackageDelivery
            ? order.pickupLocation!.longitude!
            : double.parse(order.vendor!.longitude));

    destinationLatLng = LatLng(
      order.isPackageDelivery
          ? order.dropoffLocation!.latitude!
          : order.deliveryAddress!.latitude!,
      order.isPackageDelivery
          ? order.dropoffLocation!.longitude!
          : order.deliveryAddress!.longitude!,
    );

    notifyListeners();

    vietMapFlg.Vietmap.getInstance(AppStrings.vietMapMapApiKey);

    //vendor location marker
    mapMarkers = new Set<Marker>();

    //pickup address
    final vendorIcon = await markerIcon(
      order.isPackageDelivery ? AppImages.addressPin : AppImages.vendor,
    );

    mapMarkers!.add(
      Marker(
        markerId: MarkerId("pickup"),
        position: pickupLatLng!,
        infoWindow: InfoWindow(
          title: order.isPackageDelivery
              ? order.pickupLocation?.name
              : order.vendor?.name,
        ),
        icon: vendorIcon,
      ),
    );

    //delivery address
    final deliveryAddressIcon = await markerIcon(AppImages.deliveryParcel);
    mapMarkers!.add(
      Marker(
        markerId: MarkerId("destination"),
        position: destinationLatLng!,
        infoWindow: InfoWindow(
          title: order.isPackageDelivery
              ? order.dropoffLocation?.name
              : order.deliveryAddress?.name,
        ),
        icon: deliveryAddressIcon,
      ),
    );

    //
    notifyListeners();
    if (AppMapSettings.isUsingVietmap) {
      vietMapZoomToLatLngBound();
      getETAVietMap();
    } else {
      zoomToLatLngBound();
      getETAGoogleMap();
    }
    getPolyline();
    listenToDriverLocation();
  }

  dispose() {
    super.dispose();
    driverLocationStream?.cancel();
  }

  //
  zoomToLatLngBound() {
    if (driverLatLng == null || destinationLatLng == null) {
      return;
    }
    LatLngBounds bound = boundsFromLatLngList(
      [driverLatLng!, destinationLatLng!],
    );

    //
    controller?.animateCamera(
      CameraUpdate.newLatLngBounds(bound, 80),
    );
  }

  vietMapZoomToLatLngBound() {
    if (driverLatLng == null || destinationLatLng == null) {
      return;
    }

    vietMapGl.LatLngBounds bound = boundsFromLatLngList(
      [driverLatLng!, destinationLatLng!],
    );

    vietMapController!.animateCamera(vietMapGl.CameraUpdate.newLatLngBounds(
      bound,
      top: 40,
      left: 40,
      right: 40,
      bottom: 40,
    ));

    notifyListeners();
  }

  //
  dynamic boundsFromLatLngList(List<dynamic> list) {
    assert(list.isNotEmpty);
    double? x0;
    double? x1, y0, y1;
    for (dynamic latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > (x1 ?? 0.00)) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > (y1 ?? 0.00)) y1 = latLng.longitude;
        if (latLng.longitude < (y0 ?? 0.00)) y0 = latLng.longitude;
      }
    }

    if (AppMapSettings.isUsingVietmap) {
      return vietMapGl.LatLngBounds(
          northeast: vietMapGl.LatLng(x1 ?? 0.00, y1 ?? 0.00),
          southwest: vietMapGl.LatLng(x0 ?? 0.00, y0 ?? 0.00));
    } else {
      return LatLngBounds(
          northeast: LatLng(x1 ?? 0.00, y1 ?? 0.00),
          southwest: LatLng(x0 ?? 0.00, y0 ?? 0.00));
    }
  }

  //
  void getPolyline() async {
    //vietmapcheck
    if (AppMapSettings.isUsingVietmap) {
      try {
        List<vietMapGl.LatLng> points = [];
        var routingResponse = await vietMapFlg.Vietmap.routing(
            vietMapFlg.VietMapRoutingParams(points: [
          vietMapFlg.LatLng(pickupLatLng!.latitude, pickupLatLng!.longitude),
          vietMapFlg.LatLng(
              destinationLatLng!.latitude, destinationLatLng!.longitude)
        ]));

        /// Xử lý kết quả trả về
        routingResponse.fold((vietMapFlg.Failure failure) {
          // Xử lý lỗi nếu có
        }, (vietMapFlg.VietMapRoutingModel success) {
          if (success.paths?.isNotEmpty == true &&
              success.paths![0].points?.isNotEmpty == true) {
            points = vietMapInterface.VietmapPolylineDecoder.decodePolyline(
                success.paths![0].points!);
          }
        });

        List<vietMapFlg.LatLng> polylinePoints = points.map((e) {
          return vietMapFlg.LatLng(e.latitude * 10, e.longitude * 10);
        }).toList();

        /// Vẽ đường đi lên bản đồ
        vietMapInterface.Line? line = await vietMapController?.addPolyline(
          vietMapInterface.PolylineOptions(
              geometry: polylinePoints,
              polylineColor: AppColor.primaryColor,
              polylineWidth: 10.0,
              polylineOpacity: 0.6),
        );

        notifyListeners();
      } catch (error) {
        print("getPolyline error");
        print(error);
      }
    } else {
      List<LatLng> polylineCoordinates = [];

      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        AppStrings.googleMapApiKey,
        PointLatLng(pickupLatLng!.latitude, pickupLatLng!.longitude),
        PointLatLng(destinationLatLng!.latitude, destinationLatLng!.longitude),
        travelMode: TravelMode.driving,
      );
      if (result.points.isNotEmpty) {
        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
      } else {
        print(result.errorMessage);
      }
      //
      addPolyLine(polylineCoordinates);
    }
  }

  void addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      color: AppColor.primaryColor,
      polylineId: id,
      points: polylineCoordinates,
      width: 3,
    );
    polylines[id] = polyline;
    notifyListeners();
  }

  //listen to drriver location
  void listenToDriverLocation() {
    //
    driverLocationStream = firebaseFirestore
        .collection("drivers")
        .doc("${order.driverId}")
        .snapshots()
        .listen((event) async {
      //
      var driverMarker = mapMarkers!.firstOrNullWhere(
        (e) => e.markerId.value.contains("driverLocation"),
      );

      //
      final driverInfo = event.data();
      driverLatLng = LatLng(
        driverInfo?["lat"] ?? 0.00,
        driverInfo?["long"] ?? 0.00,
      );

      //
      if (driverMarker == null) {
        //
        final driverLocationIcon = await markerIcon(AppImages.deliveryBoy);
        driverMarker = Marker(
          markerId: MarkerId("driverLocation"),
          position: driverLatLng!,
          infoWindow: InfoWindow.noText,
          icon: driverLocationIcon,
        );
      } else {
        //remove the old one
        mapMarkers!.remove(driverMarker);
        //
        driverMarker = driverMarker.copyWith(
          positionParam: driverLatLng,
        );
      }

      //adding to list
      mapMarkers!.add(driverMarker);
      //
      notifyListeners();
      if (AppMapSettings.isUsingVietmap) {
        vietMapZoomToLatLngBound();
      } else {
        zoomToLatLngBound();
      }
    });
  }

  //
  Future<BitmapDescriptor> markerIcon(String assetPath) async {
    return await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 1.1, size: Size(24, 24)),
      assetPath,
    );
  }

  void callDriver() {
    launchUrlString("tel:${order.driver?.user.phone}");
  }

  Future<void> calculateETA() async {
    try {
      double distance = await Geolocator.distanceBetween(
            pickupLatLng!.latitude,
            pickupLatLng!.longitude,
            destinationLatLng!.latitude,
            destinationLatLng!.longitude,
          ) /
          1000;
      final double etaHours = distance / 25;
      final int hours = etaHours.floor();
      final int minutes = ((etaHours - hours) * 60).round();

      // Tạo một DateTime hiện tại và cộng thêm giờ và phút
      DateTime now = DateTime.now();
      DateTime eta = now.add(Duration(hours: hours, minutes: minutes));

      print("ETA ==>  $distance");
      print("ETA ==> " + '${hours} giờ ${minutes} phút');
      print("ETA DateTime ==> $eta");
    } catch (e) {
      print("Error ETA ==> $e");
    }
  }

  Future<void> getETAVietMap() async {
    if (pickupLatLng == null || destinationLatLng == null) {
      return;
    }
    setBusy(true);
    try {
      distanceMatrixVietMap = await matrixETARequest.getMatrixETAVietMap(
        pickupLatLng: pickupLatLng!,
        destinationLatLng: destinationLatLng!,
      );
      final duration = distanceMatrixVietMap!.durations![0][0];
      final durationMinutes = (duration / 60).round();

      final updatedAt = order.updatedAt;
      d_eta = updatedAt.add(Duration(minutes: durationMinutes));
    } catch (error) {
      print("ETA Error ==> $error");
      setError(error);
    }
    setBusy(false);
  }

  Future<void> getETAGoogleMap() async {
    if (pickupLatLng == null || destinationLatLng == null) {
      return;
    }
    setBusy(true);
    try {
      distanceMatrixGoogleMap = await matrixETARequest.getMatrixETAGoogle(
        pickupLatLng: pickupLatLng!,
        destinationLatLng: destinationLatLng!,
      );
      final duration =
          distanceMatrixGoogleMap!.rows![0].elements[0].duration!.value;
      final durationMinutes = (duration! / 60).round();
      final updatedAt = order.updatedAt;
      d_eta = updatedAt.add(Duration(minutes: durationMinutes));
    } catch (error) {
      print("ETA Error ==> $error");
      setError(error);
    }
    setBusy(false);
  }
}
