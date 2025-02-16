import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/constants/home_screen.config.dart';
import 'package:sod_user/enums/product_fetch_data_type.enum.dart';
import 'package:sod_user/models/search.dart';
import 'package:sod_user/models/vendor_type.dart';
import 'package:sod_user/services/app.service.dart';
import 'package:sod_user/services/navigation.service.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/view_models/vendor/categories.vm.dart';
import 'package:sod_user/view_models/vendor/popular_services.vm.dart';
import 'package:sod_user/view_models/welcome.vm.dart';
import 'package:sod_user/views/pages/vendor/widgets/banners.view.dart';
import 'package:sod_user/views/pages/vendor/widgets/best_selling_products.view.dart';
import 'package:sod_user/views/pages/vendor/widgets/section_vendors.view.dart';
import 'package:sod_user/views/shared/widgets/section_coupons.view.dart';
import 'package:sod_user/widgets/cards/custom.visibility.dart';
import 'package:sod_user/widgets/list_items/category.list_item.dart';
import 'package:sod_user/widgets/list_items/food_horizontal_product.list_item.dart';
import 'package:sod_user/widgets/list_items/grid_view_product.list_item.dart';
import 'package:sod_user/widgets/list_items/horizontal_vendor.list_item.dart';
import 'package:sod_user/widgets/list_items/service.gridview_item.dart';
import 'package:sod_user/widgets/section.title.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import './vendor_item.dart';
import '../../vendor/widgets/section_products.view.dart';
import 'package:sod_user/widgets/cards/welcome_intro.view.dart';
import 'package:sod_user/widgets/inputs/search_bar.input.dart';

class SimpleWelcome extends StatelessWidget {
  const SimpleWelcome({required this.vm, Key? key}) : super(key: key);
  final WelcomeViewModel vm;

  @override
  Widget build(BuildContext context) {
    List<VendorType> lstservice = vm.vendorTypes
        .where((vendorType) => vendorType.slug == "service")
        .toList();
    List<VendorType> lstpharmacy = vm.vendorTypes
        .where((vendorType) => vendorType.slug == "pharmacy")
        .toList();
    List<VendorType> lstfood = vm.vendorTypes
        .where((vendorType) => vendorType.slug == "food")
        .toList();
    return ListView(
      children: [
        // welcome intro (uncomment to show)
        // WelcomeIntroView(textColor: Colors.black,),
        Stack(
          children: [
            // banners
            Banners(
              null,
              featured: true,
              viewportFraction: 1,
              showIndicators: false,
              padding: 0,
              autoPlayCurve: Curves.easeInOut,
              noMarginBetweenItem: true,
            ).pOnly(bottom: 30),
            // search box
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SearchBarInput(
                      onTap: () => AppService().changeHomePageIndex(index: 2))
                  .px(16),
            ),
          ],
        ).pOnly(bottom: 16),
        // 4 vendor types
        Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ...vm.vendorTypes
                  .take(vm.vendorTypes.length <= 5 ? 5 : 4)
                  .toList()
                  .map(
                    (vendortype) => VendorItem(vendorType: vendortype)
                        .w(context.screenWidth / 5),
                  )
                  .toList(),
              if (vm.vendorTypes.length > 5)
                Column(
                  children: [
                    AspectRatio(
                      aspectRatio: 1 / 1,
                      child: Image.asset(
                        'assets/images/icons/all.png',
                        fit: BoxFit.cover,
                      ).p(7),
                    ).w(50),
                    Text(
                      'More'.tr(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
                    .w(context.screenWidth / 5)
                    .onTap(() => showMoreVendor(context, vm.vendorTypes)),
            ]),
        // coupons
        SectionCouponsView(
          null,
          title: "Promo".tr(),
          scrollDirection: Axis.horizontal,
          itemWidth: context.percentWidth * 70,
          height: 100,
          itemsPadding: EdgeInsets.fromLTRB(10, 0, 10, 10),
          bPadding: 10,
        ),
        // popular service
        CustomVisibilty(
          visible: HomeScreenConfig.isVendorTypeListingGridView && !vm.isBusy,
          child: SectionVendorsView(
            null,
            title: "Featured Vendors".tr(),
            titlePadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            itemsPadding: EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            type: SearchFilterType.featured,
            itemWidth: context.percentWidth * 48,
            byLocation: AppStrings.enableFatchByLocation,
            hideEmpty: true,
            lstVendorType: vm.vendorTypes,
          ),
        ),
        // popular service
        lstservice.isNotEmpty && lstservice.length >= 2
            ? getPopularService(context, lstservice[0])
            : SizedBox(),
        //Pharmacy
        lstpharmacy.isNotEmpty
            ? Divider(
                color: Theme.of(context).dividerColor,
                thickness: 10,
              )
            : SizedBox(),
        lstpharmacy.isNotEmpty
            ? lstpharmacy.first.name
                .tr()
                .text
                .xl2
                .bold
                .make()
                .pOnly(top: 10, left: 16)
            : SizedBox(),
        lstpharmacy.isNotEmpty
            ? BestSellingProducts(lstpharmacy.first)
            : SizedBox(),
        //Food
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
                .pOnly(top: 10, left: 16)
            : SizedBox(),
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
        SizedBox(height: 100),
      ],
    );
  }

  void showMoreVendor(BuildContext context, List<VendorType> lstservice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.6,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Container(
                color: AppColor.onboarding1Color,
                child: ListView(
                  controller: scrollController,
                  children: [
                    //'All services'.tr().text.xl2.bold.make().p(16),
                    SizedBox(height: 16),
                    Wrap(
                      spacing: 12.0,
                      runSpacing: 12.0,
                      alignment: WrapAlignment.start,
                      children: [
                        'For you'
                            .tr()
                            .text
                            .xl2
                            .bold
                            .make()
                            .w(context.screenWidth * 0.9),
                        ...lstservice.take(4).map((e) =>
                            VendorItem(vendorType: e)
                                .w(MediaQuery.of(context).size.width / 5)),
                        'All services'
                            .tr()
                            .text
                            .xl2
                            .bold
                            .make()
                            .w(context.screenWidth * 0.9),
                        ...lstservice.skip(4).map((e) =>
                            VendorItem(vendorType: e)
                                .w(MediaQuery.of(context).size.width / 5)),
                      ],
                    ).centered(),
                    if (HomeScreenConfig.isVendorTypeListingGridView &&
                        !vm.isBusy)
                      Divider(
                              color: Theme.of(context).dividerColor,
                              thickness: 10)
                          .pOnly(top: 10),
                    Visibility(
                      visible: HomeScreenConfig.isVendorTypeListingGridView &&
                          !vm.isBusy,
                      child: Column(
                        children: lstservice
                            .map((vendorType) =>
                                listCategory(context, vendorType))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  getPopularService(BuildContext context, VendorType? vendorType) {
    return ViewModelBuilder<PopularServicesViewModel>.reactive(
      viewModelBuilder: () => PopularServicesViewModel(context, vendorType),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
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

  //Lấy category
  ViewModelBuilder<CategoriesViewModel> listCategory(
      BuildContext context, VendorType vendorType) {
    return ViewModelBuilder<CategoriesViewModel>.reactive(
      viewModelBuilder: () =>
          CategoriesViewModel(context, vendorType: vendorType),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        if (model.categories.length == 0) return SizedBox();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            vendorType.name.text.xl2.bold
                .make()
                .pOnly(left: 16, right: 16, top: 16),
            Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              alignment: WrapAlignment.start,
              children: model.categories
                  .map(
                    (category) => CategoryListItem(
                      category: category,
                      onPressed: (Category) {
                        NavigationService.pageSelected(
                          model.vendorType!,
                          context: context,
                        );
                      },
                      maxLine: false,
                    ).w(context.screenWidth / 5),
                  )
                  .toList(),
            ).centered(),
            Divider(
              color: Theme.of(context).dividerColor,
              thickness: 10.0,
            ).pOnly(top: 10),
          ],
        );
      },
    );
  }
}
