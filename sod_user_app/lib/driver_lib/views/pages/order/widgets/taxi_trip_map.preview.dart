import 'package:flutter/material.dart';
import 'package:sod_user/driver_lib/constants/app_images.dart';
import 'package:sod_user/driver_lib/constants/app_map_settings.dart';
import 'package:sod_user/driver_lib/constants/app_strings.dart';
import 'package:sod_user/driver_lib/models/order.dart';
import 'package:sod_user/driver_lib/utils/map.utils.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart' as vietMapGl;
import 'package:vietmap_gl_platform_interface/vietmap_gl_platform_interface.dart'
    as vietMapInterface;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TaxiTripMapPreview extends StatefulWidget {
  TaxiTripMapPreview(this.order, {Key? key}) : super(key: key);

  final Order order;
  @override
  State<TaxiTripMapPreview> createState() => _TaxiTripMapPreviewState();
}

class _TaxiTripMapPreviewState extends State<TaxiTripMapPreview> {
  //
  List<Marker> markers = [];
  dynamic sourceIcon;
  dynamic destinationIcon;
  vietMapGl.VietmapController? vietMapController;
  //
  @override
  Widget build(BuildContext context) {
    //vietmapcheck
    return Container(
      height: 200,
      width: double.infinity,
      child: AppMapSettings.isUsingVietmap
          ? Stack(children: [
              vietMapGl.VietmapGL(
                styleString:
                    'https://maps.vietmap.vn/api/maps/light/styles.json?apikey=${AppStrings.vietMapMapApiKey}',
                initialCameraPosition: vietMapInterface.CameraPosition(
                    target: vietMapInterface.LatLng(
                        widget.order.taxiOrder!.pickupLatLng.latitude,
                        widget.order.taxiOrder!.pickupLatLng.longitude)),
                onMapCreated: onVietMapCreated,
                trackCameraPosition: true,
              ),
              if (vietMapController != null)
                vietMapGl.MarkerLayer(
                    ignorePointer: true,
                    mapController: vietMapController!,
                    markers: [
                      vietMapGl.Marker(
                          child: Container(
                            child: sourceIcon,
                          ),
                          latLng: vietMapGl.LatLng(
                              widget.order.taxiOrder!.pickupLatLng.latitude,
                              widget.order.taxiOrder!.pickupLatLng.longitude)),
                      vietMapGl.Marker(
                          child: Container(
                            child: destinationIcon,
                          ),
                          latLng: vietMapGl.LatLng(
                              widget.order.taxiOrder!.dropoffLatLng.latitude,
                              widget.order.taxiOrder!.dropoffLatLng.longitude)),
                    ])
            ])
          : GoogleMap(
              zoomControlsEnabled: false,
              padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              markers: Set.of(markers),
              initialCameraPosition: CameraPosition(
                target: widget.order.taxiOrder!.pickupLatLng,
                zoom: 16,
              ),
              cameraTargetBounds: CameraTargetBounds(
                MapUtils.targetBounds(
                  widget.order.taxiOrder!.pickupLatLng,
                  widget.order.taxiOrder!.dropoffLatLng,
                ),
              ),
              onMapCreated: setLocMarkers,
            ),
    );
  }

  setLocMarkers(GoogleMapController gMapController) async {
    await setGoogleMapStyle(gMapController);
    markers = [];
    markers = await getLocMakers();
    //
    setState(() {
      markers = markers;
    });

    //zoom to bound
    gMapController.moveCamera(
      CameraUpdate.newLatLngBounds(
        MapUtils.targetBounds(
          widget.order.taxiOrder!.pickupLatLng,
          widget.order.taxiOrder!.dropoffLatLng,
        ),
        40,
      ),
    );
  }

  setGoogleMapStyle(gMapController) async {
    String value = await DefaultAssetBundle.of(context).loadString(
      'assets/json/google_map_style.json',
    );
    //
    gMapController?.setMapStyle(value);
  }

  //
  Future<List<Marker>> getLocMakers() async {
    BitmapDescriptor sourceIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      AppImages.pickupLocation,
    );
    //
    BitmapDescriptor destinationIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      AppImages.dropoffLocation,
    );
    //
    //
    Marker pickupLocMarker = Marker(
      markerId: MarkerId(widget.order.taxiOrder!.pickupLatitude),
      position: widget.order.taxiOrder!.pickupLatLng,
      icon: sourceIcon,
    );
    //
    Marker dropoffLocMarker = Marker(
      markerId: MarkerId(widget.order.taxiOrder!.id.toString()),
      position: widget.order.taxiOrder!.dropoffLatLng,
      icon: destinationIcon,
    );
    //
    return [pickupLocMarker, dropoffLocMarker];
  }

  void onVietMapCreated(vietMapGl.VietmapController controller) async {
    vietMapController = controller;
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

    // vietMapController!.animateCamera(
    //   vietMapGl.CameraUpdate.newLatLngZoom(
    //     vietMapGl.LatLng(
    //       widget.order.taxiOrder!.pickupLatLng.latitude,
    //       widget.order.taxiOrder!.pickupLatLng.longitude,
    //     ),
    //     11
    //   ),
    // );
    vietMapController!.animateCamera(vietMapGl.CameraUpdate.newLatLngBounds(
      MapUtils.targetBounds(
        widget.order.taxiOrder!.pickupLatLng,
        widget.order.taxiOrder!.dropoffLatLng,
      ),
      top: 40,
      left: 40,
      right: 40,
      bottom: 40,
    ));

    setState(() {});
  }
}
