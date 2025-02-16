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

class BookSharedRideSuccessPage extends StatefulWidget {
  final SharedRide ride;
  final String weight;
  final String number_of_seat;
  final SharedRide bookedRide;
  final SharedRide? bookedRideDetails;
  final SharedRideViewModel sharedRideModel;

  const BookSharedRideSuccessPage(
      {Key? key,
      required this.ride,
      required this.weight,
      required this.number_of_seat,
      required this.sharedRideModel,
      this.bookedRideDetails, // Make it optional
      required this.bookedRide})
      : super(key: key);

  @override
  State<BookSharedRideSuccessPage> createState() => _PostRideSuccessPageState();
}

class _PostRideSuccessPageState extends State<BookSharedRideSuccessPage> {
  late SharedRideViewModel ride_model;
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
            "Booked ride successfully"
                .tr()
                .text
                .size(22)
                .color(Colors.green)
                .make(),
            // UiSpacer.vSpace(5),
            // "We will send you a notification when a passenger book ride".tr().text.color(Colors.grey).align(TextAlign.center).make(),
            UiSpacer.vSpace(10),
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: Colors.blue[300],
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              child: HStack(
                [
                  Expanded(
                    child: HStack(
                      [
                        const Icon(Icons.calendar_today),
                        UiSpacer.hSpace(10),
                        widget.ride.startTime!.text.size(18).bold.make(),
                      ],
                    ),
                  ),
                  if (widget.ride.type == "package") ...[
                    HStack(
                      [
                        const Icon(Icons.storage),
                        UiSpacer.hSpace(10),
                        "${widget.weight} Kg".text.size(18).bold.make(),
                      ],
                    )
                  ],
                  if (widget.ride.type == "person") ...[
                    HStack(
                      [
                        const Icon(Icons.person),
                        UiSpacer.hSpace(10),
                        "${widget.number_of_seat} ${'Person'.tr()}"
                            .text
                            .size(18)
                            .bold
                            .make(),
                      ],
                    )
                  ],
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
                          child: widget.ride.departureName!.text.black.make()),
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
                            widget.ride.startTime!.text.black.make(),
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
                              widget.ride.destinationName!.text.black.make()),
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
                            widget.ride.endTime!.text.black.make(),
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
                        HStack(
                          alignment: MainAxisAlignment.spaceAround,
                          [
                            Expanded(
                              child: "Your booked price"
                                  .tr()
                                  .text
                                  .bold
                                  .white
                                  .make(),
                            ),
                            Expanded(
                              child: Utils.formatCurrencyVND(double.parse(
                                      widget.bookedRide.price.toString()))
                                  .text
                                  .bold
                                  .white
                                  .make(),
                            ),
                          ],
                        ).py(3),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            UiSpacer.vSpace(20),
            UiSpacer.vSpace(20),
            if (widget.ride.type == "package") ...[
              VStack(
                [
                  'Package details'.tr().text.black.bold.make(),
                  UiSpacer.vSpace(10),
                  PostShareRideTextField(
                    enabled: false,
                    hintText:
                        "${'Width'.tr()} ${widget.ride.package!.width} (cm)",
                    prefixIcon: const Icon(CupertinoIcons.info),
                  ),
                  UiSpacer.vSpace(10),
                  PostShareRideTextField(
                    enabled: false,
                    hintText:
                        "${'Height'.tr()} ${widget.ride.package!.height} (cm)",
                    prefixIcon: const Icon(CupertinoIcons.info),
                  ),
                  UiSpacer.vSpace(10),
                  PostShareRideTextField(
                    enabled: false,
                    hintText:
                        "${'Length'.tr()} ${widget.ride.package!.length} (cm)",
                    prefixIcon: const Icon(CupertinoIcons.info),
                  ),
                  UiSpacer.vSpace(10),
                  PostShareRideTextField(
                    enabled: false,
                    hintText:
                        "${'Weight'.tr()} ${widget.ride.package!.weight} (kg)",
                    prefixIcon: const Icon(CupertinoIcons.info),
                  ),
                ],
              )
            ],
            UiSpacer.vSpace(10),
            if (widget.ride.note != null) ...[
              PostShareRideTextField(
                enabled: false,
                hintText: widget.ride.note!,
                prefixIcon: const Icon(CupertinoIcons.chat_bubble),
              ),
            ],
          ],
        ),
      ).scrollVertical(physics: BouncingScrollPhysics()),
      bottomNavigationBar: CustomButton(
        onPressed: () {
          if (mounted) {
            context.nextPage(
              SharedRideDetailsPage(
                sharedRide: widget.ride,
                model: widget.sharedRideModel,
              ),
            );
          }
        },
        title: "See my trip".tr(),
      ).px(10).pOnly(bottom: 20),
    );
  }
}
