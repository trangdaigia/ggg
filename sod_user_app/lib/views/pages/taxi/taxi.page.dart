import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_map_settings.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/models/vendor_type.dart';
import 'package:sod_user/utils/utils.dart';
import 'package:sod_user/view_models/taxi.vm.dart';
import 'package:sod_user/views/pages/taxi/widgets/new_order_step_1.dart';
import 'package:sod_user/views/pages/taxi/widgets/new_order_step_2.dart';
import 'package:sod_user/views/pages/taxi/widgets/new_order_step_3.dart';
import 'package:sod_user/views/pages/taxi/widgets/new_order_step_4.dart';
import 'package:sod_user/views/pages/taxi/widgets/taxi_rate_driver.view.dart';
import 'package:sod_user/views/pages/taxi/widgets/taxi_trip_ready.view.dart';
import 'package:sod_user/views/pages/taxi/widgets/trip_driver_search.dart';
import 'package:sod_user/views/pages/taxi/widgets/unsupported_taxi_location.view.dart';
import 'package:sod_user/views/pages/taxi/widgets/where_to_go/wheretogo_sliding.page.dart';
import 'package:sod_user/views/pages/taxi/widgets/where_to_go/where_to_go.page.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/widgets/buttons/custom_leading.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart' as vietMapGl;
import 'package:velocity_x/velocity_x.dart';

class TaxiPage extends StatefulWidget {
  TaxiPage(this.vendorType, this.isTaxiOrder, this.isShippingOrder, {Key? key})
      : super(key: key);

  final VendorType vendorType;
  final bool isTaxiOrder;
  final bool isShippingOrder;

  @override
  _TaxiPageState createState() => _TaxiPageState();
}

class _TaxiPageState extends State<TaxiPage> with WidgetsBindingObserver {
  //
  late TaxiViewModel taxiViewModel;

  @override
  void initState() {
    super.initState();
    taxiViewModel = TaxiViewModel(context, widget.vendorType);
  }

  //
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // if (state == AppLifecycleState. resumed) {
    // }
    if(!AppMapSettings.isUsingVietmap){
       taxiViewModel.setGoogleMapStyle();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<TaxiViewModel>.reactive(
      viewModelBuilder: () => taxiViewModel,
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        return BasePage(
          showAppBar: false,
          showLeadingAction: !AppStrings.isSingleVendorMode,
          elevation: 0,
          title: "${widget.vendorType.name}",
          appBarColor: context.theme.colorScheme.background,
          appBarItemColor: AppColor.primaryColor,
          body: Stack(
            children: [
              AppMapSettings.isUsingVietmap
              //viet map
              ? SafeArea(
                child: Stack(
                  children: [
                    vietMapGl.VietmapGL(
                      styleString: 'https://maps.vietmap.vn/api/maps/light/styles.json?apikey=${AppStrings.vietMapMapApiKey}',
                      initialCameraPosition: vm.vietMapCameraPosition,
                      onMapCreated: vm.onVietMapCreated,
                      trackCameraPosition: true,
                    ),
                    if(vm.vietMapController != null)
                    vietMapGl.MarkerLayer(
                      ignorePointer: true,
                      mapController: vm.vietMapController!,
                      markers: [
                        if(vm.pickupLocation!=null && vm.pickupLocation!.latitude!=null&&vm.pickupLocation!.longitude!=null)
                        vietMapGl.Marker(
                            child: Container(
                              child: vm.sourceIcon,
                            ),
                            latLng: vietMapGl.LatLng(vm.pickupLocation!.latitude!, vm.pickupLocation!.longitude!)
                        )
                        else vietMapGl.Marker(
                            child: vm.sourceIcon,
                            latLng: vm.currentCoodinate
                        ),
                        if(vm.dropoffLocation!=null && vm.dropoffLocation!.latitude!=null&&vm.dropoffLocation!.longitude!=null)
                        vietMapGl.Marker(
                            child: Container(
                              child: vm.destinationIcon,
                            ),
                            latLng: vietMapGl.LatLng(vm.dropoffLocation!.latitude!, vm.dropoffLocation!.longitude!)
                        ),
                        if(vm.driverPosition!=null)
                         vietMapGl.Marker(
                            child: Container(
                              child: vm.driverIcon,
                            ),
                            latLng: vietMapGl.LatLng(vm.driverPosition!.latitude, vm.dropoffLocation!.longitude!)
                        ),
                        
                      ]
                    )
                  ],
                ),
              )
              //google map
              : SafeArea(
                child: GoogleMap(
                  initialCameraPosition: vm.mapCameraPosition,
                  onMapCreated: vm.onMapCreated,
                  padding: vm.googleMapPadding,
                  zoomGesturesEnabled: true,
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                  markers: vm.gMapMarkers,
                  polylines: vm.gMapPolylines,
                ),
              ),

              //custom leading appbar
              Visibility(
                visible: !AppStrings.isSingleVendorMode,
                child: CustomLeading(
                  padding: 10,
                  size: 24,
                  color: AppColor.primaryColor,
                  bgColor: Utils.textColorByTheme(),
                ).safeArea().positioned(
                      top: 0,
                      left: !Utils.isArabic ? 20 : null,
                      right: Utils.isArabic ? 20 : null,
                    ),
              ),

              //show when location is not supported
              UnSupportedTaxiLocationView(vm),

              widget.isTaxiOrder
                  ? WhereToGoSlidingUpPanel(widget.vendorType, vm)
                  :
                  //new taxi order form - Step 1
                  NewTaxiOrderLocationEntryView(vm, widget.isShippingOrder),

              //new taxi order form - step 2
              NewTaxiOrderSummaryView(vm),

              //taxi ship order infor form - step 3 (ship order)
              NewTaxiShipOrderInforView(vm),

              //taxi ship order contact form - step 4 (ship order)
              NewTaxiShipOrderContactView(vm),

              //
              Visibility(
                visible: vm.currentStep(5),
                child: TripDriverSearch(vm),
              ),
              //
              Visibility(
                visible: vm.currentStep(6),
                child: TaxiTripReadyView(vm),
              ),
              //
              Visibility(
                visible: vm.currentStep(7),
                child: TaxiRateDriverView(vm),
              ),
            ],
          ),
        );
      },
    );
  }
}
