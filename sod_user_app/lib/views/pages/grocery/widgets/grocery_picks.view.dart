import 'package:flutter/material.dart';
import 'package:sod_user/enums/product_fetch_data_type.enum.dart';
import 'package:sod_user/models/category.dart';
import 'package:sod_user/models/search.dart';
import 'package:sod_user/models/vendor_type.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/view_models/products.vm.dart';
import 'package:sod_user/views/pages/search/search.page.dart';
import 'package:sod_user/widgets/cards/custom.visibility.dart';
import 'package:sod_user/widgets/custom_list_view.dart';
import 'package:sod_user/widgets/custom_masonry_grid_view.dart';
import 'package:sod_user/widgets/list_items/grocery_product.list_item.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class GroceryProductsSectionView extends StatelessWidget {
  const GroceryProductsSectionView(
    this.title,
    this.vendorType, {
    this.type = ProductFetchDataType.RANDOM,
    this.category,
    this.showGrid = true,
    this.crossAxisCount = 2,
    Key? key,
  }) : super(key: key);

  final String title;
  final bool showGrid;
  final int crossAxisCount;
  final VendorType vendorType;
  final ProductFetchDataType type;
  final Category? category;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ProductsViewModel>.reactive(
      viewModelBuilder: () => ProductsViewModel(
        context,
        vendorType,
        type,
        categoryId: category?.id,
      ),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        return CustomVisibilty(
          visible: vm.products.isNotEmpty && !vm.isBusy,
          child: VStack(
            [
              //
              HStack(
                [
                  "$title".text.xl.semiBold.make().expand(),
                  UiSpacer.smHorizontalSpace(),
                  "See all"
                      .tr()
                      .text
                      .color(context.primaryColor)
                      .make()
                      .onInkTap(
                    () {
                      //
                      final search = Search(
                        category: category,
                        vendorType: vendorType,
                        showType: 2,
                      );
                      //open search page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return SearchPage(
                              search: search,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ).p12(),
              CustomVisibilty(
                visible: !showGrid,
                child: CustomListView(
                  isLoading: vm.isBusy,
                  dataSet: vm.products,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: Vx.dp12),
                  itemBuilder: (context, index) {
                    return GroceryProductListItem(
                      product: vm.products.elementAt(index),
                      onPressed: vm.productSelected,
                      qtyUpdated: vm.addToCartDirectly,
                    );
                  },
                ).h(vm.anyProductWithOptions ? 220 : 180),
              ),
              CustomVisibilty(
                visible: showGrid,
                child: CustomMasonryGridView(
                  isLoading: vm.isBusy,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: crossAxisCount,
                  items: vm.products
                      .map(
                        (product) => GroceryProductListItem(
                          product: product,
                          onPressed: vm.productSelected,
                          qtyUpdated: vm.addToCartDirectly,
                        ),
                      )
                      .toList(),
                ).px12(),
              ),
            ],
          ).py12(),
        );
      },
    );
  }
}
