import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_user/driver_lib/constants/app_colors.dart';
import 'package:sod_user/driver_lib/constants/app_strings.dart';
import 'package:sod_user/driver_lib/constants/app_ui_settings.dart';
import 'package:sod_user/driver_lib/models/user.dart';
import 'package:sod_user/driver_lib/requests/driver_type.request.dart';
import 'package:sod_user/driver_lib/services/alert.service.dart';
import 'package:sod_user/services/auth.service.dart';
import 'package:sod_user/driver_lib/services/local_storage.service.dart';
import 'package:sod_user/driver_lib/utils/ui_spacer.dart';
import 'package:sod_user/driver_lib/utils/utils.dart';
import 'package:sod_user/driver_lib/view_models/taxi/taxi.vm.dart';
import 'package:sod_user/driver_lib/views/pages/splash.page.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:swipe_button_widget/swipe_button_widget.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../../services/app.service.dart';

class DriverTypeSwitch extends StatefulWidget {
  const DriverTypeSwitch({Key? key}) : super(key: key);

  @override
  State<DriverTypeSwitch> createState() => _DriverTypeSwitchState();
}

class _DriverTypeSwitchState extends State<DriverTypeSwitch> {
  ObjectKey viewKey = new ObjectKey(DateTime.now());
  bool isProcessing = false;
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<TaxiViewModel>.reactive(
      viewModelBuilder: () => TaxiViewModel(context),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        //
        return Visibility(
          visible: AppUISettings.enableDriverTypeSwitch,
          child: VStack(
            [
              //note indicating the button below is a swipable button
              "Swipe below to switch".tr().text.sm.make().centered().py(2),
              //
              SwipeButtonWidget(
                  key: viewKey,
                  acceptPoitTransition: 0.6,
                  margin: const EdgeInsets.all(0),
                  padding: const EdgeInsets.all(0),
                  boxShadow: [],
                  borderRadius: BorderRadius.circular(10),
                  colorBeforeSwipe: model.appService.driverIsOnline
                      ? Colors.red
                      : Colors.green,
                  colorAfterSwiped: model.appService.driverIsOnline
                      ? Colors.red
                      : Colors.green,
                  height: 50,
                  childBeforeSwipe: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: model.appService.driverIsOnline
                          ? Colors.red
                          : Colors.green,
                    ),
                    width: 50,
                    height: double.infinity,
                    child: const Center(
                      child: Icon(
                        FlutterIcons.chevrons_right_fea,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  childAfterSwiped: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: model.appService.driverIsOnline
                          ? Colors.red
                          : Colors.green,
                    ),
                    width: 70,
                    height: double.infinity,
                    child: const Center(
                      child: Icon(
                        FlutterIcons.check_ant,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  leftChildren: [
                    Align(
                      alignment: Alignment(0.9, 0),
                      child: (model.appService.driverIsOnline
                              ? "Go offline"
                              : "Go online")
                          .tr()
                          .text
                          .lg
                          .color(Utils.textColorByTheme())
                          .white
                          .make(),
                    )
                  ],
                  onHorizontalDragUpdate: (e) {},
                  onHorizontalDragRight: (e) async {
                    if (isProcessing) {
                      model.toastError(
                          "Changing status is in progress, please try again"
                              .tr());
                      return false;
                    }
                    isProcessing = true;

                    final previousState = model.appService.driverIsOnline;
                    final newDriverState = !previousState;
                    final currentVehicle = null;
                    //Check if driver has vehicle
                    if (currentVehicle == null && newDriverState) {
                      model.toastError(
                          "You have not registered any vehicle. Please register a vehicle before going online");
                      isProcessing = false;
                      return false;
                    }
                    setState(() {
                      model.appService.driverIsOnline = newDriverState;
                      viewKey = ObjectKey(DateTime.now());
                    });

                    try {
                      AlertService.showLoading();

                      await model.newTaxiBookingService
                          .toggleVisibility(newDriverState);

                      isProcessing = false;
                      AlertService.stopLoading();
                      return true;
                    } catch (error) {
                      AlertService.stopLoading();

                      // Hiển thị lỗi và khôi phục trạng thái cũ
                      model.toastError("$error");
                      setState(() {
                        model.appService.driverIsOnline = previousState;
                        viewKey = ObjectKey(DateTime.now());
                      });
                      isProcessing = false;
                      return false;
                    }
                  },
                  onHorizontalDragleft: (e) async {
                    return false;
                  }).h(50),
              UiSpacer.vSpace(),
            ],
          ),
        );
      },
    );
  }
}
