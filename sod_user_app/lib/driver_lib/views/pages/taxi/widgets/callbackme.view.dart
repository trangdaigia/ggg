import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_user/driver_lib/utils/ui_spacer.dart';
import 'package:sod_user/driver_lib/view_models/taxi/taxi.vm.dart';
import 'package:sod_user/driver_lib/widgets/custom_text_form_field.dart';
import 'package:velocity_x/velocity_x.dart';

class CallbackmeView extends StatelessWidget {
  const CallbackmeView(this.vm, {Key? key}) : super(key: key);

  final TaxiViewModel vm;

  @override
  Widget build(BuildContext context) {
    if (vm.onGoingOrderTrip!.total == null) {
      return Container();
    }
    return HStack(
      [
        //
        CustomTextFormField(
          hintText: "Nhập giá trị sản phẩm",
          onChanged: (value) {
            vm.onGoingOrderTrip!.total = double.parse(value);
          },
          keyboardType: TextInputType.number,
        ).expand(),
        //
        UiSpacer.horizontalSpace(),
        //edit
        Icon(
          FlutterIcons.edit_2_fea,
          size: 32,
          color: Colors.white,
        ).p8().box.color(Colors.green).roundedFull.make().onInkTap(() {
          // vm.callBackMe();
        }),
      ],
    ).py12();
  }
}
