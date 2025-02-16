import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_map_settings.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/models/car_rental.dart';
import 'package:sod_user/view_models/car_rental.view_model.dart';
import 'package:sod_user/view_models/taxi.vm.dart';
import 'package:sod_user/widgets/states/loading.shimmer.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart' as vietMapGl;
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

final YOUR_API_KEY = AppStrings.googleMapApiKey;

class GoogleMapPage extends StatefulWidget {
  GoogleMapPage({
    super.key,
    required this.data,
    required this.model,
    required this.deliveryToHome,
  });
  CarRental data;
  CarRentalViewModel model;
  bool deliveryToHome;
  @override
  State<GoogleMapPage> createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  Set<Polyline> gMapPolylines = {};
  late LatLng origin;
  late LatLng destination;
  CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(10.823099, 106.681937),
  );
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> markers = {};
  List<LatLng> polylineCoordinates = [];
  late TaxiViewModel taxiViewModel;
  late Polyline polyline;
//

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    origin = LatLng(double.parse(widget.data.latitude!),
        double.parse(widget.data.longitude!));
    destination = LatLng(widget.model.latitude!, widget.model.longitude!);
    _kInitialPosition = widget.deliveryToHome
        ? CameraPosition(
            target: LatLng(widget.model.latitude!, widget.model.longitude!),
            zoom: 13.0)
        : CameraPosition(
            target: LatLng(double.parse(widget.data.latitude!),
                double.parse(widget.data.longitude!)),
            zoom: 13.0);

    markers = {
      Marker(
        markerId: MarkerId('point1'),
        position: origin,
        infoWindow: InfoWindow(
          title: 'Vị trí xe',
          snippet: 'Điểm bắt đầu',
        ),
      ),
      Marker(
        markerId: MarkerId('point2'),
        position: destination,
        infoWindow: InfoWindow(
          title: 'Vị trí giao nhận xe',
          snippet: 'Điểm đến',
        ),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CarRentalViewModel>.reactive(
        disposeViewModel: false,
        viewModelBuilder: () => widget.model,
        onViewModelReady: (viewModel) async {
          await viewModel.getPolylines(origin, destination);
        },
        builder: (context, viewModel, child) {
          return Stack(
            children: [
              viewModel.isBusy
                  ? LoadingShimmer()
                  : widget.deliveryToHome
                      ? AppMapSettings.isUsingVietmap
                          ? Stack(children: [
                              vietMapGl.VietmapGL(
                                styleString:
                                    'https://maps.vietmap.vn/api/maps/light/styles.json?apikey=${AppStrings.vietMapMapApiKey}',
                                initialCameraPosition: vietMapGl.CameraPosition(
                                  target: vietMapGl.LatLng(
                                      _kInitialPosition.target.latitude,
                                      _kInitialPosition.target.longitude),
                                  zoom: 13,
                                ),
                                onMapCreated:
                                    (vietMapGl.VietmapController controller) {
                                  viewModel.vietMapController = controller;

                                  List<LatLng> polylinePoints = viewModel
                                      .gMapPolylines
                                      .expand((polyline) => polyline.points)
                                      .toList();
                                  vietMapGl.LatLngBounds bounds =
                                      vietMapGl.LatLngBounds(
                                    southwest: vietMapGl.LatLng(
                                      polylinePoints
                                          .map((point) => point.latitude)
                                          .reduce((min, value) =>
                                              min < value ? min : value),
                                      polylinePoints
                                          .map((point) => point.longitude)
                                          .reduce((min, value) =>
                                              min < value ? min : value),
                                    ),
                                    northeast: vietMapGl.LatLng(
                                      polylinePoints
                                          .map((point) => point.latitude)
                                          .reduce((max, value) =>
                                              max > value ? max : value),
                                      polylinePoints
                                          .map((point) => point.longitude)
                                          .reduce((max, value) =>
                                              max > value ? max : value),
                                    ),
                                  );

                                  viewModel.vietMapController!.animateCamera(
                                      vietMapGl.CameraUpdate.newLatLngBounds(
                                    bounds,
                                    top: 40,
                                    left: 40,
                                    right: 40,
                                    bottom: 40,
                                  ));
                                },
                                trackCameraPosition: true,
                              ),
                            ])
                          : GoogleMap(
                              mapType: MapType.normal,
                              initialCameraPosition: _kInitialPosition,
                              onMapCreated: (GoogleMapController controller) {
                                _controller.complete(controller);
                                List<LatLng> polylinePoints = viewModel
                                    .gMapPolylines
                                    .expand((polyline) => polyline.points)
                                    .toList();
                                // Tạo một LatLngBounds từ danh sách tọa độ
                                LatLngBounds bounds = LatLngBounds(
                                  southwest: LatLng(
                                    polylinePoints
                                        .map((point) => point.latitude)
                                        .reduce((min, value) =>
                                            min < value ? min : value),
                                    polylinePoints
                                        .map((point) => point.longitude)
                                        .reduce((min, value) =>
                                            min < value ? min : value),
                                  ),
                                  northeast: LatLng(
                                    polylinePoints
                                        .map((point) => point.latitude)
                                        .reduce((max, value) =>
                                            max > value ? max : value),
                                    polylinePoints
                                        .map((point) => point.longitude)
                                        .reduce((max, value) =>
                                            max > value ? max : value),
                                  ),
                                );
                                // Điều chỉnh phạm vi hiển thị của bản đồ để hiển thị đường đi
                                controller.animateCamera(
                                    CameraUpdate.newLatLngBounds(bounds, 50));
                              },
                              markers: markers,
                              polylines: viewModel.gMapPolylines,
                            )
                      : AppMapSettings.isUsingVietmap
                          ? Stack(children: [
                              vietMapGl.VietmapGL(
                                styleString:
                                    'https://maps.vietmap.vn/api/maps/light/styles.json?apikey=${AppStrings.vietMapMapApiKey}',
                                initialCameraPosition: vietMapGl.CameraPosition(
                                  target: vietMapGl.LatLng(
                                      _kInitialPosition.target.latitude,
                                      _kInitialPosition.target.longitude),
                                  zoom: 13,
                                ),
                                onMapCreated:
                                    (vietMapGl.VietmapController controller) {
                                  viewModel.vietMapController = controller;

                                  List<LatLng> polylinePoints = viewModel
                                      .gMapPolylines
                                      .expand((polyline) => polyline.points)
                                      .toList();
                                  vietMapGl.LatLngBounds bounds =
                                      vietMapGl.LatLngBounds(
                                    southwest: vietMapGl.LatLng(
                                      polylinePoints
                                          .map((point) => point.latitude)
                                          .reduce((min, value) =>
                                              min < value ? min : value),
                                      polylinePoints
                                          .map((point) => point.longitude)
                                          .reduce((min, value) =>
                                              min < value ? min : value),
                                    ),
                                    northeast: vietMapGl.LatLng(
                                      polylinePoints
                                          .map((point) => point.latitude)
                                          .reduce((max, value) =>
                                              max > value ? max : value),
                                      polylinePoints
                                          .map((point) => point.longitude)
                                          .reduce((max, value) =>
                                              max > value ? max : value),
                                    ),
                                  );

                                  viewModel.vietMapController!.animateCamera(
                                      vietMapGl.CameraUpdate.newLatLngBounds(
                                    bounds,
                                    top: 40,
                                    left: 40,
                                    right: 40,
                                    bottom: 40,
                                  ));
                                },
                                trackCameraPosition: true,
                              ),
                            ])
                          : GoogleMap(
                              mapType: MapType.normal,
                              initialCameraPosition: _kInitialPosition,
                              onMapCreated: (GoogleMapController controller) {
                                _controller.complete(controller);
                              },
                              circles: <Circle>{
                                Circle(
                                  center: widget.deliveryToHome
                                      ? LatLng(widget.model.latitude!,
                                          widget.model.longitude!)
                                      : LatLng(
                                          double.parse(widget.data.latitude!),
                                          double.parse(widget.data.longitude!)),
                                  radius: 1000,
                                  strokeColor: Colors.grey,
                                  strokeWidth: 2,
                                  fillColor: Colors.grey.withOpacity(0.5),
                                  circleId: CircleId(UniqueKey().toString()),
                                ),
                              },
                            ),
              Positioned(
                  child: Container(
                margin: EdgeInsets.all(10),
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.white,
                ),
                child: Icon(Icons.close, color: Colors.black),
              ).onInkTap(() {
                Navigator.pop(context);
              })),
            ],
          );
        });
  }
}
