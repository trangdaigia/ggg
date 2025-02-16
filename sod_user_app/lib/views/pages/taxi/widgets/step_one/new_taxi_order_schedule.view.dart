import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/utils/utils.dart';
import 'package:sod_user/view_models/taxi.vm.dart';
import 'package:sod_user/view_models/taxi_new_order_location_entry.vm.dart';
import 'package:sod_user/widgets/cards/custom.visibility.dart';
import 'package:jiffy/jiffy.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class NewTaxiOrderScheduleView extends StatelessWidget {
  const NewTaxiOrderScheduleView(
    this.newTaxiOrderLocationEntryViewModel, {
    Key? key,
  }) : super(key: key);

  final NewTaxiOrderLocationEntryViewModel newTaxiOrderLocationEntryViewModel;
  @override
  Widget build(BuildContext context) {
    //
    final TaxiViewModel vm = newTaxiOrderLocationEntryViewModel.taxiViewModel;
    //
    return CustomVisibilty(
      visible: AppStrings.canScheduleTaxiOrder,
      child: VStack(
        [
          //show schedule checkbox
          HStack(
            [
              "Schedule Order".tr().text.medium.lg.make().expand(),
              UiSpacer.hSpace(),
              //clear
              Visibility(
                visible: vm.checkout!.pickupDate != null,
                child: HStack(
                  [
                    Icon(
                      FlutterIcons.x_fea,
                      color: Colors.red,
                      size: 20,
                    ).onInkTap(newTaxiOrderLocationEntryViewModel
                        .clearScheduleSelection),
                    UiSpacer.hSpace(10),
                  ],
                ),
              ),

              ///selected date
              HStack(
                [
                  Icon(
                    FlutterIcons.calendar_ant,
                    size: 18,
                  ),
                  UiSpacer.hSpace(10),
                  (vm.checkout!.pickupDate != null
                          ? (!Utils.isArabic
                              ? Jiffy("${vm.checkout?.pickupDate} ${vm.checkout?.pickupTime}", 
                                      "yyyy-MM-dd HH:mm")
                                  .format("d MMM, y hh:mm a")
                              : "${vm.checkout?.pickupDate} ${vm.checkout?.pickupTime}")
                          : "Date".tr())
                      .text
                      .sm
                      .semiBold
                      .make(),
                ],
                crossAlignment: CrossAxisAlignment.center,
                alignment: MainAxisAlignment.spaceBetween,
              )
                  .box
                  .roundedSM
                  .padding(EdgeInsets.symmetric(vertical: 5, horizontal: 10))
                  .border(
                    color: AppColor.primaryColor,
                    width: 1,
                  )
                  .color(context.theme.colorScheme.background)
                  .shadowXs
                  .make(),
            ],
          ).onTap(newTaxiOrderLocationEntryViewModel.showSchedulePeriodPicker),
          UiSpacer.vSpace(10),
        ],
      ),
    );
  }
}
