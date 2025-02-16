import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/models/user.dart';
import 'package:sod_user/services/auth.service.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/utils/utils.dart';
import 'package:sod_user/view_models/loyalty_point.vm.dart';
import 'package:sod_user/view_models/profile.vm.dart';
import 'package:sod_user/views/pages/auth/login.page.dart';
import 'package:sod_user/views/pages/loyalty/loyalty_point.page.dart';
import 'package:sod_user/views/pages/notification/notifications.page.dart';
import 'package:sod_user/views/pages/profile/edit_profile.page.dart';
import 'package:sod_user/widgets/busy_indicator.dart';
import 'package:sod_user/widgets/cards/custom.visibility.dart';
import 'package:sod_user/widgets/custom_image.view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class WelcomeIntroView extends StatelessWidget {
  const WelcomeIntroView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ProfileViewModel vm = ProfileViewModel(context);
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: !Utils.isArabic ? Alignment.centerLeft : Alignment.centerRight,
      child: VStack(
        [
          //welcome intro and loggedin account name
          StreamBuilder(
            stream: AuthServices.listenToAuthState(),
            builder: (ctx, snapshot) {
              //
              String introText = "Welcome".tr();
              String fullIntroText = introText;
              //
              if (snapshot.hasData) {
                return FutureBuilder<User>(
                  future: AuthServices.getCurrentUser(),
                  builder: (ctx, snapshot) {
                    if (snapshot.hasData) {
                      final user = snapshot.data;
                      return HStack(
                        [
                          InkWell(
                            onTap: () {
                              vm.openProfileDetail();
                            },
                            child: CustomImage(
                              imageUrl: user!.photo,
                            ).box.roundedFull.shadowSm.make().wh(50, 50),
                          ),
                          UiSpacer.hSpace(15),
                          //
                          VStack(
                            [
                              //name
                              HStack([
                                "Hello"
                                    .tr()
                                    .text
                                    .lg
                                    .fontWeight(FontWeight.w500)
                                    .color(context.backgroundColor)
                                    .make(),
                                ", ${snapshot.data?.name}"
                                    .text
                                    .lg
                                    .fontWeight(FontWeight.w900)
                                    .bold
                                    .color(context.backgroundColor)
                                    .make(),
                              ]),
                              UiSpacer.vSpace(10),
                              InkWell(
                                onTap: () {
                                  context.nextPage(LoyaltyPointPage());
                                },
                                child: Container(
                                  width: 180,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.horizontal(
                                          left: Radius.circular(50),
                                          right: Radius.circular(50))),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/con_heo.jpg',
                                        width: 30,
                                        height: 30,
                                      ),

                                      getPoint(context)

                                      //Icon(Icons.),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                          UiSpacer.hSpace(100),
                          notificationButton(context)
                        ],
                      ).pOnly(bottom: 10);
                      // fullIntroText = "$introText ${snapshot.data?.name}";
                      // final user = snapshot.data;
                      // return HStack(
                      //   [
                      //     CustomImage(
                      //       imageUrl: user!.photo,
                      //     ).box.roundedFull.shadowSm.make().wh(50, 50),
                      //     UiSpacer.hSpace(15),
                      //     //
                      //     VStack(
                      //       [
                      //         //name
                      //         fullIntroText.text
                      //             .color(Utils.textColorByTheme())
                      //             .xl
                      //             .semiBold
                      //             .make(),
                      //         //email
                      //         "${user.email}"
                      //             .hidePartial(
                      //               begin: 3,
                      //               end: "${user.email}".length - 8,
                      //             )!
                      //             .text
                      //             .color(Utils.textColorByTheme())
                      //             .sm
                      //             .thin
                      //             .make(),
                      //       ],
                      //     ),
                      //   ],
                      // ).pOnly(bottom: 10);
                    } else {
                      //auth but not data received
                      return Column(
                        children: [
                          fullIntroText.text.white.xl3.semiBold.make(),
                          "Sign in here"
                              .tr()
                              .text
                              .white
                              .xl
                              .medium
                              .underline
                              .make()
                              .onTap(() {
                            context.nextPage(LoginPage());
                          }).pOnly(top: 10),
                        ],
                      );
                    }
                  },
                );
              }
              return Column(
                children: [
                  fullIntroText.text.white.xl3.semiBold.make(),
                  "Sign in here"
                      .tr()
                      .text
                      .white
                      .xl
                      .medium
                      .underline
                      .make()
                      .onTap(() {
                    context.nextPage(LoginPage());
                  }).pOnly(top: 10),
                ],
              );
            },
          ),
          //
        ],
      ),
    ).p20();
  }

  getPoint(BuildContext context) {
    return ViewModelBuilder<LoyaltyPointViewModel>.reactive(
        viewModelBuilder: () => LoyaltyPointViewModel(context),
        onViewModelReady: (vm) => vm.initialise(),
        builder: (context, vm, child) {
          point = vm.loyaltyPoint?.points;
          return point == null
              ? BusyIndicator()
              : Text(
                  "${point} ${"Points".tr()}",
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColor.cancelledColor),
                );
        });
  }

  InkWell notificationButton(BuildContext context) {
    return InkWell(
      onTap: () {
        context.nextPage(NotificationsPage());
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(50),
        ),
        width: 50,
        height: 50,
        child: Icon(
          Icons.notifications_none_outlined,
          size: 45,
          color: context.backgroundColor,
        ),
      ),
    );
  }
}

double? point;
