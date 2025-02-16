import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/extensions/string.dart';
import 'package:sod_user/models/vehicle_type.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/view_models/taxi.vm.dart';
import 'package:sod_user/widgets/currency_hstack.dart';
import 'package:sod_user/widgets/custom_image.view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:timelines/timelines.dart';
import 'package:velocity_x/velocity_x.dart';

class HorizontalVehicleTypeListItem extends StatelessWidget {
  const HorizontalVehicleTypeListItem(
    this.vm,
    this.vehicleType, {
    Key? key,
  }) : super(key: key);
  final VehicleType vehicleType;
  final TaxiViewModel vm;
  @override
  Widget build(BuildContext context) {
    //
    final selected = vm.selectedVehicleType?.id == vehicleType.id;
    final currencySymbol = vehicleType.currency != null
        ? vehicleType.currency?.symbol
        : AppStrings.currencySymbol;
    //
    return Container(
      decoration: BoxDecoration(
        color: selected
            ? AppColor.primaryColor.withOpacity(0.05)
            : AppColor.primaryColor.withOpacity(0.01),
        border: Border.all(
          color: selected ? Colors.red : Colors.transparent,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: HStack(
        [
          //
          CustomImage(
            imageUrl: vehicleType.photo,
            width: 55,
            height: 40,
            boxFit: BoxFit.contain,
          ),
          VStack(
            [
              HStack(
                alignment: MainAxisAlignment.spaceBetween,
                [
                  "${vehicleType.name}".text.bold.maxLines(1).ellipsis.make(),
                  Spacer(),
                  VStack(
                    [
                      CurrencyHStack([
                        " $currencySymbol ".text.extraBold.make().pOnly(bottom: 5),
                        " ${vehicleType.total} "
                            .currencyValueFormat()
                            .text
                            .extraBold
                            .make()
                            .pOnly(bottom: 5),
                      ]),
                    ],
                  ),
                ],
              ),
              UiSpacer.vSpace(3),
              HStack(
                [
                  CurrencyHStack(
                    [
                      "km",
                      " ",
                      "$currencySymbol",
                      vehicleType.minFare.currencyValueFormat()
                    ],
                    textSize: 12,
                    textColor: Colors.grey.shade600,
                  ),
                  DotIndicator(size: 5, color: Colors.grey.shade600).px8(),
                  CurrencyHStack(
                    [
                      "base".tr(),
                      " ",
                      "$currencySymbol",
                      vehicleType.baseFare.currencyValueFormat()
                    ],
                    textSize: 12,
                    textColor: Colors.grey.shade600,
                  ),
                ],
              ),
            ],
          ).px16().expand(),
          //prices
        ],
        alignment: MainAxisAlignment.center,
        // crossAlignment: CrossAxisAlignment.center,
      )
          .box
          .py3
          // .px12
          // .color(selected
          //     ? AppColor.primaryColor.withOpacity(0.15)
          //     : AppColor.primaryColor.withOpacity(0.01))
          .roundedSM
          .make()
          .onTap(
        () {
          vm.vehicleListScrollController.animateTo(0.0,
              duration: Duration(milliseconds: 100), curve: Curves.linear);
          vm.changeSelectedVehicleType(vehicleType);
        },
      ),
    );
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
