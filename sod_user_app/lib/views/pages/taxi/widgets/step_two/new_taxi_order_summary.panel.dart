import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/view_models/taxi.vm.dart';
import 'package:sod_user/view_models/taxi_new_order_summary.vm.dart';
import 'package:sod_user/views/pages/taxi/widgets/order_taxi.button.dart';
import 'package:sod_user/views/pages/taxi/widgets/step_two/new_taxi_order_driver_gender.selection_view.dart';
import 'package:sod_user/views/pages/taxi/widgets/step_two/new_taxi_order_payment_method.selection_view.dart';
import 'package:sod_user/views/pages/taxi/widgets/step_two/new_taxi_order_vehicle_type.list_view.dart';
import 'package:sod_user/views/pages/taxi/widgets/taxi_discount_section.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:sod_user/widgets/buttons/custom_text_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:measure_size/measure_size.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class NewTaxiOrderSummaryPanel extends StatelessWidget {
  const NewTaxiOrderSummaryPanel(
    this.newTaxiOrderSummaryViewModel, {
    Key? key,
  }) : super(key: key);

  final NewTaxiOrderSummaryViewModel newTaxiOrderSummaryViewModel;

  @override
  Widget build(BuildContext context) {
    final TaxiViewModel vm = newTaxiOrderSummaryViewModel.taxiViewModel;
    return ViewModelBuilder<NewTaxiOrderSummaryViewModel>.reactive(
        disposeViewModel: false,
        viewModelBuilder: () => newTaxiOrderSummaryViewModel,
        onViewModelReady: (taxiModel) => taxiModel.calculateDistance(
              vm.pickupLocation!.latitude!,
              vm.pickupLocation!.longitude!,
              vm.dropoffLocation!.latitude!,
              vm.dropoffLocation!.longitude!,
            ),
        builder: (context, taxiModel, child) {
          return MeasureSize(
            onChange: (size) {
              vm.updateGoogleMapPadding(height: size.height + Vx.dp40);
            },
            child: VStack(
              [
                VStack(
                  [
                    //
                    // HStack(
                    //   [
                    //     //previous
                    //     CustomTextButton(
                    //       padding: EdgeInsets.zero,
                    //       title: "Back".tr(),
                    //       onPressed: newTaxiOrderSummaryViewModel.closePanel,
                    //     ).h(24),
                    //     UiSpacer.swipeIndicator().px12().expand(),
                    //     //cancel book
                    //     CustomTextButton(
                    //       padding: EdgeInsets.zero,
                    //       title: "Cancel".tr(),
                    //       titleColor: Colors.red,
                    //       onPressed: vm.closeOrderSummary,
                    //     ).h(24),
                    //   ],
                    // ),
                    Text('${'Select vehicle'.tr()}:',
                      style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                            ),
                      ),
                    //UiSpacer.verticalSpace(),

                    '${'Distance'.tr()}: ${(taxiModel.distance / 1000).toStringAsFixed(1)}km'
                        .text
                        .size(12)
                        .make(),

                    //vehicle types
                    
                    TaxiVehicleTypeListView(vm: vm, min: false).expand(),
                    UiSpacer.vSpace(),
                  ],
                ).safeArea().p20().expand(),
                VStack(
                  [
                    //driver gender selection
                    Visibility(
                        visible: vm.isBookDriverOrder(),
                        child: NewTaxiOrderDriverGenderSelectionView(
                                vm: newTaxiOrderSummaryViewModel)
                            .h(65)),
                    //discount section
                    TaxiDiscountSection(vm, fullView: true).box.make().py8(),
                    //selected payment method
                    NewTaxiOrderPaymentMethodSelectionView(
                      vm: newTaxiOrderSummaryViewModel,
                    ).h(50),
                    UiSpacer.vSpace(10),
                    vm.isShipOrder()
                        ? Visibility(
                            visible: vm.selectedVehicleType != null,
                            child: CustomButton(
                              title: "Next".tr(),
                              onPressed: () {
                                vm.setCurrentStep(3);
                              },
                            ).p8().safeArea(top: false),
                          )
                        : OrderTaxiButton(vm),
                  ],
                )
                    .safeArea(top: false)
                    .pSymmetric(h: 20, v: 12)
                    .box
                    .shadow2xl
                    .color(context.theme.colorScheme.background)
                    .make(),
              ],
            )
                .box
                .color(context.theme.colorScheme.background)
                .topRounded(value: 5)
                .make(),
          );
        });
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Đường kính Trái Đất (đơn vị: km)

    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a = pow(sin(dLat / 2), 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * pow(sin(dLon / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distance = earthRadius * c;
    return distance;
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }
}
