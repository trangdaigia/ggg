import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sod_user/driver_lib/constants/app_images.dart';
import 'package:sod_user/driver_lib/constants/app_map_settings.dart';
import 'package:sod_user/driver_lib/utils/utils.dart';
import 'package:sod_user/driver_lib/view_models/taxi/taxi.vm.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:sod_user/services/auth.service.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart' as vietMapGl;
import 'package:vietmap_gl_platform_interface/vietmap_gl_platform_interface.dart'
    as vietMapInterface;
import 'package:vietmap_flutter_plugin/vietmap_flutter_plugin.dart'
    as vietMapFlg;
import 'package:velocity_x/velocity_x.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';

class TaxiMapManagerService {
  //vietmapcheck
  TaxiViewModel? taxiViewModel;
  GoogleMapController? googleMapController;
  vietMapGl.VietmapController? vietMapController;
  EdgeInsets googleMapPadding = EdgeInsets.only(top: kToolbarHeight);
  Set<Polyline> gMapPolylines = {};
  // this will hold each polyline coordinate as Lat and Lng pairs
  List<LatLng> polylineCoordinates = [];
  Set<Marker> gMapMarkers = {};
  MarkerId driverMarkerId = MarkerId("driverIcon");
  PolylinePoints polylinePoints = PolylinePoints();
// for my custom icons
  dynamic sourceIcon;
  dynamic destinationIcon;
  dynamic driverIcon;
  bool canShowMap = true;

  TaxiMapManagerService(this.taxiViewModel) {
    setSourceAndDestinationIcons();
  }

  onMapReady(GoogleMapController controller) {
    googleMapController = controller;
    setGoogleMapStyle();
  }

  void onVietMapReady(vietMapGl.VietmapController controller) {
    vietMapController = controller;
  }

  onMapCameraMoveStarted() {
    taxiViewModel?.taxiLocationService.pauseAutoZoomToLocation();
  }

  onMapCameraIdle() {
    taxiViewModel?.taxiLocationService.handleAutoZoomToLocation();
  }

  void setGoogleMapStyle() async {
    if (taxiViewModel == null) {
      return;
    }
    String value =
        await DefaultAssetBundle.of(taxiViewModel!.viewContext).loadString(
      'assets/json/google_map_style.json',
    );
    //
    googleMapController?.setMapStyle(value);
  }

  Future<dynamic> setSourceAndDestinationIcons() async {
    if (AppMapSettings.isUsingVietmap) {
      sourceIcon = Container(
        child: await Image.asset(
          AppImages.pickupLocation,
        ),
      );

      destinationIcon = Container(
        child: await Image.asset(
          AppImages.dropoffLocation,
        ),
      );

      driverIcon = Container(
        child: await Image.asset(
          AppImages.driverCar,
          height: 40,
          fit: BoxFit.contain,
        ),
      );
    } else {
      sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        AppImages.pickupLocation,
      );
      //
      destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        AppImages.dropoffLocation,
      );
      //

      final Uint8List markerIcond;
      // if (AuthServices.driverVehicle?.vehicleType?.photo == null) {
        markerIcond = await Utils().getBytesFromCanvas(
          ((taxiViewModel?.viewContext.percentWidth ?? 1) * 13).ceil(),
          ((taxiViewModel?.viewContext.percentWidth ?? 1) * 25).ceil(),
          AppImages.driverCar,
        );
      // } else {
      //   String photoUrl = AuthServices.driverVehicle!.vehicleType!.photo!;

      //   if (photoUrl.toLowerCase().endsWith(".svg")) {
      //     // Xử lý SVG
      //     markerIcond = await resizeSvgImage(
      //         photoUrl,
      //         taxiViewModel?.viewContext.percentWidth ?? 1,
      //         taxiViewModel?.viewContext.percentWidth ?? 1);
      //   } else {
      //     // Xử lý PNG
      //     markerIcond = await resizeImage(
      //         photoUrl,
      //         taxiViewModel?.viewContext.percentWidth ?? 1,
      //         taxiViewModel?.viewContext.percentWidth ?? 1);
      //   }
      // }
      driverIcon = BitmapDescriptor.fromBytes(markerIcond);
    }
  }

  Future<Uint8List> loadNetworkImage(String imageUrl) async {
    final http.Response response = await http.get(Uri.parse(imageUrl));

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception("Failed to load image from network");
    }
  }

  Future<Uint8List> resizeImage(
      String url, double percentWidth, double percentHeight) async {
    //  Tải hình ảnh từ URL
    final imageBytes = await loadNetworkImage(url);

    // Chuyển đổi byte thành ui.Image
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(imageBytes, (image) {
      completer.complete(image);
    });
    final ui.Image image = await completer.future;

    // Tính toán kích thước mới với tỷ lệ
    double width = (percentWidth * 20).ceil().toDouble();
    double height = (percentHeight * 40).ceil().toDouble();

    // Tính toán tỉ lệ
    double ratio = image.width / image.height;
    if (width / height > ratio) {
      width = height * ratio; // Điều chỉnh chiều rộng
    } else {
      height = width / ratio; // Điều chỉnh chiều cao
    }

    // Vẽ hình ảnh lên Canvas
    final recorder = ui.PictureRecorder();
    final canvas =
        Canvas(recorder, Rect.fromPoints(Offset(0, 0), Offset(width, height)));

    // Vẽ hình ảnh
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(0, 0, width, height),
      Paint(),
    );

    // đổi canvas thành Uint8List
    final ui.Picture picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());
    final ByteData? byteData =
        await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<Uint8List> resizeSvgImage(
      String imageUrl, double percentWidth, double percentHeight) async {
    final http.Response response = await http.get(Uri.parse(imageUrl));

    final pictureInfo =
        await vg.loadPicture(SvgStringLoader(response.body), null);

    int width = (percentWidth * 13).toInt(); // Adjust as needed
    int height = (percentHeight * 26).toInt(); // Adjust as needed
    final scaleFactor = min(
      width / pictureInfo.size.width,
      height / pictureInfo.size.height,
    );

    final recorder = ui.PictureRecorder();

    ui.Canvas(recorder)
      ..scale(scaleFactor)
      ..drawPicture(pictureInfo.picture);

    final rasterPicture = recorder.endRecording();

    final image = rasterPicture.toImageSync(width, height);
    final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!;

    return bytes.buffer.asUint8List();
  }

  //
  //
  zoomToCurrentLocation() async {
    // myLocationListener?.cancel();
    // if (await AppPermissionHandlerService().isLocationGranted()) {
    //   final currentPosition = await Geolocator.getCurrentPosition();
    //   if (currentPosition != null) {
    //     zoomToLocation(currentPosition.latitude, currentPosition.longitude);
    //   }
    // }
    // //
    // myLocationListener =
    //     LocationService().location.onLocationChanged.listen((locationData) {
    //   //actually zoom now
    //   zoomToLocation(locationData.latitude, locationData.longitude);
    // });
  }

  //
  zoomToLocation(double lat, double lng) {
    if (AppMapSettings.isUsingVietmap) {
      vietMapController?.animateCamera(
        vietMapGl.CameraUpdate.newLatLngZoom(vietMapGl.LatLng(lat, lng), 16),
      );
    } else {
      googleMapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(lat, lng),
            zoom: 16,
          ),
        ),
      );
    }
  }

  void updateGoogleMapPadding([double? height]) {
    googleMapPadding = EdgeInsets.only(
      top: googleMapPadding.top,
      bottom: height ?? googleMapPadding.bottom,
    );
    taxiViewModel?.notifyListeners();
  }

  clearMapData() {
    clearMapMarkers();
    polylineCoordinates.clear();
    gMapPolylines.clear();
    taxiViewModel?.uiStream.add(null);

    //vietmappin
    //clear vietmap
    taxiViewModel?.notifyListeners();
  }

  //
  clearMapMarkers({bool clearDriver = false}) {
    if (clearDriver) {
      gMapMarkers = {};
    } else {
      gMapMarkers.removeWhere((e) => e.markerId != driverMarkerId);
    }
    taxiViewModel?.notifyListeners();
  }

  removeMapMarker(MarkerId markerId) {
    gMapMarkers.removeWhere((e) => e.markerId == markerId);
    taxiViewModel?.notifyListeners();
  }
}
