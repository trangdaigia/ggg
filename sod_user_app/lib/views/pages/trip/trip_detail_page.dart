import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firestore_chat/models/chat_entity.dart';
import 'package:firestore_chat/models/peer_user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_routes.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/constants/app_ui_settings.dart';
import 'package:sod_user/extensions/string.dart';
import 'package:sod_user/models/order.dart';
import 'package:sod_user/models/trip.dart';
import 'package:sod_user/models/user.dart';
import 'package:sod_user/services/auth.service.dart';
import 'package:sod_user/services/chat.service.dart';
import 'package:sod_user/services/firebase.service.dart';
import 'package:sod_user/services/order.service.dart';
import 'package:sod_user/view_models/car_management.view_model.dart';
import 'package:sod_user/view_models/car_rental.view_model.dart';
import 'package:sod_user/view_models/orders.vm.dart';
import 'package:sod_user/view_models/trip.view_model.dart';
import 'package:sod_user/view_models/wallet.vm.dart';
import 'package:sod_user/views/pages/car_rental/car_manage.dart/car_management_request.dart';
import 'package:sod_user/views/pages/car_rental/widgets/selection_day.dart';
import 'package:sod_user/views/pages/car_search/google_map.page.dart';
import 'package:sod_user/views/pages/chat/chat_detail.page.dart';
import 'package:sod_user/views/pages/home.page.dart';
import 'package:sod_user/views/pages/order/orders.page.dart';
import 'package:sod_user/views/pages/trip/trip_history_page.dart';
import 'package:sod_user/views/pages/trip/trip_page.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/widgets/busy_indicator.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:sod_user/widgets/states/loading.shimmer.dart';
import 'package:stacked/stacked.dart';
import 'package:supercharged/supercharged.dart';
import 'package:timelines/timelines.dart';
import 'package:sod_user/constants/app_map_settings.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart' as vietMapGl;
import 'package:velocity_x/velocity_x.dart';

class TripDetailPage extends StatefulWidget {
  TripDetailPage({
    super.key,
    required this.trip,
    this.viewModel,
    this.order,
  });
  final Trip trip;
  final CarManagementViewModel? viewModel;
  final Order? order;
  @override
  State<TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends State<TripDetailPage> {
  late CarRentalViewModel carRentalModel;
  double discountPrice = 0;
  CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(10.823099, 106.681937),
  );
  Set<Marker> markers = {};
  List<LatLng> polylineCoordinates = [];
  Completer<GoogleMapController> _controller = Completer();
  late LatLng origin;
  late LatLng destination;
  int rentalPriceFor1DayNotDiscount = 0;
  int rentalPriceFor1Day = 0;
  String pickUpLocation = '...';
  String dropOffLocation = '...';
  TextEditingController messageController = TextEditingController();
  TripViewModel tripModel = TripViewModel();
  late OrdersViewModel ordervm;
  var result;
  String status = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    status = widget.trip.status!;
    carRentalModel = CarRentalViewModel();
    rentalPriceFor1DayNotDiscount = (calculateRentalCost(
              DateTime.parse(widget.trip.debutDate!),
              DateTime.parse(widget.trip.expireDate!),
              DateTime.parse(widget.trip.debutDate!).hour,
              DateTime.parse(widget.trip.expireDate!).hour,
            ) /
            (widget.trip.totalDays!.toInt()! / 24).ceil())
        .ceil();
    if (widget.trip.vehicle!.vehicleRentPrice!.discountSevenDays != null &&
        widget.trip.vehicle!.vehicleRentPrice!.discountSevenDays != 0 &&
        (widget.trip.totalDays!.toInt()! / 24).ceil() > 6) {
      rentalPriceFor1Day = (((calculateRentalCost(
                        DateTime.parse(widget.trip.debutDate!),
                        DateTime.parse(widget.trip.expireDate!),
                        DateTime.parse(widget.trip.debutDate!).hour,
                        DateTime.parse(widget.trip.expireDate!).hour,
                      ) /
                      (widget.trip.totalDays!.toInt()! / 24).ceil()) *
                  (100 -
                      widget
                          .trip.vehicle!.vehicleRentPrice!.discountSevenDays!) /
                  100)
              .ceil())
          .ceil();
    } else if (widget.trip.vehicle!.vehicleRentPrice!.discountThreeDays !=
            null &&
        widget.trip.vehicle!.vehicleRentPrice!.discountThreeDays != 0 &&
        (widget.trip.totalDays!.toInt()! / 24).ceil() > 2) {
      rentalPriceFor1Day = (((calculateRentalCost(
                        DateTime.parse(widget.trip.debutDate!),
                        DateTime.parse(widget.trip.expireDate!),
                        DateTime.parse(widget.trip.debutDate!).hour,
                        DateTime.parse(widget.trip.expireDate!).hour,
                      ) /
                      (widget.trip.totalDays!.toInt()! / 24).ceil()) *
                  (100 -
                      widget
                          .trip.vehicle!.vehicleRentPrice!.discountThreeDays!) /
                  100)
              .ceil())
          .ceil();
    } else {
      rentalPriceFor1Day = (calculateRentalCost(
                DateTime.parse(widget.trip.debutDate!),
                DateTime.parse(widget.trip.expireDate!),
                DateTime.parse(widget.trip.debutDate!).hour,
                DateTime.parse(widget.trip.expireDate!).hour,
              ) /
              (widget.trip.totalDays!.toInt()! / 24).ceil())
          .ceil();
    }
    discountPrice = double.parse(((rentalPriceFor1DayNotDiscount *
                ((widget.trip.totalDays!.toInt()! / 24).ceil())) -
            (rentalPriceFor1Day *
                (widget.trip.totalDays!.toInt()! / 24).ceil()))
        .toString());
    print('Giảm giá: ${rentalPriceFor1Day}');
    _kInitialPosition = CameraPosition(
        target: LatLng(widget.trip.pickup_latitude!.toDouble()!,
            widget.trip.pickup_longitude!.toDouble()!),
        zoom: 13.0);
    origin = LatLng(widget.trip.pickup_latitude!.toDouble()!,
        widget.trip.pickup_longitude!.toDouble()!);
    if (widget.trip.route != 1 && !widget.trip.isSelfDriving!) {
      destination = LatLng(widget.trip.dropoff_latitude!.toDouble()!,
          widget.trip.dropoff_longitude!.toDouble()!);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      carRentalModel
          .getAddressFromCoordinates(
        double.parse(widget.trip.pickup_latitude!),
        double.parse(widget.trip.pickup_longitude!),
      )
          .then((value) {
        setState(() {
          pickUpLocation = value!.addressLine!;
        });
      });
      if (!widget.trip.isSelfDriving! && widget.trip.route! != 1) {
        carRentalModel
            .getAddressFromCoordinates(
          double.parse(widget.trip.dropoff_latitude!),
          double.parse(widget.trip.dropoff_longitude!),
        )
            .then((value) {
          setState(() {
            dropOffLocation = value!.addressLine!;
          });
        });
      }

      if (!widget.trip.delivery_to_home! && widget.trip.isSelfDriving!) {
        carRentalModel
            .getAddressFromCoordinates(
          double.parse(widget.trip.vehicle!.latitude!),
          double.parse(widget.trip.vehicle!.longitude!),
        )
            .then((value) {
          setState(() {
            widget.trip.vehicle!.location = value!.addressLine!;
          });
        });
      }
    });
  }

  bool checkGetCurrentUser = false;
  String delivery_fee = '';
  double? distance;
  double? distanceDelivery = 0;
  int totalFee = 0;
  bool completedBusy = false;
  bool canceledBusy = false;
  bool depositBusy = false;
  bool acceptBusy = false;
  User? currentUser;

  @override
  Widget build(BuildContext context) {
    ordervm = OrdersViewModel(context);
    return ViewModelBuilder<TripViewModel>.reactive(
        disposeViewModel: false,
        viewModelBuilder: () => tripModel,
        builder: (context, tripVM, child) {
          return ViewModelBuilder<CarRentalViewModel>.reactive(
              disposeViewModel: false,
              viewModelBuilder: () => carRentalModel,
              onViewModelReady: (viewModel) async {
                checkGetCurrentUser = false;
                currentUser = await AuthServices.getCurrentUser(force: true);
                checkGetCurrentUser = true;
                if (widget.trip.route != 1 && !widget.trip.isSelfDriving!) {
                  await viewModel.getPolylines(origin, destination);
                  distance = await viewModel.calculateDistance(
                    double.parse(widget.trip.pickup_latitude!),
                    double.parse(widget.trip.pickup_longitude!),
                    double.parse(widget.trip.dropoff_latitude!),
                    double.parse(widget.trip.dropoff_longitude!),
                    true,
                  );
                }
              },
              builder: (context, viewModel, child) {
                markers = {
                  Marker(
                    markerId: MarkerId('point1'),
                    position: origin,
                    infoWindow: InfoWindow(
                      title: 'Vị trí đón khách',
                      snippet: 'Điểm bắt đầu',
                    ),
                  ),
                  if (widget.trip.route != 1 && !widget.trip.isSelfDriving!)
                    Marker(
                      markerId: MarkerId('point2'),
                      position: destination,
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
                    if (widget.viewModel != null) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: ((context) => CarManagementRequestPage(
                                    viewModel: widget.viewModel!,
                                  ))));
                    } else if (widget.order != null) {
                      // Navigator.pushReplacement(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: ((context) => HomePage(index: 2,))));
                      Navigator.pop(context);
                    } else {
                      if (status == "canceled" || status == "completed")
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: ((context) => TripHistoryPage())));
                      else
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: ((context) => TripPage())));
                    }
                  }),
                  title: 'Chi tiết chuyến đi'.tr(),
                  body: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        carCardMethod(context).pSymmetric(h: 10).pOnly(top: 10),
                        Divider(color: Colors.grey).p(10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            'Thông tin thuê xe'
                                .text
                                .xl
                                .bold
                                .make()
                                .pSymmetric(h: 10),
                            rentalPeriodCard().pSymmetric(h: 10),
                            if (widget.trip.isSelfDriving!)
                              vehiclePickUpLocation(context).pSymmetric(h: 20),
                            //
                            if (!widget.trip.isSelfDriving!)
                              'Lộ trình ${widget.trip.route == 1 ? 'Nội thành' : widget.trip.route == 2 ? "liên tỉnh - 2 chiều" : 'liên tỉnh - 1 chiều'}'
                                  .text
                                  .xl
                                  .bold
                                  .make()
                                  .pSymmetric(h: 10),
                            if (!widget.trip.isSelfDriving!)
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 20),
                                width: double.infinity,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.location_on_outlined),
                                    Expanded(
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            'Điểm đón'
                                                .text
                                                .color(Colors.grey)
                                                .make(),
                                            '${pickUpLocation}'
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
                            if (widget.trip.route != 1 &&
                                !widget.trip.isSelfDriving!)
                              Divider(color: Colors.grey).pSymmetric(h: 20),
                            if (widget.trip.route != 1 &&
                                !widget.trip.isSelfDriving!)
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 20),
                                width: double.infinity,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.location_on_outlined),
                                    Expanded(
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            'Điểm đến'
                                                .text
                                                .color(Colors.grey)
                                                .make(),
                                            '${dropOffLocation}'
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
                            if (widget.trip.route == 1 &&
                                !widget.trip.isSelfDriving!)
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
                                            },
                                            trackCameraPosition: true,
                                          ),
                                        ])
                                      : GoogleMap(
                                          mapType: MapType.normal,
                                          initialCameraPosition:
                                              _kInitialPosition,
                                          onMapCreated:
                                              (GoogleMapController controller) {
                                            _controller.complete(controller);
                                          },
                                          markers: markers,
                                          gestureRecognizers: <Factory<
                                              OneSequenceGestureRecognizer>>[
                                            Factory<OneSequenceGestureRecognizer>(
                                                () => EagerGestureRecognizer()),
                                          ].toSet(),
                                        ),
                                ),
                              ),
                            if (widget.trip.route != 1 &&
                                !widget.trip.isSelfDriving!)
                              !viewModel.isBusy
                                  ? Container(
                                      margin: EdgeInsets.symmetric(
                                          vertical: 15, horizontal: 10),
                                      height: 250,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20)),
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
                                                        _kInitialPosition
                                                            .target.latitude,
                                                        _kInitialPosition
                                                            .target.longitude),
                                                    zoom: 13,
                                                  ),
                                                  onMapCreated: (vietMapGl
                                                      .VietmapController
                                                      controller) {
                                                    viewModel
                                                            .vietMapController =
                                                        controller;

                                                    List<LatLng>
                                                        polylinePoints =
                                                        viewModel.gMapPolylines
                                                            .expand(
                                                                (polyline) =>
                                                                    polyline
                                                                        .points)
                                                            .toList();
                                                    vietMapGl.LatLngBounds
                                                        bounds =
                                                        vietMapGl.LatLngBounds(
                                                      southwest:
                                                          vietMapGl.LatLng(
                                                        polylinePoints
                                                            .map((point) =>
                                                                point.latitude)
                                                            .reduce((min,
                                                                    value) =>
                                                                min < value
                                                                    ? min
                                                                    : value),
                                                        polylinePoints
                                                            .map((point) =>
                                                                point.longitude)
                                                            .reduce((min,
                                                                    value) =>
                                                                min < value
                                                                    ? min
                                                                    : value),
                                                      ),
                                                      northeast:
                                                          vietMapGl.LatLng(
                                                        polylinePoints
                                                            .map((point) =>
                                                                point.latitude)
                                                            .reduce((max,
                                                                    value) =>
                                                                max > value
                                                                    ? max
                                                                    : value),
                                                        polylinePoints
                                                            .map((point) =>
                                                                point.longitude)
                                                            .reduce((max,
                                                                    value) =>
                                                                max > value
                                                                    ? max
                                                                    : value),
                                                      ),
                                                    );

                                                    viewModel.vietMapController!
                                                        .animateCamera(vietMapGl
                                                                .CameraUpdate
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
                                                onMapCreated:
                                                    (GoogleMapController
                                                        controller) {
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
                                                    northeast: LatLng(
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
                                                  // Điều chỉnh phạm vi hiển thị của bản đồ để hiển thị đường đi
                                                  controller.animateCamera(
                                                      CameraUpdate
                                                          .newLatLngBounds(
                                                              bounds, 50));
                                                  _controller
                                                      .complete(controller);
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
                                    )
                                  : LoadingShimmer(),
                            //
                            (!widget.trip.isSelfDriving!)
                                ? widget.trip.route == 1
                                    ? routeInformation()
                                    : widget.trip.route != 1
                                        ? distance != null
                                            ? routeInformation()
                                            : LoadingShimmer()
                                        : SizedBox()
                                : SizedBox(),
                            if (!checkGetCurrentUser) LoadingShimmer(),
                            if (checkGetCurrentUser &&
                                currentUser!.id !=
                                    widget.trip.vehicle!.owner!.id)
                              carOwnerCard(),
                            if (checkGetCurrentUser &&
                                currentUser!.id ==
                                    widget.trip.vehicle!.owner!.id)
                              renterCard(),
                            message(),
                            if (widget.trip.isSelfDriving!) priceList(),
                            if (!widget.trip.isSelfDriving!)
                              priceListWithDriver(),
                            if (widget.trip.isSelfDriving!)
                              carRentalDocuments(),
                            if (widget.trip.isSelfDriving!) collateral(),
                          ],
                        )
                      ],
                    ),
                  ),
                  bottomNavigationBar: widget.trip.status == "canceled" ||
                          widget.trip.status == "completed" ||
                          !checkGetCurrentUser
                      ? null
                      : Padding(
                          padding: const EdgeInsets.all(10),
                          child: Container(
                              height: 64,
                              width: MediaQuery.of(context).size.width,
                              child: (widget.trip.status == "in progress" &&
                                          widget.trip.deposit == false &&
                                          currentUser!.id ==
                                              widget.trip.vehicle!.owner!.id) ||
                                      (widget.trip.status == "pending" &&
                                          currentUser!.id !=
                                              widget.trip.vehicle!.owner!.id)
                                  ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SizedBox(
                                        width: 200,
                                        height: 48,
                                        child: CustomButton(
                                          loading: canceledBusy,
                                          title: 'Cancel trip'.tr(),
                                          onPressed: () async {
                                            setState(() {
                                              canceledBusy = !canceledBusy;
                                            });
                                            bool check;
                                            check = await tripVM
                                                .cancelTrip(widget.trip.id!);
                                            if (check) {
                                              widget.trip.status = "canceled";
                                              if (widget.viewModel != null) {
                                                await widget.viewModel!
                                                    .getMyCar(showBusy: false);
                                              }
                                            }
                                            setState(() {
                                              canceledBusy = !canceledBusy;
                                            });
                                          },
                                        ),
                                      ),
                                    )
                                  : widget.trip.status == "pending" &&
                                          currentUser!.id ==
                                              widget.trip.vehicle!.owner!.id
                                      ? Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              SizedBox(
                                                width: 150,
                                                height: 48,
                                                child: CustomButton(
                                                  loading: canceledBusy,
                                                  title: 'Cancel trip'.tr(),
                                                  onPressed: () async {
                                                    setState(() {
                                                      canceledBusy =
                                                          !canceledBusy;
                                                    });
                                                    bool check;
                                                    check =
                                                        await tripVM.cancelTrip(
                                                            widget.trip.id!);
                                                    if (check) {
                                                      widget.trip.status =
                                                          "canceled";
                                                      if (widget.viewModel !=
                                                          null) {
                                                        await widget.viewModel!
                                                            .getMyCar(
                                                                showBusy:
                                                                    false);
                                                      }
                                                    }
                                                    setState(() {
                                                      canceledBusy =
                                                          !canceledBusy;
                                                    });
                                                  },
                                                ),
                                              ),
                                              SizedBox(
                                                width: 150,
                                                height: 48,
                                                child: CustomButton(
                                                  loading: acceptBusy,
                                                  color:
                                                      AppColor.deliveredColor,
                                                  title: 'Xác nhận'.tr(),
                                                  onPressed: () async {
                                                    setState(() {
                                                      acceptBusy = !acceptBusy;
                                                    });
                                                    bool check;
                                                    check =
                                                        await tripVM.acceptTrip(
                                                            widget.trip.id!);
                                                    if (check) {
                                                      widget.trip.status =
                                                          "in progress";
                                                      if (widget.viewModel !=
                                                          null) {
                                                        await widget.viewModel!
                                                            .getMyCar(
                                                                showBusy:
                                                                    false);
                                                      }
                                                    }
                                                    setState(() {
                                                      acceptBusy = !acceptBusy;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : widget.trip.status == "in progress" &&
                                              widget.trip.deposit == false
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  SizedBox(
                                                    width: 150,
                                                    height: 48,
                                                    child: CustomButton(
                                                      loading: canceledBusy,
                                                      title: 'Cancel trip'.tr(),
                                                      onPressed: () async {
                                                        setState(() {
                                                          canceledBusy =
                                                              !canceledBusy;
                                                        });
                                                        bool check;
                                                        check = await tripVM
                                                            .cancelTrip(widget
                                                                .trip.id!);
                                                        if (check) {
                                                          widget.trip.status =
                                                              "canceled";
                                                          if (widget
                                                                  .viewModel !=
                                                              null) {
                                                            await widget
                                                                .viewModel!
                                                                .getMyCar(
                                                                    showBusy:
                                                                        false);
                                                          }
                                                        }
                                                        setState(() {
                                                          canceledBusy =
                                                              !canceledBusy;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 150,
                                                    height: 30,
                                                    child: CustomButton(
                                                      color: AppColor
                                                          .deliveredColor,
                                                      title: 'Deposit'.tr(),
                                                      loading: depositBusy,
                                                      onPressed: () async {
                                                        WalletViewModel vm =
                                                            WalletViewModel(
                                                                context);
                                                        setState(() {
                                                          depositBusy = true;
                                                        });

                                                        // result = await vm
                                                        //     .showWalletTransferEntry(
                                                        //   widget.trip.vehicle!
                                                        //       .owner!.email,
                                                        //   (widget.trip.totalPrice! *
                                                        //           30 /
                                                        //           100)
                                                        //       .toString()
                                                        //       .substring(
                                                        //           0,
                                                        //           (widget.trip.totalPrice! *
                                                        //                   30 /
                                                        //                   100)
                                                        //               .toString()
                                                        //               .lastIndexOf(
                                                        //                   '.')),
                                                        //   widget.trip,
                                                        // );
                                                        // // print('result bên tripcard: $result');
                                                        // if (result is bool) {
                                                        //   await tripVM
                                                        //       .depositedTrip(
                                                        //           widget.trip
                                                        //               .id!);
                                                        //   await tripVM
                                                        //       .getTripPendingAndInProgress(
                                                        //           getTrip:
                                                        //               true);
                                                        //   widget.trip.deposit =
                                                        //       true;
                                                        //   if (widget
                                                        //           .viewModel !=
                                                        //       null) {
                                                        //     await widget
                                                        //         .viewModel!
                                                        //         .getMyCar(
                                                        //             showBusy:
                                                        //                 false);
                                                        //   }
                                                        // }
                                                        tripVM.viewContext =
                                                            context;
                                                        OrderService
                                                            .openOrderPayment(
                                                                widget.order!,
                                                                tripVM);
                                                        widget.trip.deposit =
                                                            true;
                                                        setState(() {
                                                          depositBusy = false;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : widget.trip.status ==
                                                      "in progress" &&
                                                  widget.trip.deposit == true
                                              ? Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      SizedBox(
                                                        width: 150,
                                                        height: 48,
                                                        child: CustomButton(
                                                          loading: canceledBusy,
                                                          title: 'Cancel trip'
                                                              .tr(),
                                                          onPressed: () async {
                                                            setState(() {
                                                              canceledBusy =
                                                                  !canceledBusy;
                                                            });
                                                            bool check;
                                                            check = await tripVM
                                                                .cancelTrip(
                                                                    widget.trip
                                                                        .id!);
                                                            if (check) {
                                                              widget.trip
                                                                      .status =
                                                                  "canceled";
                                                              if (widget
                                                                      .viewModel !=
                                                                  null) {
                                                                await widget
                                                                    .viewModel!
                                                                    .getMyCar(
                                                                        showBusy:
                                                                            false);
                                                              }
                                                            }

                                                            setState(() {
                                                              canceledBusy =
                                                                  !canceledBusy;
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 150,
                                                        height: 30,
                                                        child: CustomButton(
                                                          loading:
                                                              completedBusy,
                                                          color: AppColor
                                                              .deliveredColor,
                                                          title:
                                                              'Hoàn thành'.tr(),
                                                          onPressed: () async {
                                                            WalletViewModel vm =
                                                                WalletViewModel(
                                                                    context);
                                                            setState(() {
                                                              completedBusy =
                                                                  !completedBusy;
                                                            });
                                                            // result = await vm
                                                            //     .showWalletTransferEntry(
                                                            //   widget
                                                            //       .trip
                                                            //       .vehicle!
                                                            //       .owner!
                                                            //       .email,
                                                            //   (widget.trip.totalPrice! *
                                                            //           70 /
                                                            //           100)
                                                            //       .toString()
                                                            //       .substring(
                                                            //           0,
                                                            //           (widget.trip.totalPrice! *
                                                            //                   70 /
                                                            //                   100)
                                                            //               .toString()
                                                            //               .lastIndexOf(
                                                            //                   '.')),
                                                            //   widget.trip,
                                                            // );
                                                            // // print('result bên tripcard: $result');
                                                            // if (result
                                                            //     is bool) {
                                                            //   await tripVM
                                                            //       .completedTrip(
                                                            //           widget
                                                            //               .trip
                                                            //               .id!);
                                                            //   await tripVM
                                                            //       .getTripPendingAndInProgress(
                                                            //           getTrip:
                                                            //               true);
                                                            //   widget.trip
                                                            //           .status =
                                                            //       'completed';
                                                            //   if (widget
                                                            //           .viewModel !=
                                                            //       null) {
                                                            //     await widget
                                                            //         .viewModel!
                                                            //         .getMyCar(
                                                            //             showBusy:
                                                            //                 false);
                                                            //   }
                                                            // }
                                                            tripVM.viewContext =
                                                                context;
                                                            OrderService
                                                                .openOrderPayment(
                                                                    widget
                                                                        .order!,
                                                                    tripVM);
                                                            setState(() {
                                                              completedBusy =
                                                                  !completedBusy;
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : null),
                        ),
                );
              });
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
            if (widget.trip.route != 1 && !widget.trip.isSelfDriving!)
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
                'Phí phụ thu vượt ${distance == null ? '2' : '4'} giờ:'
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
          !widget.trip.vehicle!.mortgageExemption!
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
                        '${'${AppStrings.currencySymbol} ${widget.trip.subTotal!.toDouble()}'.currencyFormat()}'
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
                        'Phí đưa đón'
                            .tr()
                            .text
                            .lg
                            .color(Colors.grey.shade600)
                            .make(),
                        '${'${AppStrings.currencySymbol} ${widget.trip.deliveryFee!.toDouble()}'.currencyFormat()} (${(widget.trip.vehicle!.distance! / 1000).toStringAsFixed(1)}km)'
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
                    // Divider(color: Colors.grey),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        'Thành tiền'.text.lg.color(Colors.black).make(),
                        '${'${AppStrings.currencySymbol} ${widget.trip.totalPrice!.toDouble()}'.currencyFormat()}'
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
                        '${'${AppStrings.currencySymbol} ${rentalPriceFor1DayNotDiscount.toDouble()}'.currencyFormat()}/ngày'
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
                        '${'${AppStrings.currencySymbol} ${rentalPriceFor1DayNotDiscount.toDouble()}'.currencyFormat()} x ${(widget.trip.totalDays!.toDouble()! / 24).ceil()} ngày'
                            .text
                            .xl
                            .color(Colors.grey.shade700)
                            .semiBold
                            .make(),
                      ],
                    ),
                    if (widget.trip.delivery_to_home! &&
                        widget.trip.deliveryFee! > 0)
                      Divider(color: Colors.grey),
                    if (widget.trip.delivery_to_home! &&
                        widget.trip.deliveryFee! > 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          'Phí giao nhận xe'
                              .text
                              .lg
                              .color(Colors.grey.shade600)
                              .make(),
                          '${'${AppStrings.currencySymbol} ${widget.trip.deliveryFee}'.currencyFormat()} (${(widget.trip.vehicle!.distance! / 1000).toStringAsFixed(1)}km)'
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
                        '${'${AppStrings.currencySymbol} ${widget.trip.totalPrice!.toDouble()}'.currencyFormat()}'
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
                      imageUrl: widget.trip.vehicle!.owner?.photo != null
                          ? widget.trip.vehicle!.owner!.photo
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
                      '${widget.trip.vehicle!.owner!.name}'.text.xl.bold.make(),
                      Row(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.yellow),
                              '${widget.trip.vehicle!.owner!.rating!}'
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
                              '${widget.trip.vehicle!.owner!.trip} ${'Ride'.tr().toLowerCase()}'
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
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      'Số điện thoại: '
                          .text
                          .semiBold
                          .color(Colors.black)
                          .make(),
                      '${widget.trip.vehicle!.owner!.phone}'
                          .text
                          .color(Colors.grey.shade600)
                          .make(),
                    ],
                  ).expand(),
                  Container(
                    margin: EdgeInsets.only(right: 10, left: 5),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Colors.black)),
                    child: Icon(
                      Icons.phone,
                      color: Colors.black,
                    ).onTap(() => callOwner()),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 10, left: 5),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Colors.black)),
                    child: Icon(
                      Icons.message_outlined,
                      color: Colors.black,
                    ).onTap(() => chatOwner()),
                  ),
                ],
              ),
            ]),
          ),
        ],
      ),
    );
  }

  void callOwner() {
    launchUrlString("tel:${widget.trip.vehicle!.owner!.phone}");
  }

  void callRenter() {
    launchUrlString("tel:${widget.trip.user!.phone}");
  }

  chatOwner() {
    openChat(widget.trip.user!.id);
    return;

    // Old chat
    // Map<String, PeerUser> peers = {
    //   '${widget.trip.user!.id}': PeerUser(
    //     id: '${widget.trip.user!.id}',
    //     name: widget.trip.user!.name,
    //     image: widget.trip.user!.photo,
    //   ),
    //   '${widget.trip.vehicle!.owner!.id}': PeerUser(
    //       id: "${widget.trip.vehicle!.owner!.id}",
    //       name: widget.trip.vehicle!.owner!.name,
    //       image: widget.trip.vehicle!.owner!.photo),
    // };
    // //
    // final chatEntity = ChatEntity(
    //   onMessageSent: ChatService.sendChatMessage,
    //   mainUser: peers['${widget.trip.user!.id}']!,
    //   peers: peers,
    //   //don't translate this
    //   path: 'orders/' + widget.trip.orderCode! + "/customerDriver/chats",
    //   title: "Chat with owner".tr(),
    //   supportMedia: AppUISettings.canCustomerChatSupportMedia,
    // );
    // //
    // Navigator.of(context).pushNamed(
    //   AppRoutes.chatRoute,
    //   arguments: chatEntity,
    // );
  }

  chatRenter() {
    openChat(widget.trip.user!.id);
    return;

    // Old chat
    // Map<String, PeerUser> peers = {
    //   '${widget.trip.vehicle!.owner!.id}': PeerUser(
    //     id: '${widget.trip.vehicle!.owner!.id}',
    //     name: widget.trip.vehicle!.owner!.name,
    //     image: widget.trip.vehicle!.owner!.photo,
    //   ),
    //   '${widget.trip.user!.id}': PeerUser(
    //       id: "${widget.trip.user!.id}",
    //       name: widget.trip.user!.name,
    //       image: widget.trip.user!.photo),
    // };
    // //
    // final chatEntity = ChatEntity(
    //   onMessageSent: ChatService.sendChatMessage,
    //   mainUser: peers['${widget.trip.vehicle!.owner!.id}']!,
    //   peers: peers,
    //   //don't translate this
    //   path: 'orders/' + widget.trip.orderCode! + "/customerDriver/chats",
    //   title: "Chat with renter".tr(),
    //   supportMedia: AppUISettings.canCustomerChatSupportMedia,
    // );
    // //
    // Navigator.of(context).pushNamed(
    //   AppRoutes.chatRoute,
    //   arguments: chatEntity,
    // );
  }

  void openChat(int? otherUserId) async {
    if (otherUserId == null) return;

    final currentUser = await AuthServices.getCurrentUser();
    final currentUserId = currentUser.id;
    final otherUser = await FirebaseService().getUserById(otherUserId);
    final chatId =
        await FirebaseService().createChat(currentUserId, otherUserId);

    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return ChatDetailPage(
        chatId: chatId,
        currentUserId: currentUserId,
        otherUser: otherUser,
      );
    }));
  }

  Container renterCard() {
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
          'Renter'.tr().text.xl.bold.make(),
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
                      imageUrl: widget.trip.user?.photo != null
                          ? widget.trip.user!.photo
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
                      '${widget.trip.user!.name}'.text.xl.bold.make(),
                      Row(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.yellow),
                              '${widget.trip.user!.rating!}'
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
                              '${widget.trip.user!.trip} ${'Ride'.tr().toLowerCase()}'
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
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      'Số điện thoại: '
                          .text
                          .semiBold
                          .color(Colors.black)
                          .make(),
                      '${widget.trip.user!.phone}'
                          .text
                          .color(Colors.grey.shade600)
                          .make(),
                    ],
                  ).expand(),
                  Container(
                    margin: EdgeInsets.only(right: 0, left: 7),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Colors.black)),
                    child: Icon(
                      Icons.phone,
                      color: Colors.black,
                    ).onTap(() => callRenter()),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 0, left: 10),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Colors.black)),
                    child: Icon(
                      Icons.message_outlined,
                      color: Colors.black,
                    ).onTap(() => chatRenter()),
                  ),
                ],
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Container vehiclePickUpLocation(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 0),
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.location_on_outlined),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  '${widget.trip.delivery_to_home! ? 'Địa điểm giao nhận xe' : 'Nhận xe tại địa chỉ của xe'}'
                      .text
                      .color(Colors.grey)
                      .make(),
                  '${widget.trip.delivery_to_home! ? pickUpLocation : widget.trip.vehicle!.location}'
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
                    carRentalModel.latitude =
                        widget.trip.pickup_latitude!.toDouble();
                    carRentalModel.longitude =
                        widget.trip.pickup_longitude!.toDouble();
                    showModalBottomSheet(
                        barrierColor: Colors.transparent,
                        enableDrag: false,
                        isScrollControlled: true,
                        useRootNavigator: true,
                        context: context,
                        useSafeArea: true,
                        builder: (context) => GoogleMapPage(
                              data: widget.trip.vehicle!,
                              model: carRentalModel,
                              deliveryToHome: widget.trip.delivery_to_home!,
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
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.calendar_month_outlined).pOnly(right: 5),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    '${widget.trip.isSelfDriving! ? 'Receive the car'.tr() : 'Pick up client'.tr()}'
                        .text
                        .xl
                        .color(Colors.grey)
                        .make(),
                    '${DateTime.parse(widget.trip.debutDate!).hour.toString().padLeft(2, '0')}:${DateTime.parse(widget.trip.debutDate!).minute.toString().padLeft(2, '0')} ${DateFormat('dd/MM/yyyy').format(DateTime.parse(widget.trip.debutDate!)).toString()}'
                        .text
                        .xl
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
                Icon(Icons.calendar_month_outlined).pOnly(right: 5),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    '${widget.trip.isSelfDriving! ? 'Give car back'.tr() : 'Drop off'.tr()}'
                        .text
                        .xl
                        .color(Colors.grey)
                        .make(),
                    '${DateTime.parse(widget.trip.expireDate!).hour.toString().padLeft(2, '0')}:${DateTime.parse(widget.trip.expireDate!).minute.toString().padLeft(2, '0')} ${DateFormat('dd/MM/yyyy').format(DateTime.parse(widget.trip.expireDate!)).toString()}'
                        .text
                        .xl
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
              imageUrl: widget.trip.vehicle!.photo!.isNotEmpty
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
              '${widget.trip.vehicle!.carModel!.carMake!.name} ${widget.trip.vehicle!.carModel!.name} ${widget.trip.vehicle!.yearMade ?? ''}'
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
                      '${widget.trip.vehicle!.rating}'
                          .text
                          .color(Colors.grey)
                          .make(),
                    ],
                  ),
                  DotIndicator(size: 5, color: Colors.grey.shade600).px8(),
                  Row(
                    children: [
                      Icon(Icons.directions_car, color: Colors.green),
                      '${widget.trip.vehicle!.totalTrip} ${'Ride'.tr().toLowerCase()}'
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

  int calculateRentalCost(
      DateTime startDate, DateTime endDate, int startHour, int endHour) {
    DateTime currentDate = startDate.add(Duration(days: 1));
    int totalPrice = 0;
    endDate = startDate
        .add(Duration(days: (widget.trip.totalDays!.toInt()! / 24).ceil()));
    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      if (currentDate.weekday < 6) {
        totalPrice += widget.trip.vehicle!.vehicleRentPrice!.priceMondayFriday!;
      } else {
        totalPrice +=
            widget.trip.vehicle!.vehicleRentPrice!.priceSaturdaySunday!;
      }
      currentDate = currentDate.add(Duration(days: 1));
    }
    return totalPrice;
  }
}
