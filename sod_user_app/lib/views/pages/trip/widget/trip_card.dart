import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/extensions/string.dart';
import 'package:sod_user/models/trip.dart';
import 'package:sod_user/view_models/trip.view_model.dart';
import 'package:sod_user/view_models/wallet.vm.dart';
import 'package:sod_user/views/pages/car_rental/widgets/selection_day.dart';
import 'package:sod_user/views/pages/trip/trip_detail_page.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../../services/order.service.dart';

class TripCard extends StatefulWidget {
  const TripCard({
    super.key,
    required this.trip,
    required this.viewModel,
  });
  final Trip trip;
  final TripViewModel? viewModel;

  @override
  State<TripCard> createState() => _TripCardState();
}

var result;

class _TripCardState extends State<TripCard> {
  bool completedBusy = false;
  bool canceledBusy = false;
  bool depositBusy = false;
  @override
  Widget build(BuildContext context) {
    return Container(
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
                          imageUrl: widget.trip.vehicle!.photo!.isNotEmpty
                            ? widget.trip.vehicle!.photo!.first
                            : "https://vnn-imgs-f.vgcloud.vn/2019/03/19/18/o-to-moi-3.jpg",
                          fit: BoxFit.fitWidth,
                          placeholder: (context, url) =>
                            CircularProgressIndicator(
                              color: AppColor.cancelledColor),
                          errorWidget: (context, url, error) =>
                            Icon(Icons.directions_car_filled_outlined),
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
                              '${widget.trip.isSelfDriving! ? 'Tự lái' : 'Có tài xế'}'
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
                        child: Image.network(
                            widget.trip.vehicle!.owner!.photo),
                      ).pOnly(right: 5),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          '${'Car owner'.tr()}:'.text.make(),
                          '${widget.trip.vehicle!.owner!.name}'
                              .text
                              .bold
                              .make(),
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
                  '${widget.trip.vehicle?.carModel!.carMake!.name!} ${widget.trip.vehicle?.carModel!.name!} ${widget.trip.vehicle!.yearMade}'
                      .text
                      .bold
                      .make(),
                  '${'Order date'.tr()}: ${formatDate(widget.trip.created_at!, true)}'
                      .text
                      .make(),
                  '${'Begin'.tr()}: ${formatDateTimeToString(DateTime.parse(widget.trip.debutDate!))}'
                      .text
                      .make(),
                  '${'End'.tr()}: ${formatDateTimeToString(DateTime.parse(widget.trip.expireDate!))}'
                      .text
                      .make(),
                  '${'Total amount'.tr()}: ${'${AppStrings.currencySymbol} ${widget.trip.totalPrice!.toDouble()}'.currencyFormat()}'
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
                      '${widget.trip.status == "pending" ? 'Not resolved'.tr() : widget.trip.status == "in progress" && !widget.trip.deposit! ? "Chờ đặt cọc" : widget.trip.status == "in progress" && widget.trip.deposit! ? 'In progress'.tr() : widget.trip.status == "canceled" ? 'Cancelled'.tr() : 'Done'.tr()}'
                          .text
                          .bold
                          .make(),
                    ],
                  )
                ],
              ).expand(flex: 6),
            ],
          ).pOnly(bottom: 8),
          if (widget.viewModel != null && widget.trip.status == "pending")
            CustomButton(
              loading: canceledBusy,
              title: 'Cancel trip'.tr(),
              onPressed: () async {
                setState(() {
                  canceledBusy = !canceledBusy;
                });
                await widget.viewModel!.cancelTrip(widget.trip.id!);
                setState(() {
                  canceledBusy = !canceledBusy;
                });
              },
            ).p(8),
          if (widget.viewModel != null &&
              widget.trip.status == "in progress" &&
              widget.trip.deposit == false)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CustomButton(
                  loading: canceledBusy,
                  title: 'Cancel trip'.tr(),
                  onPressed: () async {
                    setState(() {
                      canceledBusy = !canceledBusy;
                    });
                    await widget.viewModel!.cancelTrip(widget.trip.id!);
                    setState(() {
                      canceledBusy = !canceledBusy;
                    });
                  },
                ).p(8).expand(flex: 1),
                CustomButton(
                  color: AppColor.deliveredColor,
                  title: 'Deposit'.tr(),
                  loading: depositBusy,
                  onPressed: () async {
                    setState(() {
                      depositBusy = true;
                    });
                    widget.viewModel!.viewContext = context;
                    OrderService.openOrderPayment(
                      null,
                      widget.viewModel!,
                      widget.trip.paymentLink!,
                    );
                    setState(() {
                      depositBusy = false;
                    });
                  },
                ).p(8).expand(flex: 1),
              ],
            ),
          if (widget.viewModel != null &&
              widget.trip.status == "in progress" &&
              widget.trip.deposit == true)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CustomButton(
                  loading: canceledBusy,
                  title: 'Cancel trip'.tr(),
                  onPressed: () async {
                    setState(() {
                      canceledBusy = !canceledBusy;
                    });
                    await widget.viewModel!.cancelTrip(widget.trip.id!);
                    setState(() {
                      canceledBusy = !canceledBusy;
                    });
                  },
                ).p(8).expand(flex: 1),
                CustomButton(
                  loading: completedBusy,
                  color: AppColor.deliveredColor,
                  title: 'Hoàn thành'.tr(),
                  onPressed: () async {
                    setState(() {
                      completedBusy = !completedBusy;
                    });
                    widget.viewModel!.viewContext = context;
                    OrderService.openOrderPayment(
                      null,
                      widget.viewModel!,
                      widget.trip.paymentLink!,
                    );
                    setState(() {
                      completedBusy = !completedBusy;
                    });
                  },
                ).p(8).expand(flex: 1),
              ],
            ),
        ],
      ),
    ).onTap(() {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: ((context) => TripDetailPage(trip: widget.trip))));
    });
  }
}
