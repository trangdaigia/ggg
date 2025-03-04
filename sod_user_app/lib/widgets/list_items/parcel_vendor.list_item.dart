import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/models/vendor.dart';
import 'package:sod_user/services/app.service.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/view_models/new_parcel.vm.dart';
import 'package:sod_user/views/pages/parcel/widgets/parcel_schedule.view.dart';
import 'package:sod_user/widgets/cards/custom.visibility.dart';
import 'package:sod_user/widgets/custom_image.view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class ParcelVendorListItem extends StatelessWidget {
  const ParcelVendorListItem(
    this.vendor, {
    this.selected = false,
    this.onPressed,
    required this.vm,
    Key? key,
  }) : super(key: key);

  final Vendor vendor;
  final bool selected;
  final Function(Vendor)? onPressed;
  final NewParcelViewModel vm;
  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        //
        HStack(
          [
            //image
            CustomImage(
              imageUrl: vendor.logo,
            ).wh(Vx.dp56, Vx.dp56).pOnly(
                  right: AppService.isDirectionRTL(context) ? Vx.dp0 : Vx.dp12,
                  left: AppService.isDirectionRTL(context) ? Vx.dp12 : Vx.dp0,
                ),

            VStack(
              [
                //name
                vendor.name.text.semiBold.make(),
                //description
                vendor.description.text.sm.make(),
              ],
            ).expand(),
          ],
          crossAlignment: CrossAxisAlignment.start,
          // alignment: MainAxisAlignment.start,
        ),
        //scheduleing
        CustomVisibilty(
          visible: selected,
          child: VStack(
            [
              //ParcelScheduleView
              Visibility(
                visible: vm.selectedVendor != null,
                child: ParcelScheduleView(vm),
              ),
              //SCHEDULE
              Visibility(
                visible: vm.selectedVendor != null &&
                    !vm.selectedVendor!.allowScheduleOrder,
                child: VStack(
                  [
                    UiSpacer.divider().py4(),
                    "DATE & TIME".tr().text.semiBold.base.make(),
                    "Vendor does not allow order scheduling. So you order will be processed as soon as you place them"
                        .tr()
                        .text
                        .color(context.textTheme.bodyLarge!.color)
                        .sm
                        .make(),
                  ],
                ),
              ),
            ],
          ).py12(),
        ),
      ],
    )
        .p12()
        .onInkTap(() {
          if (onPressed != null) {
            onPressed!(vendor);
          }
        })
        .box
        // .color(context.cardColor)
        .roundedSM
        .border(
          color: selected ? AppColor.primaryColor : Colors.grey.shade300,
          width: selected ? 2 : 1,
        )
        .make();
  }
}
