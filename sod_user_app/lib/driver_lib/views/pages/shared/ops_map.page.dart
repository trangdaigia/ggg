import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:sod_user/driver_lib/constants/app_map_settings.dart';
import 'package:sod_user/driver_lib/constants/app_strings.dart';
import 'package:sod_user/driver_lib/models/address.dart';
import 'package:sod_user/driver_lib/utils/ui_spacer.dart';
import 'package:sod_user/driver_lib/view_models/ops_map.vm.dart';
import 'package:sod_user/driver_lib/widgets/base.page.dart';
import 'package:sod_user/driver_lib/widgets/busy_indicator.dart';
import 'package:sod_user/driver_lib/widgets/buttons/custom_button.dart';
import 'package:sod_user/driver_lib/widgets/cards/custom.visibility.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:measure_size/measure_size.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart' as vietMapGl;
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class OPSMapPage extends StatelessWidget {
  const OPSMapPage({
    this.useCurrentLocation,
    this.region,
    this.initialPosition,
    this.initialZoom = 10,
    Key? key,
  }) : super(key: key);

  final bool? useCurrentLocation;
  final String? region;
  final LatLng? initialPosition;
  final double initialZoom;
  @override
  Widget build(BuildContext context) {
    return BasePage(
      body: ViewModelBuilder<OPSMapViewModel>.reactive(
        viewModelBuilder: () => OPSMapViewModel(context),
        onViewModelReady: (viewModel) {
          if (AppMapSettings.isUsingVietmap) {
            var latlong = vietMapGl.LatLng(0.00, 0.00);
            if (initialPosition != null)
              latlong = vietMapGl.LatLng(
                  initialPosition!.latitude, initialPosition!.longitude);
            viewModel.onVietMapCameraMove(latlong);
          } else {
            viewModel.mapCameraMove(
              CameraPosition(
                target: initialPosition ?? LatLng(0.00, 0.00),
                zoom: initialZoom,
              ),
            );
          }
        },
        builder: (ctx, vm, child) {
          return SafeArea(
            child: VStack(
              [
                HStack(
                  [
                    //close btn
                    Icon(
                      FlutterIcons.arrow_back_mdi,
                    ).p2().onInkTap(() {
                      Navigator.pop(context);
                    }),
                    UiSpacer.horizontalSpace(),
                    //auto complete
                    TypeAheadFormField<Address>(
                      keepSuggestionsOnLoading: false,
                      hideSuggestionsOnKeyboardHide: false,
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: vm.searchTEC,
                        decoration: InputDecoration(
                          hintText: 'Search address'.tr(),
                        ),
                      ),
                      minCharsForSuggestions: 3,
                      //0.9 seconds
                      debounceDuration: Duration(milliseconds: 900),
                      suggestionsCallback: (keyword) async {
                        return await vm.fetchPlaces(keyword);
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          title: "${suggestion.featureName}"
                              .text
                              .base
                              .semiBold
                              .make(),
                          subtitle: "${suggestion.addressLine}".text.sm.make(),
                        );
                      },

                      onSuggestionSelected: vm.addressSelected,
                    ).expand(),
                  ],
                ).px20().py4().scrollVertical().centered().wFull(context).h(70),

                //google map body
                Stack(
                  children: [
                    //
                    AppMapSettings.isUsingVietmap
                        ? Stack(
                            children: [
                              vietMapGl.VietmapGL(
                                  styleString:
                                      'https://maps.vietmap.vn/api/maps/light/styles.json?apikey=${AppStrings.vietMapMapApiKey}',
                                  initialCameraPosition:
                                      vm.vietMapCameraPosition,
                                  onMapCreated: vm.onVietMapCreated,
                                  trackCameraPosition: true,
                                  onCameraIdle: () {
                                    vm.busyVietmapCamPositionFlag
                                        ? null
                                        : vm.onVietMapCameraMove(vm
                                            .vietMapController!
                                            .cameraPosition!
                                            .target);
                                  }),
                              if (vm.vietMapController != null)
                                // vietMapGl.MarkerLayer(
                                //   ignorePointer: true,
                                //   mapController: vm.vietMapController!,
                                //   markers: [
                                //     vietMapGl.Marker(
                                //         width: 100,
                                //         height: 100,
                                //         child: Container(
                                //           child: Icon(Icons.location_pin, color: Colors.blueAccent, size: 36),
                                //         ),
                                //         latLng: vm.currentCoodinate
                                //     ),
                                //   ]
                                // )
                                vietMapGl.StaticMarkerLayer(
                                    ignorePointer: true,
                                    mapController: vm.vietMapController!,
                                    markers: [
                                      vietMapGl.StaticMarker(
                                          bearing: 0,
                                          width: 100,
                                          height: 100,
                                          child: Container(
                                            child: Icon(Icons.location_pin,
                                                color: Colors.blueAccent,
                                                size: 36),
                                          ),
                                          latLng: vm.currentCoodinate),
                                    ])
                            ],
                          )
                        : GoogleMap(
                            myLocationEnabled: useCurrentLocation ?? true,
                            myLocationButtonEnabled: useCurrentLocation ?? true,
                            initialCameraPosition: CameraPosition(
                              target: initialPosition ?? LatLng(0.00, 0.00),
                              zoom: initialZoom,
                            ),
                            padding: vm.googleMapPadding,
                            onMapCreated: vm.onMapCreated,
                            onCameraMove: vm.mapCameraMove,
                            markers: Set<Marker>.of(vm.gMarkers.values),
                          ),

                    //loading indicator
                    Positioned(
                      bottom: 30,
                      left: 30,
                      right: 30,
                      child: CustomVisibilty(
                        visible: vm.busy(vm.selectedAddress),
                        child: BusyIndicator().centered().p32(),
                      ),
                    ),
                    //selected address details
                    Positioned(
                      bottom: 30,
                      left: 30,
                      right: 30,
                      child: CustomVisibilty(
                        visible: vm.selectedAddress != null,
                        child: MeasureSize(
                          onChange: vm.updateMapPadding,
                          child: VStack(
                            [
                              //address full
                              "${vm.selectedAddress?.featureName}"
                                  .text
                                  .semiBold
                                  .center
                                  .xl
                                  .maxLines(3)
                                  .overflow(TextOverflow.ellipsis)
                                  .make(),
                              UiSpacer.verticalSpace(space: 5),
                              "${vm.selectedAddress?.addressLine}"
                                  .text
                                  .light
                                  .center
                                  .sm
                                  .maxLines(2)
                                  .overflow(TextOverflow.ellipsis)
                                  .make(),
                              UiSpacer.verticalSpace(),
                              //submit
                              CustomButton(
                                title: "Select".tr(),
                                onPressed: vm.submit,
                              ),
                            ],
                          )
                              .box
                              .shadow2xl
                              .color(context.theme.colorScheme.surface)
                              .p20
                              .make(),
                        ),
                      ),
                    ),
                  ],
                ).expand(),
              ],
            ),
          );
        },
      ),
    );
  }
}
