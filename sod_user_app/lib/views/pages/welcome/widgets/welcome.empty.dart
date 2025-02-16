import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/constants/app_text_styles.dart';
import 'package:sod_user/constants/home_screen.config.dart';
import 'package:sod_user/enums/product_fetch_data_type.enum.dart';
import 'package:sod_user/models/search.dart';
import 'package:sod_user/models/vendor_type.dart';
import 'package:sod_user/services/navigation.service.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/view_models/vendor/categories.vm.dart';
import 'package:sod_user/view_models/vendor/popular_services.vm.dart';
import 'package:sod_user/view_models/vendor/sub_categories.vm.dart';
import 'package:sod_user/view_models/welcome.vm.dart';
import 'package:sod_user/views/pages/delivery_address/delivery_addresses.page.dart';
import 'package:sod_user/views/pages/taxi/taxi.page.dart';
import 'package:sod_user/views/pages/vendor/widgets/banners.view.dart';
import 'package:sod_user/views/pages/vendor/widgets/best_selling_products.view.dart';
import 'package:sod_user/views/pages/vendor/widgets/section_vendors.view.dart';
import 'package:sod_user/views/shared/widgets/section_coupons.view.dart';
import 'package:sod_user/widgets/cards/custom.visibility.dart';
import 'package:sod_user/widgets/cards/welcome_intro.view.dart';
import 'package:sod_user/widgets/custom_list_view.dart';
import 'package:sod_user/widgets/finance/wallet_management.view.dart';
import 'package:sod_user/widgets/list_items/category.list_item.dart';
import 'package:sod_user/widgets/list_items/food_horizontal_product.list_item.dart';
import 'package:sod_user/widgets/list_items/grid_view_product.list_item.dart';
import 'package:sod_user/widgets/list_items/horizontal_vendor.list_item.dart';
import 'package:sod_user/widgets/list_items/service.gridview_item.dart';
import 'package:sod_user/widgets/list_items/vendor_type.vertical_list_item.dart';
import 'package:sod_user/widgets/section.title.dart';
import 'package:sod_user/widgets/states/error.state.dart';
import 'package:sod_user/widgets/states/loading.shimmer.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../vendor/widgets/section_products.view.dart';

class EmptyWelcome extends StatelessWidget {
  const EmptyWelcome({required this.vm, Key? key}) : super(key: key);

  final WelcomeViewModel vm;

  @override
  Widget build(BuildContext context) {
    bool checkCount = false;
    if (vm.vendorTypes.length < 12) {
      checkCount = true;
    } else {
      checkCount = false;
    }
    List<VendorType> lstservice = vm.vendorTypes
        .where((vendorType) => vendorType.slug == "service")
        .toList();
    List<VendorType> lstpharmacy = vm.vendorTypes
        .where((vendorType) => vendorType.slug == "pharmacy")
        .toList();
    List<VendorType> lstfood = vm.vendorTypes
        .where((vendorType) => vendorType.slug == "food")
        .toList();
    return VStack(
      [
        //
        SafeArea(child: WelcomeIntroView()),
        //
        VStack(
          [
            //finance section
            CustomVisibilty(
              visible: HomeScreenConfig.showWalletOnHomeScreen,
              child: WalletManagementView(),
            ).px20().py16(),
            //
            checkCount
                ? SizedBox()
                : CustomVisibilty(
                    visible: HomeScreenConfig.isVendorTypeListingGridView &&
                        !vm.isBusy,
                    child: AnimationLimiter(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: context.backgroundColor,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: vm.vendorTypes
                              .take(4)
                              .toList()
                              .asMap()
                              .entries
                              .map(
                                (vendortype) => Container(
                                  width: MediaQuery.of(context).size.width / 5,
                                  child: VendorTypeVerticalListItem(
                                    vendortype.value,
                                    index: vendortype.key,
                                    onPressed: () {
                                      NavigationService.pageSelected(
                                          vendortype.value,
                                          context: context);
                                    },
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ).pOnly(bottom: 10),
            //top banner
            CustomVisibilty(
              visible: HomeScreenConfig.showBannerOnHomeScreen &&
                  HomeScreenConfig.isBannerPositionTop,
              child: VStack(
                [Banners(null, featured: true).py12()],
              ),
            ),
            CustomVisibilty(
              visible: HomeScreenConfig.isVendorTypeListingGridView &&
                  vm.showGrid &&
                  vm.isBusy,
              child: LoadingShimmer().px20().centered(),
            ),
            CustomVisibilty(
              visible:
                  HomeScreenConfig.isVendorTypeListingGridView && !vm.isBusy,
              child: AnimationLimiter(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: !checkCount
                      ? Column(
                          children: [
                            rowVendorType(context, 4),
                            rowVendorType(context, 8),
                          ],
                        )
                      : Column(
                          children: [
                            rowVendorType(context, 0),
                            rowVendorType(context, 4),
                          ],
                        ),
                ),
              ),
            ).pOnly(bottom: 10),
            Divider(
              color: Theme.of(context).dividerColor,
              thickness: 10,
            ),
            // VendorType Service
            CustomVisibilty(
              visible:
                  HomeScreenConfig.isVendorTypeListingGridView && !vm.isBusy,
              child: Column(
                children: lstservice
                    .map((vendorType) => listCategory(context, vendorType))
                    .toList(),
              ),
            ),
            SectionCouponsView(
              null,
              title: "Promo".tr(),
              scrollDirection: Axis.horizontal,
              itemWidth: context.percentWidth * 70,
              height: 100,
              itemsPadding: EdgeInsets.fromLTRB(10, 0, 10, 10),
              bPadding: 10,
            ),

            //featured vendors
            // if(lstfood.isNotEmpty && lstservice.isEmpty )
            CustomVisibilty(
              visible:
                  HomeScreenConfig.isVendorTypeListingGridView && !vm.isBusy,
              child: SectionVendorsView(
                null,
                title: "Featured Vendors".tr(),
                titlePadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                itemsPadding: EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                type: SearchFilterType.featured,
                itemWidth: context.percentWidth * 48,
                byLocation: AppStrings.enableFatchByLocation,
                hideEmpty: true,
                lstVendorType: vm.vendorTypes,
              ),
            ),
            //popular service
            lstservice.isNotEmpty && lstservice.length >= 2
                ? getPopularService(context, lstservice[0])
                : SizedBox(),
            lstpharmacy.isNotEmpty
                ? Divider(
                    color: Theme.of(context).dividerColor,
                    thickness: 10,
                  )
                : SizedBox(),
            //Pharmacy
            lstpharmacy.isNotEmpty
                ? lstpharmacy.first.name
                    .tr()
                    .text
                    .xl2
                    .bold
                    .make()
                    .pOnly(top: 10, left: 5)
                : SizedBox(),
            lstpharmacy.isNotEmpty
                ? BestSellingProducts(lstpharmacy.first)
                : SizedBox(),
            lstfood.isNotEmpty
                ? Divider(color: Theme.of(context).dividerColor, thickness: 10)
                    .pOnly(top: 10)
                : SizedBox(),
            lstfood.isNotEmpty
                ? lstfood.first.name
                    .tr()
                    .text
                    .xl2
                    .bold
                    .make()
                    .pOnly(top: 10, left: 5)
                : SizedBox(),

            // lstfood.isNotEmpty ? Banners(lstfood.first) : SizedBox(),
            lstfood.isNotEmpty
                ? SectionProductsView(
                    lstfood.first,
                    title: "Campaigns".tr(),
                    scrollDirection: Axis.horizontal,
                    type: ProductFetchDataType.FLASH,
                    itemWidth: context.percentWidth * 38,
                    viewType: GridViewProductListItem,
                    byLocation: AppStrings.enableFatchByLocation,
                  )
                : SizedBox(),
            lstfood.isNotEmpty
                ? //popular foods
                SectionProductsView(
                    lstfood.first,
                    title: "Popular Foods Nearby".tr(),
                    scrollDirection: Axis.horizontal,
                    type: ProductFetchDataType.BEST,
                    itemWidth: context.percentWidth * 70,
                    itemHeight: 120,
                    viewType: FoodHorizontalProductListItem,
                    listHeight: 115,
                    byLocation: AppStrings.enableFatchByLocation,
                  )
                : SizedBox(),
            //all vendor
            lstfood.isNotEmpty
                ? CustomVisibilty(
                    visible: !AppStrings.enableSingleVendor,
                    child: SectionVendorsView(
                      lstfood.first,
                      title: "All Vendors/Restaurants".tr(),
                      scrollDirection: Axis.vertical,
                      type: SearchFilterType.best,
                      viewType: HorizontalVendorListItem,
                      separator: UiSpacer.verticalSpace(space: 0),
                    ),
                  )
                : SizedBox(),
            //spacing
            if (!lstfood.isEmpty &&
                !lstpharmacy.isEmpty &&
                !lstservice.isEmpty) ...[
              UiSpacer.vSpace(20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                margin: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey[400]!,
                        blurRadius: 8,
                        spreadRadius: 3),
                  ],
                ),
                child: GestureDetector(
                  onTap: () {
                    List<VendorType> v =
                        vm.vendorTypes.where((e) => e.slug == "taxi").toList();
                    context.nextPage(TaxiPage(v[0], true, false));
                  },
                  child: HStack(
                    [
                      Icon(Icons.circle_outlined, color: Colors.red),
                      UiSpacer.hSpace(10),
                      "Where to?".tr().text.black.make(),
                    ],
                  ),
                ),
              ),
              UiSpacer.vSpace(20),
              HStack(
                [
                  "To favorite locations".tr().text.bold.lg.make().expand(),
                  IconButton(
                    onPressed: () => context.nextPage(DeliveryAddressesPage()),
                    icon: Icon(Icons.arrow_right_alt),
                  ).box.py12.green200.roundedFull.make(),
                ],
              ).px(13),
              SizedBox(
                height: 130,
                child: HStack(
                  alignment: MainAxisAlignment.center,
                  crossAlignment: CrossAxisAlignment.center,
                  [
                    CustomListView(
                      scrollDirection: Axis.horizontal,
                      refreshController: vm.refreshController,
                      dataSet: vm.deliveryAddressesViewModel!.deliveryAddresses,
                      isLoading: vm.busy(
                          vm.deliveryAddressesViewModel!.deliveryAddresses),
                      errorWidget: LoadingError(
                        onrefresh: vm
                            .deliveryAddressesViewModel!.fetchDeliveryAddresses,
                      ),
                      itemBuilder: (context, index) {
                        final IconData icon;
                        final address = vm.deliveryAddressesViewModel!
                            .deliveryAddresses[index];
                        switch (address.name?.toString().toLowerCase()) {
                          case "home":
                            icon = FlutterIcons.home_ant;
                            break;
                          case "work":
                            icon = FlutterIcons.work_mdi;
                            break;
                          default:
                            icon = FlutterIcons.heart_ant;
                        }
                        return Container(
                          padding: EdgeInsets.all(5),
                          width: 80,
                          child: VStack(
                            crossAlignment: CrossAxisAlignment.center,
                            spacing: 10,
                            [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: CircleBorder(),
                                  padding: EdgeInsets.all(20),
                                ),
                                onPressed: () {
                                  vm.deliveryAddressesViewModel!
                                      .editDeliveryAddress(address);
                                },
                                child: Icon(icon, size: 20),
                              ),
                              Text("${address.name?.toString().toUpperCase()}",
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        );
                      },
                    ),
                    UiSpacer.hSpace(20),
                    ListView(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        Container(
                          padding: EdgeInsets.all(5),
                          width: 80,
                          child: VStack(
                            crossAlignment: CrossAxisAlignment.center,
                            spacing: 10,
                            [
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: CircleBorder(),
                                      padding: EdgeInsets.all(20),
                                    ),
                                    onPressed: () {
                                      vm.deliveryAddressesViewModel!
                                          .newDeliveryAddressPressed();
                                    },
                                    child:
                                        Icon(FlutterIcons.heart_ant, size: 20),
                                  ),
                                  Icon(Icons.add, color: Colors.blue)
                                      .box
                                      .white
                                      .roundedFull
                                      .make(),
                                ],
                              ),
                              Text("${"New".tr().toString().toUpperCase()}",
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ).scrollHorizontal(),
            ],
            UiSpacer.vSpace(100),
          ],
        )
            .box
            .color(context.theme.colorScheme.background)
            .topRounded(value: 30)
            .make(),
      ],
    ).box.color(AppColor.primaryColor).make().scrollVertical();
  }

  getPopularService(BuildContext context, VendorType? vendorType) {
    var size = MediaQuery.of(context).size;
    print(
        "Screen Size is: Height ==> ${size.height} & Width ==> ${size.width}");
    return ViewModelBuilder<PopularServicesViewModel>.reactive(
      viewModelBuilder: () => PopularServicesViewModel(context, vendorType),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        //
        if (!vm.isBusy && vm.services.isEmpty) return SizedBox.shrink();
        return VStack(
          [
            SectionTitle(
              translator.activeLocale.languageCode == "vi"
                  ? " ${vendorType!.name + " " + "Popular".tr().toLowerCase()}"
                  : "Popular service",
            ).px(20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: vm.services
                    .map(
                      (service) => Container(
                        width: MediaQuery.of(context).size.width / 2,
                        child: ServiceGridViewItem(
                          service: service,
                          onPressed: vm.serviceSelected,
                        ),
                      ),
                    )
                    .toList(),
              ).px(16),
            ),
          ],
        ).py12();
      },
    );
  }

  Row rowVendorType(BuildContext context, int skip) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: vm.vendorTypes
          .skip(skip)
          .take(4)
          .toList()
          .asMap()
          .entries
          .map((vendortype) => Container(
                width: MediaQuery.of(context).size.width / 5,
                child: VendorTypeVerticalListItem(
                  vendortype.value,
                  index: vendortype.key,
                  onPressed: () {
                    NavigationService.pageSelected(vendortype.value,
                        context: context);
                  },
                ),
              ))
          .toList(),
    );
  }

  //Lấy category
  ViewModelBuilder<CategoriesViewModel> listCategory(
      BuildContext context, VendorType vendorType) {
    return ViewModelBuilder<CategoriesViewModel>.reactive(
      viewModelBuilder: () =>
          CategoriesViewModel(context, vendorType: vendorType),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        if (model.categories.length != 0) {
          if (model.categories.skip(4).take(4).length == 4) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        vendorType.name.toString(),
                        style: AppTextStyle.h5TitleTextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      rowCategory(model, context, 0, false),
                      rowCategory(model, context, 4, false),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Divider(
                    color: Theme.of(context).dividerColor,
                    thickness: 10.0,
                  ),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        vendorType.name.toString(),
                        style: AppTextStyle.h5TitleTextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      rowCategory(model, context, 0, false),
                      rowCategory(model, context, 4, true),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Divider(
                    color: Theme.of(context).dividerColor,
                    thickness: 10.0,
                  ),
                ),
              ],
            );
          }
        } else {
          return SizedBox();
        }
      },
    );
  }

  Row rowCategory(
      CategoriesViewModel model, BuildContext context, int skip, bool start) {
    return Row(
      mainAxisAlignment:
          start ? MainAxisAlignment.start : MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: model.categories
          .skip(skip)
          .take(4)
          .map(
            (category) => Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Container(
                width: MediaQuery.of(context).size.width / 5,
                child: CategoryListItem(
                  category: category,
                  onPressed: (Category) {
                    NavigationService.pageSelected(
                      model.vendorType!,
                      context: context,
                    );
                  },
                  maxLine: false,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  ViewModelBuilder<CategoriesViewModel> listSubCategory(
      BuildContext context, VendorType serviceVendorType, int type) {
    return ViewModelBuilder<CategoriesViewModel>.reactive(
      viewModelBuilder: () =>
          CategoriesViewModel(context, vendorType: serviceVendorType),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return ViewModelBuilder<SubcategoriesViewModel>.reactive(
          viewModelBuilder: () =>
              SubcategoriesViewModel(context, model.categories[type]),
          onViewModelReady: (vm) => vm.initialise(all: true),
          builder: (context, vm, child) {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      model.categories[type].name,
                      style: AppTextStyle.h5TitleTextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 7,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: vm.subcategories.length,
                    itemBuilder: (context, index) {
                      return CategoryListItem(
                        category: vm.subcategories[index],
                        onPressed: (Category) {
                          NavigationService.pageSelected(
                            serviceVendorType,
                            context: context,
                          );
                        },
                        maxLine: false,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
