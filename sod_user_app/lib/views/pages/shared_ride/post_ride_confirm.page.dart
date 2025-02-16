import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/utils/utils.dart';
import 'package:sod_user/view_models/shared_ride.vm.dart';
import 'package:sod_user/views/pages/shared_ride/widgets/post_share_ride_text_field.view.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:velocity_x/velocity_x.dart';

class PostRideConfirmPage extends StatefulWidget {
  final SharedRideViewModel model;

  const PostRideConfirmPage({Key? key, required this.model}) : super(key: key);

  @override
  State<PostRideConfirmPage> createState() => _PostRideConfirmPageState();
}

class _PostRideConfirmPageState extends State<PostRideConfirmPage> {
  @override
  void initState() {
    widget.model.calculateEndTime();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var timeNow =
        "${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}";
    return BasePage(
      backgroundColor: Colors.white,
      customAppbar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          backgroundColor: AppColor.primaryColor,
          title: "Confirm post ride".tr().text.make(),
        ),
      ),
      showAppBar: true,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: VStack(
            crossAlignment: CrossAxisAlignment.start,
            [
              UiSpacer.vSpace(10),
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: Colors.blue[300],
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    UiSpacer.hSpace(10),
                    widget.model.date.text.text.bold.size(18).make(),
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
                            child:
                                widget.model.departure.text.text.black.make()),
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                          ),
                          child: HStack(
                            [
                              const Icon(Icons.access_time,
                                  color: Colors.black),
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
                            child: widget.model.destination.text.text.black
                                .make()),
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time,
                                  color: Colors.black),
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
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: HStack(
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
                              ),
                            ),
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
                                Utils.formatCurrencyVND(double.parse(widget
                                        .model
                                        .packagePriceController
                                        .originalText))
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
                                      'Trip price'.tr().text.bold.white.make()),
                              Utils.formatCurrencyVND(double.parse(widget
                                      .model.priceController.originalText))
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
              "Vehicle information".tr().text.black.bold.make(),
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
                ).px(20).py(15),
              ),
              widget.model.type == "package"
                  ? VStack(
                      [
                        UiSpacer.vSpace(20),
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
                  : UiSpacer.emptySpace(),
              UiSpacer.vSpace(20),
              'Note'.tr().text.bold.black.make(),
              UiSpacer.vSpace(20),
              PostShareRideTextField(
                enabled: false,
                controller: widget.model.noteController,
                hintText: "Note for passenger".tr(),
                prefixIcon: const Icon(CupertinoIcons.chat_bubble),
              ),
            ],
          ),
        ).scrollVertical(physics: const BouncingScrollPhysics()),
      ),
      bottomNavigationBar: CustomButton(
        loading: widget.model.isBusy,
        onPressed: () async {
          if (widget.model.isBusy) return;
          print("Post Shared-Ride Begin at $timeNow");
          await widget.model.postSharedRide(widget.model);
          print("Post Shared-Ride Finish at $timeNow");
        },
        title: "Post ride".tr(),
      ).p(15),
    );
  }
}
