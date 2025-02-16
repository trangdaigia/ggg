import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/view_models/new_parcel.vm.dart';
import 'package:sod_user/widgets/custom_grid_view.dart';
import 'package:sod_user/widgets/custom_list_view.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class ParcelScheduleView extends StatelessWidget {
  const ParcelScheduleView(this.vm, {Key? key}) : super(key: key);
  final NewParcelViewModel vm;
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible:
          vm.selectedVendor != null && (vm.selectedVendor!.allowScheduleOrder),
      child: VStack(
        [
          HStack(
            [
              //
              Checkbox(
                value: vm.isScheduled,
                onChanged: vm.toggleScheduledOrder,
              ),
              //
              VStack(
                [
                  "Schedule Order".tr().text.base.semiBold.make(),
                  "If you want your order to be delivered/prepared at scheduled date/time"
                      .tr()
                      .text
                      .sm
                      .make(),
                ],
              ).expand(),
            ],
            crossAlignment: CrossAxisAlignment.start,
          ).wFull(context).onInkTap(
                () => vm.toggleScheduledOrder(!vm.isScheduled),
              ),

          //delivery time slots
          Visibility(
            visible: vm.isScheduled,
            child: VStack(
              [
                //date slot
                UiSpacer.verticalSpace(),
                "Date slot".tr().text.lg.make(),
                CustomListView(
                  scrollDirection: Axis.horizontal,
                  dataSet: vm.selectedVendor!.deliverySlots,
                  itemBuilder: (context, index) {
                    final dateDeliverySlot =
                        vm.selectedVendor!.deliverySlots[index];

                    final formmatedDeliverySlot =
                        DateFormat("yyyy-MM-dd", "en").format(
                      dateDeliverySlot.date,
                    );
                    bool selected = (formmatedDeliverySlot ==
                        vm.packageCheckout.deliverySlotDate);
                    //
                    return Jiffy(dateDeliverySlot.date)
                        .format("EEEE dd MMM yyyy")
                        .text
                        .color(
                          selected ? Colors.white : null,
                        )
                        .makeCentered()
                        .px8()
                        .py4()
                        .box
                        .roundedSM
                        .border(color: AppColor.primaryColor)
                        .color(
                          selected ? AppColor.primaryColor : Colors.transparent,
                        )
                        .make()
                        .onInkTap(
                          () => vm.changeSelectedDeliveryDate(
                              formmatedDeliverySlot, index),
                        );
                  },
                ).h(Vx.dp32).py8(),
                //
                UiSpacer.verticalSpace(space: 10),
                "Time slot".tr().text.lg.make(),
                UiSpacer.verticalSpace(space: 10),
                CustomGridView(
                  // scrollDirection: Axis.horizontal,
                  noScrollPhysics: true,
                  // padding: EdgeInsets.symmetric(horizontal: 10),
                  dataSet: vm.availableTimeSlots,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 3,
                  crossAxisCount: 3,
                  itemBuilder: (context, index) {
                    //
                    final today = DateFormat("yyyy-MM-dd", "en").format(
                      DateTime.now(),
                    );
                    final availableTimeSlot = vm.availableTimeSlots[index];
                    final formmatedDeliveryTimeSlot =
                        DateFormat("HH:mm:ss", "en").format(
                      DateTime.parse("$today $availableTimeSlot"),
                    );

                    bool selected = formmatedDeliveryTimeSlot ==
                        vm.packageCheckout.deliverySlotTime;

                    //
                    return Jiffy("$today $availableTimeSlot")
                        .format("hh:mm a")
                        .text
                        .color(
                          selected ? Colors.white : null,
                        )
                        .makeCentered()
                        .box
                        .roundedSM
                        .border(color: AppColor.primaryColor)
                        .color(
                          selected ? AppColor.primaryColor : Colors.transparent,
                        )
                        .make()
                        .onInkTap(
                          () => vm.changeSelectedDeliveryTime(
                            formmatedDeliveryTimeSlot,
                          ),
                        );
                  },
                ),
                // CustomGridView(dataSet: dataSet, itemBuilder: itemBuilder),
              ],
            ),
          ),
        ],
      ).p12().box.roundedSM.border(color: Colors.grey.shade300).make().pOnly(),
    );
  }
}
