import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/models/car_rental.dart';
import 'package:sod_user/view_models/car_rental.view_model.dart';
import 'package:sod_user/views/pages/car_rental/car_rental.model.dart';
import 'package:sod_user/views/pages/car_search/car_detail.dart';
import 'package:sod_user/views/pages/car_search/car_search.page.dart';
import 'package:stacked/stacked.dart';
import 'package:timelines/timelines.dart';
import 'package:velocity_x/velocity_x.dart';

// ignore: must_be_immutable
class CarRentalCard extends StatefulWidget {
  CarRentalCard({
    super.key,
    required this.carRental,
    required this.model,
    required this.dropOffLocation,
    required this.pickUpLocation,
    required this.bottomSheet,
    required this.selectedRoute,
    required this.index,
  });
  final int index;
  final CarRental carRental;
  final CarRentalViewModel model;

  final ValueNotifier<String> dropOffLocation;
  final ValueNotifier<String> pickUpLocation;
  ValueNotifier<Widget> bottomSheet;
  ValueNotifier<int> selectedRoute;
  @override
  State<CarRentalCard> createState() => _CarRentalCardState();
}

class _CarRentalCardState extends State<CarRentalCard> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CarRentalViewModel>.reactive(
        disposeViewModel: false,
        viewModelBuilder: () => widget.model,
        builder: (context, viewModel, child) {
          return InkWell(
            onTap: (() {
              widget.model.car = widget.carRental;
              showModalBottomSheet(
                  barrierColor: Colors.transparent,
                  enableDrag: false,
                  isScrollControlled: true,
                  useRootNavigator: true,
                  context: context,
                  useSafeArea: true,
                  builder: (context) => CarDetail(
                        index: widget.index,
                        dropOffLocation: widget.dropOffLocation,
                        selectedRoute: widget.selectedRoute,
                        bottomSheet: widget.bottomSheet,
                        pickUpLocation: widget.pickUpLocation,
                        model: widget.model,
                        data: widget.carRental,
                      ));
            }),
            child: buildCarRentalCard(context, widget.model),
          );
        });
  }

  Widget buildCarRentalCard(
      BuildContext context, CarRentalViewModel viewModel) {
    int money = 0;
    if (viewModel.type == 'xe tự lái') {
      if (widget.carRental.vehicleRentPrice != null &&
          widget.carRental.vehicleRentPrice?.priceMondayFriday != null &&
          widget.carRental.vehicleRentPrice?.priceSaturdaySunday != null) {
        if (DateTime.now().weekday < 6) {
          money = widget.carRental.vehicleRentPrice!.priceMondayFriday!;
        } else {
          money = widget.carRental.vehicleRentPrice!.priceSaturdaySunday!;
        }
      } else {
        money = 120000;
      }
    } else {
      if (widget.carRental.vehicleRentPrice != null &&
          widget.carRental.vehicleRentPrice?.priceMondayFridayWithDriver !=
              null &&
          widget.carRental.vehicleRentPrice?.priceSaturdaySundayWithDriver !=
              null) {
        if (DateTime.now().weekday < 6) {
          money =
              widget.carRental.vehicleRentPrice!.priceMondayFridayWithDriver!;
        } else {
          money =
              widget.carRental.vehicleRentPrice!.priceSaturdaySundayWithDriver!;
        }
      } else {
        money = 120000;
      }
    }
    if (viewModel.type == 'xe tự lái') {
      money = money * (widget.model.self_driving.total.hours / 24).ceil();
    } else {
      money = money * (widget.model.with_driver.total.hours).ceil() +
          (widget.carRental.vehicleRentPrice!.drivingFee! *
              (widget.model.with_driver.total.hours).ceil());
    }
    return Container(
        alignment: Alignment.topCenter,
        //margin: EdgeInsets.symmetric(horizontal: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(30)),
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(30)),
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 3.5,
                      child:
                          //  modelCarManage.carRental[index].photo!.isNotEmpty
                          //     ?
                          ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: CachedNetworkImage(
                                width: MediaQuery.of(context).size.width / 2.5,
                                height: MediaQuery.of(context).size.height / 7,
                                imageUrl: widget.carRental.photo!.isNotEmpty
                                    ? widget.carRental.photo!.first
                                    : "",
                                fit: BoxFit.fitWidth,
                                placeholder: (context, url) =>
                                    CircularProgressIndicator(
                                        color: AppColor.cancelledColor),
                                errorWidget: (context, url, error) => ClipRRect(
                                  child: Image.network(
                                    'https://nld.mediacdn.vn/291774122806476800/2021/9/25/24226875648526647114344167202327751795544483n-16325671978991579408720.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ))),
                  Positioned(
                    top: 20,
                    left: 30,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.carRental.fastBooking!)
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                color: Colors.black38,
                                border: Border.all(color: Colors.transparent),
                                borderRadius: BorderRadius.horizontal(
                                    left: Radius.circular(50),
                                    right: Radius.circular(50))),
                            height: 25,
                            child: Row(
                              children: [
                                'Quick booking'
                                    .tr()
                                    .text
                                    .color(Colors.white)
                                    .make()
                                    .pOnly(right: 10),
                                Icon(Icons.flash_on_outlined,
                                    color: Colors.yellow),
                              ],
                            ),
                          ).pOnly(bottom: 10),
                        if (widget.carRental.mortgageExemption!)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Colors.black38,
                                border: Border.all(color: Colors.transparent),
                                borderRadius: BorderRadius.horizontal(
                                    left: Radius.circular(50),
                                    right: Radius.circular(50))),
                            height: 25,
                            child: Row(
                              children: [
                                'Mortgage free'
                                    .tr()
                                    .text
                                    .color(Colors.white)
                                    .make()
                                    .pOnly(right: 10),
                                Icon(FontAwesome.handshake_o,
                                    color: Colors.green),
                              ],
                            ),
                          )
                      ],
                    ),
                  ),
                  Positioned(
                    top: 20,
                    right: 30,
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        border: Border.all(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: widget.carRental.like
                          ? Icon(
                              Icons.favorite_outlined,
                              color: Colors.red.shade100,
                            )
                          : Icon(
                              Icons.favorite_outline,
                              color: Colors.white,
                            ),
                    ).onTap(() {
                      setState(() {
                        widget.carRental.like = !widget.carRental.like;
                        viewModel.likeCar(
                            widget.carRental, widget.carRental.like);
                        viewModel.updateFavourite(
                            widget.carRental.id!, !widget.carRental.like);
                      });
                    }),
                  ),
                  Positioned(
                      top: MediaQuery.of(context).size.height / 4 + 5,
                      left: 30,
                      child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: widget.carRental.owner?.photo != null
                                ? widget.carRental.owner!.photo
                                : "",
                            fit: BoxFit.fill,
                            placeholder: (context, url) =>
                                CircularProgressIndicator(
                                    color: AppColor.cancelledColor),
                            errorWidget: (context, url, error) => Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: Colors.black38,
                              ),
                              width: 50,
                              height: 50,
                              child: Icon(Icons.person),
                            ),
                          ))),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.carRental.carModel!.carMake!.name} ${widget.carRental.carModel!.name!} ${widget.carRental.yearMade ?? ''}',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(right: 10),
                          child: Row(children: [
                            Icon(Icons.location_on, color: Colors.grey),
                            Expanded(
                              child: Builder(
                                builder: (context) =>
                                    '${widget.carRental.location ?? '...'}'
                                        .text
                                        .maxLines(2)
                                        .overflow(TextOverflow.ellipsis)
                                        .color(Colors.grey)
                                        .make(),
                              ),
                            ),
                          ]).pSymmetric(h: 10),
                        ),
                      ),
                      '~${(widget.carRental.distance!.toInt() / 1000).toStringAsFixed(1)} km'
                          .text
                          .color(Colors.grey)
                          .make(),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.black,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.yellow),
                              '${widget.carRental.rating}'
                                  .text
                                  .color(Colors.grey)
                                  .make(),
                            ],
                          ),
                          DotIndicator(size: 5, color: Colors.grey.shade600)
                              .px8(),
                          Row(
                            children: [
                              Icon(Icons.directions_car, color: Colors.green),
                              '${widget.carRental.totalTrip} ${'Ride'.tr().toLowerCase()}'
                                  .text
                                  .color(Colors.grey)
                                  .make(),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          '${formatNumber(money)}'
                              .text
                              .color(AppColor.primaryColor)
                              .semiBold
                              .xl2
                              .make(),
                          if (widget.model.type == "xe tự lái")
                            '/${'day'.tr()}'.text.color(Colors.grey).make(),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}
