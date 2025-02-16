import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/services/alert.service.dart';
import 'package:sod_user/view_models/taxi.vm.dart';
import 'package:sod_user/widgets/busy_indicator.dart';
import 'package:sod_user/widgets/buttons/custom_text_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:measure_size/measure_size.dart';
import 'package:velocity_x/velocity_x.dart';

class TripDriverSearch extends StatefulWidget {
  const TripDriverSearch(this.vm, {Key? key}) : super(key: key);
  final TaxiViewModel vm;

  @override
  State<TripDriverSearch> createState() => _TripDriverSearchState();
}

class _TripDriverSearchState extends State<TripDriverSearch> {
  Timer? _timer;

  @override
  initState() {
    super.initState();

    // Kiểm tra xem có tài xế nào nhận chuyến trong 10 phút mỗi 10 giây
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      if (widget.vm.currentStep(5)) {
        if (widget.vm.onGoingOrderTrip != null &&
            widget.vm.onGoingOrderTrip!.status == "pending") {
          final now = DateTime.now();
          final tripTime = widget.vm.onGoingOrderTrip!.createdAt;

          if (now.difference(tripTime).inMinutes >= 10) {
            widget.vm.taxiRequest.cancelTrip(widget.vm.onGoingOrderTrip!.id);
            widget.vm.onGoingOrderTrip = null;
            widget.vm.setCurrentStep(1);
            timer.cancel();
            AlertService.warning(
              title: "Notifications".tr(),
              text: "The trip has been canceled due to no driver being found"
                  .tr(),
            );
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: Vx.dp20,
      left: Vx.dp20,
      right: Vx.dp20,
      child: MeasureSize(
        onChange: (size) {
          widget.vm.updateGoogleMapPadding(height: size.height);
        },
        child: VStack(
          [
            //cancel order button
            "Searching for a driver. Please wait...".tr().text.makeCentered(),
            //loading indicator
            BusyIndicator().centered().py12(),
            //only show if driver is yet to be assigned
            Visibility(
              visible: widget.vm.onGoingOrderTrip?.canCancelTaxi ?? false,
              child: CustomTextButton(
                title: "Cancel Booking".tr(),
                titleColor: AppColor.getStausColor("failed"),
                loading: widget.vm.busy(widget.vm.onGoingOrderTrip),
                onPressed: widget.vm.cancelTrip,
              ).centered(),
            ),
          ],
        )
            .p20()
            .box
            .color(context.theme.colorScheme.background)
            .roundedSM
            .outerShadow2Xl
            .make(),
      ),
    );
  }
}
