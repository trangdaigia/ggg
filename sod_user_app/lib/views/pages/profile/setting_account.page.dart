import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_user/flavors.dart';
import 'package:sod_user/resources/resources.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:sod_user/widgets/menu_item.dart';
import 'package:sod_user/view_models/profile.vm.dart';

class SettingAccountPage extends StatelessWidget {
  const SettingAccountPage({Key? key, required this.model}) : super(key: key);
  
  final ProfileViewModel model;
  //const SettingAccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //
    return BasePage(
      title: "Setting Account".tr(),
      showLeadingAction: true,
      showAppBar: true,
      body: ViewModelBuilder<ProfileViewModel>.reactive(
        viewModelBuilder: () => ProfileViewModel(context),
        onViewModelReady: (vm) => vm.initialise(),
        builder: (context, vm, child) {
          return VStack(
            [
              UiSpacer.vSpace(),
              MenuItem(
                title: "Edit Profile".tr(),
                onPressed: model.openEditProfile,
                ic: AppIcons.edit,
              ),
              //change password
              MenuItem(
                title: "Change Password".tr(),
                onPressed: model.openChangePassword,
                ic: AppIcons.password,
              ),
              MenuItem(
                title: "Logout".tr(),
                onPressed: model.logoutPressed,
                ic: AppIcons.logout,
              ),
              MenuItem(
                title: "Delete Account".tr(),
                onPressed: model.deleteAccount,
                ic: AppIcons.delete,
              ),
              if (F.appFlavor == Flavor.sod_user)
                MenuItem(
                  title: "URL API".tr(),
                  onPressed: model.openApiUrl,
                  ic: AppIcons.url,
                ),
                      //
                      UiSpacer.vSpace(15),
            ],
          ).scrollVertical();
          },
      ),
    );
  }
}
