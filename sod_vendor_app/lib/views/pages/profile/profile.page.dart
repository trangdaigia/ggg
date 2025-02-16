import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_vendor/constants/app_colors.dart';
import 'package:sod_vendor/constants/app_strings.dart';
import 'package:sod_vendor/extensions/dynamic.dart';
import 'package:sod_vendor/utils/ui_spacer.dart';
import 'package:sod_vendor/view_models/profile.vm.dart';
import 'package:sod_vendor/widgets/base.page.dart';
import 'package:sod_vendor/widgets/cards/profile.card.dart';
import 'package:sod_vendor/widgets/menu_item.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import '../../../../flavors.dart';
import 'package:sod_vendor/constants/app_languages.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: ViewModelBuilder<ProfileViewModel>.reactive(
        viewModelBuilder: () => ProfileViewModel(context),
        onViewModelReady: (model) => model.initialise(),
        builder: (context, model, child) {
          return BasePage(
            body: VStack(
              [
                //
                "Settings".tr().text.xl2.semiBold.make(),
                "Profile & App Settings".tr().text.lg.light.make(),

                //profile card
                ProfileCard(model).py12(),
                UiSpacer.vSpace(20),

                //menu
                VxBox(
                  child: VStack(
                    [
                      //
                      MenuItem(
                        title: "Notifications".tr(),
                        onPressed: model.openNotification,
                        suffix: Icon(
                          FlutterIcons.bell_faw,
                          size: 16,
                          color: Vx.black,
                        ),
                      ),

                      //
                      MenuItem(
                        title: "Messages".tr(),
                        onPressed: model.openMessages,
                        suffix: Icon(
                          FlutterIcons.chat_bubble_mdi,
                          size: 16,
                          color: Vx.black,
                        ),
                      ),

                      //
                      MenuItem(
                        title: "Rate & Review".tr(),
                        onPressed: model.openReviewApp,
                        suffix: Icon(
                          FlutterIcons.rate_review_mdi,
                          size: 16,
                          color: Vx.black,
                        ),
                      ),
                      MenuItem(
                        title: "Faqs".tr(),
                        onPressed: model.openFaqs,
                        suffix: Icon(
                          FlutterIcons.question_circle_faw,
                          size: 16,
                          color: Vx.black,
                        ),
                      ),
                      //
                      MenuItem(
                        title: "Verison".tr(),
                        trailing: model.appVersionInfo.text.make(),
                        suffix: Icon(
                          FlutterIcons.versions_oct,
                          size: 16,
                          color: Vx.black,
                        ),
                      ),

                      //
                      MenuItem(
                        title: "Privacy Policy".tr(),
                        onPressed: model.openPrivacyPolicy,
                        suffix: Icon(
                          FlutterIcons.book_faw,
                          size: 16,
                          color: Vx.black,
                        ),
                      ),
                      //
                      MenuItem(
                        title: "Contact Us".tr(),
                        onPressed: model.openContactUs,
                        suffix: Icon(
                          FlutterIcons.phone_faw,
                          size: 16,
                          color: Vx.black,
                        ),
                      ),
                      MenuItem(
                        title: "Live support".tr(),
                        onPressed: model.openLivesupport,
                        suffix: Icon(
                          FlutterIcons.chat_bubble_mdi,
                          size: 16,
                          color: Vx.black,
                        ),
                      ),
                      //
                      if (AppLanguages.canChangeLanguage)
                        MenuItem(
                          title: "Language".tr(),
                          suffix: Icon(
                            FlutterIcons.language_ent,
                            size: 17,
                            color: Vx.black,
                          ),
                          onPressed: model.changeLanguage,
                        ),
                      //
                      if (F.appFlavor == Flavor.sod_vendor)
                        MenuItem(
                          title: "URL API".tr(),
                          divider: false,
                          onPressed: model.openApiUrl,
                          suffix: Icon(
                            FlutterIcons.link_faw,
                            size: 16,
                            color: Vx.black,
                          ),
                        ),
                    ],
                  ),
                )
                    // .border(color: Theme.of(context).cardColor)
                    // .color(Theme.of(context).cardColor)
                    .color(Colors.white)
                    .outerShadow
                    .withRounded(value: 5)
                    .make(),

                //
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
            ).p20().scrollVertical(),
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
