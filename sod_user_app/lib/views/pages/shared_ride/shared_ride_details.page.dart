// ignore_for_file: must_be_immutable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:location/location.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/extensions/dynamic.dart';
import 'package:sod_user/models/shared_ride.dart';
import 'package:sod_user/services/order.service.dart';
import 'package:sod_user/utils/translate_for_flavor.utils.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/utils/utils.dart';
import 'package:sod_user/view_models/shared_ride.vm.dart';
import 'package:sod_user/views/pages/shared_ride/edit_trip.page.dart';
import 'package:sod_user/views/pages/shared_ride/search_share_ride.page.dart';
import 'package:sod_user/views/pages/shared_ride/widgets/post_share_ride_text_field.view.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:sod_user/widgets/custom_image.view.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class SharedRideDetailsPage extends StatefulWidget {
  String? type;
  final SharedRide sharedRide;
  final SharedRideViewModel model;

  SharedRideDetailsPage({
    Key? key,
    this.type,
    required this.sharedRide,
    required this.model,
  }) : super(key: key);

  @override
  State<SharedRideDetailsPage> createState() => _SharedRideDetailsPageState();
}

class _SharedRideDetailsPageState extends State<SharedRideDetailsPage> {
  bool isBooked = false;
  final formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final Location currentLocation = Location();
  int numberOfPassengers = 0;
  bool checkOwner = false;

  @override
  void initState() {
    if (widget.sharedRide.userID == widget.model.currentUser!.id) {
      checkOwner = true;
    }
    widget.sharedRide.orders!.forEach((e) {
      if (e.user.id == widget.model.currentUser!.id) {
        isBooked = true;
        widget.model.myOrderedRide = e;
      }
      if (e.status != 'cancelled') {
        numberOfPassengers += e.sharedRideTickets!;
      }
    });
    if (widget.model.myOrderedRide != null) {
      if (widget.model.myOrderedRide!.status == 'cancelled') {
        isBooked = false;
      }
    }
    widget.sharedRide.orders = widget.sharedRide.orders!
        .where((order) => order.status != 'cancelled')
        .toList();
    widget.model.detailedRide = widget.sharedRide;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //vietmapcheck
    return ViewModelBuilder<SharedRideViewModel>.reactive(
        disposeViewModel: false,
        viewModelBuilder: () => widget.model,
        builder: (context, model, child) {
          widget.sharedRide.orders!.forEach((element) {
            print('order status: ${element.paymentStatus} | id: ${element.id}');
          });
          return Scaffold(
            backgroundColor: Colors.white,
            key: scaffoldKey,
            appBar: AppBar(
              title: Text("Trip details".tr()),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  context.nextAndRemoveUntilPage(SearchRidePage());
                },
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: Colors.blue[300],
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today),
                            const SizedBox(width: 10),
                            Text(widget.sharedRide.startDate!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18)),
                          ],
                        ),
                      ),
                      if (widget.model.myOrderedRide?.status != "pending") ...[
                        if (isBooked &&
                            widget.type == "history" &&
                            widget.model.myOrderedRide!.status !=
                                "cancelled") ...[
                          UiSpacer.vSpace(20),
                          HStack(
                            [
                              "Payment Status".tr().text.make().expand(),
                              widget.model.myOrderedRide!.paymentStatus
                                  .tr()
                                  .capitalized
                                  .text
                                  .make(),
                            ],
                          ).box.blue300.p8.make().cornerRadius(10),
                        ],
                      ],
                      if (widget.model.myOrderedRide?.status != "pending")
                        if (isBooked &&
                            widget.type == "history" &&
                            widget.model.myOrderedRide!.status != "cancelled" &&
                            widget.model.myOrderedRide!.paymentStatus ==
                                "pending" &&
                            widget.sharedRide.status != "canceled") ...[
                          UiSpacer.vSpace(20),
                          CustomButton(
                            title: "PAY FOR ORDER".tr(),
                            titleStyle: context.textTheme.bodyLarge!.copyWith(
                              color: Colors.white,
                            ),
                            icon: FlutterIcons.credit_card_fea,
                            iconSize: 18,
                            onPressed: () => OrderService.openOrderPayment(
                                widget.model.myOrderedRide!, widget.model),
                            shapeRadius: 0,
                          ),
                        ],
                      const SizedBox(height: 20),
                      Container(
                        decoration: const BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              blurRadius: 40,
                              spreadRadius: 1,
                              offset: Offset(0, 15),
                            ),
                          ],
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(13),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () async {
                                        GeoData data =
                                            await Geocoder2.getDataFromAddress(
                                          address:
                                              widget.sharedRide.departureName!,
                                          googleMapApiKey:
                                              AppStrings.googleMapApiKey,
                                        );
                                        await MapsLauncher.launchCoordinates(
                                            data.latitude, data.longitude);
                                      },
                                      child: widget
                                          .sharedRide.departureName!.text.black
                                          .make(),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[300],
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.access_time),
                                        const SizedBox(width: 5),
                                        Text(widget.sharedRide.startTime!),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 13),
                              child: Row(
                                children: [
                                  Expanded(child: Divider(color: Colors.grey)),
                                  Icon(Icons.keyboard_arrow_down),
                                  Expanded(child: Divider(color: Colors.grey)),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(13),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () async {
                                        GeoData data =
                                            await Geocoder2.getDataFromAddress(
                                          address: widget
                                              .sharedRide.destinationName!,
                                          googleMapApiKey:
                                              AppStrings.googleMapApiKey,
                                        );
                                        await MapsLauncher.launchCoordinates(
                                            data.latitude, data.longitude);
                                      },
                                      child: widget.sharedRide.destinationName!
                                          .text.black
                                          .make(),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[300],
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.access_time),
                                        const SizedBox(width: 5),
                                        Text(widget.sharedRide.endTime!),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
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
                                  if (widget.sharedRide.type == "package" &&
                                      widget.type != "history") ...[
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
                                        Utils.formatCurrencyVND(double.parse(
                                                widget.sharedRide.package!
                                                        .price ??
                                                    "0"))
                                            .text
                                            .bold
                                            .white
                                            .make(),
                                      ],
                                    ).py(3),
                                    UiSpacer.divider(color: Colors.white),
                                  ],
                                  if (widget.type != "history") ...[
                                    HStack(
                                      alignment: MainAxisAlignment.spaceAround,
                                      [
                                        Expanded(
                                            child: 'Trip price'
                                                .tr()
                                                .text
                                                .bold
                                                .white
                                                .make()),
                                        Utils.formatCurrencyVND(double.parse(
                                                widget.sharedRide.price
                                                    .toString()))
                                            .text
                                            .bold
                                            .white
                                            .make(),
                                      ],
                                    ).py(3),
                                  ],
                                  if (widget.type == "history") ...[
                                    HStack(
                                      alignment: MainAxisAlignment.spaceAround,
                                      [
                                        Expanded(
                                            child: 'Your booked price'
                                                .tr()
                                                .text
                                                .bold
                                                .white
                                                .make()),
                                        Utils.formatCurrencyVND(double.parse(
                                                widget
                                                    .model.myOrderedRide!.total
                                                    .toString()))
                                            .text
                                            .bold
                                            .white
                                            .make(),
                                      ],
                                    ).py(3),
                                  ]
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (widget.type == "my_ride") ...[
                        Row(
                          children: [
                            Expanded(child: "Passenger".tr().text.black.make()),
                            Row(
                              children: [
                                const Icon(Icons.person_add_alt),
                                const SizedBox(width: 3),
                                "${numberOfPassengers}/${widget.sharedRide.numberOfSeat.toString()}"
                                    .text
                                    .black
                                    .make(),
                              ],
                            )
                          ],
                        ),
                      ],
                      const SizedBox(height: 10),
                      if (widget.type == "search" ||
                          widget.type == "history") ...[
                        "Driver information".tr().text.bold.black.make(),
                        const SizedBox(height: 10),
                      ],
                      if (widget.type == "search" ||
                          widget.type == "history") ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 15),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[350]!),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(25)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  CachedNetworkImage(
                                    width: 50,
                                    height: 50,
                                    imageUrl: widget.sharedRide.user!.photo,
                                    filterQuality: FilterQuality.high,
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      widget
                                          .sharedRide.user!.name.text.black.bold
                                          .make(),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Text(
                                              double.parse(widget
                                                      .sharedRide.user!.rating!)
                                                  .ceil()
                                                  .toString(),
                                              style: TextStyle(
                                                  color: Colors.yellow)),
                                          Icon(Icons.star,
                                              color: Colors.yellow),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      if (widget.sharedRide.orders!.isNotEmpty) ...[
                        "Passenger information".tr().text.bold.black.make(),
                        const SizedBox(height: 10),
                      ],
                      widget.sharedRide.orders!.isEmpty
                          ? Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 20),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[350]!),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(25)),
                              ),
                              child: "No passenger".tr().text.black.make(),
                            )
                          : ListView.builder(
                              itemCount: widget.sharedRide.orders!.length,
                              shrinkWrap: true,
                              itemBuilder: ((context, index) {
                                return passengerCard(index, model);
                              }),
                            ).scrollVertical(
                              physics: AlwaysScrollableScrollPhysics()),
                      const SizedBox(height: 20),
                      "Vehicle information".tr().text.bold.black.make(),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[350]!),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(25)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 20),
                          child: Row(children: [
                            const Icon(CupertinoIcons.car_detailed,
                                color: Colors.grey),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  "${widget.sharedRide.vehicle!.carModel?.carMake ?? ""}, ${widget.sharedRide.vehicle!.carModel} (${widget.sharedRide.vehicle!.yearMade ?? "2000"})"
                                      .text
                                      .black
                                      .make(),
                                  const SizedBox(height: 5),
                                  "${widget.sharedRide.vehicle!.color}"
                                      .text
                                      .black
                                      .make(),
                                ],
                              ),
                            ),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (widget.sharedRide.type != null &&
                          (widget.sharedRide.type == "package" ||
                              widget.sharedRide.type == "person_package")) ...[
                        VStack(
                          [
                            'Package details'.tr().text.black.bold.make(),
                            UiSpacer.vSpace(20),
                            PostShareRideTextField(
                              enabled: false,
                              hintText:
                                  "${'Width'.tr()} ${widget.sharedRide.package!.width} (cm)",
                              prefixIcon: const Icon(CupertinoIcons.info),
                            ),
                            UiSpacer.vSpace(10),
                            PostShareRideTextField(
                              enabled: false,
                              hintText:
                                  "${'Height'.tr()} ${widget.sharedRide.package!.height} (cm)",
                              prefixIcon: const Icon(CupertinoIcons.info),
                            ),
                            UiSpacer.vSpace(10),
                            PostShareRideTextField(
                              enabled: false,
                              hintText:
                                  "${'Length'.tr()} ${widget.sharedRide.package!.length} (cm)",
                              prefixIcon: const Icon(CupertinoIcons.info),
                            ),
                            UiSpacer.vSpace(10),
                            PostShareRideTextField(
                              enabled: false,
                              hintText:
                                  "${'Weight'.tr()} ${widget.sharedRide.package!.weight} (kg)",
                              prefixIcon: const Icon(CupertinoIcons.info),
                            ),
                          ],
                        )
                      ],
                      const SizedBox(height: 20),
                      'Note'.tr().text.black.bold.make(),
                      const SizedBox(height: 20),
                      PostShareRideTextField(
                        enabled: false,
                        controller: widget.model.noteController,
                        hintText: widget.sharedRide.note ?? "",
                        prefixIcon: const Icon(CupertinoIcons.chat_bubble),
                      ),
                      if (widget.sharedRide.type == "package" &&
                          widget.type == "search") ...[
                        const SizedBox(height: 20),
                        'Enter your package weight'.tr().text.black.bold.make(),
                        const SizedBox(height: 20),
                        Form(
                          key: formKey,
                          child: PostShareRideTextField(
                            validator: (value) {
                              if (value == null) return "Empty".tr();
                              return null;
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            controller: widget.model.bookWeightController,
                            hintText: "",
                            prefixIcon: const Icon(CupertinoIcons.info),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey))),
              child: VStack(
                [
                  if (widget.sharedRide.status == "new" &&
                      widget.type == "my_ride" && !widget.sharedRide.expired) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      height: 50,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: CustomButton(
                                onPressed: () => context.nextPage(EditTripPage(
                                    sharedRide: widget.sharedRide,
                                    model: model)),
                                title: "Edit trip".tr(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: CustomButton(
                                color: AppColor.closeColor,
                                onPressed: () => cancelRideDialog(),
                                title: "Cancel trip".tr(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                  if (isBooked &&
                      widget.type == "history" &&
                      model.myOrderedRide!.status != "cancelled" &&
                      widget.sharedRide.status != 'canceled') ...[
                    if (!checkOwner)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          "${model.myOrderedRide!.status == "ready" && model.myOrderedRide!.paymentStatus != 'successful' ? "Awaiting payment".tr() : model.myOrderedRide!.status == "ready" && model.myOrderedRide!.paymentStatus == 'successful' ? 'ready'.tr().capitalized : model.myOrderedRide!.status == "pending" ? 'Awaiting confirmation'.tr() : 'cancelled'.capitalized}"
                              .text
                              .xl
                              .color(Colors.red)
                              .make()
                              .pOnly(top: 5, right: 20),
                        ],
                      ),
                    SizedBox(
                      height: 50,
                      child: CustomButton(
                        title: TranslateUtils.getTranslateForFlavor(
                                "Chat with driver")
                            .tr(),
                        color: AppColor.primaryColor,
                        onPressed: () => model.chatDriver(),
                      ).px(15).pOnly(bottom: 5, top: 5),
                    ),
                    SizedBox(
                      height: 50,
                      child: CustomButton(
                        title: "Cancel trip".tr(),
                        color: AppColor.closeColor,
                        onPressed: () {
                          model.cancelBookedRide();
                        },
                      ).px(15).pOnly(bottom: 10),
                    )
                  ],
                  if (isBooked &&
                      widget.type == "search" &&
                      model.myOrderedRide!.status != 'cancelled') ...[
                    CustomButton(title: "Already booked ride".tr())
                        .px(15)
                        .py(10)
                  ],
                  if (!isBooked && widget.type == "search") ...[
                    CustomButton(
                      title: "Book ride with driver".tr(),
                      loading: model.isBusy,
                      onPressed: () async {
                        if (widget.sharedRide.type == "package" &&
                            model.bookWeightController.text.isEmpty) {
                          context.showToast(
                            msg: "Please type in your package weight".tr(),
                            bgColor: Colors.red,
                            textColor: Colors.white,
                          );
                          return;
                        }
                        LocationData location =
                            await currentLocation.getLocation();
                        model.openPaymentMethodSelection(
                          widget.sharedRide.id,
                          LatLng(location.latitude!, location.longitude!),
                        );
                      },
                    ).px(15).py(10),
                  ],
                ],
              ),
            ),
          );
        });
  }

  Container passengerCard(int index, SharedRideViewModel model) {
    var size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[350]!),
        borderRadius: const BorderRadius.all(Radius.circular(25)),
      ),
      child: Column(
        children: [
          if (checkOwner)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                '${widget.sharedRide.orders![index].status == 'ready' && widget.sharedRide.orders![index].paymentStatus != 'successful' ? "Awaiting payment".tr() : widget.sharedRide.orders![index].status == 'ready' && widget.sharedRide.orders![index].paymentStatus == 'successful' ? 'ready'.tr().capitalized : widget.sharedRide.orders![index].status == 'pending' ? 'pending'.tr().capitalized : 'cancelled'.tr()}'
                    .text
                    .color(widget.sharedRide.orders![index].status == 'ready' &&
                            widget.sharedRide.orders![index].paymentStatus ==
                                'successful'
                        ? Colors.green
                        : widget.sharedRide.orders![index].status == 'cancelled'
                            ? Colors.grey
                            : Colors.blue)
                    .make(),
              ],
            ).pOnly(bottom: 5),
          HStack(
            [
              CustomImage(
                imageUrl: widget.sharedRide.orders![index].user.photo,
                width: 45,
                height: 45,
                boxFit: BoxFit.contain,
              ),
              UiSpacer.hSpace(10),
              VStack(
                [
                  widget.sharedRide.orders![index].user.name
                      .tr()
                      .text
                      .black
                      .make(),
                  UiSpacer.vSpace(4),
                  widget.sharedRide.orders![index].user.rawPhone!
                      .tr()
                      .text
                      .black
                      .make(),
                  '${'Tickets'.tr()}: ${widget.sharedRide.orders![index].sharedRideTickets}'
                      .tr()
                      .text
                      .black
                      .make(),
                ],
              ).expand(),
              VStack(
                alignment: MainAxisAlignment.center,
                crossAlignment: CrossAxisAlignment.center,
                [
                  if (widget.type == "my_ride" &&
                      widget.sharedRide.status != 'canceled') ...[
                    SizedBox(
                      height: 30,
                      child: CustomButton(
                        title: "Chat".tr(),
                        color: AppColor.primaryColor,
                        onPressed: () => widget.model.chatCustomer(
                          widget.sharedRide.orders![index].user,
                          widget.sharedRide.orders![index],
                        ),
                      ),
                    ).pOnly(bottom: 5),
                  ],
                  if ((widget.sharedRide.orders![index].sharedRideLatitude !=
                              null ||
                          widget.sharedRide.orders![index]
                                  .sharedRideLongitude !=
                              null) &&
                      widget.sharedRide.status != "canceled") ...[
                    GestureDetector(
                      onTap: () async {
                        await MapsLauncher.launchCoordinates(
                          widget.sharedRide.orders![index].sharedRideLatitude
                              .toDouble(),
                          widget.sharedRide.orders![index].sharedRideLongitude
                              .toDouble(),
                        );
                      },
                      child: HStack(
                        [
                          "Location".tr().text.black.make(),
                          UiSpacer.hSpace(5),
                          Icon(Icons.gps_fixed_outlined, color: Colors.black),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
            crossAlignment: CrossAxisAlignment.center,
          ),
          if (checkOwner &&
              widget.sharedRide.orders![index].status == 'pending') ...[
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: size.width < 375 ? 145 : 150,
                  height: 30,
                  child: CustomButton(
                    title: 'Accept'.tr(),
                    color: Colors.green,
                    loading: model.isBusy,
                    onPressed: () async {
                      bool check = await model.acceptOrderBookedRide(
                          widget.sharedRide.orders![index].id,
                          widget.sharedRide.orders![index].user);
                      if (check) {
                        setState(() {
                          widget.sharedRide.orders![index].status = 'ready';
                        });
                      }
                    },
                  ),
                ),
                SizedBox(
                  width: size.width < 375 ? 145 : 150,
                  height: 30,
                  child: CustomButton(
                    title: 'Refuse'.tr(),
                    loading: model.isBusy,
                    onPressed: () async {
                      bool check = await model.cancelOrderBookedRide(
                          widget.sharedRide.orders![index].id);
                      if (check) {
                        setState(() {
                          widget.sharedRide.orders![index].status = 'cancelled';
                        });
                      }
                    },
                  ),
                )
              ],
            )
          ]
        ],
      ),
    );
  }

  cancelRideDialog() {
    showDialog(
      barrierColor: const Color.fromARGB(200, 100, 180, 246),
      barrierDismissible: true,
      context: scaffoldKey.currentContext!,
      builder: (context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Write a reason for trip cancellation".tr(),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              const SizedBox(height: 25),
              Text(
                "Give us a reason of canceling trip to support you better in the next trip"
                    .tr(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 200,
                child: TextField(
                  controller: widget.model.cancelReason,
                  maxLines: null,
                  expands: true,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Colors.black26, style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Colors.red, style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Colors.black26, style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    prefixIcon: const Icon(Icons.chat_bubble),
                    filled: true,
                    hintText: 'Write a reason for trip cancellation'.tr(),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                        onPressed: () => Navigator.pop(context),
                        title: "Close".tr()),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomButton(
                      color: AppColor.closeColor,
                      onPressed: () {
                        widget.model.cancelSharedRide();
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      title: "SEND".tr(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
