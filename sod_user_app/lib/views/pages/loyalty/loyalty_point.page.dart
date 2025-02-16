import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_finance_settings.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/extensions/string.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/utils/utils.dart';
import 'package:sod_user/view_models/loyalty_point.vm.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:sod_user/widgets/custom_list_view.dart';
import 'package:sod_user/widgets/list_items/loyalty_point_report.list_item.dart';
import 'package:sod_user/widgets/states/loading_indicator.dart';
import 'package:sod_user/widgets/states/loyalty_point.empty.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class LoyaltyPointPage extends StatelessWidget {
  const LoyaltyPointPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //
    return BasePage(
      title: "Loyalty Points".tr(),
      showLeadingAction: true,
      showAppBar: true,
      body: ViewModelBuilder<LoyaltyPointViewModel>.reactive(
        viewModelBuilder: () => LoyaltyPointViewModel(context),
        onViewModelReady: (vm) => vm.initialise(),
        builder: (context, vm, child) {
          return VStack(
            [
              UiSpacer.vSpace(),
              //points section
              LoadingIndicator(
                loading: vm.isBusy,
                child: GlassContainer(
                  height: 130,
                  margin: EdgeInsets.zero,
                  width: context.screenWidth,
                  borderColor: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  gradient: LinearGradient(
                    colors: [
                      AppColor.primaryColor.withOpacity(0.35),
                      AppColor.primaryColor.withOpacity(0.50),
                      AppColor.primaryColor.withOpacity(0.80),
                      AppColor.primaryColor.withOpacity(0.99),
                      // AppColor.primaryColorDark,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.30, 0.60, 1.0],
                  ),
                  blur: 5.0,
                  isFrostedGlass: true,
                  frostedOpacity: 0.50,
                  shadowColor: AppColor.primaryColor.withOpacity(0.50),
                  child: HStack(
                    [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          MediaQuery(
                            data: MediaQuery.of(context)
                                .copyWith(textScaler: TextScaler.linear(1.0)),
                            child: Text(
                              '${vm.loyaltyPoint?.points}',
                              style: TextStyle(
                                fontSize: 40.0,
                                fontWeight: FontWeight.w600,
                                color: Utils.textColorByTheme(),
                                shadows: [
                                  Shadow(
                                    offset: Offset(0.0, 0.0),
                                    blurRadius: 2.0,
                                    color: AppColor.primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 8.0),
                          MediaQuery(
                            data: MediaQuery.of(context)
                                .copyWith(textScaler: TextScaler.linear(1.0)),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Text(
                                'Points'.tr(),
                                style: TextStyle(
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.w600,
                                  color: Utils.textColorByTheme(),
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0.0, 0.0),
                                      blurRadius: 2.0,
                                      color: AppColor.primaryColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ).p12().expand(),

                      //
                      VStack(
                        [
                          ("~ " +
                                  "${AppStrings.currencySymbol}${vm.estimatedAmount}"
                                      .currencyFormat())
                              .text
                              .semiBold
                              .xl
                              .color(Utils.textColorByTheme())
                              .make(),
                          //~ exchange rate
                          "Exchange Rate"
                              .tr()
                              .text
                              .sm
                              .color(Utils.textColorByTheme())
                              .make(),
                          ("1 point".tr() +
                                  " = " +
                                  "${AppStrings.currencySymbol} ${AppFinanceSettings.loyaltyPointsToAmount}"
                                      .currencyFormat())
                              .text
                              .medium
                              .color(Utils.textColorByTheme())
                              .make(),
                        ],
                      ),

                      //
                    ],
                  ).p12(),
                ),
              ).px20(),

              UiSpacer.vSpace(5),
              CustomButton(
                title: "Withdraw To Wallet".tr(),
                loading: vm.busy(vm.loyaltyPoint),
                onPressed: vm.showAmountEntry,
              ).px24().wFull(context),

              UiSpacer.divider().px20().py20(),
              //recent report
              "Recent report".tr().text.semiBold.lg.make().px20(),
              UiSpacer.vSpace(10),
              CustomListView(
                isLoading: vm.busy(vm.loyaltyPointReports),
                dataSet: vm.loyaltyPointReports,
                noScrollPhysics: true,
                itemBuilder: (ctx, index) {
                  final loyaltyPointReport = vm.loyaltyPointReports[index];
                  return LoyaltyPointReportListItem(loyaltyPointReport);
                },
                separatorBuilder: (ctx, index) => UiSpacer.vSpace(10),
                emptyWidget: EmptyLoyaltyPointReport(),
              ).px20(),
              UiSpacer.vSpace(),
            ],
          ).scrollVertical();
        },
      ),
    );
  }
}
