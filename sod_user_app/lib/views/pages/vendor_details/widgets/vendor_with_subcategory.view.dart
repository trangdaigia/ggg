import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/constants/app_ui_sizes.dart';
import 'package:sod_user/models/vendor.dart';
import 'package:sod_user/view_models/vendor_details.vm.dart';
import 'package:sod_user/views/pages/vendor_details/vendor_category_products.page.dart';
import 'package:sod_user/views/pages/vendor_details/widgets/vendor_details_header.view.dart';
import 'package:sod_user/widgets/busy_indicator.dart';
import 'package:sod_user/widgets/custom_grid_view.dart';
import 'package:sod_user/widgets/list_items/category.list_item.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class VendorDetailsWithSubcategoryPage extends StatelessWidget {
  VendorDetailsWithSubcategoryPage({
    required this.vendor,
    Key? key,
  }) : super(key: key);

  final Vendor vendor;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<VendorDetailsViewModel>.reactive(
      viewModelBuilder: () => VendorDetailsViewModel(context, vendor),
      onViewModelReady: (model) => model.getVendorDetails(),
      builder: (context, model, child) {
        return VStack(
          [
            //
            VendorDetailsHeader(model),
            //categories
            model.isBusy
                ? BusyIndicator().p20().centered()
                : CustomGridView(
                    noScrollPhysics: true,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    childAspectRatio: AppUISizes.getAspectRatio(
                      context,
                      AppStrings.categoryPerRow,
                      AppStrings.categoryImageHeight + 35,
                    ),
                    crossAxisCount: AppStrings.categoryPerRow,
                    dataSet: model.vendor!.categories,
                    padding: EdgeInsets.all(20),
                    itemBuilder: (ctx, index) {
                      final category = model.vendor!.categories[index];
                      return CategoryListItem(
                        h: AppStrings.categoryImageHeight + 20,
                        category: category,
                        onPressed: (category) {
                          //
                          context.nextPage(
                            VendorCategoryProductsPage(
                              category: category,
                              vendor: model.vendor!,
                            ),
                          );
                        },
                      );
                    },
                  ),
          ],
        ).scrollVertical().expand();
      },
    );
  }
}
