import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:jiffy/jiffy.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_images.dart';
import 'package:sod_user/constants/app_map_settings.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/constants/app_ui_settings.dart';
import 'package:sod_user/models/order.dart';
import 'package:sod_user/services/location.service.dart';
import 'package:sod_user/view_models/order_tracking.vm.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:sod_user/widgets/custom_image.view.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart' as vietMapGl;
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class OrderTrackingPage extends StatelessWidget {
  const OrderTrackingPage({
    required this.order,
    Key? key,
  }) : super(key: key);

  //
  final Order order;

  @override
  Widget build(BuildContext context) {
    //
    return ViewModelBuilder<OrderTrackingViewModel>.reactive(
      viewModelBuilder: () => OrderTrackingViewModel(context, order),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        return BasePage(
          title: "Order Tracking".tr(),
          showAppBar: true,
          showLeadingAction: true,
          isLoading: vm.isBusy,
          body: Stack(
            children: [
              //
              AppMapSettings.isUsingVietmap
                  ? Stack(
                      children: [
                        vietMapGl.VietmapGL(
                          styleString:
                              'https://maps.vietmap.vn/api/maps/light/styles.json?apikey=${AppStrings.vietMapMapApiKey}',
                          initialCameraPosition: vietMapGl.CameraPosition(
                            target: vietMapGl.LatLng(
                              LocationService
                                      .currenctAddress?.coordinates?.latitude ??
                                  0.00,
                              LocationService.currenctAddress?.coordinates
                                      ?.longitude ??
                                  0.00,
                            ),
                            zoom: 15,
                          ),
                          onMapCreated: vm.setVietMapController,
                          trackCameraPosition: true,
                        ),
                        if (vm.vietMapController != null)
                          vietMapGl.MarkerLayer(
                              ignorePointer: true,
                              mapController: vm.vietMapController!,
                              markers: [
                                vietMapGl.Marker(
                                    child: Container(
                                      child:
                                          Image.asset(AppImages.pickupLocation),
                                    ),
                                    latLng: vietMapGl.LatLng(
                                        vm.pickupLatLng!.latitude,
                                        vm.pickupLatLng!.longitude)),
                                vietMapGl.Marker(
                                    child: Container(
                                      child: Image.asset(
                                          AppImages.dropoffLocation),
                                    ),
                                    latLng: vietMapGl.LatLng(
                                        vm.destinationLatLng!.latitude,
                                        vm.destinationLatLng!.longitude)),
                                if (vm.driverLatLng != null)
                                  vietMapGl.Marker(
                                      child: Container(
                                        child: Image.asset(
                                          AppImages.deliveryBoy,
                                          height: 40,
                                          width: 40,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                      latLng: vietMapGl.LatLng(
                                          vm.destinationLatLng!.latitude,
                                          vm.destinationLatLng!.longitude)),
                              ])
                      ],
                    )
                  : GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          LocationService
                                  .currenctAddress?.coordinates?.latitude ??
                              0.00,
                          LocationService
                                  .currenctAddress?.coordinates?.longitude ??
                              0.00,
                        ),
                        zoom: 15,
                      ),
                      padding: EdgeInsets.only(bottom: Vx.dp64 * 2),
                      myLocationEnabled: true,
                      markers: vm.mapMarkers ?? Set<Marker>(),
                      polylines: Set<Polyline>.of(vm.polylines.values),
                      onMapCreated: vm.setMapController,
                    ),
              //Estimated Time of Arrival
              Visibility(
                visible: vm.d_eta != null,
                child: Positioned(
                  left: 0,
                  right: 0,
                  bottom: 90,
                  child: SafeArea(
                    child: HStack(
                      [
                        //
                        VStack(
                          [
                            //Estimated Time of Arrival
                            HStack(
                              [
                                "Estimated: ".text.xl.semiBold.make(),
                                "${Jiffy(vm.d_eta).format('MMM dd \| HH:mm')}"
                                    .text
                                    .light
                                    .lg
                                    .make(),
                              ],
                            )
                          ],
                        ).px12().expand(),
                      ],
                    )
                        .box
                        .color(context.theme.colorScheme.background)
                        .roundedSM
                        .shadowXl
                        .outerShadow3Xl
                        .make()
                        .wFull(context)
                        .h(Vx.dp32 * 1.3)
                        .p12(),
                  ),
                ),
              ),
              //call driver
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  child: HStack(
                    [
                      //driver profile
                      CustomImage(
                        imageUrl: order.driver!.user.photo,
                      )
                          .wh(Vx.dp56, Vx.dp56)
                          .box
                          .roundedFull
                          .shadowXs
                          .clip(Clip.antiAlias)
                          .make(),

                      //
                      VStack(
                        [
                          order.driver!.user.name.text.xl.semiBold.make(),
                          order.driver!.user.phone.text.make(),
                        ],
                      ).px12().expand(),

                      //call
                      Visibility(
                        visible: AppUISettings.canCallDriver,
                        child: CustomButton(
                          icon: FlutterIcons.phone_call_fea,
                          iconColor: Colors.white,
                          title: "",
                          color: AppColor.primaryColor,
                          shapeRadius: Vx.dp24,
                          onPressed: vm.callDriver,
                        ).wh(Vx.dp64, Vx.dp40).p12(),
                      ),
                    ],
                  )
                      .p12()
                      .box
                      .color(context.theme.colorScheme.background)
                      .roundedSM
                      .shadowXl
                      .outerShadow3Xl
                      .make()
                      .wFull(context)
                      .h(Vx.dp64 * 1.3)
                      .p12(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
