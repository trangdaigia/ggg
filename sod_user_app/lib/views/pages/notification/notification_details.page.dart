import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_images.dart';
import 'package:sod_user/constants/app_routes.dart';
import 'package:sod_user/global/global_variable.dart';
import 'package:sod_user/models/notification.dart';
import 'package:sod_user/services/app.service.dart';
import 'package:sod_user/views/pages/shared_ride/shared_ride.page.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:sod_user/widgets/custom_image.view.dart';
import 'package:velocity_x/velocity_x.dart';

class NotificationDetailsPage extends StatelessWidget {
  const NotificationDetailsPage({
    required this.notification,
    Key? key,
  }) : super(key: key);

  final NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: notification.title,
      showAppBar: true,
      showLeadingAction: true,
      body: SafeArea(
        child: VStack(
          [
            // Logo
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(AppImages.appLogo),
            ).centered(),
            SizedBox(height: 16),

            //image
            if (notification.image != null && notification.image!.isNotEmpty)
              CustomImage(
                imageUrl: notification.image!,
                width: double.infinity,
                height: context.percentHeight * 30,
              ).py(16)
            else
              SizedBox(height: 10),

            //body
            notification.body.toString().tr().text.size(16).make(),
            const SizedBox(
              height: 10,
            ),
            
            Visibility(
              visible:
                  notification.body!.contains("vừa đặt chuyến xe của bạn") ||
                      (notification.body!
                          .contains("Có khách hàng thuê xe của bạn")),
              child: Center(
                child: CustomButton(
                  onPressed: () {
                    notification.body!.contains("vừa đặt chuyến xe của bạn")
                        ? context.nextPage(SharedRidePage())
                        : {
                            (Navigator.of(
                                    AppService().navigatorKey.currentContext!)
                                .pushNamed(AppRoutes.carManagement)),
                            GlobalVariable.activeSecondIndex = true
                          };
                  },
                  padding: EdgeInsets.all(0),
                  title: "See my trip".tr(),
                ).px(15),
              ),
            )
          ],
        ).p(16).scrollVertical(),
      ),
    );
  }
}
