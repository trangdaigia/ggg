import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_images.dart';
import 'package:sod_user/constants/app_map_settings.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/models/delivery_address.dart';
import 'package:sod_user/services/geocoder.service.dart';
import 'package:sod_user/services/location.service.dart';
import 'package:sod_user/utils/map.utils.dart';
import 'package:sod_user/view_models/checkout_base.vm.dart';
import 'package:sod_user/views/pages/delivery_address/widgets/address_search.view.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart' as vietMapGl;
import 'package:vietmap_gl_platform_interface/vietmap_gl_platform_interface.dart'
    as vietMapInterface;
import 'package:vietmap_flutter_plugin/vietmap_flutter_plugin.dart'
    as vietMapFlg;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import 'dart:math' show pi, sin, cos, sqrt, atan2;
// import 'package:geocoder/geocoder.dart';

class TaxiGoogleMapViewModel extends CheckoutBaseViewModel {
//
  int currentOrderStep = 1;
  int currentAddressSelectionStep = 1;
  bool onTrip = false;
  bool ignoreMapInteraction = false;

//MAp related variables
  CameraPosition mapCameraPosition = CameraPosition(target: LatLng(0.00, 0.00));
  vietMapInterface.CameraPosition vietMapCameraPosition =
      vietMapInterface.CameraPosition(
          target: vietMapInterface.LatLng(0.00, 0.00));
  GoogleMapController? googleMapController;
  vietMapGl.VietmapController? vietMapController;
  EdgeInsets googleMapPadding = EdgeInsets.all(10);
  StreamSubscription? currentLocationListener;
  // this will hold the generated polylines
  Set<Polyline> gMapPolylines = {};
  // this will hold each polyline coordinate as Lat and Lng pairs
  List<LatLng> polylineCoordinates = [];
  Set<Marker> gMapMarkers = {};
  PolylinePoints polylinePoints = PolylinePoints();
// for my custom icons
  dynamic sourceIcon;
  dynamic destinationIcon;
  dynamic driverIcon;
//END MAP RELATED VARIABLES

//step 1
  TextEditingController placeSearchTEC = TextEditingController();
  TextEditingController pickupLocationTEC = TextEditingController();
  FocusNode pickupLocationFocusNode = FocusNode();
  DeliveryAddress? pickupLocation;
  TextEditingController dropoffLocationTEC = TextEditingController();
  FocusNode dropoffLocationFocusNode = FocusNode();
  DeliveryAddress? dropoffLocation;
  TextEditingController tmp = TextEditingController();
  vietMapGl.LatLng currentCoodinate = vietMapGl.LatLng(0.00, 0.00);

  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  //
  dispose() {
    super.dispose();
    currentLocationListener?.cancel();
    pickupLocationFocusNode.dispose();
    dropoffLocationFocusNode.dispose();
  }

  void setCurrentStep(int step) {
    currentOrderStep = step;
    onTrip = false;
    notifyListeners();
  }

  //MAP RELATED FUNCTIONS
  void updateGoogleMapPadding({required double height}) {
    googleMapPadding = EdgeInsets.only(bottom: height - 20);
    notifyListeners();
  }

  void onMapCreated(GoogleMapController controller) {
    googleMapController = controller;
    notifyListeners();
    setGoogleMapStyle();
    //start listening to user current location
    startUserLocationListener();
    setSourceAndDestinationIcons();
  }

  void onVietMapCreated(vietMapGl.VietmapController controller) {
    vietMapFlg.Vietmap.getInstance(AppStrings.vietMapMapApiKey);
    vietMapController = controller;
    //start listening to user current location
    startUserLocationListener();
    setSourceAndDestinationIcons();
    notifyListeners();
  }

  //
  void setGoogleMapStyle() async {
    String value = await DefaultAssetBundle.of(viewContext).loadString(
      'assets/json/google_map_style.json',
    );
    //
    googleMapController?.setMapStyle(value);
  }

  //resize icon
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
  ByteData data = await rootBundle.load(path);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
  ui.FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }
  

  //
  void setSourceAndDestinationIcons() async {
    if (AppMapSettings.isUsingVietmap) {
      sourceIcon = Container(
        child: await Image.asset(
          width: 30.0, 
          height: 30.0, 
          fit: BoxFit.cover,
          AppImages.pickupLocation,
        ),
      );
      destinationIcon = Container(
        child: await Image.asset(
          width: 30.0, 
          height: 30.0, 
          fit: BoxFit.cover,
          AppImages.dropoffLocation,
        ),
      );

      driverIcon = Container(
        child: await Image.asset(
          AppImages.driverCar,
        ),
      );
    } else {
      final Uint8List iconPickUpResized = await getBytesFromAsset(AppImages.pickupLocation, 100);
      // sourceIcon = await BitmapDescriptor.fromAssetImage(
      //   ImageConfiguration(devicePixelRatio: 1.5),
      //   AppImages.pickupLocation,
      // );
      sourceIcon = await BitmapDescriptor.fromBytes(iconPickUpResized);
      
       final Uint8List iconDropOffResized = await getBytesFromAsset(AppImages.dropoffLocation, 100);
      // destinationIcon = await BitmapDescriptor.fromAssetImage(
      //   ImageConfiguration(devicePixelRatio: 1.5),
      //   AppImages.dropoffLocation,
        
      // );
      destinationIcon = await BitmapDescriptor.fromBytes(iconDropOffResized);
      
      driverIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(
          devicePixelRatio: 2.5,
        ),
        AppImages.driverCar,
      );
    }
  }

  //
  void startUserLocationListener() async {
    //
    await LocationService.prepareLocationListener(viewContext);
    currentLocationListener =
        LocationService.currenctAddressSubject.listen((currentAddress) {
      //
      if (!onTrip) {
        if (AppMapSettings.isUsingVietmap) {
          currentCoodinate = vietMapGl.LatLng(
            currentAddress.coordinates?.latitude ?? 0.00,
            currentAddress.coordinates?.longitude ?? 0.00,
          );

          vietMapzoomToLocation(currentCoodinate, zoom: 16);

          notifyListeners();
        } else {
          zoomToLocation(
            LatLng(
              currentAddress.coordinates?.latitude ?? 0.00,
              currentAddress.coordinates?.longitude ?? 0.00,
            ),
          );
        }
      }
    });
  }

  //zoom to provided location
  void zoomToLocation(LatLng target, {double zoom = 16}) {
    googleMapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: target,
          zoom: zoom,
        ),
      ),
    );
    notifyListeners();
  }

  void vietMapzoomToLocation(vietMapGl.LatLng target, {double zoom = 16}) {
    vietMapController?.animateCamera(
      vietMapGl.CameraUpdate.newLatLngZoom(target, zoom = zoom),
    );
    notifyListeners();
  }

  openLocationSelector(int step, {bool showpicker = true}) async {
    //open address picker
    if (showpicker) {
      await openLocationPicker();
    }
    // currentAddressSelectionStep = step;
    //
    if (currentAddressSelectionStep == 1) {
      pickupLocation = checkout?.deliveryAddress;
      pickupLocationTEC.text = checkout?.deliveryAddress?.address ?? "";
    } else {
      dropoffLocation = checkout?.deliveryAddress;
      dropoffLocationTEC.text = checkout?.deliveryAddress?.address ?? "";
    }

    //
    notifyListeners();
  }

  //
  openLocationPicker() async {
    //
    deliveryAddress = DeliveryAddress();
    checkout?.deliveryAddress = null;
    //
    await showModalBottomSheet(
      context: viewContext,
      isScrollControlled: true,
      isDismissible: false,
      builder: (context) {
        return AddressSearchView(
          this,
          addressSelected: (dynamic prediction) async {
            if (prediction is Prediction) {
              deliveryAddress?.address = prediction.description;
              deliveryAddress?.latitude = prediction.lat?.toDoubleOrNull();
              deliveryAddress?.longitude = prediction.lng?.toDoubleOrNull();
              //
              checkout!.deliveryAddress = deliveryAddress;
              //
              setBusy(true);
              await getLocationCityName(deliveryAddress!);
              setBusy(false);
            } else if (prediction is Address) {
              deliveryAddress?.address = prediction.addressLine;
              deliveryAddress?.latitude = prediction.coordinates?.latitude;
              deliveryAddress?.longitude = prediction.coordinates?.longitude;
              deliveryAddress?.city = prediction.locality;
              deliveryAddress?.state = prediction.adminArea;
              deliveryAddress?.country = prediction.countryName;
              checkout!.deliveryAddress = deliveryAddress;
            }
          },
          selectOnMap: this.showDeliveryAddressPicker,
        );
      },
    );
  }

  //
  Future<DeliveryAddress> showDeliveryAddressPicker() async {
    //
    dynamic result = await newPlacePicker();

    if (result is PickResult) {
      PickResult locationResult = result;
      deliveryAddress = DeliveryAddress();
      deliveryAddress!.address = locationResult.formattedAddress;
      deliveryAddress!.latitude = locationResult.geometry?.location.lat;
      deliveryAddress!.longitude = locationResult.geometry?.location.lng;
      checkout!.deliveryAddress = deliveryAddress;

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
      openLocationSelector(currentAddressSelectionStep, showpicker: false);
    } else if (result is Address) {
      Address locationResult = result;
      deliveryAddress = DeliveryAddress();
      deliveryAddress?.address = locationResult.addressLine;
      deliveryAddress?.latitude = locationResult.coordinates?.latitude;
      deliveryAddress?.longitude = locationResult.coordinates?.longitude;
      deliveryAddress?.city = locationResult.locality;
      deliveryAddress?.state = locationResult.adminArea;
      deliveryAddress?.country = locationResult.countryName;
      checkout!.deliveryAddress = deliveryAddress;
      //
      openLocationSelector(currentAddressSelectionStep, showpicker: false);
    }
    //

    return deliveryAddress ?? DeliveryAddress();
  }

  //setupCurrentLocationAsPickuplocation()
  setupCurrentLocationAsPickuplocation() async {
    //get current location
    setBusy(true);
    Position currentLocation = await GeocoderService().determinePosition();
    //
    final address = await GeocoderService().findAddressesFromCoordinates(
      Coordinates(
        currentLocation.latitude,
        currentLocation.longitude,
      ),
    );
    //
    if (address.isNotEmpty) {
      pickupLocation = DeliveryAddress(
        name: address.first.featureName,
        address: address.first.addressLine,
        latitude: currentLocation.latitude,
        longitude: currentLocation.longitude,
      );
      pickupLocationTEC.text = pickupLocation?.address ?? "";
    }
    setBusy(false);
    notifyListeners();
  }

  //plylines
  drawTripPolyLines() async {
    //vietmapcheck
    if (pickupLocation == null || dropoffLocation == null) {
      return;
    }

    //
    if (pickupLocation!.latitude == null || pickupLocation!.longitude == null) {
      return;
    }
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
        vietMapInterface.Line? line = await vietMapController?.addPolyline(
          vietMapInterface.PolylineOptions(
              geometry: polylinePoints,
              polylineColor: AppColor.primaryColor,
              polylineWidth: 8.0,
              polylineOpacity: 0.6),
        );

        vietMapController!.animateCamera(vietMapGl.CameraUpdate.newLatLngBounds(
          MapUtils.targetBounds(
            LatLng(
              pickupLocation!.latitude!,
              pickupLocation!.longitude!,
            ),
            LatLng(
              dropoffLocation!.latitude!,
              dropoffLocation!.longitude!,
            ),
          ),
          top: 160,
          left: 160,
          right: 160,
          bottom: 280,
        ));

        notifyListeners();
      } catch (error) {
        print("getPolyline error");
        print(error);
      }
    } else {
      // source pin
      try {
        gMapMarkers = {};
        gMapMarkers.add(
          Marker(
            markerId: MarkerId('sourcePin'),
            position: LatLng(
              pickupLocation!.latitude!,
              pickupLocation!.longitude!,
            ),
            icon: sourceIcon!,
            anchor: Offset(0.5, 0.5),
          ),
        );

        // draw driver nearby marker
        await addDriverNearbyMarker();

        //
        if (dropoffLocation!.latitude == null ||
            dropoffLocation!.longitude == null) {
          return;
        }
        // destination pin
        gMapMarkers.add(
          Marker(
            markerId: MarkerId('destPin'),
            position: LatLng(
              dropoffLocation!.latitude!,
              dropoffLocation!.longitude!,
            ),
            icon: destinationIcon!,
            anchor: Offset(0.5, 0.5),
          ),
        );
        //load the ploylines
        PolylineResult polylineResult =
            await polylinePoints.getRouteBetweenCoordinates(
          AppStrings.googleMapApiKey,
          PointLatLng(pickupLocation!.latitude!, pickupLocation!.longitude!),
          PointLatLng(dropoffLocation!.latitude!, dropoffLocation!.longitude!),
        );
        //get the points from the result
        List<PointLatLng> result = polylineResult.points;
        //
        if (result.isNotEmpty) {
          // loop through all PointLatLng points and convert them
          // to a list of LatLng, required by the Polyline
          result.forEach((PointLatLng point) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          });
        }

        // with an id, an RGB color and the list of LatLng pairs
        Polyline polyline = Polyline(
          polylineId: PolylineId("poly"),
          color: AppColor.primaryColor,
          points: polylineCoordinates,
          width: 3,
        );
        //
        gMapPolylines = {};
        gMapPolylines.add(polyline);

        //
        //zoom to latbound
        final pickupLocationLatLng = LatLng(
          pickupLocation!.latitude!,
          pickupLocation!.longitude!,
        );
        final dropoffLocationLatLng = LatLng(
          dropoffLocation!.latitude!,
          dropoffLocation!.longitude!,
        );

        await updateCameraLocation(
          pickupLocationLatLng,
          dropoffLocationLatLng,
          googleMapController!,
        );
        //
        notifyListeners();
      } catch (error) {
        print("Lỗi gì đây???????????????????");
        print(error);
      }
    }
  }

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
    GoogleMapController? mapController,
  ) async {
    if (mapController == null) {
      return;
    }
    mapController.animateCamera(cameraUpdate);
    LatLngBounds l1 = await mapController.getVisibleRegion();
    LatLngBounds l2 = await mapController.getVisibleRegion();

    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90) {
      return checkCameraLocation(cameraUpdate, mapController);
    }
  }

  zoomToCurrentLocation() async {
    Position? currentLocation = await Geolocator.getLastKnownPosition();
    if (currentLocation == null) {
      currentLocation = await GeocoderService().determinePosition();
    }

    //
    double lat = currentLocation.latitude;
    double lng = currentLocation.longitude;
    zoomToLocation(LatLng(lat, lng));
  }

  //
  clearMapData() async {
    gMapMarkers.clear();
    polylineCoordinates.clear();
    gMapPolylines.clear();
    pickupLocationTEC.clear();
    dropoffLocationTEC.clear();
    //
    await setupCurrentLocationAsPickuplocation();
    notifyListeners();
  }

  Future<void> addDriverNearbyMarker() async {
    final currentLat = LocationService.cLat ?? 0;
    final currentLng = LocationService.cLng ?? 0;
    const R = 20; // bán kính tìm kiếm (km)
    const MAX = 20; // số lượng tài xế tìm kiếm

    firebaseFirestore
        .collection("drivers")
        .where('online', isEqualTo: 1)
        .get()
        .then((value) {
      var count = 0;
      for (var element in value.docs) {
        if (count > MAX) break;

        // Check if all required fields exist
        if (!element.data().containsKey('id') ||
            !element.data().containsKey('lat') ||
            !element.data().containsKey('long') ||
            !element.data().containsKey('rotation')) {
          continue;
        }

        // Safe field access
        String? id = element['id'];
        double? lat = element['lat']?.toDouble();
        double? lng = element['long']?.toDouble();
        double? rotation = element['rotation']?.toDouble();

        // Skip if any field is null
        if (id == null || lat == null || lng == null || rotation == null) {
          continue;
        }
        
        if (calculateDistance(currentLat, currentLng, lat, lng) <= R) {
          gMapMarkers.add(
            Marker(
              markerId: MarkerId(id),
              position: LatLng(lat, lng),
              icon: driverIcon!,
              rotation: rotation,
              infoWindow: InfoWindow(
                title: 'Driver',
                snippet: 'Driver is here',
              ),
            ),
          );
          count++;
        }
      }
    });
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
