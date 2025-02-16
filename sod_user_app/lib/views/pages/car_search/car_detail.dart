import 'dart:async';

import 'package:sod_user/constants/app_images.dart';
import 'package:sod_user/constants/app_map_settings.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/extensions/string.dart';
import 'package:sod_user/models/coordinates.dart';
import 'package:sod_user/services/geocoder.service.dart' as geocoderService;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/models/car_rental.dart';
import 'package:sod_user/services/alert.service.dart';
import 'package:sod_user/services/location.service.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/view_models/base.view_model.dart';
import 'package:sod_user/view_models/car_rental.view_model.dart';
import 'package:sod_user/view_models/taxi.vm.dart';
import 'package:sod_user/view_models/taxi_new_order_location_entry.vm.dart';
import 'package:sod_user/views/pages/car_rental/car_rental.model.dart';
import 'package:sod_user/views/pages/car_rental/widgets/selection_day.dart';
import 'package:sod_user/views/pages/car_search/confirm_booking.dart';
import 'package:sod_user/views/pages/car_search/owner_detail.dart';
import 'package:sod_user/views/pages/taxi/widgets/step_one/new_taxi_pick_on_map.view.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/widgets/busy_indicator.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:sod_user/widgets/custom_list_view.dart';
import 'package:sod_user/widgets/list_items/address.list_item.dart';
import 'package:sod_user/widgets/states/loading.shimmer.dart';
import 'package:sod_user/widgets/taxi_custom_text_form_field.dart';
import 'package:stacked/stacked.dart';
import 'package:timelines/timelines.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart' as vietMapGl;
import 'package:velocity_x/velocity_x.dart';

// ignore: must_be_immutable
class CarDetail extends StatefulWidget {
  CarDetail({
    super.key,
    required this.data,
    required this.model,
    required this.bottomSheet,
    required this.selectedRoute,
    required this.dropOffLocation,
    required this.pickUpLocation,
    required this.index,
  });
  final int index;
  final CarRental data;
  CarRentalViewModel model;
  final ValueNotifier<String> pickUpLocation;
  final ValueNotifier<String> dropOffLocation;
  ValueNotifier<Widget> bottomSheet;
  ValueNotifier<int> selectedRoute;

  @override
  State<CarDetail> createState() => _CarDetailState();
}

class _CarDetailState extends State<CarDetail> {
  String oldLocation = '';
  late CarDetailViewModel carVM;
  int checkLocation = 1;
  final ScrollController _scrollController = ScrollController();
  bool appBarVisible = false;
  CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(10.823099, 106.681937),
  );
  TaxiViewModel? taxiViewModel;
  NewTaxiOrderLocationEntryViewModel? taxiNewOrderViewModel;
  vietMapGl.VietmapController? vietMapController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.data.deliveryDistance == 0) {
      widget.data.deliveryToHome = false;
    }
    carVM = CarDetailViewModel();
    if (widget.data.latitude != null) {
      carVM.latitude = double.parse(widget.data.latitude!);
      carVM.longitude = double.parse(widget.data.longitude!);
    } else {
      carVM.latitude = 10.706355;
      carVM.longitude = 106.568326;
      widget.data.longitude = "106.568326";
      widget.data.latitude = "10.706355";
    }
    if (widget.data.vehicleRentPrice == null) {
      VehicleRentPrice priceNull = VehicleRentPrice(
          priceMondayFriday: 250000,
          priceSaturdaySunday: 300000,
          discountSevenDays: 12,
          discountThreeDays: 6);
      widget.data.vehicleRentPrice = priceNull;
    }
    _scrollController.addListener(showAppBar);
    _kInitialPosition = CameraPosition(
        target: LatLng(double.parse(widget.data.latitude!),
            double.parse(widget.data.longitude!)),
        zoom: 13.0);
    taxiViewModel = TaxiViewModel(context, null);
    taxiNewOrderViewModel =
        NewTaxiOrderLocationEntryViewModel(context, taxiViewModel!);
    taxiViewModel!.initialise();
    taxiNewOrderViewModel!.initialise();
  }

  void showAppBar() {
    if (_scrollController.offset >= 285 - kToolbarHeight) {
      // Hiển thị AppBar
      setState(() {
        appBarVisible = true;
      });
    } else {
      // Ẩn AppBar
      setState(() {
        appBarVisible = false;
      });
    }
  }

//Xe tự lái
  void update_self_driving(CarRentalPeriod _self_driving) {
    setState(() {
      widget.model.self_driving = _self_driving;
      widget.model.startTime = formatTime(widget.model.self_driving.start_time);
      widget.model.endTime = formatTime(widget.model.self_driving.end_time);
      widget.model.startDate = widget.model.self_driving.start_day;
      widget.model.endDate = widget.model.self_driving.end_day;
    });
  }

  //Xe có tài xế
  void update_with_driver(CarRentalPeriod _with_driver) {
    setState(() {
      widget.model.with_driver = _with_driver;
      widget.model.startTime = formatTime(widget.model.with_driver.start_time);
      widget.model.endTime = formatTime(widget.model.with_driver.end_time);
      widget.model.startDate = widget.model.with_driver.start_day;
      widget.model.endDate = widget.model.with_driver.end_day;
    });
  }

  String formatTime(Time time) {
    return '${time.hours < 10 ? '0${time.hours}' : time.hours}:${time.minute == 0 ? '00' : time.minute}';
  }

  void updatePickUpLocation(String _location) {
    setState(() {
      widget.pickUpLocation.value = _location;
      widget.model.pickUpLocation = _location;
      hasExecuted = false;
    });
  }

  final controller = CarouselSliderController();
  int activeIndex = 0;
  String delivery_fee = '0';
  String oldDelivery_fee = '0';
  Completer<GoogleMapController> _controller = Completer();
  bool hasExecuted = false;
  int rentalPriceFor1Day = 0;
  int rentalPriceFor1DayNotDiscount = 0;
  int priceWithDriver = 0;
  int route = 0;
  @override
  Widget build(BuildContext context) {
    widget.selectedRoute.addListener(() {
      setState(() {
        route = widget.selectedRoute.value;
      });
    });

    widget.dropOffLocation.addListener(() {
      setState(() {
        distance = 0;
      });
    });

    if (widget.model.type == 'xe tự lái') {
      widget.model.totalTimeRent = widget.model.self_driving.total.hours;
    } else {
      widget.model.totalTimeRent = widget.model.with_driver.total.hours;
    }
    carVM.deliveryLocation = widget.pickUpLocation.value;
    if (widget.data.latitude != null) {
      carVM.latitude = double.parse(widget.data.latitude!);
      carVM.longitude = double.parse(widget.data.longitude!);
    } else {
      carVM.latitude = 10.706355;
      carVM.longitude = 106.568326;
      widget.data.longitude = "106.568326";
      widget.data.latitude = "10.706355";
    }
    if (widget.data.vehicleRentPrice == null ||
        (widget.data.vehicleRentPrice?.priceMondayFriday == null &&
            widget.data.vehicleRentPrice?.priceSaturdaySunday == null)) {
      VehicleRentPrice priceNull = VehicleRentPrice(
          priceMondayFriday: 250000,
          priceSaturdaySunday: 300000,
          discountSevenDays: 12,
          discountThreeDays: 6);
      widget.data.vehicleRentPrice = priceNull;
    }
    if (widget.data.vehicleRentPrice!.discountSevenDays != null &&
        widget.data.vehicleRentPrice!.discountSevenDays != 0 &&
        (widget.model.totalTimeRent! / 24).ceil() > 6) {
      rentalPriceFor1Day = (((calculateRentalCost(
                          widget.model.startDate,
                          widget.model.endDate,
                          int.parse(widget.model.startTime!.substring(0, 2)),
                          int.parse(widget.model.endTime!.substring(0, 2))) /
                      (widget.model.totalTimeRent! / 24).ceil()) *
                  (100 - widget.data.vehicleRentPrice!.discountSevenDays!) /
                  100)
              .ceil())
          .ceil();
    } else if (widget.data.vehicleRentPrice!.discountThreeDays != null &&
        widget.data.vehicleRentPrice!.discountThreeDays != 0 &&
        (widget.model.totalTimeRent! / 24).ceil() > 2) {
      rentalPriceFor1Day = (((calculateRentalCost(
                          widget.model.startDate,
                          widget.model.endDate,
                          int.parse(widget.model.startTime!.substring(0, 2)),
                          int.parse(widget.model.endTime!.substring(0, 2))) /
                      (widget.model.totalTimeRent! / 24).ceil()) *
                  (100 - widget.data.vehicleRentPrice!.discountThreeDays!) /
                  100)
              .ceil())
          .ceil();
    } else {
      rentalPriceFor1Day = (calculateRentalCost(
                  widget.model.startDate,
                  widget.model.endDate,
                  int.parse(widget.model.startTime!.substring(0, 2)),
                  int.parse(widget.model.endTime!.substring(0, 2))) /
              (widget.model.totalTimeRent! / 24).ceil())
          .ceil();
    }
    rentalPriceFor1DayNotDiscount = (calculateRentalCost(
                widget.model.startDate,
                widget.model.endDate,
                int.parse(widget.model.startTime!.substring(0, 2)),
                int.parse(widget.model.endTime!.substring(0, 2))) /
            (widget.model.totalTimeRent! / 24).ceil())
        .ceil();
    if (widget.model.type != 'xe tự lái') {
      if (DateTime.now().weekday < 6) {
        priceWithDriver =
            (widget.data.vehicleRentPrice!.priceMondayFridayWithDriver! *
                        (widget.model.totalTimeRent!))
                    .toInt() +
                (widget.data.vehicleRentPrice!.drivingFee! *
                    (widget.model.totalTimeRent!));
        if (route != 0) {
          if (widget.dropOffLocation.value != '' && distance == 0) {
            print('Đúng điều kiện để tính khoảng cách');
            WidgetsBinding.instance.addPostFrameCallback((_) {
              widget.model
                  .getLongLatFromAddress(widget.dropOffLocation.value, true)
                  .then((location) {
                widget.model.dropOffLatitude = location.latitude!;
                widget.model.dropOffLongitude = location.longitude!;
                widget.model
                    .calculateDistance(
                        widget.model.latitude!,
                        widget.model.longitude!,
                        location.latitude!,
                        location.longitude!)
                    .then((value) {
                  distance = value;
                  setState(() {
                    priceWithDriver +=
                        (value * widget.data.vehicleRentPrice!.priceOneKm!)
                            .toInt();
                  });
                });
              });
            });
          }
        }
      } else {
        priceWithDriver =
            (widget.data.vehicleRentPrice!.priceSaturdaySundayWithDriver! *
                        (widget.model.totalTimeRent!))
                    .toInt() +
                (widget.data.vehicleRentPrice!.drivingFee! *
                    (widget.model.totalTimeRent!));
        if (route != 0) {
          if (widget.dropOffLocation.value != '' && distance == 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              widget.model
                  .getLongLatFromAddress(widget.dropOffLocation.value, true)
                  .then((location) {
                widget.model.dropOffLatitude = location.latitude!;
                widget.model.dropOffLongitude = location.longitude!;
                widget.model
                    .calculateDistance(
                        widget.model.latitude!,
                        widget.model.longitude!,
                        location.latitude!,
                        location.longitude!)
                    .then((value) {
                  distance = value;
                  setState(() {
                    priceWithDriver += ((distance) /
                            1000 *
                            widget.data.vehicleRentPrice!.priceOneKm!)
                        .toInt();
                  });
                });
              });
            });
          }
        }
      }
    }
    return ViewModelBuilder<CarDetailViewModel>.reactive(
        disposeViewModel: false,
        viewModelBuilder: () => carVM,
        builder: (context, carvm, child) {
          carvm.deliveryLocation = widget.pickUpLocation.value;
          if (widget.data.deliveryToHome! || widget.model.type != 'xe tự lái') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              delivery_fee = deliveryFee(widget.data, carvm)!;
              if (delivery_fee != oldDelivery_fee) {
                setState(() {
                  oldDelivery_fee = delivery_fee;
                });
              }
              print('Tiền phí là: ${delivery_fee}');
            });
          }
          return ViewModelBuilder<CarRentalViewModel>.reactive(
              disposeViewModel: false,
              viewModelBuilder: () => widget.model,
              builder: (context, viewModel, child) {
                return Scaffold(
                  floatingActionButton: Container(
                    height: 70,
                    width: double.infinity,
                    color: appBarVisible ? Colors.white : null,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                color: appBarVisible ? null : Colors.black26,
                                borderRadius: BorderRadius.circular(50)),
                            child: Icon(
                              Icons.close,
                              color:
                                  appBarVisible ? Colors.black : Colors.white,
                            ),
                          ).onTap(() {
                            setState(() {
                              Navigator.pop(context);
                            });
                          }),
                          appBarVisible
                              // ? '${widget.data.carModel!.carMake!.name} ${widget.data.carModel!.name} ${widget.data.yearMade ?? ''}'
                              //     .text
                              //     .xl
                              //     .maxLines(1)
                              //     .bold
                              //     .make()
                              ? Expanded(
                                  child: Text(
                                      '${widget.data.carModel!.carMake!.name} ${widget.data.carModel!.name} ${widget.data.yearMade ?? ''}',
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600)),
                                )
                              : Spacer(),
                          Row(
                            children: [
                              Container(
                                margin: EdgeInsets.only(right: 10, left: 5),
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                    color:
                                        appBarVisible ? Colors.transparent: Colors.black26,
                                    borderRadius: BorderRadius.circular(50)),
                                child: Icon(
                                  Icons.share_outlined,
                                  color: appBarVisible
                                      ? Colors.black
                                      : Colors.white,
                                ).onTap(() {
                                  viewModel.shareCarRental(viewModel.car!);
                                }),
                              ),
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                    color:
                                        appBarVisible ? null : Colors.black26,
                                    borderRadius: BorderRadius.circular(50)),
                                child: widget.data.like
                                    ? Icon(
                                        Icons.favorite_outlined,
                                        color: Colors.red.shade100,
                                      )
                                    : Icon(
                                        Icons.favorite_outline,
                                        color: appBarVisible
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                              ).onTap(() {
                                setState(() {
                                  widget.data.like = !widget.data.like;
                                  widget.model
                                      .likeCar(widget.data, widget.data.like);
                                  bool status = widget.data.like;
                                  viewModel.updateFavourite(
                                      widget.data.id!, !status);
                                });
                              }),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.centerTop,
                  body: viewModel.isBusy == false
                      ? SingleChildScrollView(
                          controller: _scrollController,
                          child: Column(children: [
                            SizedBox(
                              height: 300,
                              width: double.infinity,
                              child: CarouselSlider.builder(
                                  carouselController: controller,
                                  itemCount: widget.data.photo!.length == 0
                                      ? 1
                                      : widget.data.photo!.length,
                                  itemBuilder: (context, index, realIndex) {
                                    if (widget.data.photo!.length == 0) {
                                      return buildImage(
                                        "https://nld.mediacdn.vn/291774122806476800/2021/9/25/24226875648526647114344167202327751795544483n-16325671978991579408720.jpg",
                                        context,
                                        0,
                                        widget.data.photo!.length + 1,
                                      );
                                    } else {
                                      final image = widget.data.photo![index];
                                      return buildImage(image, context, index,
                                          widget.data.photo!.length);
                                    }
                                  },
                                  options: CarouselOptions(
                                      viewportFraction: 1.0,
                                      disableCenter: true,
                                      enableInfiniteScroll: false,
                                      enlargeCenterPage: true,
                                      onPageChanged: (index, reason) =>
                                          setState(() => activeIndex = index))),
                            ).pOnly(bottom: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    '${widget.data.carModel!.carMake!.name} ${widget.data.carModel!.name} ${widget.data.yearMade ?? ''}'
                                        .text
                                        .xl2
                                        .maxLines(1)
                                        .bold
                                        .make(),
                                  ],
                                ).pOnly(bottom: 10, left: 10, right: 10),
                                Row(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.star, color: Colors.yellow),
                                        '${widget.data.rating}'
                                            .text
                                            .color(Colors.grey)
                                            .make(),
                                      ],
                                    ),
                                    DotIndicator(
                                            size: 5,
                                            color: Colors.grey.shade600)
                                        .px8(),
                                    Row(
                                      children: [
                                        Icon(Icons.directions_car,
                                            color: Colors.green),
                                        '${widget.data.totalTrip} ${'Ride'.tr().toLowerCase()}'
                                            .text
                                            .color(Colors.grey)
                                            .make(),
                                      ],
                                    ),
                                  ],
                                ).pSymmetric(h: 10),
                                widget.model.type != "xe tự lái"
                                    ? ValueListenableBuilder<Widget>(
                                        valueListenable: widget.bottomSheet,
                                        builder: (context, value, child) {
                                          return value;
                                        })
                                    : Container(
                                        margin: EdgeInsets.all(10),
                                        padding: EdgeInsets.all(10),
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              'Car rental time'
                                                  .tr()
                                                  .text
                                                  .xl
                                                  .bold
                                                  .make(),
                                              Container(
                                                  margin:
                                                      EdgeInsets.only(top: 10),
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 15),
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(
                                                          color: Colors
                                                              .grey.shade200),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        children: [
                                                          '${widget.model.type == 'xe tự lái' ? 'Receive the car'.tr() : 'Pick up client'.tr()}'
                                                              .text
                                                              .color(
                                                                  Colors.grey)
                                                              .make(),
                                                          '${widget.model.type == 'xe tự lái' ? formatTime(widget.model.self_driving.start_time) : formatTime(widget.model.with_driver.start_time)} ${DateFormat('dd/MM/yyyy').format(widget.model.type == 'xe tự lái' ? widget.model.self_driving.start_day : widget.model.with_driver.start_day).toString()}'
                                                              .text
                                                              .bold
                                                              .make(),
                                                        ],
                                                      ),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        children: [
                                                          '${widget.model.type == 'xe tự lái' ? 'Give car back'.tr() : 'Drop off'.tr()}'
                                                              .text
                                                              .color(
                                                                  Colors.grey)
                                                              .make(),
                                                          '${widget.model.type == 'xe tự lái' ? formatTime(widget.model.self_driving.end_time) : formatTime(widget.model.with_driver.end_time)} ${DateFormat('dd/MM/yyyy').format(widget.model.type == 'xe tự lái' ? widget.model.self_driving.end_day : widget.model.with_driver.end_day).toString()}'
                                                              .text
                                                              .bold
                                                              .make(),
                                                        ],
                                                      ),
                                                    ],
                                                  )).onTap(() {
                                                showModalBottomSheet(
                                                    barrierColor:
                                                        Colors.transparent,
                                                    enableDrag: false,
                                                    isScrollControlled: true,
                                                    useRootNavigator: true,
                                                    context: context,
                                                    useSafeArea: true,
                                                    builder: (context) => widget
                                                                .model.type ==
                                                            "xe tự lái"
                                                        ? SelectionDay(
                                                            model: viewModel,
                                                            car_Rental_Period:
                                                                widget.model
                                                                    .self_driving,
                                                            update_self_driving:
                                                                update_self_driving,
                                                            update_with_driver:
                                                                update_with_driver,
                                                          )
                                                        : SelectionDay(
                                                            model: viewModel,
                                                            car_Rental_Period:
                                                                widget.model
                                                                    .with_driver,
                                                            update_self_driving:
                                                                update_self_driving,
                                                            update_with_driver:
                                                                update_with_driver,
                                                          ));
                                              }),
                                              widget.data.vehicleRentPrice!
                                                              .discountThreeDays !=
                                                          null &&
                                                      widget
                                                              .data
                                                              .vehicleRentPrice!
                                                              .discountThreeDays !=
                                                          null &&
                                                      widget
                                                              .data
                                                              .vehicleRentPrice!
                                                              .discountThreeDays !=
                                                          0 &&
                                                      widget
                                                              .data
                                                              .vehicleRentPrice!
                                                              .discountSevenDays !=
                                                          0
                                                  ? Container(
                                                      margin: EdgeInsets.only(
                                                          top: 10),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10,
                                                              vertical: 15),
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          border: Border.all(
                                                              color: Colors.grey
                                                                  .shade200),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10)),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              'Thuê hơn 3 ngày giảm '
                                                                  .text
                                                                  .make(),
                                                              ' ${widget.data.vehicleRentPrice?.discountThreeDays}%'
                                                                  .text
                                                                  .semiBold
                                                                  .make(),
                                                            ],
                                                          ),
                                                          '-'.text.make(),
                                                          Row(
                                                            children: [
                                                              'Thuê hơn 7 ngày giảm '
                                                                  .text
                                                                  .make(),
                                                              '${widget.data.vehicleRentPrice?.discountSevenDays}%'
                                                                  .text
                                                                  .semiBold
                                                                  .make(),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  : SizedBox(),
                                              'Vehicle delivery location'
                                                  .tr()
                                                  .text
                                                  .xl
                                                  .bold
                                                  .make()
                                                  .pOnly(top: 10),
                                              Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 15),
                                                  width: double.infinity,
                                                  margin: EdgeInsets.only(
                                                      bottom: 10, top: 10),
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(
                                                          color: Colors
                                                              .grey.shade200),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      Expanded(
                                                        child: Row(
                                                          children: [
                                                            Radio<int>(
                                                              groupValue:
                                                                  checkLocation,
                                                              value: 1,
                                                              onChanged:
                                                                  (value) {
                                                                setState(() {
                                                                  checkLocation =
                                                                      value!;
                                                                });
                                                              },
                                                            ),
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceAround,
                                                                children: [
                                                                  'I came to pick up the car myself'
                                                                      .tr()
                                                                      .text
                                                                      .color(Colors
                                                                          .grey)
                                                                      .make(),
                                                                  Text(
                                                                    '${widget.data.location}',
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 70,
                                                        alignment:
                                                            Alignment.topCenter,
                                                        child: 'Free'
                                                            .tr()
                                                            .text
                                                            .color(Colors.green)
                                                            .make(),
                                                      ),
                                                    ],
                                                  )),
                                              carvm.isBusy
                                                  ? LoadingShimmer()
                                                  : widget.data.deliveryToHome! &&
                                                          checkDeliver
                                                      ? Container(
                                                          padding: EdgeInsets.symmetric(
                                                              horizontal: 10,
                                                              vertical: 10),
                                                          width:
                                                              double.infinity,
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade200),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                      10)),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceAround,
                                                            children: [
                                                              Expanded(
                                                                child: Row(
                                                                  children: [
                                                                    Radio<int>(
                                                                      groupValue:
                                                                          checkLocation,
                                                                      value: 2,
                                                                      onChanged:
                                                                          (value) {
                                                                        setState(
                                                                            () {
                                                                          checkLocation =
                                                                              value!;
                                                                        });
                                                                      },
                                                                    ),
                                                                    Expanded(
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceAround,
                                                                        children: [
                                                                          'Delivery to my location'
                                                                              .tr()
                                                                              .text
                                                                              .color(Colors.grey)
                                                                              .make(),
                                                                          ValueListenableBuilder<String>(
                                                                              valueListenable: widget.pickUpLocation,
                                                                              builder: (context, value, child) {
                                                                                return Text(
                                                                                  '${value}',
                                                                                  style: TextStyle(
                                                                                    color: Colors.black,
                                                                                    fontWeight: FontWeight.bold,
                                                                                  ),
                                                                                  maxLines: 1,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                );
                                                                              })
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Container(
                                                                width: 70,
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    //'${deliveryFee(widget.data, carvm)}'
                                                                    '${checkDeliver && delivery_fee != '' && delivery_fee != "Free".tr() && delivery_fee != "..." ? '${'${AppStrings.currencySymbol} ${delivery_fee}'.currencyFormat()}' : '$delivery_fee'}'
                                                                        .text
                                                                        .color(Colors
                                                                            .green)
                                                                        .make(),
                                                                    IconButton(
                                                                        icon:
                                                                            Icon(
                                                                          Icons
                                                                              .arrow_forward_ios_outlined,
                                                                          color:
                                                                              Colors.black,
                                                                          size:
                                                                              10,
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          selectLocationPickup(
                                                                              context);
                                                                        }),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ))
                                                      : !widget.data
                                                              .deliveryToHome!
                                                          ? Container(
                                                              padding: EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 15),
                                                              width: double
                                                                  .infinity,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .grey
                                                                        .shade200),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                              ),
                                                              child: Row(
                                                                children: [
                                                                  Radio<int>(
                                                                    groupValue:
                                                                        checkLocation,
                                                                    value: 2,
                                                                    onChanged:
                                                                        (value) {},
                                                                  ),
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      'Delivery to my location'
                                                                          .tr()
                                                                          .text
                                                                          .color(
                                                                              Colors.grey)
                                                                          .make(),
                                                                      'Rất tiếc, chủ xe không hỗ trợ giao xe tận nơi'
                                                                          .tr()
                                                                          .text
                                                                          .sm
                                                                          .color(
                                                                              Colors.grey)
                                                                          .make(),
                                                                    ],
                                                                  )
                                                                ],
                                                              ))
                                                          : Container(
                                                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                              width: double.infinity,
                                                              decoration: BoxDecoration(color: Colors.red.shade100, border: Border.all(color: Colors.red), borderRadius: BorderRadius.circular(10)),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceAround,
                                                                children: [
                                                                  Expanded(
                                                                    child: Row(
                                                                      children: [
                                                                        Radio<
                                                                            int>(
                                                                          groupValue:
                                                                              checkLocation,
                                                                          value:
                                                                              2,
                                                                          onChanged:
                                                                              (value) {
                                                                            setState(() {
                                                                              checkLocation = value!;
                                                                            });
                                                                          },
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceAround,
                                                                            children: [
                                                                              'Delivery to my location'.tr().text.color(Colors.grey).make(),
                                                                              ValueListenableBuilder<String>(
                                                                                  valueListenable: widget.pickUpLocation,
                                                                                  builder: (context, value, child) {
                                                                                    return Text(
                                                                                      '${value}',
                                                                                      style: TextStyle(
                                                                                        color: Colors.black,
                                                                                        fontWeight: FontWeight.bold,
                                                                                      ),
                                                                                      maxLines: 1,
                                                                                      overflow: TextOverflow.ellipsis,
                                                                                    );
                                                                                  }),
                                                                              'Địa điểm giao nhận quá xa so với vị trí có thể giao xe tận nơi là ${widget.data.deliveryDistance}km. Bạn vui lòng chọn địa điểm giao nhận gần hơn hoặc có thể chọn xe khác.'.text.color(Colors.red).make(),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    width: 70,
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        IconButton(
                                                                            icon:
                                                                                Icon(
                                                                              Icons.arrow_forward_ios_outlined,
                                                                              color: Colors.black,
                                                                              size: 10,
                                                                            ),
                                                                            onPressed:
                                                                                () {
                                                                              selectLocationPickup(context);
                                                                            }),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              )),
                                            ]).pOnly(top: 5),
                                      ),
                                if (widget.data.describe!.isNotEmpty)
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Divider(color: Colors.grey).p(10),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            'Description'
                                                .tr()
                                                .text
                                                .xl
                                                .bold
                                                .make(),
                                          ],
                                        ).pSymmetric(h: 10),
                                        '${widget.data.describe}'
                                            .text
                                            .make()
                                            .pSymmetric(h: 20),
                                      ]),
                                if (widget.data.utilites!.length != 0)
                                  Column(
                                    children: [
                                      Divider(color: Colors.grey).p(10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          'Amenities on the car'
                                              .tr()
                                              .text
                                              .xl
                                              .bold
                                              .make(),
                                        ],
                                      ).pSymmetric(h: 10),
                                      SingleChildScrollView(
                                        child: Container(
                                          padding: EdgeInsets.only(
                                              top: 10, left: 10, right: 10),
                                          child: GridView.count(
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            childAspectRatio: 6.5,
                                            crossAxisCount: 2,
                                            children: List.generate(
                                                widget.data.utilites!.length,
                                                (index) {
                                              return Text(
                                                widget.data.utilites![index]
                                                    .tr(),
                                              );
                                            }),
                                          ),
                                        ),
                                      ).pSymmetric(h: 10),
                                    ],
                                  ),
                                Divider(color: Colors.grey).p(10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    'Vehicle position'
                                        .tr()
                                        .text
                                        .xl
                                        .bold
                                        .make()
                                        .pSymmetric(h: 10),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(children: [
                                      Icon(Icons.location_on,
                                          color: Colors.grey),
                                      Expanded(
                                        child: Builder(
                                          builder: (context) =>
                                              '${widget.data.location}'
                                                  .text
                                                  .color(Colors.grey)
                                                  .make(),
                                        ),
                                      ),
                                    ]).pSymmetric(h: 10),
                                  ],
                                ).pSymmetric(h: 10),
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 10),
                                  height: 250,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20)),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child:
                                        //vietmapcheck
                                        AppMapSettings.isUsingVietmap
                                            ? Stack(
                                                children: [
                                                  vietMapGl.VietmapGL(
                                                    styleString:
                                                        'https://maps.vietmap.vn/api/maps/light/styles.json?apikey=${AppStrings.vietMapMapApiKey}',
                                                    initialCameraPosition:
                                                        vietMapGl
                                                            .CameraPosition(
                                                      target: vietMapGl.LatLng(
                                                          _kInitialPosition
                                                              .target.latitude,
                                                          _kInitialPosition
                                                              .target
                                                              .longitude),
                                                      zoom: 13,
                                                    ),
                                                    onMapCreated: (vietMapGl
                                                        .VietmapController
                                                        controller) {
                                                      vietMapController =
                                                          controller;
                                                    },
                                                    trackCameraPosition: true,
                                                  ),
                                                  if (vietMapController != null)
                                                    vietMapGl.MarkerLayer(
                                                        ignorePointer: true,
                                                        mapController:
                                                            vietMapController!,
                                                        markers: [
                                                          vietMapGl.Marker(
                                                              width: 100,
                                                              height: 100,
                                                              child: Container(
                                                                child: Icon(
                                                                    Icons
                                                                        .location_pin,
                                                                    color: Colors
                                                                        .redAccent,
                                                                    size: 36),
                                                              ),
                                                              latLng: vietMapGl.LatLng(
                                                                  _kInitialPosition
                                                                      .target
                                                                      .latitude,
                                                                  _kInitialPosition
                                                                      .target
                                                                      .longitude)),
                                                        ])
                                                ],
                                              )
                                            : GoogleMap(
                                                mapType: MapType.normal,
                                                initialCameraPosition:
                                                    _kInitialPosition,
                                                onMapCreated:
                                                    (GoogleMapController
                                                        controller) {
                                                  _controller
                                                      .complete(controller);
                                                },
                                                circles: <Circle>{
                                                  Circle(
                                                    center: LatLng(
                                                        double.parse(widget
                                                            .data.latitude!),
                                                        double.parse(widget
                                                            .data.longitude!)),
                                                    radius: 1000,
                                                    strokeColor: Colors.grey,
                                                    strokeWidth: 2,
                                                    fillColor: Colors.grey
                                                        .withOpacity(0.5),
                                                    circleId: CircleId(
                                                        UniqueKey().toString()),
                                                  ),
                                                },
                                              ),
                                  ),
                                ),
                                carOwnerCard(),
                                if (widget.model.type == 'xe tự lái')
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 10),
                                    width: double.infinity,
                                    height: 150,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 0),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.grey,
                                                width: 0.5))),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        'Giấy tờ thuê xe'
                                            .tr()
                                            .text
                                            .xl
                                            .bold
                                            .make()
                                            .pOnly(top: 5),
                                        '${'Chọn 1 trong 2 hình thức'.tr()}:'
                                            .text
                                            .bold
                                            .base
                                            .make(),
                                        'GPLX & CCCD gắn chip (đối chiếu)'
                                            .tr()
                                            .text
                                            .lg
                                            .color(Colors.grey)
                                            .make(),
                                        'GPLX (đối chiếu) & Passport (giữ lại)'
                                            .tr()
                                            .text
                                            .lg
                                            .color(Colors.grey)
                                            .make()
                                      ],
                                    ),
                                  ),
                                if (widget.model.type == 'xe tự lái')
                                  Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    width: double.infinity,
                                    height: 120,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 0),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.grey,
                                                width: 0.5))),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        'Tài sản thế chấp'
                                            .tr()
                                            .text
                                            .xl
                                            .bold
                                            .make(),
                                        !widget.data.mortgageExemption!
                                            ? 'Không yêu cầu khách thuê thế chấp Tiền mặt hoặc Xe máy'
                                                .tr()
                                                .text
                                                .lg
                                                .color(Colors.grey)
                                                .make()
                                            : Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  '15 triệu (tiền mặt/chuyển khoản cho chủ xe khi nhận xe)'
                                                      .tr()
                                                      .text
                                                      .lg
                                                      .color(Colors.grey)
                                                      .make(),
                                                  'hoặc Xe máy (kèm cà vẹt gốc) giá trị 15 triệu'
                                                      .tr()
                                                      .text
                                                      .lg
                                                      .color(Colors.grey)
                                                      .make(),
                                                ],
                                              )
                                      ],
                                    ),
                                  ),
                                Container(
                                    margin: EdgeInsets.symmetric(
                                        vertical: 0, horizontal: 10),
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 0),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.grey,
                                                width: 0.5))),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        'Điều khoản'.tr().text.xl.bold.make(),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (widget.model.type ==
                                                'xe tự lái')
                                              sizeRules
                                                  ? dieuKhoanFull.text.lg
                                                      .color(Colors.grey)
                                                      .make()
                                                  : dieuKhoan.text.lg
                                                      .color(Colors.grey)
                                                      .make(),
                                            if (widget.model.type !=
                                                'xe tự lái')
                                              sizeRules
                                                  ? dieuKhoanWithDriverFull
                                                      .text.lg
                                                      .color(Colors.grey)
                                                      .make()
                                                  : dieuKhoanWithDriver.text.lg
                                                      .color(Colors.grey)
                                                      .make(),
                                            '${sizeRules ? '${'Thu gọn'.tr()}  <' : "${'Xem thêm'.tr()}  >"}'
                                                .text
                                                .bold
                                                .base
                                                .make()
                                                .onTap(() {
                                              setState(() {
                                                sizeRules = !sizeRules;
                                              });
                                            }),
                                          ],
                                        ),
                                      ],
                                    ))
                              ],
                            ),
                          ]),
                        )
                      : Visibility(
                          visible: viewModel.isBusy,
                          child: BusyIndicator().centered(),
                        ),
                  bottomNavigationBar: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    width: double.infinity,
                    height: 80,
                    decoration: BoxDecoration(
                        border: Border(
                            top: BorderSide(
                      color: Colors.grey,
                    ))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            widget.data.vehicleRentPrice!
                                            .discountThreeDays !=
                                        null &&
                                    widget.data.vehicleRentPrice!
                                            .discountThreeDays !=
                                        0 &&
                                    (widget
                                                    .model.totalTimeRent! /
                                                24)
                                            .ceil() >
                                        2 &&
                                    widget.model.type == 'xe tự lái'
                                ? Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                        RichText(
                                          text: TextSpan(
                                            text:
                                                '${formatNumber(rentalPriceFor1DayNotDiscount)}',
                                            style: TextStyle(
                                              fontSize: Vx.dp20,
                                              fontWeight: FontWeight.w400,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              decorationColor:
                                                  AppColor.cancelledColor,
                                              decorationThickness: 1.0,
                                              color: AppColor.cancelledColor,
                                            ),
                                          ),
                                        ),
                                        '${formatNumber(rentalPriceFor1Day)}'
                                            .text
                                            .color(AppColor.primaryColor)
                                            .semiBold
                                            .size(Vx.dp20)
                                            .make(),
                                        if (widget.model.type == 'xe tự lái')
                                          '/${'day'.tr()}'
                                              .text
                                              .color(Colors.grey)
                                              .make(),
                                      ])
                                : widget.data.vehicleRentPrice!
                                                .discountThreeDays !=
                                            null &&
                                        widget.data.vehicleRentPrice!
                                                .discountThreeDays !=
                                            0 &&
                                        (widget.model.totalTimeRent! / 24)
                                                .ceil() >
                                            6 &&
                                        widget.model.type == 'xe tự lái'
                                    ? Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                            RichText(
                                              text: TextSpan(
                                                text:
                                                    '${formatNumber(rentalPriceFor1DayNotDiscount)}',
                                                style: TextStyle(
                                                  fontSize: Vx.dp20,
                                                  fontWeight: FontWeight.w400,
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                  decorationColor:
                                                      AppColor.cancelledColor,
                                                  decorationThickness: 1.0,
                                                  color:
                                                      AppColor.cancelledColor,
                                                ),
                                              ),
                                            ),
                                            '${formatNumber(rentalPriceFor1Day)}'
                                                .text
                                                .color(AppColor.primaryColor)
                                                .semiBold
                                                .xl2
                                                .make(),
                                            if (widget.model.type ==
                                                'xe tự lái')
                                              '/${'day'.tr()}'
                                                  .text
                                                  .color(Colors.grey)
                                                  .make(),
                                          ])
                                    : widget.model.type != 'xe tự lái'
                                        ? Row(children: [
                                            '${formatNumber(priceWithDriver)}'
                                                .text
                                                .color(AppColor.primaryColor)
                                                .semiBold
                                                .xl2
                                                .make(),
                                          ])
                                        : Row(children: [
                                            '${formatNumber(rentalPriceFor1DayNotDiscount)}'
                                                .text
                                                .color(AppColor.primaryColor)
                                                .semiBold
                                                .xl2
                                                .make(),
                                            if (widget.model.type ==
                                                'xe tự lái')
                                              '/${'day'.tr()}'
                                                  .text
                                                  .color(Colors.grey)
                                                  .make(),
                                          ]),
                            '${'Giá tổng'.tr()}: ${formatNumber(totalPrice())}'
                                .text
                                .underline
                                .color(Colors.grey)
                                .make(),
                          ],
                        ),
                        Container(
                          height: 40,
                          width: MediaQuery.of(context).size.width / 3,
                          child: CustomButton(
                            title: 'Chọn thuê'.tr(),
                            onPressed: () async {
                              print('Vị trí: ${widget.model.pickUpLocation}');
                              if (!checkDeliver && checkLocation == 2) {
                                await AlertService.warning(
                                    title: "Thông báo".tr(),
                                    text:
                                        'Địa điểm giao nhận quá xa so với vị trí có thể giao xe tận nơi là ${widget.data.deliveryDistance}km. Bạn vui lòng chọn địa điểm giao nhận gần hơn hoặc có thể chọn xe khác.');
                              } else if (widget.model.pickUpLocation == '' ||
                                  widget.model.pickUpLocation ==
                                      'Nhập địa điểm') {
                                await AlertService.warning(
                                    title: "Thông báo".tr(),
                                    text: 'Bạn chưa chọn địa điểm cụ thể.');
                              } else if (widget.selectedRoute.value > 0 &&
                                  (widget.model.dropOffLocation ==
                                          'Nhập địa điểm' ||
                                      widget.model.dropOffLocation == '')) {
                                await AlertService.warning(
                                    title: "Thông báo".tr(),
                                    text: 'Bạn chưa chọn điểm đến cụ thể.');
                              } else {
                                await viewModel.getLongLatFromAddress(
                                    widget.pickUpLocation.value);
                                String route;
                                if (widget.selectedRoute.value == 0) {
                                  route = 'Nội thành';
                                } else if (widget.selectedRoute.value == 1) {
                                  var dropOff =
                                      await viewModel.getLongLatFromAddress(
                                          widget.dropOffLocation.value, true);
                                  viewModel.dropOffLongitude =
                                      dropOff.longitude;
                                  viewModel.dropOffLatitude = dropOff.latitude;
                                  route = 'liên tỉnh - 2 chiều';
                                } else {
                                  var dropOff =
                                      await viewModel.getLongLatFromAddress(
                                          widget.dropOffLocation.value, true);
                                  viewModel.dropOffLongitude =
                                      dropOff.longitude;
                                  viewModel.dropOffLatitude = dropOff.latitude;
                                  route = 'liên tỉnh - 1 chiều';
                                }
                                print(route);
                                // viewModel.addRentalRequest(
                                //     totalPrice: totalPrice().toString(),
                                //     status: "pending",
                                //     totalDays:
                                //         '${(widget.model.totalTimeRent! / 24).ceil()}',
                                //     debutDate:
                                //         '${widget.model.startDate.toString().substring(0, 10)}',
                                //     expireDate:
                                //         '${widget.model.endDate.toString().substring(0, 10)}',
                                //     contactPhone: '${widget.data.owner!.phone}',
                                //     vehicleId: '${widget.data.id}');
                                // print(
                                //     'Địa chỉ đón111: ${widget.model.dropOffLocation}');
                                // print('totalPrice: ${totalPrice().toString()}');
                                // print('');
                                // print('Vào thuê xe');
                                bool deliveryToHome = checkLocation == 2;
                                showModalBottomSheet(
                                    barrierColor: Colors.transparent,
                                    enableDrag: false,
                                    isScrollControlled: true,
                                    useRootNavigator: true,
                                    context: context,
                                    useSafeArea: true,
                                    builder: (context) => ConfirmBooking(
                                          priceWithDriver: priceWithDriver,
                                          dropOffLocation:
                                              widget.dropOffLocation,
                                          pickUpLocation: widget.pickUpLocation,
                                          route: route,
                                          totalPrice: totalPrice(),
                                          rentalPriceFor1Day:
                                              rentalPriceFor1Day,
                                          rentalPriceFor1DayNotDiscount:
                                              rentalPriceFor1DayNotDiscount,
                                          distance: distance,
                                          delivery_fee: delivery_fee,
                                          model: viewModel,
                                          data: widget.data,
                                          deliveryToHome: deliveryToHome,
                                        ));
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
        });
  }

  Widget carOwnerCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      color: Colors.grey.shade200,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          'Car owner'.tr().text.xl.bold.make(),
          Container(
            padding: EdgeInsets.all(15),
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(children: [
              Row(
                children: [
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: CircleAvatar(
                        child: CachedNetworkImage(
                      imageUrl: widget.data.owner?.photo != null
                          ? widget.data.owner!.photo
                          : "",
                      fit: BoxFit.fill,
                      placeholder: (context, url) => CircularProgressIndicator(
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
                    )),
                  ),
                  Column(
                    children: [
                      '${widget.data.owner!.name}'.text.xl.bold.make(),
                      Row(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.yellow),
                              '${widget.data.owner!.rating!}'
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
                              '${widget.data.owner!.trip} ${'Ride'.tr().toLowerCase()}'
                                  .text
                                  .color(Colors.grey)
                                  .make(),
                            ],
                          ),
                        ],
                      ).pSymmetric(h: 10),
                    ],
                  )
                ],
              ),
              Divider(color: Colors.grey),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      'Response rate'
                          .tr()
                          .text
                          .color(Colors.grey)
                          .center
                          .make()
                          .pOnly(bottom: 10, top: 10),
                      '${widget.data.owner!.responseRate}'.text.bold.make()
                    ],
                  ).w(MediaQuery.of(context).size.width / 4),
                  SizedBox(width: 16),
                  Column(
                    children: [
                      'Agreement rate'
                          .tr()
                          .text
                          .color(Colors.grey)
                          .center
                          .make()
                          .pOnly(bottom: 10, top: 10),
                      '${widget.data.owner!.rateOfAgreement}'.text.bold.make()
                    ],
                  ).w(MediaQuery.of(context).size.width / 4),
                  SizedBox(width: 16),
                  Column(
                    children: [
                      'Response within'
                          .tr()
                          .text
                          .color(Colors.grey)
                          .center
                          .make()
                          .pOnly(bottom: 10, top: 10),
                      '${widget.data.owner!.feedbackIn} ${'min'.tr()}'
                          .text
                          .bold
                          .make()
                    ],
                  ).w(MediaQuery.of(context).size.width / 4),
                ],
              )
            ]),
          )
        ],
      ),
    ).onInkTap(() {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => OwnerDetailPage(
                  owner: widget.data.owner!,
                  model: widget.model,
                  dropOffLocation: widget.dropOffLocation,
                  pickUpLocation: widget.pickUpLocation,
                  bottomSheet: widget.bottomSheet,
                  selectedRoute: widget.selectedRoute,
                )),
      );
    });
  }

  bool checkDeliveryCar = false;
  bool checkDeliver = false;
  bool checkFreeDeliver = false;
  int totalFee = 0;
  double distance = 0;
  String? deliveryFee(CarRental data, CarDetailViewModel carvm) {
    if (!carvm.isBusy && oldLocation != widget.pickUpLocation.value) {
      carvm.getDistance(widget.pickUpLocation.value).then((value) {
        print('Tính xong khoảng cách: $value');
        distance = value / 1000;
        totalFee =
            (((value / 1000) - data.deliveryFree!) * data.deliveryFee!).toInt();
        totalFee = (totalFee / 1000).round();
        totalFee = totalFee * 1000000;
        if (value.toInt() / 1000 <= data.deliveryFree!) {
          checkFreeDeliver = true;
        } else {
          checkFreeDeliver = false;
        }
        if (value.toInt() / 1000 <= data.deliveryDistance!) {
          checkDeliver = true;
        } else {
          checkDeliver = false;
        }
        oldLocation = widget.pickUpLocation.value;
      });
    }
    if (checkLocation == 2 || widget.model.type != 'xe tự lái') {
      if (checkFreeDeliver) {
        return 'Free'.tr();
      }
      if (checkDeliver || widget.model.type != 'xe tự lái') {
        print('Đúng điều kiện lấy phí');
        print('Phí là: $totalFee');
        return carvm.isBusy
            ? "..."
            : '${totalFee / 1000}'; //'${'${AppStrings.currencySymbol} ${totalFee / 1000}'.currencyFormat()}';
      } else {
        return '';
      }
    } else {
      return '';
    }
  }

  Future<dynamic> selectLocationPickup(BuildContext context) {
    checkDeliveryCar = false;
    taxiViewModel!.pickupLocationTEC.text = widget.pickUpLocation.value;
    return showModalBottomSheet(
        barrierColor: Colors.transparent,
        enableDrag: false,
        isScrollControlled: true,
        useRootNavigator: true,
        useSafeArea: true,
        context: context,
        builder: (context) => ViewModelBuilder<TaxiViewModel>.reactive(
            viewModelBuilder: () => taxiViewModel!,
            disposeViewModel: false,
            builder: (context, vm, child) {
              return ViewModelBuilder<
                      NewTaxiOrderLocationEntryViewModel>.reactive(
                  viewModelBuilder: () =>
                      NewTaxiOrderLocationEntryViewModel(context, vm),
                  disposeViewModel: false,
                  onViewModelReady: (vm) =>
                      WidgetsBinding.instance.addPostFrameCallback(
                        (_) {
                          vm.initialise();
                        },
                      ),
                  builder: (context, taxiNewOrderViewModel, child) {
                    print(taxiViewModel!.pickupLocationTEC.text);

                    return BasePage(
                        title: 'Location'.tr(),
                        showAppBar: true,
                        showLeadingAction: true,
                        body: Column(
                          children: [
                            TaxiCustomTextFormField(
                              hintText: "Pickup Location".tr(),
                              controller: taxiViewModel!.pickupLocationTEC,
                              focusNode: taxiViewModel!.pickupLocationFocusNode,
                              onChanged: taxiNewOrderViewModel.searchPlace,
                              clear: true,
                            ),
                            CustomListView(
                              padding: EdgeInsets.zero,
                              isLoading: taxiNewOrderViewModel
                                  .busy(taxiNewOrderViewModel.places),
                              dataSet: taxiNewOrderViewModel.places != null
                                  ? taxiNewOrderViewModel.places!
                                  : [],
                              itemBuilder: (contex, index) {
                                final place =
                                    taxiNewOrderViewModel.places![index];
                                return AddressListItem(
                                  place,
                                  onAddressSelected:
                                      taxiNewOrderViewModel.onAddressSelected,
                                );
                              },
                              separatorBuilder: (ctx, index) =>
                                  UiSpacer.divider(),
                            ).expand(),
                            NewTaxiPickOnMapButton(
                              taxiNewOrderViewModel: taxiNewOrderViewModel,
                            ),
                            CustomButton(
                              title: 'Completed'.tr(),
                              onPressed: () async {
                                if (taxiViewModel!.pickupLocationTEC.text ==
                                        '' ||
                                    taxiViewModel!
                                        .pickupLocationTEC.text.isEmpty) {
                                  await AlertService.warning(
                                      title: "Thông báo".tr(),
                                      text: 'Bạn chưa chọn địa điểm cụ thể.');
                                } else {
                                  updatePickUpLocation(
                                      taxiViewModel!.pickupLocationTEC.text);
                                  Navigator.pop(context);
                                }
                              },
                            ).pSymmetric(v: 10, h: 10),
                          ],
                        ).pOnly(bottom: context.mq.viewInsets.bottom));
                  });
            }));
  }

  Widget buildImage(
          String image, BuildContext context, int index, int length) =>
      Stack(children: [
        SizedBox(
          width: double.infinity,
          child: ClipRRect(
              child: CachedNetworkImage(
            imageUrl: image,
            fit: BoxFit.fill,
            placeholder: (context, url) =>
                CircularProgressIndicator(color: AppColor.cancelledColor),
            errorWidget: (context, url, error) => ClipRRect(
              child: Image.network(
                'https://nld.mediacdn.vn/291774122806476800/2021/9/25/24226875648526647114344167202327751795544483n-16325671978991579408720.jpg',
                fit: BoxFit.cover,
              ),
            ),
          )),
        ),
        Positioned(
            right: 20,
            top: 250,
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(3),
              decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(10)),
              child: "${index + 1}/$length".text.color(Colors.white).make(),
            )),
      ]);

  int totalPrice() {
    int total = widget.data.vehicleRentPrice!.discountSevenDays != null &&
            widget.data.vehicleRentPrice!.discountSevenDays != 0 &&
            (widget.model.totalTimeRent! / 24).ceil() > 6 &&
            widget.model.type == 'xe tự lái'
        ? (calculateRentalCost(
                    widget.model.startDate,
                    widget.model.endDate,
                    int.parse(widget.model.startTime!.substring(0, 2)),
                    int.parse(widget.model.endTime!.substring(0, 2))) *
                (100 - widget.data.vehicleRentPrice!.discountSevenDays!) /
                100)
            .ceil()
        : widget.data.vehicleRentPrice!.discountThreeDays != null &&
                widget.data.vehicleRentPrice!.discountThreeDays != 0 &&
                (widget.model.totalTimeRent! / 24).ceil() > 2 &&
                widget.model.type == 'xe tự lái'
            ? (calculateRentalCost(
                        widget.model.startDate,
                        widget.model.endDate,
                        int.parse(widget.model.startTime!.substring(0, 2)),
                        int.parse(widget.model.endTime!.substring(0, 2))) *
                    (100 - widget.data.vehicleRentPrice!.discountThreeDays!) /
                    100)
                .ceil()
            : calculateRentalCost(
                    widget.model.startDate,
                    widget.model.endDate,
                    int.parse(widget.model.startTime!.substring(0, 2)),
                    int.parse(widget.model.endTime!.substring(0, 2)))
                .ceil();
    if (checkDeliver &&
        delivery_fee != '' &&
        delivery_fee != "Free".tr() &&
        delivery_fee != "...") {
      //String cleanValue = delivery_fee.replaceAll(RegExp(r'[^0-9]'), '');
      int value =
          int.parse(delivery_fee.substring(0, delivery_fee.lastIndexOf('.')));
      total += value;
    }
    if (widget.model.type != 'xe tự lái' &&
        delivery_fee != '' &&
        delivery_fee != "Free".tr() &&
        delivery_fee != "...") {
      int value1 =
          int.parse(delivery_fee.substring(0, delivery_fee.lastIndexOf('.')));
      total = priceWithDriver + value1;
    }
    return total;
  }

  bool sizeRules = false;
  String formatNumber(int? number, [String? symbol]) {
    if (number! >= 1000) {
      double result = number / 1000;
      String formattedNumber = result.toStringAsFixed(0);
      if (result >= 1000) {
        final int length = formattedNumber.length;
        final int commaCount = (length - 1) ~/ 3;
        for (int i = 1; i <= commaCount; i++) {
          final int commaIndex = length - (i * 3);
          formattedNumber =
              formattedNumber.replaceRange(commaIndex, commaIndex, ',');
        }
      }
      return '${formattedNumber}${symbol ?? 'K'}';
    } else {
      return number.toString();
    }
  }

  int calculateRentalCost(
      DateTime startDate, DateTime endDate, int startHour, int endHour) {
    DateTime currentDate = startDate.add(Duration(days: 1));
    int totalPrice = 0;
    endDate = startDate
        .add(Duration(days: (widget.model.totalTimeRent! / 24).ceil()));
    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      if (currentDate.weekday < 6) {
        totalPrice += widget.data.vehicleRentPrice!.priceMondayFriday!;
      } else {
        totalPrice += widget.data.vehicleRentPrice!.priceSaturdaySunday!;
      }
      currentDate = currentDate.add(Duration(days: 1));
    }
    return totalPrice;
  }

  String dieuKhoanFull = """
  ${'Quy định khác'.tr()}:
  - ${'Sử dụng xe đúng mục đích.'.tr()}
  - ${'Không sử dụng xe thuê vào mục đích phi pháp, trái pháp luật.'.tr()}
  - ${'Không sử dụng xe thuê để cầm cố, thế chấp.'.tr()}
  - ${'Không hút thuốc, nhả kẹo cao su, xả rác trong xe.'.tr()}
  - ${'Không chở hàng quốc cấm dễ cháy nổ.'.tr()}
  - ${'Không chở hoa quả, thực phẩm nặng mùi trong xe.'.tr()}
  - ${'Khi trả xe, nếu xe bẩn hoặc có mùi trong xe, khách hàng vui lòng vệ sinh xe sạch sẽ hoặc gửi phụ thu phí vệ sinh xe.'.tr()}
  ${'Trân trọng cảm ơn, chúc quý khách hàng có những chuyến đi tuyệt vời !'.tr()}
  """;
}

String dieuKhoan = """
  ${'Quy định khác'.tr()}:
  - ${'Sử dụng xe đúng mục đích.'.tr()}
  - ${'Không sử dụng xe thuê vào mục đích phi pháp, trái pháp luật.'.tr()}
  - ${'Không sử dụng xe thuê để cầm cố, thế chấp.'.tr()}
  - ${'Không hút thuốc, nhả kẹo cao su, xả rác trong xe.'.tr()}
  """;
String dieuKhoanWithDriverFull = """
  1. Quý khách vui lòng không hút thuốc trên xe hoặc mang các thực phẩm có mùi
  2. Để đảm bảo thời gian đón khách đúng giờ & tránh tắc đường, tài xế chỉ đón khách tại điểm đã đặt xe hoặc điểm thay thế (Vui lòng báo trước cho tài xế trong trường hợp có thay đổi địa điểm đón khách)
  3. Trong trường hợp khách thuê thay đổi lộ trình chuyến đi, vui lòng báo trước với tài xế để chuẩn bị và chăm sóc tốt hơn
  4. Khách thuê có Thú Cưng. Nên liên lạc với Chủ Xe trước
  Chúc Quý Khách chuyến đi vui vẻ !
""";
String dieuKhoanWithDriver = """
  1. Quý khách vui lòng không hút thuốc trên xe hoặc mang các thực phẩm có mùi
  2. Để đảm bảo thời gian đón khách đúng giờ & tránh tắc đường, tài xế chỉ đón khách tại điểm đã đặt xe hoặc điểm thay thế (Vui lòng báo trước cho tài xế trong trường hợp có thay đổi địa điểm đón khách)
""";

class CarDetailViewModel extends MyBaseViewModel {
  double? latitude;
  double? longitude;
  String? location;
  String? deliveryLocation;
  double? distance;
  CarRentalViewModel carRentalVM = CarRentalViewModel();
  changeStatusFavourite(CarRental data) {
    data.like = !data.like;
    notifyListeners();
  }

  Future<void> getAddressFromCoordinates() async {
    if (latitude! > 90) {
      latitude = 90.0;
    }
    final coordinates = geocoderService.Coordinates(latitude!, longitude!);
    setBusy(true);
    geocoderService.GeocoderService service = geocoderService.GeocoderService();
    List<geocoderService.Address> lstAddress = [];
    lstAddress = await service.findAddressesFromCoordinates(coordinates);
    if (lstAddress.isNotEmpty) {
      location = '${lstAddress.first.addressLine!}';
    } else {
      location = 'Không có vị trí';
    }
    setBusy(false);
  }

  //Lấy vĩ độ và kinh độ từ location
  Future<Coordinates> getCoordinatesFromQuery(String query) async {
    try {
      CarRentalViewModel model = CarRentalViewModel();

      var addresses = await model.getLongLatFromAddress(query, true);

      var latitude = addresses.latitude;
      var longitude = addresses.longitude;
      return Coordinates(latitude!, longitude!);
    } catch (error) {
      print("Đã xảy ra lỗi: $error");
      return Coordinates(0, 0);
    }
  }

  Future<double> getDistance(
      [String? locationPickUpNew, String? locationDropOffNew]) async {
    print('Vị trí vào hàm tính khoảng cách: ${deliveryLocation}');
    Coordinates locationDropOff;
    setBusy(true);
    Coordinates locationPickUp =
        await getCoordinatesFromQuery(locationPickUpNew ?? deliveryLocation!);
    if (locationDropOffNew != null) {
      locationDropOff = await getCoordinatesFromQuery(locationDropOffNew);
      distance = await carRentalVM.calculateDistance(
          locationPickUp.latitude,
          locationPickUp.longitude,
          locationDropOff.latitude,
          locationDropOff.longitude);
    } else {
      distance = await carRentalVM.calculateDistance(
        latitude!,
        longitude!,
        locationPickUp.latitude,
        locationPickUp.longitude,
      );
    }
    setBusy(false);
    //notifyListeners();
    print('Khoảng cách là: ${distance}');
    return distance!;
  }
}
