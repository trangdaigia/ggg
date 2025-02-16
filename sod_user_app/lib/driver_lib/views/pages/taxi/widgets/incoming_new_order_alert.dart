import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/driver_lib/constants/app_taxi_settings.dart';
import 'package:sod_user/driver_lib/extensions/dynamic.dart';
import 'package:sod_user/driver_lib/models/new_taxi_order.dart';
import 'package:sod_user/driver_lib/utils/ui_spacer.dart';
import 'package:sod_user/driver_lib/view_models/taxi/new_taxi_order_alert.vm.dart';
import 'package:sod_user/driver_lib/view_models/taxi/taxi.vm.dart';
import 'package:sod_user/driver_lib/views/pages/taxi/widgets/taxi_order_type_title.dart';
import 'package:sod_user/driver_lib/widgets/busy_indicator.dart';
import 'package:sod_user/driver_lib/widgets/buttons/custom_text_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:measure_size/measure_size.dart';
import 'package:sod_user/driver_lib/widgets/cards/amount_tile.dart';
import 'package:stacked/stacked.dart';
import 'package:swipebuttonflutter/swipebuttonflutter.dart';
import 'package:sod_user/driver_lib/models/order.dart';
import 'package:velocity_x/velocity_x.dart';

class IncomingNewOrderAlert extends StatefulWidget {
  const IncomingNewOrderAlert(this.newTaxiOrder, this.newTaxiOrderDetail,
      {Key? key, this.accpectOrder})
      : super(key: key);

  final NewTaxiOrder newTaxiOrder;
  final Order newTaxiOrderDetail;
  final bool? accpectOrder;

  @override
  _IncomingNewOrderAlertState createState() => _IncomingNewOrderAlertState();
}

class _IncomingNewOrderAlertState extends State<IncomingNewOrderAlert> {
  //
  bool started = false;
  late NewTaxiOrderAlertViewModel vm;

  //
  @override
  void initState() {
    super.initState();
    vm = NewTaxiOrderAlertViewModel(
        widget.newTaxiOrder, context, widget.accpectOrder);
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<NewTaxiOrderAlertViewModel>.reactive(
      viewModelBuilder: () => NewTaxiOrderAlertViewModel(
          widget.newTaxiOrder, context, widget.accpectOrder),
      onViewModelReady: (vm) {
        started = true;
        vm.initialise();
      },
      builder: (context, vm, child) {
        return MeasureSize(
          onChange: (size) {},
          child: VStack(
            [
              //
              HStack(
                [
                  //title
                  "New Order Alert".tr().text.semiBold.xl.make().py8().expand(),

                  //countdown
                  CircularCountDownTimer(
                    duration: AppStrings.alertDuration,
                    controller: vm.countDownTimerController,
                    initialDuration: vm.newOrder.initialAlertDuration,
                    width: 30,
                    height: 30,
                    ringColor: Colors.grey.shade300,
                    ringGradient: null,
                    fillColor: AppColor.accentColor,
                    fillGradient: null,
                    backgroundColor: AppColor.primaryColorDark,
                    backgroundGradient: null,
                    strokeWidth: 4.0,
                    strokeCap: StrokeCap.round,
                    textStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textFormat: CountdownTextFormat.S,
                    isReverse: true,
                    isReverseAnimation: false,
                    isTimerTextShown: true,
                    autoStart: false,
                    onStart: () {
                      print('Countdown Started');
                    },
                    onComplete: () {
                      vm.countDownCompleted(started);
                    },
                  ),
                ],
              ),

              // Ship order detail
              Visibility(
                visible: widget.newTaxiOrderDetail.taxiOrder != null,
                child: TaxiOrderTypeTitle(
                        widget.newTaxiOrderDetail.taxiOrder!.type.tr())
                    .pOnly(bottom: 12),
              ),

              //for no info to show
              Visibility(
                visible: !AppTaxiSettings.showTaxiDropoffInfo &&
                    !AppTaxiSettings.showTaxiPickupInfo,
                child: VStack(
                  [
                    HStack(
                      [
                        "Pickup Distance".tr().text.medium.make().expand(),
                        "${vm.newOrder.pickupDistance.numCurrency}km"
                            .text
                            .medium
                            .xl
                            .make(),
                      ],
                    ),
                    HStack(
                      [
                        "Trip Distance".tr().text.lg.make().expand(),
                        "${vm.newOrder.tripDistance}km".text.medium.xl.make(),
                      ],
                    ),
                  ],
                ),
              ),

              //pickup info
              Visibility(
                visible: AppTaxiSettings.showTaxiPickupInfo,
                child: VStack(
                  [
                    (widget.newTaxiOrderDetail.taxiOrder!.type == "ship"
                            ? "Pickup Location"
                            : "Pick_customer_up_address")
                        .tr()
                        .text
                        .medium
                        .make(),
                    "${vm.newOrder.pickup?.address} (${vm.newOrder.pickup?.distance}km)"
                        .text
                        .semiBold
                        .lg
                        .maxLines(2)
                        .make(),
                    10.heightBox,
                  ],
                ),
              ),
              //dropoff info
              Visibility(
                visible: AppTaxiSettings.showTaxiDropoffInfo,
                child: VStack(
                  [
                    (widget.newTaxiOrderDetail.taxiOrder!.type == "ship"
                            ? "Dropoff Location"
                            : "Dropoff Address")
                        .tr()
                        .text
                        .medium
                        .make(),
                    "${vm.newOrder.dropoff?.address} (${vm.newOrder.dropoff?.distance}km)"
                        .text
                        .semiBold
                        .lg
                        .maxLines(2)
                        .make(),
                    15.heightBox,
                  ],
                ),
              ),
              //fee
              HStack(
                [
                  "Trip Fare".tr().text.medium.make().expand(),
                  10.widthBox,
                  "${AppStrings.currencySymbol} ${vm.newOrder.amount}"
                      .currencyFormat()
                      .text
                      .semiBold
                      .xl
                      .make(),
                ],
              ).pOnly(bottom: 8),

              //Ship order detail
              if (widget.newTaxiOrderDetail.taxiOrder != null &&
                  widget.newTaxiOrderDetail.taxiOrder!.type == "ship")
                Visibility(
                  visible: widget.newTaxiOrderDetail.taxiOrder != null &&
                      widget.newTaxiOrderDetail.taxiOrder!.type == "ship",
                  child: VStack([
                    DottedLine(dashColor: context.textTheme.bodyLarge!.color!)
                        .py8(),
                    "Delivery detail".tr().text.semiBold.xl.make().py4(),
                    VStack([
                      Visibility(
                        visible: widget.newTaxiOrderDetail.taxiOrder!
                                    .shipPackage!.photo !=
                                null &&
                            widget.newTaxiOrderDetail.taxiOrder!.shipPackage!
                                    .photo !=
                                "",
                        child: Image.network(widget.newTaxiOrderDetail
                                    .taxiOrder!.shipPackage!.photo ??
                                "")
                            .h(100)
                            .wFull(context),
                      ).py4(),
                      AmountTile(
                              "Weight".tr(),
                              widget.newTaxiOrderDetail.taxiOrder!.shipPackage!
                                      .weight
                                      .toString() +
                                  "Kg")
                          .py2(),
                      AmountTile(
                              "Ship package type".tr(),
                              widget.newTaxiOrderDetail.taxiOrder!.shipPackage!
                                  .shipPackageType
                                  .tr())
                          .py2(),
                      Visibility(
                        visible: widget.newTaxiOrderDetail.taxiOrder!
                                .shipPackage!.floorNumberOrBuildingNumber !=
                            null,
                        child: AmountTile(
                                "Floor / building number".tr(),
                                widget
                                        .newTaxiOrderDetail
                                        .taxiOrder!
                                        .shipPackage!
                                        .floorNumberOrBuildingNumber ??
                                    "")
                            .py2(),
                      ),
                      AmountTile(
                              "Contact name".tr(),
                              widget.newTaxiOrderDetail.taxiOrder!.shipPackage
                                      ?.contactName ??
                                  "")
                          .py2(),
                      AmountTile(
                              "Contact number".tr(),
                              widget.newTaxiOrderDetail.taxiOrder!.shipPackage
                                      ?.contactNumber ??
                                  "")
                          .py2(),
                      Visibility(
                        visible: widget.newTaxiOrderDetail.taxiOrder!
                                .shipPackage!.noteForDrier !=
                            null,
                        child: AmountTile(
                                "Note for driver".tr(),
                                widget.newTaxiOrderDetail.taxiOrder!
                                        .shipPackage!.noteForDrier ??
                                    "")
                            .py2(),
                      ),
                    ]),
                  ]),
                ),

              //swipe to accept
              VStack(
                [
                  10.heightBox,
                  SwipingButton(
                    height: 50,
                    backgroundColor: AppColor.accentColor.withOpacity(0.50),
                    swipeButtonColor: AppColor.primaryColorDark,
                    swipePercentageNeeded: 0.80,
                    text: "Accept".tr(),
                    onSwipeCallback: vm.processOrderAcceptance,
                  ).wFull(context).box.make().h(vm.isBusy ? 0 : 50),
                  vm.isBusy
                      ? BusyIndicator().centered().p20()
                      : UiSpacer.emptySpace(),
                ],
              ).py12(),
              "Swipe to accept order".tr().text.makeCentered().py(1),

              // cancel button
              SafeArea(
                child: VStack(
                  [
                    5.heightBox,
                    CustomTextButton(
                      title: "Reject Order".tr(),
                      titleColor: Colors.red,
                      onPressed: () {
                        //reject order for this driver
                        vm.countDownCompleted(started);
                      },
                    ).wFull(context),
                    10.heightBox,
                  ],
                ),
              ),
            ],
          )
              .px(20)
              .py(10)
              .box
              .color(context.theme.colorScheme.background)
              .topRounded()
              .shadow
              .make(),
        );
      },
    );
  }
}
