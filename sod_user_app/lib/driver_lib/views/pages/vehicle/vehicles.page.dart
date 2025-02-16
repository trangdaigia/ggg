import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_images.dart';
import 'package:sod_user/driver_lib/view_models/vehicles.vm.dart';
import 'package:sod_user/driver_lib/widgets/base.page.dart';
import 'package:sod_user/driver_lib/widgets/buttons/custom_button.dart';
import 'package:sod_user/driver_lib/widgets/list_items/vehicle.list_item.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/widgets/states/empty.state.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class VehiclesPage extends StatelessWidget {
  const VehiclesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<VehiclesViewModel>.reactive(
      viewModelBuilder: () => VehiclesViewModel(context),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        return BasePage(
          showAppBar: true,
          showLeadingAction: true,
          title: "Services".tr(),
          body: vm.isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async => vm.fetchVehicles(),
                        child: vm.vehicles.length < 1
                            ? EmptyState(
                                title: "No Vehicles".tr(),
                                description:
                                    "You have not added any vehicles yet".tr(),
                                imageUrl: AppImages.noVehicle,
                              ).centered()
                            : SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildVehicleList(
                                      vehicles: vm.verifiedVehicles,
                                      onSelect: vm.makeVehicleCurrent,
                                      onDisable: vm.disableVehicle,
                                    ),
                                    buildVehicleList(
                                      vehicles: vm.unverifiedVehicles,
                                      onSelect: vm.makeVehicleCurrent,
                                      onDisable: vm.disableVehicle,
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 5.0),
                      child: CustomButton(
                        title: "New Vehicle".tr(),
                        onPressed: vm.newVehicleCreate,
                      ),
                    ),
                  ],
                ).pOnly(top: 10),
        );
      },
    );
  }

  Widget buildVehicleList({
    required List vehicles,
    required Function onSelect,
    required Function onDisable,
  }) {
    if (vehicles.length == 0) return SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          vehicles.isEmpty
              ? SizedBox.shrink()
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: vehicles.length,
                  separatorBuilder: (context, index) =>
                      Divider(thickness: 0.5, color: Colors.grey[300]),
                  itemBuilder: (context, index) {
                    final vehicle = vehicles[index];
                    return VehicleListItem(
                      vehicle: vehicle,
                      onDisable: () => onDisable(vehicle),
                      onLongpress: () => onSelect(vehicle),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
