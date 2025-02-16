import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:sod_user/extensions/string.dart';
import 'package:sod_user/models/order.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/view_models/order_details.vm.dart';
import 'package:sod_user/views/pages/cart/widgets/amount_tile.dart';
import 'package:sod_user/views/pages/order/widgets/basic_taxi_trip_info.view.dart';
import 'package:sod_user/views/pages/order/widgets/order.bottomsheet.dart';
import 'package:sod_user/views/pages/order/widgets/order_payment_info.view.dart';
import 'package:sod_user/views/pages/order/widgets/order_driver_info.view.dart';
import 'package:sod_user/views/pages/order/widgets/taxi_order_trip_verification.view.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/widgets/busy_indicator.dart';
import 'package:sod_user/widgets/cards/order_summary.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

import 'widgets/taxi_trip_map.preview.dart';

class TaxiOrderDetailPage extends StatefulWidget {
  const TaxiOrderDetailPage({
    required this.order,
    Key? key,
  }) : super(key: key);

  //
  final Order order;

  @override
  _TaxiOrderDetailPageState createState() => _TaxiOrderDetailPageState();
}

class _TaxiOrderDetailPageState extends State<TaxiOrderDetailPage> {
  @override
  Widget build(BuildContext context) {
    //
    return ViewModelBuilder<OrderDetailsViewModel>.reactive(
      viewModelBuilder: () => OrderDetailsViewModel(context, widget.order),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        //
        String currencySymbol = vm.order.taxiOrder!.currencySymbol;

        //
        return BasePage(
          title: "Trip Details".tr(),
          elevation: 0,
          showAppBar: true,
          showLeadingAction: true,
          isLoading: vm.isBusy,
          body: VStack(
            [
              //taxi trip map preview
              TaxiTripMapPreview(vm.order),
              //basic info
              BasicTaxiTripInfoView(vm.order),
              UiSpacer.vSpace(),

              //payment status
              OrderPaymentInfoView(vm)
                  .wFull(context)
                  .box
                  .shadowXs
                  .color(context.theme.colorScheme.background)
                  .make(),
              //driver
              OrderDriverInfoView(
                vm.order,
                rateDriverAction: vm.rateDriver,
              ),
              //trip codes
              TaxiOrderTripVerificationView(vm.order),

              //order summary
              OrderSummary(
                subTotal: vm.order.subTotal!,
                discount: vm.order.discount ?? 0,
                driverTip: vm.order.tip ?? 0,
                total: vm.order.total!,
                mCurrencySymbol:
                    "${vm.order.taxiOrder!.currency != null ? vm.order.taxiOrder!.currency!.symbol : AppStrings.currencySymbol}",
                //
                customWidget: VStack(
                  [
                    AmountTile(
                      "Base Fare".tr(),
                      "${currencySymbol} ${vm.order.taxiOrder!.base_fare ?? 0}"
                          .currencyFormat(currencySymbol),
                    ).py2(),
                    AmountTile(
                      ("Trip Distance".tr() + " (Km)"),
                      ("${vm.order.taxiOrder!.trip_distance ?? 0} " +
                          "(${vm.order.taxiOrder!.distance_fare ?? 0}/Km)"),
                    ).py2(),
                    AmountTile(
                      "Trip Duration".tr(),
                      ("${vm.order.taxiOrder!.trip_time ?? 0} " +
                          "(${vm.order.taxiOrder!.time_fare ?? 0}/Minute)"),
                    ).py2(),
                    DottedLine(dashColor: context.textTheme.bodyLarge!.color!)
                        .py8(),
                    if (vm.order.taxiOrder != null &&
                        vm.order.taxiOrder!.type == "ship")
                      VStack([
                        "Ship package detail"
                            .tr()
                            .text
                            .semiBold
                            .xl
                            .make()
                            .pOnly(bottom: Vx.dp12),
                        if (vm.order.taxiOrder!.shipPackage != null &&
                            vm.order.taxiOrder!.shipPackage!.photo != null)
                          Image.network(
                            vm.order.taxiOrder!.shipPackage!.photo!,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return BusyIndicator().centered().expand();
                            },
                          ).h(200).pOnly(bottom: 12).wFull(context),
                        AmountTile(
                                "Ship package type".tr(),
                                vm.order.taxiOrder!.shipPackage!.shipPackageType
                                    .tr())
                            .py2(),
                        AmountTile(
                                "Floor / building number".tr(),
                                vm.order.taxiOrder!.shipPackage
                                        ?.floorNumberOrBuildingNumber ??
                                    "")
                            .py2(),
                        AmountTile(
                                "Contact name".tr(),
                                vm.order.taxiOrder!.shipPackage?.contactName ??
                                    "")
                            .py2(),
                        AmountTile(
                                "Contact number".tr(),
                                vm.order.taxiOrder!.shipPackage
                                        ?.contactNumber ??
                                    "")
                            .py2(),
                        AmountTile(
                                "Note for driver".tr(),
                                vm.order.taxiOrder!.shipPackage?.noteForDrier ??
                                    "")
                            .py2(),
                        DottedLine(
                                dashColor: context.textTheme.bodyLarge!.color!)
                            .py8()
                      ]),
                  ],
                ),
              )
                  .px20()
                  .py12()
                  .box
                  .shadowXs
                  .color(context.theme.colorScheme.background)
                  .make()
                  .pSymmetric(v: 20),
              UiSpacer.vSpace(),
            ],
          ).scrollVertical(),
          bottomSheet: vm.order.isOrderTracking ? null : OrderBottomSheet(vm),
        );
      },
    );
  }
}
