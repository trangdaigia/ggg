import 'package:flutter/material.dart';
import 'package:sod_user/models/vehicle_type.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/view_models/taxi.vm.dart';
import 'package:sod_user/widgets/custom_list_view.dart';
import 'package:sod_user/widgets/list_items/horizontal_vehicle_type.list_item.dart';
import 'package:velocity_x/velocity_x.dart';

class TaxiVehicleTypeListView extends StatelessWidget {
  const TaxiVehicleTypeListView({
    Key? key,
    this.min = false,
    required this.vm,
  }) : super(key: key);

  final TaxiViewModel vm;
  final bool min;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        List<VehicleType> mVehicleTypes = [];
        if (min) {
          if (vm.vehicleTypes.length > 3) {
            mVehicleTypes = vm.vehicleTypes.sublist(0, 3);
          } else {
            mVehicleTypes = vm.vehicleTypes;
          }
        } else {
          mVehicleTypes = vm.vehicleTypes;
        }
        return CustomListView(
          scrollController: vm.vehicleListScrollController,
          padding: EdgeInsets.zero,
          noScrollPhysics: false,
          dataSet: mVehicleTypes,
          isLoading: vm.busy(vm.vehicleTypes),
          itemBuilder: (context, index) {
            final vehicleType = mVehicleTypes[index];
            return HorizontalVehicleTypeListItem(vm, vehicleType);
          },
          separatorBuilder: (ctx, index) => UiSpacer.emptySpace(),
        ).h(250);
      },
    );
  }
}
