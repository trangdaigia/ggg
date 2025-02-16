import 'package:flutter/material.dart';
import 'package:flutter_overboard/flutter_overboard.dart';
import 'package:sod_user/driver_lib/constants/app_colors.dart';
import 'package:sod_user/driver_lib/utils/utils.dart';
import 'package:sod_user/driver_lib/view_models/onboarding.vm.dart';
import 'package:sod_user/driver_lib/widgets/base.page.dart';
import 'package:sod_user/driver_lib/widgets/busy_indicator.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class OnboardingPage extends StatefulWidget {
  OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      body: ViewModelBuilder<OnboardingViewModel>.nonReactive(
        viewModelBuilder: () => OnboardingViewModel(context, finishLoading),
        onViewModelReady: (vm) => vm.initialise(),
        builder: (context, vm, child) {
          return VStack(
            [
              Visibility(
                visible: vm.isBusy,
                child: BusyIndicator().centered().expand(),
              ),
              //
              Visibility(
                visible: !vm.isBusy,
                child: Directionality(
                  textDirection: Utils.textDirection,
                  child: OverBoard(
                    pages: vm.onBoardData,
                    showBullets: true,
                    skipText: "Skip".tr(),
                    nextText: "Next".tr(),
                    finishText: "Done".tr(),
                    skipCallback: vm.onDonePressed,
                    finishCallback: vm.onDonePressed,
                    buttonColor: AppColor.primaryColor,
                    inactiveBulletColor: AppColor.accentColor,
                    activeBulletColor: AppColor.primaryColorDark,
                  ).expand(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  finishLoading() {
    setState(() {});
  }
}
