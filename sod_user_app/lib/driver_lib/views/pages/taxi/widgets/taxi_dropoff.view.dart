import 'package:flutter/material.dart';
import 'package:sod_user/driver_lib/utils/ui_spacer.dart';
import 'package:sod_user/driver_lib/view_models/taxi/taxi.vm.dart';
import 'package:sod_user/driver_lib/widgets/buttons/route.button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:supercharged/supercharged.dart';
import 'package:velocity_x/velocity_x.dart';

class TaxiDropoffView extends StatelessWidget {
  const TaxiDropoffView(this.vm, {Key? key}) : super(key: key);

  final TaxiViewModel vm;

  @override
  Widget build(BuildContext context) {
    return HStack(
      [
        //
        VStack(
          [
            (vm.isShipOrder() ? "Delivery address" : "Dropoff Address")
                .tr()
                .text
                .hairLine
                .lg
                .make(),
            "${vm.onGoingOrderTrip?.taxiOrder?.dropoffAddress}"
                .text
                .lg
                .semiBold
                .make(),
          ],
        ).expand(),
        UiSpacer.horizontalSpace(),
        RouteButton(
          null,
          lat: vm.onGoingOrderTrip!.taxiOrder!.dropoffLatitude.toDouble(),
          lng: vm.onGoingOrderTrip!.taxiOrder!.dropoffLongitude.toDouble(),
        ),
      ],
    );
  }
}
