import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_user/driver_lib/constants/app_colors.dart';
import 'package:sod_user/driver_lib/utils/utils.dart';
import 'package:sod_user/driver_lib/view_models/taxi/taxi.vm.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:swipe_button_widget/swipe_button_widget.dart';
import 'package:velocity_x/velocity_x.dart';

class TaxiCancelSwipeView extends StatelessWidget {
  const TaxiCancelSwipeView(this.vm, {Key? key}) : super(key: key);

  final TaxiViewModel vm;

  @override
  Widget build(BuildContext context) {
    return SwipeButtonWidget(
            acceptPoitTransition: 0.7,
            margin: const EdgeInsets.all(0),
            padding: const EdgeInsets.all(0),
            boxShadow: [],
            borderRadius: BorderRadius.circular(0),
            colorBeforeSwipe: Colors.red,
            colorAfterSwiped: Colors.red,
            height: 50,
            childBeforeSwipe: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(0),
                color: Colors.red,
              ),
              width: 60,
              height: double.infinity,
              child: const Center(
                child: Icon(
                  FlutterIcons.close_box_mco,
                  color: Colors.white,
                  size: 38,
                ),
              ),
            ),
            childAfterSwiped: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(0),
                color: AppColor.primaryColorDark,
              ),
              width: 60,
              height: double.infinity,
              child: const Center(
                child: Icon(
                  FlutterIcons.check_ant,
                  color: Colors.white,
                  size: 38,
                ),
              ),
            ),
            leftChildren: [
              Align(
                alignment: Alignment(0.8, 0),
                child: Text(
                  "Cancel Trip".tr(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Utils.textColorByTheme(),
                  ),
                ),
              )
            ],
            onHorizontalDragUpdate: (e) {},
            onHorizontalDragRight: (e) async {
              return await vm.onGoingTaxiBookingService
                  .cancelOrderStatusUpdate();
            },
            onHorizontalDragleft: (e) async {
              return false;
            })
        .h(vm.isBusy ? 0 : 60)
        .box
        .roundedSM
        .clip(Clip.antiAlias)
        .make()
        .wFull(context);
  }
}
