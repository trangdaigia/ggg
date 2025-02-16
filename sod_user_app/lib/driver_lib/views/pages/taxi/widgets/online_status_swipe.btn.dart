import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_user/driver_lib/requests/auth.request.dart';
import 'package:sod_user/driver_lib/services/alert.service.dart';
import 'package:sod_user/driver_lib/services/app.service.dart';
import 'package:sod_user/driver_lib/services/app.service.dart';
import 'package:sod_user/services/auth.service.dart';
import 'package:sod_user/driver_lib/view_models/taxi/taxi.vm.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:swipe_button_widget/swipe_button_widget.dart';
import 'package:velocity_x/velocity_x.dart';

class OnlineStatusSwipeButton extends StatefulWidget {
  const OnlineStatusSwipeButton(this.vm, {Key? key}) : super(key: key);
  final TaxiViewModel vm;

  @override
  State<OnlineStatusSwipeButton> createState() =>
      _OnlineStatusSwipeButtonState();
}

class _OnlineStatusSwipeButtonState extends State<OnlineStatusSwipeButton> {
  //
  ObjectKey viewKey = new ObjectKey(DateTime.now());
  bool isProcessing = false;
  //
  @override
  Widget build(BuildContext context) {
    //
    return SwipeButtonWidget(
        key: viewKey,
        acceptPoitTransition: 0.7,
        margin: const EdgeInsets.all(0),
        padding: const EdgeInsets.all(0),
        boxShadow: [],
        borderRadius: BorderRadius.circular(0),
        colorBeforeSwipe:
            AppService().driverIsOnline ? Colors.red : Colors.green,
        colorAfterSwiped:
            AppService().driverIsOnline ? Colors.red : Colors.green,
        height: 50,
        childBeforeSwipe: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(0),
            color: AppService().driverIsOnline ? Colors.red : Colors.green,
          ),
          width: 100,
          height: double.infinity,
          child: const Center(
            child: Icon(
              FlutterIcons.chevrons_right_fea,
              color: Colors.white,
              size: 34,
            ),
          ),
        ),
        childAfterSwiped: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(0),
            color: AppService().driverIsOnline ? Colors.red : Colors.green,
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
            child: (AppService().driverIsOnline ? "Go offline" : "Go online")
                .tr()
                .text
                .extraBold
                .xl2
                .white
                .make(),
          )
        ],
        onHorizontalDragUpdate: (e) {},
        onHorizontalDragRight: (e) async {
          if (isProcessing) {
            widget.vm.toastError(
                "Changing status is in progress, please try again".tr());
            return false;
          }
          isProcessing = true;
          final previousState = AppService().driverIsOnline;
          final newDriverState = !previousState;
          final currentVehicle = null;
          //Check if driver has vehicle
          if (currentVehicle == null && newDriverState) {
            widget.vm.toastError(
                "You have not registered any vehicle. Please register a vehicle before going online");
            isProcessing = false;
            return false;
          }

          try {
            AlertService.showLoading();
            await widget.vm.toggleOnlineStatus();

            return true;
          } catch (error) {
            // Hiển thị lỗi và khôi phục trạng thái cũ
            widget.vm.toastError("$error");
            setState(() {
              AppService().driverIsOnline = previousState;
            });
            return false;
          } finally {
            setState(() {
              viewKey = ObjectKey(DateTime.now());
            });
            isProcessing = false;
            AlertService.stopLoading();
          }
        },
        onHorizontalDragleft: (e) async {
          return false;
        }).h(widget.vm.isBusy ? 0 : 60);
  }
}
