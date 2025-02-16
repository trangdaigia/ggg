import 'package:flutter/material.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/view_models/taxi.vm.dart';
import 'package:sod_user/view_models/taxi_new_order_summary.vm.dart';
import 'package:sod_user/views/pages/taxi/widgets/order_taxi.button.dart';
import 'package:sod_user/views/pages/taxi/widgets/step_two/new_taxi_order_driver_gender.selection_view.dart';
import 'package:sod_user/views/pages/taxi/widgets/step_two/new_taxi_order_payment_method.selection_view.dart';
import 'package:sod_user/views/pages/taxi/widgets/taxi_discount_section.dart';
import 'package:sod_user/views/pages/taxi/widgets/step_two/new_taxi_order_vehicle_type.list_view.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:sod_user/widgets/buttons/custom_text_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:measure_size/measure_size.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'dart:math';
import 'package:sod_user/constants/app_colors.dart';

class NewTaxiOrderSummaryCollapsed extends StatelessWidget {
  const NewTaxiOrderSummaryCollapsed(
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
        onViewModelReady: (taxiModel) async {
          return await taxiModel.calculateDistance(
              vm.pickupLocation!.latitude!,
              vm.pickupLocation!.longitude!,
              vm.dropoffLocation!.latitude!,
              vm.dropoffLocation!.longitude!);
        },
        builder: (context, taxiModel, child) {
          return MeasureSize(
            onChange: (size) {
              vm.updateGoogleMapPadding(height: size.height + Vx.dp40);
            },
            child: Stack(
              children: [
                VStack(
                  [
                    //
                    // HStack(
                    //   [
                    //     //previous
                    //     CustomTextButton(
                    //       padding: EdgeInsets.zero,
                    //       title: "Back".tr(),
                    //       onPressed: () => vm.closeOrderSummary(clear: false),
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
                    UiSpacer.vSpace(16),
                    Text(
                      '${'Select vehicle'.tr()}:',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    //UiSpacer.vSpace(10),

                    '${'Distance'.tr()}: ${(taxiModel.distance / 1000).toStringAsFixed(1)}km'
                        .text
                        .size(12)
                        .make(),

                    //vehicle types
                    UiSpacer.vSpace(2),
                    Container(
                      decoration: BoxDecoration(
                        color: context.theme.colorScheme.background,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: vm.vehicleTypes.isNotEmpty
                       ? TaxiVehicleTypeListView(vm: vm).pOnly(bottom: 20) // Danh sách xe đã load
                        : Center( // Nội dung thay thế khi danh sách trống
                            child: CircularProgressIndicator(), // Hiển thị trạng thái đang load
                          ),
                    height: 250, // Chiều cao tối thiểu đảm bảo bo tròn hiển thị
                    ),
                  ],
                ).px16(),
                //action group
                Container(
                  child: Padding(
                          padding: EdgeInsets.only(left: 16, right: 16),
                          child: VStack(
                            [
                              //UiSpacer.vSpace(16),
                              Visibility(
                                visible: vm.isBookDriverOrder(),
                                child: HStack([
                                  NewTaxiOrderDriverGenderSelectionView(
                                          vm: newTaxiOrderSummaryViewModel)
                                      .h(65)
                                      .expand(flex: 5),
                                ]).pOnly(bottom: 12),
                              ),
                              Container(
                                  height: 62,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color:
                                            Color.fromARGB(255, 195, 191, 191),
                                        width: 1.0, // Đảm bảo đây là số thực
                                      ),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.only(bottom: 5),
                                    child: HStack(
                                      [
                                        //selected payment method
                                        NewTaxiOrderPaymentMethodSelectionView(
                                          vm: newTaxiOrderSummaryViewModel, hasBorder: true,
                                        ).h(65).expand(flex: 5),
                                        //UiSpacer.hSpace(),
                                        //discount section
                                        GestureDetector(
                                          child: TaxiDiscountSection(vm,
                                              fullView: false),
                                          onTap: newTaxiOrderSummaryViewModel
                                              .openPanel,
                                        )
                                            .h(65)
                                            .box
                                            .roundedSM
                                            .color(const Color.fromARGB(255, 234, 245, 255))
                                            .px8
                                            .make()
                                            .expand(flex: 5),
                                      ],
                                    ),
                                  )),

                              UiSpacer.vSpace(10),
                              //OrderTaxiButton(vm),
                              vm.isShipOrder()
                                  ? Visibility(
                                      visible: true,
                                      child: CustomButton(
                                        title: "Next".tr(),
                                        onPressed: () {
                                          vm.setCurrentStep(3);
                                        },
                                      ).p8().safeArea(top: false),
                                    )
                                  : OrderTaxiButton(vm),
                              UiSpacer.vSpace(10),
                            ],
                          )
                              .box
                              .color(const Color.fromARGB(255, 234, 245, 255))
                              //.shadow5xl
                              .make())
                      .positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                  ),
                )
              ],
            )
                .box
                .color(const Color.fromARGB(255, 234, 245, 255))
                //.topRounded(value: 20)
                .outerShadowXl
                .make(),
          );
        });
  }
}
