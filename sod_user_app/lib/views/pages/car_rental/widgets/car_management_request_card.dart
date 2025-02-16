import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/extensions/string.dart';
import 'package:sod_user/global/global_variable.dart';
import 'package:sod_user/models/car_rental.dart';
import 'package:sod_user/models/trip.dart';
import 'package:sod_user/services/alert.service.dart';
import 'package:sod_user/view_models/car_management.view_model.dart';
import 'package:sod_user/views/pages/car_rental/widgets/selection_day.dart';
import 'package:sod_user/views/pages/trip/trip_detail_page.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:velocity_x/velocity_x.dart';

class CarManagementRequestCard extends StatefulWidget {
  final CarRental car;
  final CarManagementViewModel viewModel;
  final Trip request;

  const CarManagementRequestCard({
    Key? key,
    required this.car,
    required this.viewModel,
    required this.request,
  }) : super(key: key);

  @override
  State<CarManagementRequestCard> createState() =>
      _CarManagementRequestCardState();
}

class _CarManagementRequestCardState extends State<CarManagementRequestCard> {
  bool checkAccept = false;
  bool checkCanceled = false;

  @override
  Widget build(BuildContext context) {
    return widget.request.status == "pending" ||
            widget.request.status == "in progress"
        ? Container(
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade200)),
            child: Column(
              children: [
                Row(
                  children: [
                    Column(
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: AspectRatio(
                                aspectRatio: 1 / 1,
                                child: CachedNetworkImage(
                                  imageUrl: widget.car.photo!.isNotEmpty
                                      ? widget.car.photo!.first
                                      : "",
                                  fit: BoxFit.fitWidth,
                                  placeholder: (context, url) =>
                                      CircularProgressIndicator(
                                          color: AppColor.cancelledColor),
                                  errorWidget: (context, url, error) => Icon(
                                      Icons.directions_car_filled_outlined),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 4,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.black45,
                                ),
                                child:
                                    '${widget.request.isSelfDriving! ? 'Tự lái' : 'Có tài xế'}'
                                        .text
                                        .color(Colors.white)
                                        .make()
                                        .pSymmetric(h: 5, v: 2),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            CircleAvatar(
                              child: Image.network(widget.request.user!.photo),
                            ).pOnly(right: 5),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                '${'Renter'.tr()}:'.text.make(),
                                '${widget.request.user!.name}'.text.bold.make(),
                              ],
                            ).expand(),
                          ],
                        ).pOnly(top: 8, left: 8),
                      ],
                    ).expand(flex: 4),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        '${widget.request.vehicle?.carModel!.carMake!.name!} ${widget.request.vehicle?.carModel!.name!} ${widget.request.vehicle!.yearMade}'
                            .text
                            .bold
                            .make(),
                        '${'Order date'.tr()}: ${formatDate(widget.request.created_at!, true)}'
                            .text
                            .make(),
                        '${'Begin'.tr()}: ${formatDateTimeToString(DateTime.parse(widget.request.debutDate!))}'
                            .text
                            .make(),
                        '${'End'.tr()}: ${formatDateTimeToString(DateTime.parse(widget.request.expireDate!))}'
                            .text
                            .make(),
                        '${'Total amount'.tr()}: ${'${AppStrings.currencySymbol} ${widget.request.totalPrice!.toDouble()}'.currencyFormat()}'
                            .text
                            .make(),
                        SizedBox(height: 12),
                        Divider(
                          color: Colors.grey,
                          thickness: 0.5,
                        ),
                        Wrap(
                          children: [
                            '${'Status'.tr()}: '.text.make(),
                            '${widget.request.status == "pending" ? 'Not resolved'.tr() : widget.request.status == "in progress" && !widget.request.deposit! ? "Chờ đặt cọc".tr() : 'In progress'.tr()}'
                                .text
                                .bold
                                .make(),
                          ],
                        ),
                      ],
                    ).expand(flex: 6),
                  ],
                ).pOnly(bottom: 8),
                widget.request.status == "in progress" &&
                        !widget.request.deposit!
                    ? CustomButton(
                        loading: checkCanceled,
                        title: 'Cancel trip'.tr(),
                        onPressed: () async {
                          setState(() {
                            checkCanceled = true;
                            GlobalVariable.refreshCache = true;
                          });
                          widget.viewModel
                              .cancelTrip(widget.request.id!)
                              .then((value) async {
                            if (value) {
                              await AlertService.success(
                                title: "Canceled ride successfully".tr(),
                              );
                              GlobalVariable.refreshCache = true;
                            } else {
                              await AlertService.success(
                                title: "Canceled ride failed".tr(),
                              );
                            }
                            setState(() {
                              checkCanceled = false;
                            });
                          });
                        },
                      ).p(8)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          CustomButton(
                            loading: checkCanceled,
                            title: 'Cancel trip'.tr(),
                            onPressed: () async {
                              setState(() {
                                checkCanceled = true;
                              });
                              widget.viewModel
                                  .cancelTrip(widget.request.id!)
                                  .then((value) async {
                                if (value) {
                                  await AlertService.success(
                                    title: "Canceled ride successfully".tr(),
                                  );
                                } else {
                                  await AlertService.success(
                                    title: "Canceled ride failed".tr(),
                                  );
                                }
                                setState(() {
                                  checkCanceled = false;
                                });
                              });
                            },
                          ).p(8).expand(flex: 1),
                          CustomButton(
                            loading: checkAccept,
                            color: AppColor.deliveredColor,
                            title: widget.request.status != "pending"
                                ? "Completed".tr()
                                : "Confirm".tr(),
                            onPressed: () async {
                              setState(() {
                                checkAccept = true;
                                GlobalVariable.refreshCache = true;
                              });
                              widget.request.status == "pending"
                                  ? widget.viewModel
                                      .acceptTrip(widget.request.id!)
                                      .then((value) async {
                                      if (value) {
                                        await AlertService.success(
                                          title:
                                              "Accept ride successfully".tr(),
                                        );
                                        GlobalVariable.refreshCache = true;
                                      } else {
                                        await AlertService.success(
                                          title: "Accept ride failed".tr(),
                                        );
                                      }
                                      setState(() {
                                        checkAccept = false;
                                      });
                                    })
                                  : widget.viewModel
                                      .completedTrip(widget.request.id!)
                                      .then((value) async {
                                      if (value) {
                                        await AlertService.success(
                                          title:
                                              "Accept ride successfully".tr(),
                                        );
                                      } else {
                                        await AlertService.success(
                                          title: "Accept ride failed".tr(),
                                        );
                                      }
                                      setState(() {
                                        checkAccept = false;
                                      });
                                    });
                            },
                          ).p(8).expand(flex: 1),
                        ],
                      )
              ],
            ),
          ).onTap(() {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (context) => TripDetailPage(
                      trip: widget.request, viewModel: widget.viewModel)),
            );
          })
        : Container();
  }
}
