import 'package:flutter/material.dart';
import 'package:sod_user/models/product.dart';
import 'package:sod_user/models/search.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/view_models/search.vm.dart';
import 'package:sod_user/views/pages/search/widget/search.header.dart';
import 'package:sod_user/views/pages/search/widget/vendor_search_header.view.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/widgets/cards/custom.visibility.dart';
import 'package:sod_user/widgets/custom_dynamic_grid_view.dart';
import 'package:sod_user/widgets/custom_list_view.dart';
import 'package:sod_user/widgets/list_items/commerce_product.list_item.dart';
import 'package:sod_user/widgets/list_items/grocery_product.list_item.dart';
import 'package:sod_user/widgets/list_items/horizontal_product.list_item.dart';
import 'package:sod_user/widgets/list_items/vendor.list_item.dart';
import 'package:sod_user/widgets/states/search.empty.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class ProductSearchPage extends StatelessWidget {
  const ProductSearchPage(
      {Key? key, required this.search, this.showCancel = true})
      : super(key: key);

  //
  final Search search;
  final bool showCancel;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SearchViewModel>.reactive(
      viewModelBuilder: () => SearchViewModel(context, search),
      onViewModelReady: (model) => model.startSearch(),
      disposeViewModel: false,
      builder: (context, model, child) {
        return BasePage(
          showCartView: showCancel,
          body: SafeArea(
            bottom: false,
            child: VStack(
              [
                //header
                UiSpacer.verticalSpace(),
                SearchHeader(model, showCancel: showCancel),

                //tags
                VendorSearchHeaderview(
                  model,
                  showProducts: true,
                  showVendors: true,
                ),

                //vendors listview
                CustomVisibilty(
                  visible: model.selectTagId == 1,
                  child: CustomListView(
                    refreshController: model.refreshController,
                    canRefresh: true,
                    canPullUp: true,
                    onRefresh: model.startSearch,
                    onLoading: () => model.startSearch(initialLoaoding: false),
                    isLoading: model.isBusy,
                    dataSet: model.searchResults,
                    itemBuilder: (context, index) {
                      //
                      final searchResult = model.searchResults[index];
                      if (searchResult is Product) {
                        //grocery product list item
                        if (searchResult.vendor.vendorType.isGrocery) {
                          return GroceryProductListItem(
                            product: searchResult,
                            onPressed: model.productSelected,
                            qtyUpdated: model.addToCartDirectly,
                          );
                        } else if (searchResult.vendor.vendorType.isCommerce) {
                          return CommerceProductListItem(
                            searchResult,
                            height: 80,
                          );
                        } else {
                          //regular views
                          return HorizontalProductListItem(
                            searchResult,
                            onPressed: model.productSelected,
                            qtyUpdated: model.addToCartDirectly,
                          );
                        }
                      } else {
                        return VendorListItem(
                          vendor: searchResult,
                          onPressed: model.vendorSelected,
                        );
                      }
                    },
                    separatorBuilder: (context, index) =>
                        UiSpacer.verticalSpace(space: 10),
                    emptyWidget: EmptySearch(),
                  ).expand(),
                ),

                //product/services related view
                CustomVisibilty(
                  visible: model.selectTagId != 1,
                  child: VStack(
                    [
                      //result listview
                      CustomVisibilty(
                        visible: !model.showGrid,
                        child: CustomListView(
                          refreshController: model.refreshController,
                          canRefresh: true,
                          canPullUp: true,
                          onRefresh: model.startSearch,
                          onLoading: () =>
                              model.startSearch(initialLoaoding: false),
                          isLoading: model.isBusy,
                          dataSet: model.searchResults,
                          itemBuilder: (context, index) {
                            //
                            final searchResult = model.searchResults[index];
                            if (searchResult is Product) {
                              //grocery product list item
                              if (searchResult.vendor.vendorType.isGrocery) {
                                return GroceryProductListItem(
                                  product: searchResult,
                                  onPressed: model.productSelected,
                                  qtyUpdated: model.addToCartDirectly,
                                );
                              } else if (searchResult
                                  .vendor.vendorType.isCommerce) {
                                return CommerceProductListItem(
                                  searchResult,
                                  height: 80,
                                );
                              } else {
                                //regular views
                                return HorizontalProductListItem(
                                  searchResult,
                                  onPressed: model.productSelected,
                                  qtyUpdated: model.addToCartDirectly,
                                );
                              }
                            } else {
                              return VendorListItem(
                                vendor: searchResult,
                                onPressed: model.vendorSelected,
                              );
                            }
                          },
                          separatorBuilder: (context, index) =>
                              UiSpacer.verticalSpace(space: 10),
                          emptyWidget: EmptySearch(),
                        ).expand(),
                      ),

                      //result gridview
                      CustomVisibilty(
                        visible: model.showGrid,
                        child: CustomDynamicHeightGridView(
                          noScrollPhysics: true,
                          refreshController: model.refreshController,
                          canRefresh: true,
                          canPullUp: true,
                          onRefresh: model.startSearch,
                          onLoading: () =>
                              model.startSearch(initialLoaoding: false),
                          isLoading: model.isBusy,
                          itemCount: model.searchResults.length,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          itemBuilder: (context, index) {
                            //
                            final searchResult = model.searchResults[index];
                            if (searchResult is Product) {
                              //regular views
                              return CommerceProductListItem(
                                searchResult,
                                height: 80,
                              );
                            } else {
                              return VendorListItem(
                                vendor: searchResult,
                                onPressed: model.vendorSelected,
                              );
                            }
                          },
                          separatorBuilder: (context, index) =>
                              UiSpacer.verticalSpace(space: 10),
                          emptyWidget: EmptySearch(),
                        ).expand(),
                      ),
                    ],
                  ).expand(),
                ),
              ],
            ).pOnly(
              left: Vx.dp16,
              right: Vx.dp16,
            ),
          ),
        );
      },
    );
  }
}
