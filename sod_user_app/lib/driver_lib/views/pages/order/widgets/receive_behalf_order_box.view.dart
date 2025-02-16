import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sod_user/driver_lib/utils/ui_spacer.dart';
import 'package:sod_user/driver_lib/view_models/order_details.vm.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class ReceiveBehalfOrderBoxView extends StatelessWidget {
  const ReceiveBehalfOrderBoxView(this.vm, {Key? key}) : super(key: key);

  final OrderDetailsViewModel vm;
  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        VStack(
          [
            "Box details".tr().text.xl.semiBold.make(),
            //area address
            HStack(
              [
                //
                Icon(Icons.area_chart, size: 15),
                UiSpacer.smHorizontalSpace(),
                //
                "${vm.order.receiveBehalfOrder!.box!.building!.area!.name}"
                    .text
                    .make()
                    .expand(),
              ],
              crossAlignment: CrossAxisAlignment.start,
            ).py12(),
            //building & box address
            HStack(
              [
                //
                Icon(CupertinoIcons.building_2_fill, size: 15),
                UiSpacer.smHorizontalSpace(),
                //
                VStack(
                  [
                    "${vm.order.receiveBehalfOrder!.box!.building!.address}"
                        .text
                        .make(),
                    "${vm.order.receiveBehalfOrder!.box!.name}"
                        .text
                        .color(Vx.gray400)
                        .sm
                        .light
                        .make(),
                  ],
                ).expand(),
              ],
              crossAlignment: CrossAxisAlignment.start,
            ),
          ],
        ),
      ],
    );
  }
}
