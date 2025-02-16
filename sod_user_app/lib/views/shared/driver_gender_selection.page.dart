import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/view_models/taxi.vm.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/widgets/custom_list_view.dart';
import 'package:sod_user/widgets/list_items/driver_gender.list_item.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class DriverGenderSelectionPage extends StatelessWidget {
  DriverGenderSelectionPage(
    this.taxiViewModel,
    {
    Key? key,
  }) : super(key: key);

  final TaxiViewModel taxiViewModel;
  final List<String> genderList = ["Male", "Female"];

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      title: "Select driver gender".tr(),
      body: VStack(
        [
          CustomListView(
            dataSet: genderList,
            separatorBuilder: (ctx, index) => UiSpacer.vSpace(10),
            itemBuilder: (ctx, index) {
              final gender = genderList[index];
              final selected = (taxiViewModel.requestDriverGenderMan && gender == "Male") || (!taxiViewModel.requestDriverGenderMan && gender == "Female");
              final borderCorlor = selected
              ? AppColor.primaryColor
              : context.textTheme.bodyLarge!.color!.withOpacity(0.20);
              final double borderWidth = selected ? 2 : 1;

              return DriverGenderOptionListItem(taxiViewModel, gender, borderCorlor, borderWidth);
            },
          ).p12(),
        ],
      ),
    );
  }
}
