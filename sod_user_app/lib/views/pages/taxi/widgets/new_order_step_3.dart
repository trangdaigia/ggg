import 'package:flutter/material.dart';
import 'package:sod_user/view_models/taxi.vm.dart';
import 'package:sod_user/view_models/taxi_new_ship_order_infor.vm.dart';
import 'package:sod_user/views/pages/taxi/widgets/step_third/new_taxi_ship_order_infor_form.dart';
import 'package:stacked/stacked.dart';

class NewTaxiShipOrderInforView extends StatelessWidget {
  const NewTaxiShipOrderInforView(this.vm, {Key? key}) : super(key: key);
  final TaxiViewModel vm;
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<NewTaxiShipOrderInforViewModel>.reactive(
        viewModelBuilder: () => NewTaxiShipOrderInforViewModel(context, vm),
        onViewModelReady: (vm) => WidgetsBinding.instance.addPostFrameCallback(
              (_) {
                vm.initialise();
              },
            ),
        builder: (context, taxiNewShipOrderInforViewModel, child) {
          return Visibility(
            visible: vm.currentStep(3),
            child: Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: NewTaxiShipOrderInforForm(taxiNewShipOrderInforViewModel)
            ),
          );
        });
  }
}
