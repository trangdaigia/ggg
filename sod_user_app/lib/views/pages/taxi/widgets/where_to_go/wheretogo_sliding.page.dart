import 'package:flutter/material.dart';
import 'package:sod_user/models/vendor_type.dart';
import 'package:sod_user/view_models/taxi.vm.dart';
import 'package:sod_user/view_models/taxi_new_order_location_entry.vm.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:sod_user/views/pages/taxi/widgets/step_one/new_taxi_order_entry.panel.dart';
import 'package:sod_user/views/pages/taxi/widgets/where_to_go/where_to_go.page.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class WhereToGoSlidingUpPanel extends StatelessWidget {
  const WhereToGoSlidingUpPanel(this.vendor, this.vm, {Key? key})
      : super(key: key);
  final TaxiViewModel vm;
  final VendorType vendor;
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<NewTaxiOrderLocationEntryViewModel>.reactive(
      viewModelBuilder: () => NewTaxiOrderLocationEntryViewModel(context, vm),
      onViewModelReady: (vm) => WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          vm.initialise();
        },
      ),
      builder: (context, taxiNewOrderViewModel, child) {
        return Visibility(
          visible: vm.currentStep(1),
          child: Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SlidingUpPanel(
              color: Colors.transparent,
              panel: NewTaxiOrderEntryPanel(taxiNewOrderViewModel, false),
              collapsed: SavedLocationPage(vendor, taxiNewOrderViewModel),
              controller: taxiNewOrderViewModel.panelController,
              maxHeight: context.screenHeight,
              minHeight: context.screenHeight,
              onPanelClosed: taxiNewOrderViewModel.notifyListeners,
            ),
          ),
        );
      },
    );
  }
}
