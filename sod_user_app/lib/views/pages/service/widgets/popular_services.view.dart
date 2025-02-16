import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/models/vendor_type.dart';
import 'package:sod_user/utils/utils.dart';
import 'package:sod_user/view_models/vendor/popular_services.vm.dart';
import 'package:sod_user/widgets/buttons/custom_outline_button.dart';
import 'package:sod_user/widgets/custom_masonry_grid_view.dart';
import 'package:sod_user/widgets/list_items/service.gridview_item.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class PopularServicesView extends StatefulWidget {
  const PopularServicesView(this.vendorType, {Key? key}) : super(key: key);

  final VendorType vendorType;

  @override
  _PopularServicesViewState createState() => _PopularServicesViewState();
}

class _PopularServicesViewState extends State<PopularServicesView> {
  late int _servicesLimit = 5;
  late int serviceNonDisplay = 0;
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PopularServicesViewModel>.reactive(
      viewModelBuilder: () => PopularServicesViewModel(
        context,
        widget.vendorType,
      ),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        //
        if (!vm.isBusy && vm.services.isEmpty) {
          return SizedBox.shrink();
        }

        // Lấy số lượng dịch vụ để hiển thị
        final displayedServices = vm.services.take(_servicesLimit).toList();
        print("Lenght of Service is ==> ${vm.services.length}");
        print("Lenght of displayedServices is ==> ${displayedServices.length}");
        print("Lenght of serviceNonDisplay is ==> $serviceNonDisplay");

        return VStack(
          [
            //
            ("Popular".tr() + " ${widget.vendorType.name}")
                .text
                .lg
                .medium
                .bold
                .make()
                .px12(),

            CustomMasonryGridView(
              isLoading: vm.isBusy,
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
              items: displayedServices.map((service) {
                return ServiceGridViewItem(
                  service: service,
                  onPressed: vm.serviceSelected,
                );
              }).toList(),
            ).p12(),

            // Only show the View More button when there is a service not displayed
            if (vm.services.length > displayedServices.length &&
                vm.services.length != 0)
              CustomOutlineButton(
                height: 24,
                child: "View More"
                    .tr()
                    .text
                    .medium
                    .sm
                    .color(Utils.textColorByTheme())
                    .makeCentered(),
                onPressed: () {
                  serviceNonDisplay =
                      vm.services.length - displayedServices.length;
                  setState(() {
                    // Increase the number of services displayed when clicking "View More"
                    _servicesLimit += serviceNonDisplay;
                  });
                },
              ).px20(),
          ],
        ).py12();
      },
    );
  }
}
