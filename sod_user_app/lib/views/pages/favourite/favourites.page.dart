import 'package:flutter/material.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/view_models/favourites.vm.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/widgets/custom_list_view.dart';
import 'package:sod_user/widgets/list_items/horizontal_product.list_item.dart';
import 'package:sod_user/widgets/states/error.state.dart';
import 'package:sod_user/widgets/states/product.empty.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class FavouritesPage extends StatelessWidget {
  const FavouritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<FavouritesViewModel>.reactive(
      viewModelBuilder: () => FavouritesViewModel(context),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        return BasePage(
          showAppBar: true,
          showLeadingAction: true,
          title: "Favourites".tr(),
          isLoading: vm.isBusy,
          body: VStack(
            [
              //
              "Note: Tap & Hold to remove favourite".tr().text.make().p20(),

              //
              CustomListView(
                padding: EdgeInsets.symmetric(horizontal: 10),
                dataSet: vm.products,
                isLoading: vm.busy(vm.products),
                emptyWidget: EmptyProduct(),
                errorWidget: LoadingError(
                  onrefresh: vm.fetchProducts,
                ),
                itemBuilder: (context, index) {
                  //
                  final product = vm.products[index];
                  //
                  return HorizontalProductListItem(
                    product,
                    onPressed: vm.openProductDetails,
                    qtyUpdated: vm.addToCartDirectly,
                  ).onLongPress(
                    () => vm.removeFavourite(product),
                    GlobalKey(),
                  );
                },
                separatorBuilder: (context, index) =>
                    UiSpacer.verticalSpace(space: 10),
              ).expand(),
            ],
          ),
        );
      },
    );
  }
}
