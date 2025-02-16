import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_images.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/constants/app_text_styles.dart';
import 'package:sod_user/models/vendor_type.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/view_models/parcel.vm.dart';
import 'package:sod_user/views/pages/parcel/new_parcel.page.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:sod_user/widgets/custom_text_form_field.dart';
import 'package:sod_user/widgets/recent_orders.view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class ParcelPage extends StatefulWidget {
  ParcelPage(this.vendorType, {Key? key}) : super(key: key);

  final VendorType vendorType;

  @override
  _ParcelPageState createState() => _ParcelPageState();
}

class _ParcelPageState extends State<ParcelPage> {
  //
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ParcelViewModel>.reactive(
      viewModelBuilder: () =>
          ParcelViewModel(context, vendorType: widget.vendorType),
      builder: (context, vm, child) {
        return BasePage(
          showAppBar: true,
          showLeadingAction: !AppStrings.isSingleVendorMode,
          elevation: 0,
          showCart: true,
          title: "${vm.vendorType?.name}",
          //appBarColor: AppColor.primaryColor,
          //appBarItemColor: context.theme.colorScheme.background,
          key: vm.pageKey,
          body: SmartRefresher(
            enablePullDown: true,
            enablePullUp: false,
            controller: vm.refreshController,
            onRefresh: vm.reloadPage,
            child: VStack(
              [
                //header
                VStack(
                  [
                    //
                    "Track your package"
                        .tr()
                        .text
                        .semiBold
                        .color(context.backgroundColor)
                        .xl4
                        .make(),
                    //
                    CustomTextFormField(
                      colorHintText: Colors.white, // labelText: "Order Code",
                      isReadOnly: vm.isBusy,
                      hintText: "Search by order code".tr(),
                      onFieldSubmitted: vm.trackOrder,
                      fillColor: Colors.white,
                      textColor: Colors.white,
                    ).py12(),
                  ],
                ).p20().box.color(AppColor.primaryColor).make(),

                //
                UiSpacer.verticalSpace(),
                CustomButton(
                  child: HStack(
                    [
                      Icon(
                        Icons.add,
                        color: context.theme.colorScheme.onPrimary,
                      ),
                      5.widthBox,
                      "New Parcel Order"
                          .tr()
                          .text
                          .textStyle(
                            AppTextStyle.h4TitleTextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          )
                          .make(),
                    ],
                  ).p12(),
                  onPressed: () {
                    //open the new parcel page
                    context.nextPage(
                      NewParcelPage(
                        widget.vendorType,
                      ),
                    );
                  },
                ).wFull(context).px20(),

                //recent orders
                UiSpacer.verticalSpace(),
                RecentOrdersView(
                  vendorType: widget.vendorType,
                  emptyView: VStack(
                    [
                      20.heightBox,
                      Image.asset(
                        AppImages.emptyParcelOrder,
                        height: context.percentHeight * 20,
                      ),
                      10.heightBox,
                      "No Recent Parcel Orders"
                          .tr()
                          .text
                          .semiBold
                          .xl
                          .center
                          .makeCentered(),
                      5.heightBox,
                      "There are no recent parcel orders to display at the moment."
                          .tr()
                          .text
                          .lg
                          .medium
                          .center
                          .makeCentered(),
                      20.heightBox,
                    ],
                    crossAlignment: CrossAxisAlignment.center,
                    alignment: MainAxisAlignment.center,
                  ),
                ),
                UiSpacer.verticalSpace(),
              ],
            ).scrollVertical(),
          ),
        );
      },
    );
  }
}
