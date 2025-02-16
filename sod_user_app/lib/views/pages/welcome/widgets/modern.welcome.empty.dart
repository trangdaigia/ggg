import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/constants/home_screen.config.dart';
import 'package:sod_user/models/search.dart';
import 'package:sod_user/models/vendor_type.dart';
import 'package:sod_user/services/navigation.service.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/view_models/welcome.vm.dart';
import 'package:sod_user/views/pages/delivery_address/delivery_addresses.page.dart';
import 'package:sod_user/views/pages/taxi/taxi.page.dart';
import 'package:sod_user/views/pages/vendor/widgets/banners.view.dart';
import 'package:sod_user/views/pages/vendor/widgets/section_vendors.view.dart';
import 'package:sod_user/views/pages/welcome/widgets/welcome_header.section.dart';
import 'package:sod_user/views/shared/widgets/section_coupons.view.dart';
import 'package:sod_user/widgets/cards/custom.visibility.dart';
import 'package:sod_user/widgets/custom_list_view.dart';
import 'package:sod_user/widgets/finance/wallet_management.view.dart';
import 'package:sod_user/widgets/list_items/modern_vendor_type.vertical_list_item.dart';
import 'package:sod_user/widgets/states/error.state.dart';
import 'package:sod_user/widgets/states/loading.shimmer.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:masonry_grid/masonry_grid.dart';
import 'package:velocity_x/velocity_x.dart';

class ModernEmptyWelcome extends StatelessWidget {
  const ModernEmptyWelcome({
    required this.vm,
    Key? key,
  }) : super(key: key);

  final WelcomeViewModel vm;
  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        //
        WelcomeHeaderSection(vm),
        VStack(
          [
            //finance section
            CustomVisibilty(
              visible: HomeScreenConfig.showWalletOnHomeScreen,
              child: WalletManagementView().px20().py16(),
            ),

            //top banner
            CustomVisibilty(
              visible: (HomeScreenConfig.showBannerOnHomeScreen &&
                  HomeScreenConfig.isBannerPositionTop),
              child: Banners(
                null,
                featured: true,
                padding: 6,
              ),
            ),
            //
            VStack(
              [
                //gridview
                CustomVisibilty(
                  visible: HomeScreenConfig.isVendorTypeListingGridView &&
                      vm.showGrid &&
                      vm.isBusy,
                  child: LoadingShimmer().px20().centered(),
                ),
                CustomVisibilty(
                  visible: HomeScreenConfig.isVendorTypeListingGridView &&
                      vm.showGrid &&
                      !vm.isBusy,
                  child: AnimationLimiter(
                    child: MasonryGrid(
                      column: HomeScreenConfig.vendorTypePerRow,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      children: List.generate(
                        vm.vendorTypes.length,
                        (index) {
                          final vendorType = vm.vendorTypes[index];
                          return ModernVendorTypeVerticalListItem(
                            vendorType,
                            onPressed: () {
                              NavigationService.pageSelected(
                                vendorType,
                                context: context,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ).p20(),

            //botton banner
            CustomVisibilty(
              visible: HomeScreenConfig.showBannerOnHomeScreen &&
                  !HomeScreenConfig.isBannerPositionTop,
              child: Banners(
                null,
                featured: true,
              ).py12(),
            ),
            //coupons
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
            SectionVendorsView(
              null,
              title: "Featured Vendors".tr(),
              scrollDirection: Axis.horizontal,
              type: SearchFilterType.featured,
              itemWidth: context.percentWidth * 48,
              byLocation: AppStrings.enableFatchByLocation,
              hideEmpty: true,
              titlePadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              itemsPadding: EdgeInsets.symmetric(horizontal: 20),
            ),
            //spacing
            100.heightBox,

            if (!vm.checkVendorHasService()) ...[
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
          ],
        )
            .scrollVertical()
            .box
            .color(context.theme.colorScheme.background)
            .make()
            .expand(),
      ],
    );
  }
}
