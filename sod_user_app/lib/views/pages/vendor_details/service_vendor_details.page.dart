import 'package:flutter/material.dart';
import 'package:sod_user/models/vendor.dart';
import 'package:sod_user/view_models/service_vendor_details.vm.dart';
import 'package:sod_user/view_models/vendor_details.vm.dart';
import 'package:sod_user/views/pages/vendor_details/widgets/vendor_details_header.view.dart';
import 'package:sod_user/widgets/custom_masonry_grid_view.dart';
import 'package:sod_user/widgets/list_items/grid_view_service.list_item.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class ServiceVendorDetailsPage extends StatelessWidget {
  ServiceVendorDetailsPage(
    this.vendorDetailsViewModel, {
    required this.vendor,
    Key? key,
  }) : super(key: key);

  final Vendor vendor;
  final VendorDetailsViewModel vendorDetailsViewModel;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ServiceVendorDetailsViewModel>.reactive(
      viewModelBuilder: () => ServiceVendorDetailsViewModel(context, vendor),
      onViewModelReady: (model) => model.getVendorServices(),
      builder: (context, model, child) {
        return VStack(
          [
            //
            VendorDetailsHeader(vendorDetailsViewModel),
            //services
            CustomMasonryGridView(
              isLoading: model.isBusy,
              crossAxisSpacing: 10,
              mainAxisSpacing: 20,
              childAspectRatio: 1.1,
              items: model.services
                  .map(
                    (service) => GridViewServiceListItem(
                      service: service,
                      onPressed: model.servicePressed,
                    ),
                  )
                  .toList(),
            ).p20(),
          ],
        ).scrollVertical().expand();
      },
    );
  }
}
