import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/models/shared_ride.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/utils/utils.dart';
import 'package:sod_user/view_models/shared_ride.vm.dart';
import 'package:sod_user/views/pages/shared_ride/shared_ride_details.page.dart';
import 'package:sod_user/views/pages/shared_ride/widgets/post_share_ride_text_field.view.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:velocity_x/velocity_x.dart';

class PostRideSuccessPage extends StatefulWidget {
  final SharedRideViewModel model;
  final SharedRide sharedRide;
  const PostRideSuccessPage(
      {Key? key, required this.model, required this.sharedRide})
      : super(key: key);
  @override
  State<PostRideSuccessPage> createState() => _PostRideSuccessPageState();
}

class _PostRideSuccessPageState extends State<PostRideSuccessPage> {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: VStack(
          crossAlignment: CrossAxisAlignment.center,
          [
            UiSpacer.vSpace(40),
            Image.asset(
              "assets/images/post_ride_success.png",
              height: 100,
              width: 100,
            ),
            UiSpacer.vSpace(40),
            "Posted ride successfully"
                .tr()
                .text
                .size(22)
                .color(Colors.green)
                .make(),
            UiSpacer.vSpace(5),
            "We will send you a notification when a passenger book ride"
                .tr()
                .text
                .color(Colors.grey)
                .align(TextAlign.center)
                .make(),
            UiSpacer.vSpace(10),
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: Colors.blue[300],
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              child: HStack(
                [
                  const Icon(Icons.calendar_today),
                  UiSpacer.hSpace(10),
                  widget.model.date.text.text.size(18).bold.make(),
                ],
              ),
            ),
            UiSpacer.vSpace(20),
            Container(
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 20,
                    spreadRadius: 1,
                    offset: Offset(0, 10),
                  ),
                ],
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: VStack(
                [
                  HStack(
                    [
                      Expanded(
                          child: widget.model.departure.text.text.black.make()),
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time, color: Colors.black),
                            UiSpacer.hSpace(5),
                            widget.model.time.text.text.black.make(),
                          ],
                        ),
                      )
                    ],
                  ).p(13),
                  HStack(
                    [
                      Expanded(child: Divider(color: Colors.grey)),
                      Icon(Icons.keyboard_arrow_down),
                      Expanded(child: Divider(color: Colors.grey)),
                    ],
                  ).px(13),
                  HStack(
                    [
                      Expanded(
                          child:
                              widget.model.destination.text.text.black.make()),
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time, color: Colors.black),
                            UiSpacer.hSpace(5),
                            widget.model.endTime!.text.black.make(),
                          ],
                        ),
                      )
                    ],
                  ).p(13),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.teal[900],
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(10)),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 13, vertical: 15),
                    child: VStack(
                      [
                        if (widget.model.type == "person") ...[
                          HStack(
                            alignment: MainAxisAlignment.spaceAround,
                            [
                              Expanded(
                                  child: "Number of seat"
                                      .tr()
                                      .text
                                      .bold
                                      .white
                                      .make()),
                              "${widget.model.number_of_seat.text} ${"spot".tr()}"
                                  .text
                                  .bold
                                  .white
                                  .make(),
                            ],
                          ).py(3),
                          UiSpacer.divider(color: Colors.white),
                        ],
                        if (widget.model.type == "package") ...[
                          HStack(
                            alignment: MainAxisAlignment.spaceAround,
                            [
                              Expanded(
                                  child: "Package price"
                                      .tr()
                                      .text
                                      .bold
                                      .white
                                      .make()),
                              Utils.formatCurrencyVND(double.parse(widget.model
                                      .packagePriceController.originalText))
                                  .text
                                  .bold
                                  .white
                                  .make(),
                            ],
                          ).py(3),
                          UiSpacer.divider(color: Colors.white),
                        ],
                        HStack(
                          alignment: MainAxisAlignment.spaceAround,
                          [
                            Expanded(
                                child:
                                    "Trip price".tr().text.bold.white.make()),
                            Utils.formatCurrencyVND(double.parse(
                                    widget.model.priceController.originalText))
                                .text
                                .bold
                                .white
                                .make(),
                          ],
                        ).py(3),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            UiSpacer.vSpace(20),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[350]!),
                borderRadius: const BorderRadius.all(Radius.circular(25)),
              ),
              child: HStack(
                [
                  const Icon(CupertinoIcons.car_detailed, color: Colors.grey),
                  UiSpacer.hSpace(20),
                  Expanded(
                    child: VStack(
                      crossAlignment: CrossAxisAlignment.start,
                      [
                        "${widget.model.selectedVehicle!.carModel?.carMake ?? ""}, ${widget.model.selectedVehicle!.carModel} (${widget.model.selectedVehicle!.yearMade ?? "2000"})"
                            .text
                            .black
                            .make(),
                        UiSpacer.vSpace(5),
                        "${widget.model.selectedVehicle!.color}"
                            .text
                            .black
                            .make(),
                      ],
                    ),
                  ),
                ],
              ).py(15).px(20),
            ),
            UiSpacer.vSpace(20),
            if (widget.model.type == "package") ...[
              VStack(
                [
                  'Package details'.tr().text.black.bold.make(),
                  UiSpacer.vSpace(10),
                  PostShareRideTextField(
                    enabled: false,
                    hintText:
                        "${'Width'.tr()} ${widget.model.widthController.text} (cm)",
                    prefixIcon: const Icon(CupertinoIcons.info),
                  ),
                  UiSpacer.vSpace(10),
                  PostShareRideTextField(
                    enabled: false,
                    hintText:
                        "${'Height'.tr()} ${widget.model.heightController.text} (cm)",
                    prefixIcon: const Icon(CupertinoIcons.info),
                  ),
                  UiSpacer.vSpace(10),
                  PostShareRideTextField(
                    enabled: false,
                    hintText:
                        "${'Length'.tr()} ${widget.model.lengthController.text} (cm)",
                    prefixIcon: const Icon(CupertinoIcons.info),
                  ),
                  UiSpacer.vSpace(10),
                  PostShareRideTextField(
                    enabled: false,
                    hintText:
                        "${'Weight'.tr()} ${widget.model.weightController.text} (kg)",
                    prefixIcon: const Icon(CupertinoIcons.info),
                  ),
                ],
              )
            ],
            UiSpacer.vSpace(20),
            if (widget.model.noteController.text.isNotEmpty) ...[
              PostShareRideTextField(
                enabled: false,
                controller: widget.model.noteController,
                hintText: widget.model.noteController.text,
                prefixIcon: const Icon(CupertinoIcons.chat_bubble),
              ),
            ],
          ],
        ),
      ).scrollVertical(physics: BouncingScrollPhysics()),
      bottomNavigationBar: CustomButton(
        onPressed: () => context.nextPage(SharedRideDetailsPage(
          sharedRide: widget.sharedRide,
          model: widget.model,
        )),
        title: "See my trip".tr(),
      ).px(15),
    );
  }
}
