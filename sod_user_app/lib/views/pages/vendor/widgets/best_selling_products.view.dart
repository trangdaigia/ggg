import 'package:flutter/material.dart';
import 'package:sod_user/models/vendor_type.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/view_models/vendor/best_selling_products.vm.dart';
import 'package:sod_user/widgets/custom_dynamic_grid_view.dart';
import 'package:sod_user/widgets/list_items/commerce_product.list_item.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/widgets/section.title.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class BestSellingProducts extends StatelessWidget {
  const BestSellingProducts(
    this.vendorType, {
    this.imageHeight,
    Key? key,
  }) : super(key: key);

  final VendorType vendorType;
  final double? imageHeight;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<BestSellingProductsViewModel>.reactive(
      viewModelBuilder: () => BestSellingProductsViewModel(
        context,
        vendorType,
      ),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return VStack(
          [
            //
            UiSpacer.verticalSpace(),
            //"Best Selling".tr().text.make().px12().py2(),
            SectionTitle("Best Selling".tr()).pOnly(left: 12, bottom: 6),
            CustomDynamicHeightGridView(
              noScrollPhysics: true,
              separatorBuilder: (context, index) =>
                  UiSpacer.smHorizontalSpace(),
              itemCount: model.products.length,
              isLoading: model.isBusy,
              itemBuilder: (context, index) {
                //
                return CommerceProductListItem(
                  model.products[index],
                  height: imageHeight ?? 80,
                  // onPressed: model.productSelected,
                  // qtyUpdated: model.addToCartDirectly,
                );
              },
            ).px12().py2(),
          ],
        );
      },
    );
  }
}
