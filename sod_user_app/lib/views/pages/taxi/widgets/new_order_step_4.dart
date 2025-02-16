import 'package:flutter/material.dart';
import 'package:sod_user/view_models/taxi.vm.dart';
import 'package:sod_user/view_models/taxi_new_ship_order_contact.vm.dart';
import 'package:sod_user/view_models/taxi_new_ship_order_infor.vm.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:sod_user/views/pages/taxi/widgets/step_fourth/new_taxi_ship_order_contact_form.dart';
import 'package:sod_user/views/pages/taxi/widgets/step_third/new_taxi_ship_order_infor_form.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

import 'step_two/new_taxi_order_summary.collapsed.dart';
import 'step_two/new_taxi_order_summary.panel.dart';

class NewTaxiShipOrderContactView extends StatelessWidget {
  const NewTaxiShipOrderContactView(this.vm, {Key? key}) : super(key: key);
  final TaxiViewModel vm;
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<NewTaxiShipOrderContactViewModel>.reactive(
        viewModelBuilder: () => NewTaxiShipOrderContactViewModel(context, vm),
        onViewModelReady: (vm) => WidgetsBinding.instance.addPostFrameCallback(
              (_) {
                vm.initialise();
              },
            ),
        builder: (context, taxiNewShipOrderContactViewModel, child) {
          return Visibility(
            visible: vm.currentStep(4),
            child: Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: NewTaxiShipOrderContactForm(taxiNewShipOrderContactViewModel)
            ),
          );
        });
  }
}
