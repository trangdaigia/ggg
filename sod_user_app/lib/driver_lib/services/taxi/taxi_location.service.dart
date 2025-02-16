import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sod_user/driver_lib/constants/app_map_settings.dart';
import 'package:sod_user/driver_lib/constants/app_strings.dart';
import 'package:sod_user/driver_lib/services/app_permission_handler.service.dart';
import 'package:sod_user/services/auth.service.dart';
import 'package:sod_user/driver_lib/services/location.service.dart';
import 'package:sod_user/driver_lib/services/toast.service.dart';
import 'package:sod_user/driver_lib/view_models/taxi/taxi.vm.dart';
import 'package:georange/georange.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart' as vietMapGl;
import 'package:supercharged/supercharged.dart';
import 'package:rxdart/rxdart.dart';

class TaxiLocationService {
  //
  TaxiViewModel? taxiViewModel;
  StreamSubscription? myLocationListener;
  BehaviorSubject<int> etaStream = BehaviorSubject<int>();
  Timer? _timer;
  Timer? _etaTimer;
  Marker? driverMarker;
  vietMapGl.LatLng? driverPosition;

  //
  TaxiLocationService(this.taxiViewModel) {
    //
    startLocationListener();
    LocationService().prepareLocationListener();
  }

  dispose() {
    myLocationListener?.cancel();
    _timer?.cancel();
    _etaTimer?.cancel();
  }

  //
  startLocationListener() async {
    if (await AppPermissionHandlerService().isLocationGranted()) {
      taxiViewModel?.taxiMapManagerService.canShowMap = true;
      taxiViewModel?.notifyListeners();
      startListeningToDriverLocation();
    }
  }

  //
  startListeningToDriverLocation() async {
    //
    // myLocationListener?.cancel();
    //
    myLocationListener = LocationService().currentLocationStream.listen(
      (event) {
        print(
            "Location stream event: Lat: ${event.latitude} - Lng: ${event.longitude}");
        //
        if (AppMapSettings.isUsingVietmap) {
          driverPosition = vietMapGl.LatLng(event.latitude, event.longitude);
        } else {
          if (driverMarker == null) {
            //new driver maker
            driverMarker = Marker(
              markerId: taxiViewModel!.taxiMapManagerService.driverMarkerId,
              position: LatLng(
                event.latitude,
                event.longitude,
              ),
              rotation: event.heading,
              icon: taxiViewModel!.taxiMapManagerService.driverIcon!,
              anchor: Offset(0.5, 0.5),
            );
            print(
                "[latitude: ${event.latitude} - longitude: ${event.latitude}]");
            //
            taxiViewModel!.taxiMapManagerService.gMapMarkers =
                taxiViewModel!.taxiMapManagerService.gMapMarkers
                    .replaceFirstWhere(
                      (marker) =>
                          marker.markerId ==
                          taxiViewModel!.taxiMapManagerService.driverMarkerId,
                      driverMarker!,
                    )
                    .toSet();
          } else {
            //update driver maker
            driverMarker = driverMarker?.copyWith(
              positionParam: LatLng(
                event.latitude,
                event.longitude,
              ),
              rotationParam: event.heading,
            );

            //
            taxiViewModel!.taxiMapManagerService.gMapMarkers.add(driverMarker!);
          }
        }

        //
        taxiViewModel?.notifyListeners();
        zoomToLocation();
      },
    );
  }

  zoomToLocation() async {
    //
    //vietmapcheck
    if (AppMapSettings.isUsingVietmap) {
      taxiViewModel!.taxiMapManagerService.vietMapController?.animateCamera(
        vietMapGl.CameraUpdate.newLatLngZoom(
            vietMapGl.LatLng((driverPosition?.latitude ?? 0.00) - 0.001,
                driverPosition?.longitude ?? 0.00),
            16),
      );
    } else {
      taxiViewModel!.taxiMapManagerService.googleMapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: driverMarker?.position ?? LatLng(0.00, 0.00),
            zoom: 16,
          ),
        ),
      );
    }

    //
    pauseAutoZoomToLocation();
  }

  pauseAutoZoomToLocation() async {
    _timer?.cancel();
  }

  handleAutoZoomToLocation() async {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      zoomToLocation();
    });
  }

  void requestLocationPermissionForGoogleMap() async {
    await AppPermissionHandlerService().handleLocationRequest();
    taxiViewModel!.taxiLocationService.startLocationListener();
  }

  //ETA section
  startETAListener(LatLng latLng) {
    _etaTimer?.cancel();
    _etaTimer = Timer.periodic(Duration(seconds: 10), (Timer timer) {
      calculatedETAToLocation(latLng);
    });
  }

  calculatedETAToLocation(LatLng latLng) async {
    //
    try {
      Point startPoint;
      if (AppMapSettings.isUsingVietmap) {
        startPoint = Point(
          latitude: driverPosition!.latitude,
          longitude: driverPosition!.longitude,
        );
      } else {
        startPoint = Point(
          latitude: driverMarker!.position.latitude,
          longitude: driverMarker!.position.longitude,
        );
      }
      print(
          "[latitude: ${driverMarker?.position.latitude} - longitude: ${driverMarker?.position.longitude}]");
      final endPoint = Point(
        latitude: latLng.latitude,
        longitude: latLng.longitude,
      );
      final distance = GeoRange().distance(startPoint, endPoint);
      double etaInHours = (distance /
          (AppStrings.env("taxi")["drivingSpeed"] ?? "50")
              .toString()
              .toDouble()!);
      final eta = (etaInHours * 60).ceil();
      etaStream.add(eta);
    } catch (err) {
      etaStream.add(-1);
      // ToastService.toastError(
      //   "Lỗi xác định tọa độ: [latitude: ${driverMarker?.position.latitude} - longitude: ${driverMarker?.position.longitude}]",
      // );
    }
  }
}
