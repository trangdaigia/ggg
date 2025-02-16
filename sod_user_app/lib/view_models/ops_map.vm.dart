import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_map_settings.dart';
import 'package:sod_user/services/geocoder.service.dart';
import 'package:sod_user/services/location.service.dart';
import 'package:sod_user/view_models/base.view_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart' as vietMapGl;
import 'package:vietmap_gl_platform_interface/vietmap_gl_platform_interface.dart'
    as vietMapInterface;

class OPSMapViewModel extends MyBaseViewModel {
  //
  OPSMapViewModel(BuildContext context) {
    this.viewContext = context;
  }

  Address? selectedAddress;
  GeocoderService geocoderService = GeocoderService();
  TextEditingController searchTEC = TextEditingController();
  EdgeInsets googleMapPadding = EdgeInsets.all(10);
  GoogleMapController? gMapController;
  vietMapGl.VietmapController? vietMapController;
  Timer? _debounce;
  Map<MarkerId, Marker> gMarkers = <MarkerId, Marker>{};
  Marker? centerMarker;
  MarkerId centerMarkerId = MarkerId('center_loc_marker');
  vietMapInterface.CameraPosition vietMapCameraPosition =
      vietMapInterface.CameraPosition(
          target: vietMapInterface.LatLng(
    LocationService.currenctAddress?.coordinates?.latitude ?? 0.00,
    LocationService.currenctAddress?.coordinates?.longitude ?? 0.00,
  ));
  vietMapGl.LatLng currentCoodinate = vietMapGl.LatLng(
    LocationService.currenctAddress?.coordinates?.latitude ?? 0.00,
    LocationService.currenctAddress?.coordinates?.longitude ?? 0.00,
  );
  Address? previousAddress;
  bool busyVietmapCamPositionFlag = true;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<List<Address>> fetchPlaces(String keyword) async {
    return await geocoderService.findAddressesFromQuery(keyword);
  }

  Future<Address> fetchPlaceDetails(Address address) async {
    return await geocoderService.fecthPlaceDetails(address);
  }

  onMapCreated(controller) {
    gMapController = controller;
    notifyListeners();
  }

  void onVietMapCreated(vietMapGl.VietmapController controller) {
    vietMapController = controller;
  }

  addressSelected(Address address) async {
    setBusyForObject(selectedAddress, true);
    selectedAddress = address;
    //fecth place details from google if its google map or vietmap
    if (address.gMapPlaceId != null) {
      selectedAddress = await geocoderService.fecthPlaceDetails(address);
    }

    //
    searchTEC.clear();
    if (address.coordinates != null || selectedAddress?.coordinates != null) {
      double lat = address.coordinates?.latitude ??
          selectedAddress?.coordinates?.latitude ??
          0.0;
      double lng = address.coordinates?.longitude ??
          selectedAddress?.coordinates?.longitude ??
          0.0;

      if (AppMapSettings.isUsingVietmap) {
        await vietMapController?.moveCamera(
            vietMapGl.CameraUpdate.newLatLngZoom(
                vietMapGl.LatLng(lat, lng), 16));
      } else {
        gMapController?.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: 16,
              target: LatLng(
                lat,
                lng,
              ),
            ),
          ),
        );
      }
    }
    setBusyForObject(selectedAddress, false);
  }

  updateMapPadding(Size size) {
    googleMapPadding = EdgeInsets.only(bottom: size.height + 10);
  }

  CameraPosition positionOld = CameraPosition(
    target: LatLng(0.00, 0.00),
    zoom: 10,
  );

  bool check = false;
  mapCameraMove(CameraPosition position) async {
    if (centerMarker == null) {
      centerMarker = Marker(
        markerId: centerMarkerId,
        position: position.target,
        draggable: true,
      );
    } else {
      centerMarker = centerMarker?.copyWith(
        positionParam: position.target,
      );
    }

    //
    gMarkers[centerMarkerId] = centerMarker!;
    notifyListeners();
    if (position != positionOld) {
      check = true;
      positionOld = position;
    }
    //
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () async {
      // do something with query
      if (check == true) {
        check = false;
        selectedAddress = null;
        setBusyForObject(selectedAddress, true);
        try {
          final address = (await geocoderService.findAddressesFromCoordinates(
            Coordinates(
              position.target.latitude,
              position.target.longitude,
            ),
          ))
              .first;

          addressSelected(address);
        } catch (error) {
          toastError("$error");
        }
        previousAddress = selectedAddress;
        setBusyForObject(selectedAddress, false);
      }
    });
  }

  vietMapGl.LatLng latlongOld = vietMapGl.LatLng(0.0, 0.0);
  void onVietMapCameraMove(vietMapGl.LatLng latlong) {
    currentCoodinate = latlong;
    notifyListeners();
    if (latlong != latlongOld) {
      check = true;
      latlongOld = latlong;
    }
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1600), () async {
      // do something with query
      if (check == true) {
        check = false;
        selectedAddress = null;
        setBusyForObject(selectedAddress, true);
        try {
          busyVietmapCamPositionFlag = true;
          notifyListeners();

          final address = (await geocoderService.findAddressesFromCoordinates(
            Coordinates(
              currentCoodinate.latitude,
              currentCoodinate.longitude,
            ),
          ))
              .first;

          addressSelected(address);

          busyVietmapCamPositionFlag = false;
          notifyListeners();
        } catch (error) {
          toastError("$error");
        }
        setBusyForObject(selectedAddress, false);
      }
    });
  }

  submit() {
    Navigator.pop(viewContext, selectedAddress);
  }
}
