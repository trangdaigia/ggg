import 'package:flutter/material.dart';
import 'package:sod_vendor/utils/ui_spacer.dart';
import 'package:sod_vendor/utils/utils.dart';
import 'package:sod_vendor/view_models/vendor_switcher.vm.dart';
import 'package:sod_vendor/widgets/custom_image.view.dart';
import 'package:sod_vendor/widgets/custom_list_view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:sod_vendor/widgets/busy_indicator.dart';

class VendorSwitcherBottomSheetView extends StatefulWidget {
  const VendorSwitcherBottomSheetView({Key? key}) : super(key: key);
  @override
  _VendorSwitcherBottomSheetViewState createState() =>
      _VendorSwitcherBottomSheetViewState();
}

class _VendorSwitcherBottomSheetViewState
    extends State<VendorSwitcherBottomSheetView> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<VendorSwitcherBottomSheetViewModel>.reactive(
      viewModelBuilder: () => VendorSwitcherBottomSheetViewModel(),
      onViewModelReady: (viewModel) => viewModel.fetchMyVendors(),
      builder: (
        BuildContext context,
        VendorSwitcherBottomSheetViewModel model,
        Widget? child,
      ) {
        return Scaffold(
          body: VStack(
            [
              //
              VStack(
                [
                  "List of vendors".tr().text.xl2.semiBold.make(),
                  "Please select a vendor to switch to".tr().text.make(),
                ],
              ).p(12),
              UiSpacer.divider(),
              CustomListView(
                dataSet: model.vendors,
                isLoading: model.busy(model.vendors),
                itemBuilder: (context, index) {
                  final vendor = model.vendors[index];
                  return AbsorbPointer(
                    absorbing: model.isBusy,
                    child: ListTile(
                      onTap: () {
                        model.switchVendor(vendor);
                      },
                      leading: CustomImage(
                        imageUrl: vendor.logo,
                        width: 30,
                        height: 30,
                      ),
                      title: "${vendor.name}".text.make(),
                      subtitle:
                          "${vendor.address}".text.ellipsis.maxLines(1).make(),
                      trailing: model.busy(vendor.id)
                          ? BusyIndicator(
                              color: context.primaryColor,
                            )
                          : Icon(
                              Utils.isArabic
                                  ? Icons.chevron_left
                                  : Icons.chevron_right,
                              color: context.theme.primaryColor,
                            ),
                    ),
                  );
                },
              ).expand(),
            ],
          ),
        );
      },
    );
  }
}
