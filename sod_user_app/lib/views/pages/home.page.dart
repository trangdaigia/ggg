import 'dart:io';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_ui_settings.dart';
import 'package:sod_user/constants/app_upgrade_settings.dart';
import 'package:sod_user/global/global_variable.dart';
import 'package:sod_user/requests/vendor_type.request.dart';
import 'package:sod_user/services/cart.service.dart';
import 'package:sod_user/services/local_storage.service.dart';
import 'package:sod_user/services/location.service.dart';
import 'package:sod_user/view_models/home.vm.dart';
import 'package:sod_user/view_models/welcome.vm.dart';
import 'package:sod_user/views/pages/notification/notifications.page.dart';
import 'package:sod_user/views/pages/profile/profile.page.dart';
import 'package:sod_user/views/pages/welcome/widgets/wallet.fab.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:stacked/stacked.dart';
import 'package:upgrader/upgrader.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:rx_shared_preferences/src/interface/extensions.dart';
import 'order/orders.page.dart';
import 'search/main_search.page.dart';
import 'welcome/widgets/cart.fab.dart';

class HomePage extends StatefulWidget {
  HomePage({
    Key? key,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeViewModel vm;
  late Widget? fab;
  bool showSearch = true;
  bool showHomePage = true;
  int totalCartItems = 0;

  @override
  void initState() {
    super.initState();
    vm = HomeViewModel(context);

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        await LocationService.prepareLocationListener(context)
            .then((_) => showHomePage = true);
        vm.initialise();
      },
    );

    // Kiểm tra xem vendor type chỉ có receive behalf không, có thì ẩn home page
    checkVendorTypeOnlyHasReceiveRehalf();

    GlobalVariable.showHomePage ? showHomePage = true : showHomePage = false;
    fab = getFab();

    //start listening to changes to items in cart
    LocalStorageService.rxPrefs?.getIntStream(CartServices.totalItemKey).listen(
      (total) {
        if (total != null) {
          setState(() {
            totalCartItems = total;
          });
        }
      },
    );
  }

  void checkVendorTypeOnlyHasReceiveRehalf() async {
    try {
      final vendorTypes = await VendorTypeRequest().index();
      if (vendorTypes.length == 1 &&
          vendorTypes.first.slug == "receive_behalf") {
        setState(() {
          GlobalVariable.showHomePage = false;
          showHomePage = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DoubleBack(
      message: "Press back again to close".tr(),
      child: ViewModelBuilder<HomeViewModel>.reactive(
        viewModelBuilder: () => vm,
        builder: (context, model, child) {
          return BasePage(
            body: UpgradeAlert(
              upgrader: Upgrader(
                // showIgnore: !AppUpgradeSettings.forceUpgrade(),
                shouldPopScope: () => !AppUpgradeSettings.forceUpgrade(),
                dialogStyle: Platform.isIOS
                    ? UpgradeDialogStyle.cupertino
                    : UpgradeDialogStyle.material,
              ),
              child: PageView(
                controller: model.pageViewController,
                onPageChanged: model.onPageChanged,
                children: [
                  if (showHomePage == true) ...[model.homeView],
                  OrdersPage(),
                  showSearch
                      ? MainSearchPage()
                      : NotificationsPage(
                          showLeading: false,
                        ),
                  ProfilePage(),
                ],
              ),
            ),
            fab: (showHomePage == true)
                ? totalCartItems > 0
                    ? fab
                    : null
                : null,
            fabLocation: AppUISettings.showCart
                ? (showHomePage == true)
                    ? FloatingActionButtonLocation.endFloat
                    : FloatingActionButtonLocation.miniEndDocked
                : null,
            bottomNavigationBar: AnimatedBottomNavigationBar.builder(
              itemCount: GlobalVariable.showHomePage
                  ? ((showHomePage == true) ? 4 : 3)
                  : (showHomePage == false ? 3 : 4),
              backgroundColor: Theme.of(context).colorScheme.surface,
              blurEffect: true,
              shadow: BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                blurRadius: 10,
              ),
              activeIndex: model.currentIndex,
              onTap: model.onTabChange,
              gapLocation:
                  showHomePage == true ? GapLocation.none : GapLocation.none,
              notchSmoothness: NotchSmoothness.softEdge,
              leftCornerRadius: 14,
              rightCornerRadius: 14,
              tabBuilder: (int index, bool isActive) {
                (showHomePage == true) ? showSearch = true : showSearch = false;
                final color = isActive
                    ? AppColor.primaryColor
                    : Theme.of(context).textTheme.bodyLarge?.color;
                List<String> titles = [
                  if (showHomePage == true) ...["Home".tr()],
                  "Activity".tr(),
                  showSearch ? "Search".tr() : "Notifications".tr(),
                  "More".tr(),
                ];
                List<IconData> icons = [
                  if (showHomePage == true) ...[FlutterIcons.home_ant],
                  FlutterIcons.inbox_ant,
                  showSearch
                      ? FlutterIcons.search_fea
                      : Icons.notifications_none_rounded,
                  FlutterIcons.menu_fea,
                ];
                Widget tab = Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icons[index],
                      size: 20,
                      color: color,
                    ),
                    titles[index]
                        .text
                        .fontWeight(
                          isActive ? FontWeight.bold : FontWeight.normal,
                        )
                        .size(3)
                        .color(color)
                        .scale(1)
                        .make(),
                  ],
                );
                //
                return tab;
              },
            ),
          );
        },
      ),
    );
  }

  //Kiểm tra trước khi show cart hoặc wallet
  Widget? getFab() {
    return ViewModelBuilder<WelcomeViewModel>.reactive(
        viewModelBuilder: () => WelcomeViewModel(context),
        onViewModelReady: (model) => model.initialise(),
        builder: (context, model, child) {
          bool showServices = false;
          bool showProducts = false;
          bool lstShowCart = model.vendorTypes
              .where((vendorType) =>
                  vendorType.slug == 'food' ||
                  vendorType.slug == "grocery" ||
                  vendorType.slug == 'commerce' ||
                  vendorType.slug == 'pharmacy')
              .toList()
              .isNotEmpty;
          for (var vendorType in model.vendorTypes) {
            if (vendorType.isService || vendorType.isBooking) {
              showServices = true;
            } else if (vendorType.isProduct) {
              showProducts = true;
            }
          }
          (showHomePage == true) ? showSearch = true : showSearch = false;
          if (showServices && showProducts) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                showSearch = true; // Cập nhật giá trị của showSearch
              });
            });
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                showSearch = false; // Cập nhật giá trị của showSearch
              });
            });
          }
          return ViewModelBuilder<HomeViewModel>.reactive(
              disposeViewModel: false,
              viewModelBuilder: () => vm,
              builder: (context, vm, child) {
                return lstShowCart ? CartHomeFab(vm) : WalletHomeFab(vm);
              });
        });
  }
}
