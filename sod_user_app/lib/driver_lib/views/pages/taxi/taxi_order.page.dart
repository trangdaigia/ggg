import 'package:flutter/material.dart';
import 'package:sod_user/driver_lib/constants/app_colors.dart';
import 'package:sod_user/driver_lib/constants/app_map_settings.dart';
import 'package:sod_user/driver_lib/constants/app_strings.dart';
import 'package:sod_user/driver_lib/view_models/taxi/taxi.vm.dart';
import 'package:sod_user/driver_lib/views/pages/taxi/widgets/location_permission.view.dart';
import 'package:sod_user/driver_lib/views/pages/taxi/widgets/sos_button.dart';
import 'package:sod_user/driver_lib/views/pages/taxi/widgets/statuses/idle.view.dart';
import 'package:sod_user/driver_lib/widgets/base.page.dart';
import 'package:sod_user/driver_lib/widgets/busy_indicator.dart';
import 'package:sod_user/driver_lib/widgets/cards/custom.visibility.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart' as vietMapGl;
import 'package:vietmap_gl_platform_interface/vietmap_gl_platform_interface.dart'
    as vietMapInterface;
import 'package:velocity_x/velocity_x.dart';

class TaxiOrderPage extends StatefulWidget {
  const TaxiOrderPage({Key? key, required this.taxiViewModel})
      : super(key: key);

  final TaxiViewModel taxiViewModel;
  @override
  _TaxiOrderPageState createState() => _TaxiOrderPageState();
}

class _TaxiOrderPageState extends State<TaxiOrderPage>
    with AutomaticKeepAliveClientMixin<TaxiOrderPage>, WidgetsBindingObserver {
  @override
  bool get wantKeepAlive => true;

  //
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    widget.taxiViewModel.taxiMapManagerService.setGoogleMapStyle();
  }

  @override
  Widget build(BuildContext context) {
    //vietmapcheck
    super.build(context);
    return BasePage(
      body: ViewModelBuilder<TaxiViewModel>.reactive(
        viewModelBuilder: () => widget.taxiViewModel,
        onViewModelReady: (vm) => vm.initialise(),
        builder: (context, vm, child) {
          return Stack(
            children: [
              //google map
              CustomVisibilty(
                visible: vm.taxiMapManagerService.canShowMap,
                child: AppMapSettings.isUsingVietmap
                    ? Stack(children: [
                        vietMapGl.VietmapGL(
                          styleString:
                              'https://maps.vietmap.vn/api/maps/light/styles.json?apikey=${AppStrings.vietMapMapApiKey}',
                          initialCameraPosition:
                              vietMapInterface.CameraPosition(
                                  target: vietMapInterface.LatLng(0.00, 0.00)),
                          onMapCreated: vm.taxiMapManagerService.onVietMapReady,
                          trackCameraPosition: true,
                          onCameraIdle:
                              vm.taxiMapManagerService.onMapCameraIdle,
                        ),
                        if (vm.taxiMapManagerService.vietMapController != null)
                          vietMapGl.MarkerLayer(
                              ignorePointer: true,
                              mapController:
                                  vm.taxiMapManagerService.vietMapController!,
                              markers: [
                                if (vm.onGoingTaxiBookingService
                                            .pickupLocation !=
                                        null &&
                                    vm.onGoingTaxiBookingService.pickupLocation!
                                            .latitude !=
                                        null &&
                                    vm.onGoingTaxiBookingService.pickupLocation!
                                            .longitude !=
                                        null)
                                  vietMapGl.Marker(
                                    child: Container(
                                      child:
                                          vm.taxiMapManagerService.sourceIcon,
                                    ),
                                    latLng: vietMapGl.LatLng(
                                      vm.onGoingTaxiBookingService
                                          .pickupLocation!.latitude!,
                                      vm.onGoingTaxiBookingService
                                          .pickupLocation!.longitude!,
                                    ),
                                  ),
                                if (vm.onGoingTaxiBookingService
                                            .dropoffLocation !=
                                        null &&
                                    vm.onGoingTaxiBookingService
                                            .dropoffLocation!.latitude !=
                                        null &&
                                    vm.onGoingTaxiBookingService
                                            .dropoffLocation!.longitude !=
                                        null)
                                  vietMapGl.Marker(
                                    child: Container(
                                      child: vm.taxiMapManagerService
                                          .destinationIcon,
                                    ),
                                    latLng: vietMapGl.LatLng(
                                      vm.onGoingTaxiBookingService
                                          .dropoffLocation!.latitude!,
                                      vm.onGoingTaxiBookingService
                                          .dropoffLocation!.longitude!,
                                    ),
                                  ),
                                if (vm.taxiLocationService.driverPosition !=
                                        null &&
                                    (["pending", "preparing"].contains(
                                            vm.onGoingOrderTrip?.status) ||
                                        vm.onGoingOrderTrip == null))
                                  vietMapGl.Marker(
                                      child: Container(
                                        child:
                                            vm.taxiMapManagerService.driverIcon,
                                      ),
                                      latLng: vm
                                          .taxiLocationService.driverPosition!),
                              ])
                      ])
                    : GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(0.00, 0.00),
                        ),
                        myLocationButtonEnabled: true,
                        onMapCreated: vm.taxiMapManagerService.onMapReady,
                        onCameraIdle: vm.taxiMapManagerService.onMapCameraIdle,
                        onCameraMoveStarted:
                            vm.taxiMapManagerService.onMapCameraMoveStarted,
                        padding: vm.taxiMapManagerService.googleMapPadding,
                        markers: vm.taxiMapManagerService.gMapMarkers,
                        polylines: vm.taxiMapManagerService.gMapPolylines,
                      ),
              ),

              Positioned(
                top: 40,
                left: 16,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              //sos button
              SOSButton(),
              //
              StreamBuilder<Widget?>(
                stream: vm.uiStream,
                builder: (ctx, snapshot) {
                  if (!snapshot.hasData || snapshot.data == null) {
                    return IdleTaxiView(
                      taxiViewModel: vm,
                      taxiMapManagerService: vm.taxiMapManagerService,
                      driverIsOnline: vm.appService.driverIsOnline,
                      driverVehicles:
                          vm.vehicles.where((e) => e.isActive == 1).toList(),
                    );
                  }
                  return snapshot.data!;
                },
              ),
              //permission request
              CustomVisibilty(
                visible: !vm.taxiMapManagerService.canShowMap,
                child: LocationPermissionView(
                  onResult: (request) {
                    if (request) {
                      vm.taxiLocationService
                          .requestLocationPermissionForGoogleMap();
                    }
                  },
                ).centered(),
              ),

              //loading
              Visibility(
                visible: vm.isBusy,
                child: BusyIndicator(
                  color: AppColor.primaryColor,
                )
                    .wh(60, 60)
                    .box
                    .white
                    .rounded
                    .p32
                    .makeCentered()
                    .box
                    .color(Colors.black.withOpacity(0.3))
                    .make()
                    .wFull(context)
                    .hFull(context),
              ),
            ],
          );
        },
      ),
    );
  }
}
