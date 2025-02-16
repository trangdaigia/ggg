import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_user/driver_lib/constants/app_colors.dart';
import 'package:sod_user/driver_lib/constants/app_routes.dart';
import 'package:sod_user/driver_lib/constants/app_strings.dart';
import 'package:sod_user/driver_lib/constants/app_text_styles.dart';
import 'package:sod_user/driver_lib/constants/app_ui_settings.dart';
import 'package:sod_user/driver_lib/extensions/dynamic.dart';
import 'package:sod_user/driver_lib/utils/ui_spacer.dart';
import 'package:sod_user/driver_lib/view_models/profile.vm.dart';
import 'package:sod_user/driver_lib/views/pages/order/orders.page.dart';
import 'package:sod_user/driver_lib/views/pages/profile/finance.page.dart';
import 'package:sod_user/driver_lib/views/pages/profile/legal.page.dart';
import 'package:sod_user/driver_lib/views/pages/profile/support.page.dart';
import 'package:sod_user/driver_lib/views/pages/profile/widget/document_request.view.dart';
import 'package:sod_user/driver_lib/views/pages/profile/widget/driver_type.switch.dart';
import 'package:sod_user/driver_lib/constants/app_languages.dart';
import 'package:sod_user/driver_lib/views/pages/vehicle/vehicles.page.dart';
import 'package:sod_user/driver_lib/widgets/buttons/custom_button.dart';
import 'package:sod_user/driver_lib/widgets/cards/profile.card.dart';
import 'package:sod_user/driver_lib/widgets/menu_item.dart';
import '../../../../flavors.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class HomeMenuView extends StatelessWidget {
  const HomeMenuView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ProfileViewModel>.reactive(
      viewModelBuilder: () => ProfileViewModel(context),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return Stack(
          children: [
            VStack(
              [
                //profile card
                ProfileCard(model),
                12.heightBox,

                // //if driver switch is enabled
                // if (model.checkVendorHasSlug("taxi") &&
                //     (model.checkVendorHasSlug("shipping") ||
                //         model.checkVendorHasSlug("food") ||
                //         model.checkVendorHasSlug("service"))) ...[
                //   DriverTypeSwitch(),
                // ],
                CustomButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.homeRoute),
                  title: "Orders".tr(),
                ).pOnly(bottom: 10),
                //document verification
                if (model.checkSlugIsActive()) ...[
                  DocumentRequestView(),
                ],

                if (model.checkVendorHasSlug("rental driver") ||
                    model.checkVendorHasSlug("shipping") ||
                    model.checkVendorHasSlug("taxi")) ...[
                  Visibility(
                    visible: AppUISettings.enableDriverTypeSwitch ||
                        model.currentUser!.isTaxiDriver,
                    child: MenuItem(
                      title: "Manage services".tr(),
                      onPressed: () {
                        context.nextPage(VehiclesPage());
                      },
                      topDivider: true,
                      suffix: Icon(
                        FlutterIcons.car_faw,
                        size: 18,
                      ),
                    ),
                  ),
                ],
                // orders
                MenuItem(
                  title: "Orders".tr(),
                  onPressed: () {
                    context.nextPage(OrdersPage());
                  },
                  suffix: Icon(
                    FlutterIcons.list_alt_faw,
                    size: 18,
                  ),
                ),

                MenuItem(
                  title: "Finance".tr(),
                  onPressed: () {
                    context.nextPage(FinancePage());
                  },
                  suffix: Icon(
                    FlutterIcons.finance_mco,
                    size: 18,
                  ),
                ),

                //menu
                VStack(
                  [
                    //
                    MenuItem(
                      title: "Notifications".tr(),
                      onPressed: model.openNotification,
                      suffix: Icon(
                        FlutterIcons.bell_faw,
                        size: 18,
                      ),
                    ),

                    //
                    MenuItem(
                      title: "Messages".tr(),
                      onPressed: model.openMessages,
                      suffix: Icon(
                        FlutterIcons.chat_mdi,
                        size: 18,
                      ),
                    ),

                    //
                    MenuItem(
                      title: "Rate & Review".tr(),
                      onPressed: model.openReviewApp,
                      suffix: Icon(
                        FlutterIcons.rate_review_mdi,
                        size: 18,
                      ),
                    ),

                    MenuItem(
                      title: "Faqs".tr(),
                      onPressed: model.openFaqs,
                      suffix: Icon(
                        FlutterIcons.question_circle_faw,
                        size: 18,
                      ),
                    ),

                    //
                    MenuItem(
                      title: "Legal".tr(),
                      onPressed: () {
                        context.nextPage(LegalPage());
                      },
                      suffix: Icon(
                        FlutterIcons.legal_faw,
                        size: 18,
                      ),
                    ),
                    MenuItem(
                      title: "Support".tr(),
                      onPressed: () {
                        context.nextPage(SupportPage());
                      },
                      suffix: Icon(
                        FlutterIcons.support_faw,
                        size: 18,
                      ),
                    ),

                    //
                    if (AppLanguages.canChangeLanguage)
                      MenuItem(
                        title: "Language".tr(),
                        suffix: Icon(
                          FlutterIcons.language_ent,
                          size: 17,
                          color: AppColor.cancelledColor,
                        ),
                        onPressed: model.changeLanguage,
                      ),
                    //
                    if (F.appFlavor == Flavor.sod_delivery)
                      MenuItem(
                        title: "URL API".tr(),
                        divider: false,
                        onPressed: model.openApiUrl,
                        suffix: Icon(
                          FlutterIcons.link_faw,
                          size: 18,
                        ),
                      ),
                  ],
                ),

                //
                MenuItem(
                  child: "Logout"
                      .tr()
                      .text
                      .textStyle(
                        AppTextStyle.h4TitleTextStyle(
                            color: Colors.red.shade500),
                      )
                      .make(),
                  onPressed: model.logoutPressed,
                  divider: false,
                  suffix: Icon(
                    FlutterIcons.logout_ant,
                    size: 16,
                    color: AppColor.cancelledColor,
                  ),
                ),

                UiSpacer.vSpace(15),

                //
                ("Version".tr() + " - ${model.appVersionInfo}")
                    .text
                    .center
                    .sm
                    .makeCentered()
                    .py20(),
                "Copyright ©%s %s all right reserved"
                    .tr()
                    .fill([
                      "${DateTime.now().year}",
                      AppStrings.companyName,
                    ])
                    .text
                    .center
                    .sm
                    .makeCentered()
                    .py20(),
              ],
            )
                .p(18)
                .scrollVertical()
                .hFull(context)
                .box
                .color(context.colors.surface)
                .topRounded(value: 20)
                .make()
                .pOnly(top: 20),

            //close
            IconButton(
              icon: Icon(
                FlutterIcons.close_ant,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ).box.roundedFull.red500.make().positioned(top: 0, right: 20),
          ],
        );
      },
    );
  }
}
