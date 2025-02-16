import 'package:flutter/material.dart';
import 'package:flutter_overboard/flutter_overboard.dart';
import 'package:sod_vendor/constants/app_images.dart';
import 'package:sod_vendor/constants/app_routes.dart';
import 'package:sod_vendor/requests/settings.request.dart';
import 'package:sod_vendor/services/auth.service.dart';
import 'package:sod_vendor/utils/ui_spacer.dart';
import 'package:sod_vendor/utils/utils.dart';
import 'package:sod_vendor/widgets/custom_image.view.dart';
import 'base.view_model.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class OnboardingViewModel extends MyBaseViewModel {
  OnboardingViewModel(BuildContext context, this.finishLoading) {
    this.viewContext = context;
  }

  final Function finishLoading;

  List<PageModel> onBoardData = [];

  initialise() {
    final bgColor = viewContext.theme.colorScheme.background;
    final textColor =
        Utils.textColorByColor(viewContext.theme.colorScheme.background);

    onBoardData = [
      PageModel(
        color: bgColor,
        titleColor: textColor,
        bodyColor: textColor,
        imageAssetPath: AppImages.onboarding1,
        title: "Take Orders".tr(),
        body: "Get notified as soon as an order is place".tr(),
        doAnimateImage: true,
      ),
      PageModel(
        color: bgColor,
        titleColor: textColor,
        bodyColor: textColor,
        imageAssetPath: AppImages.onboarding2,
        title: "Chat with driver/customer".tr(),
        body:
            "Call/Chat with driver/delivery boy for update about your order and more"
                .tr(),
        doAnimateImage: true,
      ),
      PageModel(
        color: bgColor,
        titleColor: textColor,
        bodyColor: textColor,
        imageAssetPath: AppImages.onboarding3,
        title: "Earning".tr(),
        body: "See your earning increase with demand".tr(),
        doAnimateImage: true,
      ),
    ];
    //
    loadOnboardingData();
  }

  loadOnboardingData() async {
    setBusy(true);
    try {
      final apiResponse = await SettingsRequest().appOnboardings();
      //load the data
      if (apiResponse.allGood) {
        final mOnBoardDatas = (apiResponse.body as List).map(
          (e) {
            return PageModel.withChild(
              child: VStack(
                [
                  Padding(
                    padding: new EdgeInsets.only(bottom: 25.0),
                    child: CustomImage(
                      imageUrl: "${e['photo']}",
                      width: viewContext.percentWidth * 90,
                      height: viewContext.percentWidth * 90,
                      boxFit: BoxFit.cover,
                    ).centered(),
                  ),
                  "${e["title"]}".tr().text.xl3.bold.make(),
                  UiSpacer.vSpace(5),
                  "${e["description"]}".tr().text.lg.hairLine.make(),
                ],
              ).p20(),
              color: viewContext.theme.colorScheme.background,
              doAnimateChild: true,
            );
          },
        ).toList();
        //
        if (mOnBoardDatas.isNotEmpty) {
          onBoardData = mOnBoardDatas;
        }
      } else {
        toastError("${apiResponse.message}");
      }
    } catch (error) {
      toastError("$error");
    }
    setBusy(false);
    finishLoading();
  }

  void onDonePressed() async {
    //
    await AuthServices.firstTimeCompleted();
    Navigator.of(viewContext).pushNamedAndRemoveUntil(
      AppRoutes.loginRoute,
      (route) => false,
    );
  }
}
