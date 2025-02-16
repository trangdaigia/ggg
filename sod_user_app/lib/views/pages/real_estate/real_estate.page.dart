import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_routes.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/constants/home_screen.config.dart';
import 'package:sod_user/models/vendor_type.dart';
import 'package:sod_user/view_models/real_estate.vm.dart';
import 'package:sod_user/views/pages/vendor/widgets/banners.view.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:sod_user/widgets/cards/custom.visibility.dart';
import 'package:sod_user/widgets/list_items/real_estate_category.list_item.dart';
import 'package:sod_user/widgets/list_items/real_estate_with_detail.list_item.dart';
import 'package:sod_user/widgets/list_items/real_estate_option.list_item.dart';
import 'package:sod_user/widgets/states/loading_indicator.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class RealEstatePage extends StatefulWidget {
  const RealEstatePage(this.vendorType, {Key? key}) : super(key: key);

  final VendorType vendorType;
  @override
  _RealEstatePageState createState() => _RealEstatePageState();
}

const propertyType = ["Can ho/Chung cu", "Nha o", "Dat", "Van phong/Mat bang"];

class _RealEstatePageState extends State<RealEstatePage> {
  late RealEstateViewModel vm;
  GlobalKey pageKey = GlobalKey<State>();
  @override
  void initState() {
    super.initState();
    this.vm = RealEstateViewModel(context);
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<RealEstateViewModel>.reactive(
      viewModelBuilder: () => RealEstateViewModel(context),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return BasePage(
            showAppBar: true,
            showLeadingAction: !AppStrings.isSingleVendorMode,
            elevation: 0,
            title: "${widget.vendorType.name}",
            appBarColor: context.theme.colorScheme.surface,
            appBarItemColor: AppColor.primaryColor,
            isSearch: true,
            isIconNotifi: true,
            isIconMessage: true,
            showCart: false,
            key: model.pageKey,
            body: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: VStack([
                  CustomVisibilty(
                    visible: HomeScreenConfig.showBannerOnHomeScreen &&
                        HomeScreenConfig.isBannerPositionTop,
                    child: VStack(
                      [Banners(null, featured: true).py12()],
                    ),
                  ),
                  AnimationLimiter(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: ["Sell".tr(), "Rent".tr(), "Du an", "Gi do"]
                            .mapIndexed(
                              (option, index) => Container(
                                width: MediaQuery.of(context).size.width / 5,
                                child: RealEstateOptionListItem(
                                  option,
                                  index,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  Divider(
                    color: Theme.of(context).dividerColor,
                    thickness: 10,
                  ),
                  //Real eastate by region
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Column(
                      children: [
                        ("Real estate by category")
                            .tr()
                            .text
                            .lg
                            .semiBold
                            .size(16)
                            .center
                            .make(),
                      ],
                    ),
                  ),
                  //TAB
                  SizedBox( //FIX HERE
                    height: 400, // Adjust height as needed
                    child: LoadingIndicator(
                      loading: false,
                      child: ContainedTabBarView(
                          callOnChangeWhileIndexIsChanging: true,
                          tabBarProperties: TabBarProperties(
                            isScrollable: false,
                            alignment: TabBarAlignment.start,
                            labelPadding: EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 0,
                            ),
                            //
                            padding: EdgeInsets.all(0),
                            labelColor: AppColor.primaryColor,
                            unselectedLabelColor: Colors.black,
                            labelStyle: context.textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            unselectedLabelStyle:
                                context.textTheme.bodyLarge!.copyWith(),
                          ),
                          tabBarViewProperties: TabBarViewProperties(
                              physics: NeverScrollableScrollPhysics()),
                          tabs: [
                            Tab(child: "Sell".tr().text.make()),
                            Tab(child: "Rent".tr().text.make()),
                          ],
                          views: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: model.realEstateCategories
                                      .map(
                                        (category) => Container(
                                          padding: EdgeInsets.only(right: 7),
                                          child: RealEstateCategoryListItem(
                                                category,
                                              ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ),
                            Container(
                              height: 300,
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: model.realEstateCategories
                                      .map(
                                        (category) => Container(
                                          padding: EdgeInsets.only(right: 7),
                                          child: InkWell(
                                              onTap: () {},
                                              child: RealEstateCategoryListItem(
                                                category,
                                              )),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ),
                          ]),
                    ),
                  ),
                  Divider( //FIX HERE
                    color: Theme.of(context).dividerColor,
                    thickness: 10,
                  ),
                  //
                  // Buy: Property with detail
                  //

                  ("Selling real estate")
                      .tr()
                      .text
                      .lg
                      .semiBold
                      .size(16)
                      .center
                      .make()
                      .px8()
                      .py4(),
                  SizedBox(
                    height: 330, // Explicit height constraint
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: model.realEstates
                            .map(
                              (realEstate) => Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: RealEstateWithDetail(realEstate)),
                            )
                            .toList(),
                      ),
                    ).px8().py4(),
                  ),
                  CustomButton(
                          title: "See all".tr(),
                          elevation: 0,
                          loading: model.isBusy,
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.realEstateSearch, arguments: {
                              "selling_type": "Sell"
                            });
                          },
                          titleStyle: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                          color: AppColor.faintBgColor)
                      .h(Vx.dp48)
                      .centered(),
                  Divider( //FIX HERE
                    color: Theme.of(context).dividerColor,
                    thickness: 10,
                  ),
                  //
                  // Rent: Property with detail
                  //
                  ("Renting real estate")
                      .tr()
                      .text
                      .lg
                      .semiBold
                      .size(16)
                      .center
                      .make()
                      .px8()
                      .py4(),
                  SizedBox(
                    height: 330, // Explicit height constraint
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: model.realEstates
                            .map(
                              (realEstate) => Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: RealEstateWithDetail(realEstate)),
                            )
                            .toList(),
                      ),
                    ).px8().py(4),
                  ),
                  CustomButton(
                          title: "See all".tr(),
                          elevation: 0,
                          loading: model.isBusy,
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.realEstateSearch, arguments: {
                              "selling_type": "Rent"
                            });
                          },
                          titleStyle: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                          color: AppColor.faintBgColor)
                      .h(Vx.dp48)
                      .centered(),
                ])));
      },
    );
  }
}
