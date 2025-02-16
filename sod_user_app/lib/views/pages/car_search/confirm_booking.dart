import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_map_settings.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/extensions/string.dart';
import 'package:sod_user/models/car_rental.dart';
import 'package:sod_user/models/coordinates.dart';
import 'package:sod_user/view_models/car_rental.view_model.dart';
import 'package:sod_user/views/pages/car_rental/car_rental.model.dart';
import 'package:sod_user/views/pages/car_rental/widgets/selection_day.dart';
import 'package:sod_user/views/pages/car_search/google_map.page.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/widgets/busy_indicator.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:sod_user/widgets/states/loading.shimmer.dart';
import 'package:stacked/stacked.dart';
import 'package:timelines/timelines.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart' as vietMapGl;

class ConfirmBooking extends StatefulWidget {
  ConfirmBooking({
    super.key,
    required this.data,
    required this.model,
    required this.deliveryToHome,
    required this.delivery_fee,
    required this.distance,
    required this.totalPrice,
    required this.rentalPriceFor1DayNotDiscount,
    required this.rentalPriceFor1Day,
    required this.route,
    required this.dropOffLocation,
    required this.pickUpLocation,
    required this.priceWithDriver,
  });
  CarRental data;
  CarRentalViewModel model;
  bool deliveryToHome;
  String delivery_fee;
  double distance;
  int totalPrice;
  int rentalPriceFor1DayNotDiscount;
  int rentalPriceFor1Day;
  int priceWithDriver;
  String route;
  final ValueNotifier<String> pickUpLocation;
  final ValueNotifier<String> dropOffLocation;
  @override
  State<ConfirmBooking> createState() => _ConfirmBookingState();
}

TextEditingController messageController = TextEditingController();

class _ConfirmBookingState extends State<ConfirmBooking> {
  int discountPrice = 0;
  int subTotal = 0;
  CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(10.823099, 106.681937),
  );
  Set<Marker> markers = {};
  List<LatLng> polylineCoordinates = [];
  Completer<GoogleMapController> _controller = Completer();
  late LatLng origin;
  late LatLng destination;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (widget.model.type == 'xe tự lái') {
      discountPrice = (widget.rentalPriceFor1DayNotDiscount *
              ((widget.model.totalTimeRent! / 24).ceil())) -
          (widget.rentalPriceFor1Day *
              ((widget.model.totalTimeRent! / 24).ceil()));
      subTotal = widget.rentalPriceFor1DayNotDiscount *
          ((widget.model.totalTimeRent! / 24).ceil());
    } else {
      subTotal = widget.priceWithDriver;
    }

    _kInitialPosition = CameraPosition(
        target: LatLng(widget.model.latitude!, widget.model.longitude!),
        zoom: 13.0);
    if (widget.route != 'Nội thành' && widget.model.type != 'xe tự lái') {
      origin = LatLng(widget.model.latitude!, widget.model.longitude!);
      destination =
          LatLng(widget.model.dropOffLatitude!, widget.model.dropOffLongitude!);
    }
  }

  double? distance;
  @override
  Widget build(BuildContext context) {
    print('Phí đưa đón: ${widget.delivery_fee}');
    print('Vĩ độ đón: ${widget.model.latitude!}');
    print('Kinh độ đón: ${widget.model.longitude!}');
    print('Vĩ độ đến: ${widget.model.dropOffLatitude!}');
    print('Kinh độ đến: ${widget.model.dropOffLongitude!}');
    if (widget.delivery_fee == '' ||
        widget.delivery_fee == "Free".tr() ||
        widget.delivery_fee == "...") {
      widget.delivery_fee = '0';
    }
    widget.pickUpLocation.addListener(() {
      print('Thay đổi điểm đón');
      setState(() {
        distance = 0;
      });
    });
    return ViewModelBuilder<CarRentalViewModel>.reactive(
        disposeViewModel: false,
        viewModelBuilder: () => widget.model,
        onViewModelReady: (viewModel) async {
          if (widget.route != 'Nội thành' && widget.model.type != 'xe tự lái') {
            await viewModel.getPolylines(origin, destination);
            distance = await viewModel.calculateDistance(
              widget.model.latitude!,
              widget.model.longitude!,
              widget.model.dropOffLatitude!,
              widget.model.dropOffLongitude!,
              true,
            );
          }
        },
        builder: (context, viewModel, child) {
          widget.model = viewModel;
          markers = {
            Marker(
              markerId: MarkerId('point1'),
              position: LatLng(viewModel.latitude!, viewModel.longitude!),
              infoWindow: InfoWindow(
                title: 'Vị trí đón khách',
                snippet: 'Điểm bắt đầu',
              ),
            ),
            if (widget.route != 'Nội thành' && widget.model.type != 'xe tự lái')
              Marker(
                markerId: MarkerId('point2'),
                position: LatLng(
                    viewModel.dropOffLatitude!, viewModel.dropOffLongitude!),
                infoWindow: InfoWindow(
                  title: 'Vị trí đến',
                  snippet: 'Điểm bắt kết thúc',
                ),
              ),
          };
          return BasePage(
            resizeToAvoidBottomInset: true,
            backgroundColor: Colors.white,
            showAppBar: true,
            showLeadingAction: true,
            leading: Container(
              margin: EdgeInsets.all(5),
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.grey),
              ),
              child: Icon(
                Icons.close,
                color: Colors.black,
              ),
            ).onInkTap(() {
              Navigator.pop(context);
            }),
            title: 'Xác nhận đặt xe'.tr(),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  carCardMethod(context).pSymmetric(h: 10).pOnly(top: 10),
                  Divider(color: Colors.grey).p(10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      'Thông tin thuê xe'.text.xl.bold.make().pSymmetric(h: 10),
                      rentalPeriodCard().pSymmetric(h: 10),
                      if (widget.model.type == 'xe tự lái')
                        vehiclePickUpLocation(context).pSymmetric(h: 20),
                      //
                      if (widget.model.type != 'xe tự lái')
                        'Lộ trình ${widget.route}'
                            .text
                            .xl
                            .bold
                            .make()
                            .pSymmetric(h: 10),
                      if (widget.model.type != 'xe tự lái')
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          width: double.infinity,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.location_on_outlined),
                              Expanded(
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: EdgeInsets.symmetric(horizontal: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      'Điểm đón'.text.color(Colors.grey).make(),
                                      '${widget.model.pickUpLocation}'
                                          .text
                                          .overflow(TextOverflow.ellipsis)
                                          .maxLines(2)
                                          .bold
                                          .make()
                                          .pOnly(top: 5),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ).pOnly(top: 10),
                      if (widget.route != 'Nội thành' &&
                          widget.model.type != 'xe tự lái')
                        Divider(color: Colors.grey).pSymmetric(h: 20),
                      if (widget.route != 'Nội thành' &&
                          widget.model.type != 'xe tự lái')
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          width: double.infinity,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.location_on_outlined),
                              Expanded(
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: EdgeInsets.symmetric(horizontal: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      'Điểm đến'.text.color(Colors.grey).make(),
                                      '${widget.model.dropOffLocation}'
                                          .text
                                          .overflow(TextOverflow.ellipsis)
                                          .maxLines(2)
                                          .bold
                                          .make()
                                          .pOnly(top: 5),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      if (widget.route == 'Nội thành' &&
                          widget.model.type != 'xe tự lái')
                        Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 10),
                          height: 250,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: AppMapSettings.isUsingVietmap
                                ? Stack(children: [
                                    vietMapGl.VietmapGL(
                                      styleString:
                                          'https://maps.vietmap.vn/api/maps/light/styles.json?apikey=${AppStrings.vietMapMapApiKey}',
                                      initialCameraPosition:
                                          vietMapGl.CameraPosition(
                                        target: vietMapGl.LatLng(
                                            _kInitialPosition.target.latitude,
                                            _kInitialPosition.target.longitude),
                                        zoom: 13,
                                      ),
                                      onMapCreated: (vietMapGl.VietmapController
                                          controller) {
                                        viewModel.vietMapController =
                                            controller;
                                      },
                                      trackCameraPosition: true,
                                    ),
                                  ])
                                : GoogleMap(
                                    mapType: MapType.normal,
                                    initialCameraPosition: _kInitialPosition,
                                    onMapCreated:
                                        (GoogleMapController controller) {
                                      _controller.complete(controller);
                                    },
                                    markers: markers,
                                    gestureRecognizers:
                                        <Factory<OneSequenceGestureRecognizer>>[
                                      Factory<OneSequenceGestureRecognizer>(
                                          () => EagerGestureRecognizer()),
                                    ].toSet(),
                                  ),
                          ),
                        ),
                      if (widget.route != 'Nội thành' &&
                          widget.model.type != 'xe tự lái')
                        viewModel.isBusy
                            ? LoadingShimmer()
                            : Container(
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
                                          ? Stack(children: [
                                              vietMapGl.VietmapGL(
                                                styleString:
                                                    'https://maps.vietmap.vn/api/maps/light/styles.json?apikey=${AppStrings.vietMapMapApiKey}',
                                                initialCameraPosition:
                                                    vietMapGl.CameraPosition(
                                                  target: vietMapGl.LatLng(
                                                      _kInitialPosition
                                                          .target.latitude,
                                                      _kInitialPosition
                                                          .target.longitude),
                                                  zoom: 13,
                                                ),
                                                onMapCreated:
                                                    (vietMapGl.VietmapController
                                                        controller) {
                                                  viewModel.vietMapController =
                                                      controller;

                                                  List<LatLng> polylinePoints =
                                                      viewModel.gMapPolylines
                                                          .expand((polyline) =>
                                                              polyline.points)
                                                          .toList();
                                                  vietMapGl.LatLngBounds
                                                      bounds =
                                                      vietMapGl.LatLngBounds(
                                                    southwest: vietMapGl.LatLng(
                                                      polylinePoints
                                                          .map((point) =>
                                                              point.latitude)
                                                          .reduce(
                                                              (min, value) =>
                                                                  min < value
                                                                      ? min
                                                                      : value),
                                                      polylinePoints
                                                          .map((point) =>
                                                              point.longitude)
                                                          .reduce(
                                                              (min, value) =>
                                                                  min < value
                                                                      ? min
                                                                      : value),
                                                    ),
                                                    northeast: vietMapGl.LatLng(
                                                      polylinePoints
                                                          .map((point) =>
                                                              point.latitude)
                                                          .reduce(
                                                              (max, value) =>
                                                                  max > value
                                                                      ? max
                                                                      : value),
                                                      polylinePoints
                                                          .map((point) =>
                                                              point.longitude)
                                                          .reduce(
                                                              (max, value) =>
                                                                  max > value
                                                                      ? max
                                                                      : value),
                                                    ),
                                                  );

                                                  viewModel.vietMapController!
                                                      .animateCamera(
                                                          vietMapGl.CameraUpdate
                                                              .newLatLngBounds(
                                                    bounds,
                                                    top: 40,
                                                    left: 40,
                                                    right: 40,
                                                    bottom: 40,
                                                  ));
                                                },
                                                trackCameraPosition: true,
                                              ),
                                            ])
                                          : GoogleMap(
                                              mapType: MapType.normal,
                                              initialCameraPosition:
                                                  _kInitialPosition,
                                              onMapCreated: (GoogleMapController
                                                  controller) {
                                                _controller
                                                    .complete(controller);
                                                List<LatLng> polylinePoints =
                                                    viewModel.gMapPolylines
                                                        .expand((polyline) =>
                                                            polyline.points)
                                                        .toList();
                                                // Tạo một LatLngBounds từ danh sách tọa độ
                                                LatLngBounds bounds =
                                                    LatLngBounds(
                                                  southwest: LatLng(
                                                    polylinePoints
                                                        .map((point) =>
                                                            point.latitude)
                                                        .reduce((min, value) =>
                                                            min < value
                                                                ? min
                                                                : value),
                                                    polylinePoints
                                                        .map((point) =>
                                                            point.longitude)
                                                        .reduce((min, value) =>
                                                            min < value
                                                                ? min
                                                                : value),
                                                  ),
                                                  northeast: LatLng(
                                                    polylinePoints
                                                        .map((point) =>
                                                            point.latitude)
                                                        .reduce((max, value) =>
                                                            max > value
                                                                ? max
                                                                : value),
                                                    polylinePoints
                                                        .map((point) =>
                                                            point.longitude)
                                                        .reduce((max, value) =>
                                                            max > value
                                                                ? max
                                                                : value),
                                                  ),
                                                );
                                                // Điều chỉnh phạm vi hiển thị của bản đồ để hiển thị đường đi
                                                controller.animateCamera(
                                                    CameraUpdate
                                                        .newLatLngBounds(
                                                            bounds, 50));
                                              },
                                              markers: markers,
                                              polylines:
                                                  viewModel.gMapPolylines,
                                              gestureRecognizers: <Factory<
                                                  OneSequenceGestureRecognizer>>[
                                                Factory<OneSequenceGestureRecognizer>(
                                                    () =>
                                                        EagerGestureRecognizer()),
                                              ].toSet(),
                                            ),
                                ),
                              ),
                      //
                      (widget.model.type != 'xe tự lái')
                          ? widget.route == 'Nội thành'
                              ? routeInformation()
                              : widget.route != 'Nội thành'
                                  ? distance != null
                                      ? routeInformation()
                                      : LoadingShimmer()
                                  : SizedBox()
                          : SizedBox(),
                      carOwnerCard(),

                      message(),
                      if (widget.model.type == 'xe tự lái') priceList(),
                      if (widget.model.type != 'xe tự lái')
                        priceListWithDriver(),
                      if (widget.model.type == 'xe tự lái')
                        carRentalDocuments(),
                      if (widget.model.type == 'xe tự lái') collateral(),
                    ],
                  )
                ],
              ),
            ),
            bottomNavigationBar: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                width: double.infinity,
                height: 80,
                decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.grey))),
                child: CustomButton(
                    loading: viewModel.isBusy,
                    title: 'Gửi yêu cầu thuê xe',
                    onPressed: () async {
                      if (widget.model.type == 'xe tự lái') {
                        await widget.model.addRentalRequestTest(
                            deliveryFee: double.parse(widget.delivery_fee),
                            subTotal: subTotal,
                            discount: discountPrice,
                            deliveryToHome: widget.deliveryToHome ? 1 : 0,
                            route: 0,
                            pickup_latitude: widget.model.latitude.toString(),
                            pickup_longitude: widget.model.longitude.toString(),
                            dropoff_latitude:
                                widget.model.dropOffLatitude.toString(),
                            dropoff_longitude:
                                widget.model.dropOffLongitude.toString(),
                            typee: 1,
                            totalPrice: widget.totalPrice.toString(),
                            status: "pending",
                            totalDays:
                                '${(widget.model.self_driving.total.hours).ceil()}',
                            debutDate:
                                '${widget.model.self_driving.getStartDateTime().toString()}',
                            expireDate:
                                '${widget.model.self_driving.getEndDateTime().toString()}',
                            contactPhone: '${widget.data.owner!.phone}',
                            vehicleId: '${widget.data.id}',
                            driverID: widget.data.owner!.id);

                        print("Vehicle ID  ==> ${widget.data.id}");
                      } else {
                        await widget.model.addRentalRequestTest(
                            deliveryFee: double.parse(widget.delivery_fee),
                            subTotal: subTotal,
                            discount: 0,
                            deliveryToHome: widget.deliveryToHome ? 1 : 0,
                            route: widget.route == 'Nội thành'
                                ? 1
                                : widget.route == 'liên tỉnh - 2 chiều'
                                    ? 2
                                    : 3,
                            pickup_latitude: widget.model.latitude.toString(),
                            pickup_longitude: widget.model.longitude.toString(),
                            dropoff_latitude:
                                widget.model.dropOffLatitude.toString(),
                            dropoff_longitude:
                                widget.model.dropOffLongitude.toString(),
                            typee: 0,
                            totalPrice: widget.totalPrice.toString(),
                            status: "pending",
                            totalDays:
                                '${widget.model.with_driver.total.hours}',
                            debutDate:
                                '${widget.model.with_driver.getStartDateTime().toString()}',
                            expireDate:
                                '${widget.model.with_driver.getEndDateTime().toString()}',
                            contactPhone: '${widget.data.owner!.phone}',
                            vehicleId: '${widget.data.id}',
                            driverID: widget.data.owner!.id);
                      }
                      Navigator.pop(context);
                      Navigator.pop(context);
                      print("Vehicle ID  ==> ${widget.data.id}");
                      print(
                          'DropOff: ${widget.model.dropOffLatitude.toString()},${widget.model.dropOffLongitude.toString()}');
                    })),
          );
        });
  }

  Container routeInformation() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey.shade200,
      ),
      margin: EdgeInsets.symmetric(horizontal: 10),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      width: double.infinity,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            'Thông tin lộ trình'.tr().text.lg.bold.make(),
            if (widget.route != 'Nội thành' && widget.model.type != 'xe tự lái')
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  'Tổng lộ trình:'.text.base.make(),
                  '${(distance! / 1000).toStringAsFixed(1)} km'
                      .text
                      .base
                      .make(),
                ],
              ).pOnly(top: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                'Số km tối đa đi được:'.text.base.make(),
                '${distance == null ? '50 km' : '${((distance! + (distance! * 11 / 100)) / 1000).toStringAsFixed(1)} km'}'
                    .text
                    .base
                    .make(),
              ],
            ).pOnly(top: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                'Phí phụ thu vượt ${distance == null ? '50 km' : '${((distance! + (distance! * 11 / 100)) / 1000).toStringAsFixed(1)} km'}:'
                    .text
                    .base
                    .make(),
                '8 k/km'.text.base.make(),
              ],
            ).pOnly(top: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                'Phí phụ thu vượt ${widget.model.with_driver.total.hours} giờ:'
                    .text
                    .base
                    .make(),
                '80 k/giờ'.text.base.make(),
              ],
            ).pOnly(top: 5),
          ]),
    );
  }

  Container collateral() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      width: double.infinity,
      height: 120,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          'Tài sản thế chấp'.tr().text.xl.bold.make(),
          !widget.data.mortgageExemption!
              ? 'Không yêu cầu khách thuê thế chấp Tiền mặt hoặc Xe máy'
                  .tr()
                  .text
                  .lg
                  .color(Colors.grey)
                  .make()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }

  Container carRentalDocuments() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          'Giấy tờ thuê xe'.tr().text.xl.bold.make().pOnly(top: 5),
          '${'Chọn 1 trong 2 hình thức'.tr()}:'.text.bold.base.make(),
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
    );
  }

  Container priceListWithDriver() {
    return Container(
        margin: EdgeInsets.only(top: 15),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        color: Colors.grey.shade200,
        width: double.infinity,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              'Bảng tính giá'.tr().text.xl.bold.make(),
              Container(
                margin: EdgeInsets.symmetric(vertical: 15),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white),
                alignment: Alignment.topCenter,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        'Giá thuê'.text.lg.color(Colors.grey.shade600).make(),
                        '${'${AppStrings.currencySymbol} ${widget.priceWithDriver.toDouble()}'.currencyFormat()}'
                            .text
                            .xl
                            .color(Colors.grey.shade700)
                            .semiBold
                            .make(),
                      ],
                    ),
                    Divider(color: Colors.grey),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     'Giảm giá'.text.lg.color(Colors.grey.shade600).make(),
                    //     '${'${AppStrings.currencySymbol} ${discountPrice.toDouble()}'.currencyFormat()}'
                    //         .text
                    //         .xl
                    //         .color(Colors.grey.shade700)
                    //         .semiBold
                    //         .make(),
                    //   ],
                    // ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        'Phí đưa đón'
                            .text
                            .lg
                            .color(Colors.grey.shade600)
                            .make(),
                        widget.delivery_fee != '0'
                            ? '${'${'${AppStrings.currencySymbol} ${widget.delivery_fee}'.currencyFormat()}'} (${(widget.distance).toStringAsFixed(1)}km)'
                                .text
                                .xl
                                .color(Colors.grey.shade700)
                                .semiBold
                                .make()
                            : '${'Free'.tr()} (${widget.distance.toStringAsFixed(1)}km)'
                                .text
                                .xl
                                .color(Colors.grey.shade700)
                                .semiBold
                                .make(),
                      ],
                    ),
                    Divider(color: Colors.grey),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        'Thành tiền'.text.lg.color(Colors.black).make(),
                        '${'${AppStrings.currencySymbol} ${widget.totalPrice.toDouble()}'.currencyFormat()}'
                            .text
                            .xl
                            .color(Colors.black)
                            .semiBold
                            .make(),
                      ],
                    ),
                  ],
                ),
              ),
            ]));
  }

  Container priceList() {
    return Container(
        margin: EdgeInsets.only(top: 15),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        color: Colors.grey.shade200,
        width: double.infinity,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              'Bảng tính giá'.tr().text.xl.bold.make(),
              Container(
                margin: EdgeInsets.symmetric(vertical: 15),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white),
                alignment: Alignment.topCenter,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        'Đơn giá thuê'
                            .text
                            .lg
                            .color(Colors.grey.shade600)
                            .make(),
                        '${'${AppStrings.currencySymbol} ${widget.rentalPriceFor1DayNotDiscount.toDouble()}'.currencyFormat()}/ngày'
                            .text
                            .xl
                            .color(Colors.grey.shade700)
                            .semiBold
                            .make(),
                      ],
                    ),
                    Divider(color: Colors.grey),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        'Tổng cộng'.text.lg.color(Colors.grey.shade600).make(),
                        '${'${AppStrings.currencySymbol} ${widget.rentalPriceFor1DayNotDiscount.toDouble()}'.currencyFormat()} x ${(widget.model.totalTimeRent! / 24).ceil()} ngày'
                            .text
                            .xl
                            .color(Colors.grey.shade700)
                            .semiBold
                            .make(),
                      ],
                    ),
                    if (widget.deliveryToHome) Divider(color: Colors.grey),
                    if (widget.deliveryToHome)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          'Phí giao nhận xe'
                              .text
                              .lg
                              .color(Colors.grey.shade600)
                              .make(),
                          widget.delivery_fee != '0'
                              ? '${'${'${AppStrings.currencySymbol} ${widget.delivery_fee}'.currencyFormat()}'} (${widget.distance.toStringAsFixed(1)}km)'
                                  .text
                                  .xl
                                  .color(Colors.grey.shade700)
                                  .semiBold
                                  .make()
                              : '${'Free'.tr()} (${widget.distance.toStringAsFixed(1)}km)'
                                  .text
                                  .xl
                                  .color(Colors.grey.shade700)
                                  .semiBold
                                  .make(),
                        ],
                      ),
                    Divider(color: Colors.grey),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        'Giảm giá'.text.lg.color(Colors.grey.shade600).make(),
                        '${'${AppStrings.currencySymbol} ${discountPrice.toDouble()}'.currencyFormat()}'
                            .text
                            .xl
                            .color(Colors.grey.shade700)
                            .semiBold
                            .make(),
                      ],
                    ),
                    Divider(color: Colors.grey),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        'Thành tiền'.text.lg.color(Colors.black).make(),
                        '${'${AppStrings.currencySymbol} ${widget.totalPrice.toDouble()}'.currencyFormat()}'
                            .text
                            .xl
                            .color(Colors.black)
                            .semiBold
                            .make(),
                      ],
                    ),
                  ],
                ),
              ),
            ]));
  }

  Container message() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        width: double.infinity,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                'Lời nhắn cho chủ xe'.text.color(Colors.grey.shade600).make(),
                RichText(
                  text: TextSpan(
                    text: 'Gợi ý lời nhắn',
                    style: TextStyle(
                      color: Colors.black,
                      decoration: TextDecoration.underline,
                      decorationThickness: 2.0,
                      decorationColor: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            TextField(
              controller: messageController,
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10)),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10))),
              onChanged: (value) {
                print(value);
              },
              maxLines: 4,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
            ).pOnly(top: 10),
          ],
        ));
  }

  Container carOwnerCard() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      height: 220,
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
            height: 150,
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
              'Nhằm bảo mật thông tin cá nhân, SOD sẽ gửi chi tiết liên hệ của chủ xe sau khi khách hàng hoàn tất bước thanh toán trên ứng dụng.'
                  .text
                  .color(Colors.grey.shade600)
                  .make(),
            ]),
          ),
        ],
      ),
    );
  }

  Container vehiclePickUpLocation(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.location_on_outlined),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  '${widget.deliveryToHome ? 'Địa điểm giao nhận xe' : 'Nhận xe tại địa chỉ của xe'}'
                      .text
                      .color(Colors.grey)
                      .make(),
                  '${widget.deliveryToHome ? widget.model.pickUpLocation : widget.data.location}'
                      .text
                      .overflow(TextOverflow.ellipsis)
                      .bold
                      .make()
                      .pOnly(top: 5),
                  Row(
                    children: [
                      RichText(
                        text: TextSpan(
                          text: 'Xem trên bản đồ',
                          style: TextStyle(
                            color: Colors.black,
                            decoration: TextDecoration.underline,
                            decorationThickness:
                                2.0, // Điều chỉnh độ đậm của underline
                            decorationColor:
                                Colors.black, // Màu sắc của underline
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ).pOnly(top: 5),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 15,
                      ).pOnly(top: 5),
                    ],
                  ).onInkTap(() {
                    showModalBottomSheet(
                        barrierColor: Colors.transparent,
                        enableDrag: false,
                        isScrollControlled: true,
                        useRootNavigator: true,
                        context: context,
                        useSafeArea: true,
                        builder: (context) => GoogleMapPage(
                              data: widget.data,
                              model: widget.model,
                              deliveryToHome: widget.deliveryToHome,
                            ));
                  }),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Container rentalPeriodCard() {
    return Container(
        margin: EdgeInsets.only(top: 10),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.calendar_month_outlined).pOnly(right: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    '${widget.model.type == 'xe tự lái' ? 'Receive the car'.tr() : 'Pick up client'.tr()}'
                        .text
                        .color(Colors.grey)
                        .make(),
                    '${widget.model.type == 'xe tự lái' ? formatTime(widget.model.self_driving.start_time) : formatTime(widget.model.with_driver.start_time)} ${DateFormat('dd/MM/yyyy').format(widget.model.type == 'xe tự lái' ? widget.model.self_driving.start_day : widget.model.with_driver.start_day).toString()}'
                        .text
                        .bold
                        .make()
                        .pOnly(top: 5),
                  ],
                ),
              ],
            ).pOnly(right: 15),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.calendar_month_outlined).pOnly(right: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    '${widget.model.type == 'xe tự lái' ? 'Give car back'.tr() : 'Drop off'.tr()}'
                        .text
                        .color(Colors.grey)
                        .make(),
                    '${widget.model.type == 'xe tự lái' ? formatTime(widget.model.self_driving.end_time) : formatTime(widget.model.with_driver.end_time)} ${DateFormat('dd/MM/yyyy').format(widget.model.type == 'xe tự lái' ? widget.model.self_driving.end_day : widget.model.with_driver.end_day).toString()}'
                        .text
                        .bold
                        .make()
                        .pOnly(top: 5),
                  ],
                ),
              ],
            ),
          ],
        ));
  }

  Container carCardMethod(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              width: MediaQuery.of(context).size.width / 3,
              height: MediaQuery.of(context).size.height / 10,
              imageUrl: widget.data.photo!.isNotEmpty
                  ? "https://nld.mediacdn.vn/291774122806476800/2021/9/25/24226875648526647114344167202327751795544483n-16325671978991579408720.jpg" //widget.data.photo!.first
                  : "https://nld.mediacdn.vn/291774122806476800/2021/9/25/24226875648526647114344167202327751795544483n-16325671978991579408720.jpg",
              fit: BoxFit.fill,
              placeholder: (context, url) =>
                  CircularProgressIndicator(color: AppColor.cancelledColor),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              '${widget.data.carModel!.carMake!.name} ${widget.data.carModel!.name} ${widget.data.yearMade ?? ''}'
                  .text
                  .xl
                  .maxLines(1)
                  .bold
                  .make(),
              Row(
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.yellow),
                      '${widget.data.rating}'.text.color(Colors.grey).make(),
                    ],
                  ),
                  DotIndicator(size: 5, color: Colors.grey.shade600).px8(),
                  Row(
                    children: [
                      Icon(Icons.directions_car, color: Colors.green),
                      '${widget.data.totalTrip} ${'Ride'.tr().toLowerCase()}'
                          .text
                          .color(Colors.grey)
                          .make(),
                    ],
                  ),
                ],
              ),
            ]),
          )
        ],
      ),
    );
  }
}
