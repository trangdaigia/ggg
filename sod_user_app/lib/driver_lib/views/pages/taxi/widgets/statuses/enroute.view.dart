import 'package:flutter/material.dart';
import 'package:sod_user/driver_lib/utils/ui_spacer.dart';
import 'package:sod_user/driver_lib/view_models/taxi/taxi.vm.dart';
import 'package:sod_user/driver_lib/views/pages/taxi/widgets/taxi_amount.view.dart';
import 'package:sod_user/driver_lib/views/pages/taxi/widgets/taxi_contact.view.dart';
import 'package:sod_user/driver_lib/views/pages/taxi/widgets/taxi_customer.view.dart';
import 'package:sod_user/driver_lib/views/pages/taxi/widgets/taxi_dropoff.view.dart';
import 'package:sod_user/driver_lib/views/pages/taxi/widgets/taxi_eta.view.dart';
import 'package:sod_user/driver_lib/views/pages/taxi/widgets/taxi_pickup.view.dart';
import 'package:sod_user/driver_lib/views/pages/taxi/widgets/taxi_swipe.view.dart';
import 'package:measure_size/measure_size.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:velocity_x/velocity_x.dart';

class EnrouteTaxiView extends StatelessWidget {
  const EnrouteTaxiView(this.taxiViewModel, {Key? key}) : super(key: key);
  final panelHeight = 50;

  final TaxiViewModel taxiViewModel;
  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
    );

    //
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: MeasureSize(
        onChange: (size) {
          // taxiViewModel.taxiMapManagerService
          //     .updateGoogleMapPadding(size.height + 10);
          taxiViewModel.taxiMapManagerService
              .updateGoogleMapPadding(context.percentHeight * panelHeight);
        },
        child: SlidingUpPanel(
          borderRadius: borderRadius,
          minHeight: context.percentHeight * panelHeight,
          panelBuilder: (ScrollController sc) => VStack(
            [
              UiSpacer.vSpace(10),
              UiSpacer.slideIndicator(),
              TaxiETAView(
                taxiViewModel,
                taxiViewModel.onGoingOrderTrip!.taxiOrder!.dropoffLatLng,
              ).py12(),
              HStack(
                [
                  TaxiCustomerView(taxiViewModel.onGoingOrderTrip!.user)
                      .expand(),
                  TaxiAmountView(taxiViewModel.onGoingOrderTrip!),
                ],
              ),
              UiSpacer.vSpace(10),
              UiSpacer.divider(thickness: 3).py8(),
              TaxiDropoffView(taxiViewModel),
              UiSpacer.divider().py8(),
              TaxiActionSwipeView(taxiViewModel).py12(),
              UiSpacer.divider(thickness: 3).py8(),
              TaxiPickupView(taxiViewModel),
              UiSpacer.divider(thickness: 3).py8(),
              TaxiContactView(taxiViewModel),
              UiSpacer.divider().py8(),
              UiSpacer.vSpace(),
            ],
          )
              .p12()
              .scrollVertical()
              .box
              .color(context.theme.colorScheme.background)
              .shadow2xl
              .outerShadow
              .withRounded(value: borderRadius.topLeft.x)
              .make(),
        ),
      ),
    );
  }
}
