import 'package:flutter/material.dart';
import 'package:sod_user/driver_lib/utils/ui_spacer.dart';
import 'package:sod_user/driver_lib/view_models/taxi/taxi.vm.dart';
import 'package:sod_user/driver_lib/widgets/buttons/route.button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:supercharged/supercharged.dart';
import 'package:velocity_x/velocity_x.dart';

class TaxiPickupView extends StatelessWidget {
  const TaxiPickupView(this.vm, {Key? key}) : super(key: key);

  final TaxiViewModel vm;

  @override
  Widget build(BuildContext context) {
    return HStack(
      [
        //
        VStack(
          [
            (vm.isShipOrder() ? "Pickup Address" : "Pick_customer_up_address")
                .tr()
                .text
                .hairLine
                .lg
                .make(),
            "${vm.onGoingOrderTrip?.taxiOrder?.pickupAddress}"
                .text
                .lg
                .semiBold
                .make(),
          ],
        ).expand(),
        UiSpacer.horizontalSpace(),
        RouteButton(
          null,
          lat: vm.onGoingOrderTrip!.taxiOrder!.pickupLatitude.toDouble(),
          lng: vm.onGoingOrderTrip!.taxiOrder!.pickupLongitude.toDouble(),
        ),
      ],
    );
  }
}
