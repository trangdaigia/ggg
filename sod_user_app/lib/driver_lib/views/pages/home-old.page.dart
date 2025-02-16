import 'dart:io';

import 'package:flutter/material.dart';
import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_user/driver_lib/constants/app_upgrade_settings.dart';
import 'package:sod_user/driver_lib/services/app.service.dart';
import 'package:sod_user/models/driver.dart';
import 'package:sod_user/services/auth.service.dart';
import 'package:sod_user/driver_lib/view_models/taxi/taxi.vm.dart';
import 'package:sod_user/driver_lib/views/pages/order/assigned_orders.page.dart';
import 'package:sod_user/driver_lib/views/pages/profile/profile.page.dart';
import 'package:sod_user/driver_lib/view_models/home.vm.dart';
import 'package:sod_user/driver_lib/views/pages/taxi/taxi_order.page.dart';
import 'package:sod_user/driver_lib/widgets/busy_indicator.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:upgrader/upgrader.dart';
import 'package:velocity_x/velocity_x.dart';

import 'order/orders.page.dart';

class HomePage extends StatefulWidget {
  HomePage({
    Key? key,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  //
  @override
  Widget build(BuildContext context) {
    return DoubleBack(
      message: "Press back again to close".tr(),
      child: ViewModelBuilder<HomeViewModel>.reactive(
        viewModelBuilder: () => HomeViewModel(context),
        onViewModelReady: (vm) => vm.initialise(),
        builder: (context, vm, child) {
          return Scaffold(
            body: UpgradeAlert(
              upgrader: Upgrader(
                showIgnore: !AppUpgradeSettings.forceUpgrade(),
                shouldPopScope: () => !AppUpgradeSettings.forceUpgrade(),
                dialogStyle: Platform.isIOS
                    ? UpgradeDialogStyle.cupertino
                    : UpgradeDialogStyle.material,
              ),
              child: PageView(
                controller: vm.pageViewController,
                physics: NeverScrollableScrollPhysics(),
                onPageChanged: vm.onPageChanged,
                children: [
                  FutureBuilder<Driver?>(
                    future: AuthServices.getCurrentDriver(),
                    builder: (ctx, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: BusyIndicator());
                      }
                      return (snapshot.data != null &&
                              !snapshot.data!.isTaxiDriver)
                          ? AssignedOrdersPage(
                              homeVm: vm,
                            )
                          : TaxiOrderPage(
                              taxiViewModel: TaxiViewModel(context),
                            );
                    },
                  ),
                  OrdersPage(),
                  ProfilePage(),
                ],
              ),
            ),
            floatingActionButton: vm.driverVehicle == null
                ? vm.isBusy
                    ? BusyIndicator()
                    : FloatingActionButton.extended(
                        icon: Icon(
                          !AppService().driverIsOnline
                              ? FlutterIcons.location_off_mdi
                              : FlutterIcons.location_on_mdi,
                          color: Colors.white,
                        ),
                        label: (AppService().driverIsOnline
                                ? "You are Online"
                                : "You are Offline")
                            .tr()
                            .text
                            .white
                            .make(),
                        backgroundColor: (AppService().driverIsOnline
                            ? Colors.green
                            : Colors.red),
                        onPressed: vm.toggleOnlineStatus,
                      )
                : null,
            bottomNavigationBar: VxBox(
              child: SafeArea(
                child: GNav(
                  gap: 8,
                  activeColor: Colors.white,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                  iconSize: 20,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  duration: Duration(milliseconds: 250),
                  tabBackgroundColor: Theme.of(context).primaryColor,
                  tabs: [
                    GButton(
                      icon: FlutterIcons.rss_fea,
                      text: 'Assigned'.tr(),
                    ),
                    GButton(
                      icon: FlutterIcons.inbox_ant,
                      text: 'Orders'.tr(),
                    ),
                    GButton(
                      icon: FlutterIcons.menu_fea,
                      text: 'More'.tr(),
                    ),
                  ],
                  selectedIndex: vm.currentIndex,
                  onTabChange: vm.onTabChange,
                ),
              ),
            )
                .p16
                .shadow
                .color(Theme.of(context).bottomSheetTheme.backgroundColor!)
                .make(),
          );
        },
      ),
    );
  }
}
