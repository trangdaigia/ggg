import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sod_user/driver_lib/constants/app_colors.dart';
import 'package:sod_user/driver_lib/constants/app_map_settings.dart';
import 'package:sod_user/driver_lib/constants/app_strings.dart';
import 'package:sod_user/driver_lib/models/delivery_address.dart';
import 'package:sod_user/driver_lib/view_models/taxi/taxi.vm.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supercharged/supercharged.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart' as vietMapGl;
import 'package:vietmap_gl_platform_interface/vietmap_gl_platform_interface.dart'
    as vietMapInterface;
import 'package:vietmap_flutter_plugin/vietmap_flutter_plugin.dart'
    as vietMapFlg;

class TaxiPolylinesService {
  TaxiViewModel taxiViewModel;
  TaxiPolylinesService(this.taxiViewModel);
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

  //plylines
  drawTripPolyLines() async {
    //vietmappin

    //setting up latlng
    pickupLocation = DeliveryAddress(
      latitude:
          taxiViewModel.onGoingOrderTrip!.taxiOrder!.pickupLatitude.toDouble(),
      longitude:
          taxiViewModel.onGoingOrderTrip!.taxiOrder!.pickupLongitude.toDouble(),
      address: taxiViewModel.onGoingOrderTrip!.taxiOrder!.pickupAddress,
    );
    //
    dropoffLocation = DeliveryAddress(
      latitude:
          taxiViewModel.onGoingOrderTrip!.taxiOrder!.dropoffLatitude.toDouble(),
      longitude: taxiViewModel.onGoingOrderTrip!.taxiOrder!.dropoffLongitude
          .toDouble(),
      address: taxiViewModel.onGoingOrderTrip!.taxiOrder!.dropoffAddress,
    );

    if (AppMapSettings.isUsingVietmap) {
      try {
        List<vietMapGl.LatLng> points = [];
        var routingResponse = await vietMapFlg.Vietmap.routing(
            vietMapFlg.VietMapRoutingParams(points: [
          vietMapFlg.LatLng(
              pickupLocation!.latitude!, pickupLocation!.longitude!),
          vietMapFlg.LatLng(
              dropoffLocation!.latitude!, dropoffLocation!.longitude!)
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

        List<vietMapFlg.LatLng> polylinePoints = [
          vietMapFlg.LatLng(
              pickupLocation!.latitude!, pickupLocation!.longitude!)
        ];
        polylinePoints.addAll(points.map((e) {
          return vietMapFlg.LatLng(e.latitude * 10, e.longitude * 10);
        }).toList());

        /// Vẽ đường đi lên bản đồ
        vietMapInterface.Line? line = await taxiViewModel
            .taxiMapManagerService.vietMapController
            ?.addPolyline(
          vietMapInterface.PolylineOptions(
              geometry: polylinePoints,
              polylineColor: AppColor.primaryColor,
              polylineWidth: 8.0,
              polylineOpacity: 0.6),
        );

        taxiViewModel.notifyListeners();
      } catch (error) {
        print("getPolyline error");
        print(error);
      }
    } else {
      // source pin
      taxiViewModel.taxiMapManagerService.clearMapMarkers();
      taxiViewModel.taxiMapManagerService.gMapMarkers.add(
        Marker(
          markerId: pickupMarkerId,
          position: LatLng(
            pickupLocation?.latitude ?? 0.00,
            pickupLocation?.longitude ?? 0.00,
          ),
          icon: taxiViewModel.taxiMapManagerService.sourceIcon!,
          anchor: Offset(0.5, 0.5),
        ),
      );
      // destination pin

      taxiViewModel.taxiMapManagerService.gMapMarkers.add(
        Marker(
          markerId: dropoffMarkerId,
          position: LatLng(
            dropoffLocation!.latitude!,
            dropoffLocation!.longitude!,
          ),
          icon: taxiViewModel.taxiMapManagerService.destinationIcon!,
          anchor: Offset(0.5, 0.5),
        ),
      );
      //load the ploylines
      PolylineResult polylineResult = await taxiViewModel
          .taxiMapManagerService.polylinePoints
          .getRouteBetweenCoordinates(
        AppStrings.googleMapApiKey,
        PointLatLng(pickupLocation!.latitude!, pickupLocation!.longitude!),
        PointLatLng(dropoffLocation!.latitude!, dropoffLocation!.longitude!),
      );
      //get the points from the result
      List<PointLatLng> result = polylineResult.points;
      //
      if (result.isNotEmpty) {
        //clear previous polyline points
        taxiViewModel.taxiMapManagerService.polylineCoordinates.clear();
        // loop through all PointLatLng points and convert them
        // to a list of LatLng, required by the Polyline
        result.forEach((PointLatLng point) {
          taxiViewModel.taxiMapManagerService.polylineCoordinates
              .add(LatLng(point.latitude, point.longitude));
        });
      }

      // with an id, an RGB color and the list of LatLng pairs
      Polyline polyline = Polyline(
        polylineId: PolylineId("poly"),
        color: AppColor.primaryColor,
        points: taxiViewModel.taxiMapManagerService.polylineCoordinates,
        width: 5,
      );
      //
      taxiViewModel.taxiMapManagerService.gMapPolylines = {};
      taxiViewModel.taxiMapManagerService.gMapPolylines.add(polyline);
      taxiViewModel.notifyListeners();
    }
  }

  drawPolyLinesToPickup() async {
    //setting up latlng
    if (AppMapSettings.isUsingVietmap) {
      pickupLocation = DeliveryAddress(
        latitude: taxiViewModel.taxiLocationService.driverPosition!.latitude,
        longitude: taxiViewModel.taxiLocationService.driverPosition!.longitude,
        address: taxiViewModel.onGoingOrderTrip!.taxiOrder!.pickupAddress,
      );
    } else {
      // Driver marker was null so listen driver location
      if (taxiViewModel.taxiLocationService.driverMarker == null) {
        await taxiViewModel.taxiLocationService
            .startListeningToDriverLocation();
      }
      //
      pickupLocation = DeliveryAddress(
        latitude:
            taxiViewModel.taxiLocationService.driverMarker!.position.latitude,
        longitude:
            taxiViewModel.taxiLocationService.driverMarker!.position.longitude,
        address: taxiViewModel.onGoingOrderTrip!.taxiOrder!.pickupAddress,
      );
    }
    //
    dropoffLocation = DeliveryAddress(
      latitude:
          taxiViewModel.onGoingOrderTrip!.taxiOrder!.pickupLatitude.toDouble(),
      longitude:
          taxiViewModel.onGoingOrderTrip!.taxiOrder!.pickupLongitude.toDouble(),
      address: taxiViewModel.onGoingOrderTrip!.taxiOrder!.pickupAddress,
    );

    if (AppMapSettings.isUsingVietmap) {
      try {
        List<vietMapGl.LatLng> points = [];
        var routingResponse = await vietMapFlg.Vietmap.routing(
            vietMapFlg.VietMapRoutingParams(points: [
          vietMapFlg.LatLng(
              pickupLocation!.latitude!, pickupLocation!.longitude!),
          vietMapFlg.LatLng(
              dropoffLocation!.latitude!, dropoffLocation!.longitude!)
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
        // vietMapInterface.Line? line = await taxiViewModel.taxiMapManagerService.vietMapController?.addPolyline(
        //   vietMapInterface.PolylineOptions(
        //       geometry: polylinePoints,
        //       polylineColor: AppColor.primaryColor,
        //       polylineWidth: 10.0,
        //       polylineOpacity: 0.6),
        // );

        taxiViewModel.notifyListeners();
      } catch (error) {
        print("getPolyline error");
        print(error);
      }
    } else {
      // source pin
      taxiViewModel.taxiMapManagerService.clearMapMarkers();
      taxiViewModel.taxiMapManagerService.gMapMarkers.add(
        Marker(
          markerId: pickupMarkerId,
          position: LatLng(
            pickupLocation!.latitude!,
            pickupLocation!.longitude!,
          ),
          icon: taxiViewModel.taxiMapManagerService.sourceIcon!,
          anchor: Offset(0.5, 0.5),
        ),
      );
      // destination pin

      taxiViewModel.taxiMapManagerService.gMapMarkers.add(
        Marker(
          markerId: dropoffMarkerId,
          position: LatLng(
            dropoffLocation!.latitude!,
            dropoffLocation!.longitude!,
          ),
          icon: taxiViewModel.taxiMapManagerService.destinationIcon!,
          anchor: Offset(0.5, 0.5),
        ),
      );
      //load the ploylines
      PolylineResult polylineResult = await taxiViewModel
          .taxiMapManagerService.polylinePoints
          .getRouteBetweenCoordinates(
        AppStrings.googleMapApiKey,
        PointLatLng(pickupLocation!.latitude!, pickupLocation!.longitude!),
        PointLatLng(dropoffLocation!.latitude!, dropoffLocation!.longitude!),
      );
      //get the points from the result
      List<PointLatLng> result = polylineResult.points;
      //
      if (result.isNotEmpty) {
        //clear previous polyline points
        taxiViewModel.taxiMapManagerService.polylineCoordinates.clear();
        // loop through all PointLatLng points and convert them
        // to a list of LatLng, required by the Polyline
        result.forEach((PointLatLng point) {
          taxiViewModel.taxiMapManagerService.polylineCoordinates
              .add(LatLng(point.latitude, point.longitude));
        });
      }

      // with an id, an RGB color and the list of LatLng pairs
      Polyline polyline = Polyline(
        polylineId: PolylineId("poly"),
        color: AppColor.primaryColor,
        points: taxiViewModel.taxiMapManagerService.polylineCoordinates,
        width: 5,
      );
      //
      taxiViewModel.taxiMapManagerService.gMapPolylines = {};
      taxiViewModel.taxiMapManagerService.gMapPolylines.add(polyline);
      taxiViewModel.notifyListeners();
    }
  }

  //
  Future<void> updateCameraLocation(
    LatLng source,
    LatLng destination,
    GoogleMapController? mapController,
  ) async {
    if (mapController == null) return;

    LatLngBounds bounds;

    if (source.latitude > destination.latitude &&
        source.longitude > destination.longitude) {
      bounds = LatLngBounds(southwest: destination, northeast: source);
    } else if (source.longitude > destination.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(source.latitude, destination.longitude),
          northeast: LatLng(destination.latitude, source.longitude));
    } else if (source.latitude > destination.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(destination.latitude, source.longitude),
          northeast: LatLng(source.latitude, destination.longitude));
    } else {
      bounds = LatLngBounds(southwest: source, northeast: destination);
    }

    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 70);

    return checkCameraLocation(cameraUpdate, mapController);
  }

  Future<void> checkCameraLocation(
    CameraUpdate cameraUpdate,
    GoogleMapController mapController,
  ) async {
    mapController.animateCamera(cameraUpdate);
    LatLngBounds l1 = await mapController.getVisibleRegion();
    LatLngBounds l2 = await mapController.getVisibleRegion();

    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90) {
      return checkCameraLocation(cameraUpdate, mapController);
    }
  }
}
