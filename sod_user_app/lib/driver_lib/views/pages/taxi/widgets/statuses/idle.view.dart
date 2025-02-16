import 'package:flutter/material.dart';
import 'package:sod_user/driver_lib/models/vehicle.dart';
import 'package:sod_user/driver_lib/services/taxi/taxi_google_map_manager.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:measure_size/measure_size.dart';
import 'package:sod_user/driver_lib/view_models/taxi/taxi.vm.dart';
import 'package:sod_user/driver_lib/widgets/list_items/vehicle.list_item.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../../../constants/app_colors.dart';

class IdleTaxiView extends StatelessWidget {
  const IdleTaxiView(
      {Key? key,
      required this.taxiMapManagerService,
      required this.driverIsOnline,
      required this.driverVehicles,
      required this.taxiViewModel})
      : super(key: key);

  final TaxiMapManagerService taxiMapManagerService;
  final bool driverIsOnline;
  final List<Vehicle> driverVehicles;
  final TaxiViewModel taxiViewModel;
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: MeasureSize(
        onChange: (size) {
          taxiMapManagerService.updateGoogleMapPadding(size.height + 10);
        },
        child: VStack(
          [
            //
            Visibility(
              visible: driverIsOnline,
              child: VStack(
                [
                  LinearProgressIndicator(
                    //Đổi màu loading
                    color: AppColor.cancelledColor,
                    minHeight: 4,
                  ).wFull(context),
                  "Searching for order"
                      .tr()
                      .text
                      .extraBold
                      .sm
                      .makeCentered()
                      .p8(),
                ],
              ),
            ),
            //Online/offline
            // OnlineStatusSwipeButton(taxiViewModel),
            //
            Visibility(
                visible: driverVehicles.isNotEmpty,
                child: SingleChildScrollView(
                  child: VStack(
                    [
                      ...driverVehicles.map((e) => VehicleListItem(
                            vehicle: e,
                            onLongpress: () {},
                            onDisable: () {},
                            canChangeStatus: false,
                          ))
                    ],
                  ).p20(),
                )),
          ],
        )
            .box
            .color(context.theme.colorScheme.background)
            .shadow2xl
            .outerShadow
            .make(),
      ),
    );
  }
}
