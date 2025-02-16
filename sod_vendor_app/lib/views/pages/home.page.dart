import 'dart:io';
import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_vendor/constants/app_colors.dart';
import 'package:sod_vendor/constants/app_upgrade_settings.dart';
import 'package:sod_vendor/utils/utils.dart';
import 'package:sod_vendor/views/pages/profile/profile.page.dart';
import 'package:sod_vendor/view_models/home.vm.dart';
import 'package:sod_vendor/views/pages/vendor/vendor_details.page.dart';
import 'package:sod_vendor/widgets/base.page.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:stacked/stacked.dart';
import 'package:upgrader/upgrader.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

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
  Widget build(BuildContext context) {
    return DoubleBack(
      message: "Press back again to close".tr(),
      child: ViewModelBuilder<HomeViewModel>.reactive(
        viewModelBuilder: () => HomeViewModel(context),
        onViewModelReady: (model) => model.initialise(),
        builder: (context, model, child) {
          return BasePage(
            body: UpgradeAlert(
              upgrader: Upgrader(
                showIgnore: !AppUpgradeSettings.forceUpgrade(),
                shouldPopScope: () => !AppUpgradeSettings.forceUpgrade(),
                dialogStyle: Platform.isIOS
                    ? UpgradeDialogStyle.cupertino
                    : UpgradeDialogStyle.material,
              ),
              child: PageView(
                controller: model.pageViewController,
                onPageChanged: model.onPageChanged,
                children: [
                  OrdersPage(),
                  //
                  Utils.vendorSectionPage(model.currentVendor),
                  VendorDetailsPage(),
                  ProfilePage(),
                ],
              ),
            ),
            bottomNavigationBar: VxBox(
              child: SafeArea(
                child: GNav(
                  gap: 8,
                  activeColor: Theme.of(context).primaryColor,
                  color: Colors.black,
                  iconSize: 24,
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  duration: Duration(seconds: 2),
                  curve: Curves.bounceInOut,
                  tabBackgroundColor: Colors.transparent,
                  style: GnavStyle.oldSchool,
                  textSize: 10,
                  tabBorderRadius: 0,
                  tabs: [
                    GButton(
                      icon: FlutterIcons.inbox_ant,
                      text: 'Orders'.tr(),
                    ),
                    GButton(
                      icon: Utils.vendorIconIndicator(model.currentVendor),
                      text: Utils.vendorTypeIndicator(model.currentVendor).tr(),
                    ),
                    GButton(
                      icon: FlutterIcons.briefcase_fea,
                      text: 'Vendor'.tr(),
                    ),
                    GButton(
                      icon: FlutterIcons.menu_fea,
                      text: 'More'.tr(),
                    ),
                  ],
                  selectedIndex: model.currentIndex,
                  onTabChange: model.onTabChange,
                ).py4(),
              ),
            )
                .px16
                .shadow
                .color(AppColor.onboarding3Color)
                .make(),
          );
        },
      ),
    );
  }
}
