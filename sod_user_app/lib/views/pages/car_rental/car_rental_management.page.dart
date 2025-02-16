import 'package:flutter/material.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:provider/provider.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/models/car_rental.dart';
import 'package:sod_user/models/coordinates.dart';
import 'package:sod_user/models/vendor_type.dart';
import 'package:sod_user/services/alert.service.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/view_models/car_rental.view_model.dart';
import 'package:sod_user/view_models/taxi.vm.dart';
import 'package:sod_user/view_models/taxi_new_order_location_entry.vm.dart';
import 'package:sod_user/views/pages/car_rental/car_rental.model.dart';
import 'package:sod_user/views/pages/car_rental/car_rental/car_rental.page.dart';
import 'package:sod_user/views/pages/car_rental/widgets/selection_day.dart';
import 'package:sod_user/views/pages/car_search/car_search.page.dart';
import 'package:sod_user/views/pages/taxi/widgets/step_one/new_taxi_pick_on_map.view.dart';
import 'package:sod_user/views/pages/trip/trip_page.dart';
import 'package:sod_user/views/pages/vendor/widgets/header.view.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/widgets/busy_indicator.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:sod_user/widgets/cards/custom.visibility.dart';
import 'package:sod_user/widgets/custom_list_view.dart';
import 'package:sod_user/widgets/list_items/address.list_item.dart';
import 'package:sod_user/widgets/taxi_custom_text_form_field.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class CarRentalManagementPage extends StatefulWidget {
  const CarRentalManagementPage({super.key, required this.vendorType});

  final VendorType vendorType;

  @override
  State<CarRentalManagementPage> createState() =>
      _CarRentalManagementPageState();
}

class _CarRentalManagementPageState extends State<CarRentalManagementPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  late TabController _tabController;
  late TaxiViewModel taxiViewModel;
  late CarRentalViewModel viewModelnew;
  Coordinates? localPickUp;
  Coordinates? localDropOff;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    taxiViewModel = TaxiViewModel(
      context,
      widget.vendorType,
    );
    viewModelnew = CarRentalViewModel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      selectTime_Date(widget.vendorType);
    });
  }

  final ValueNotifier<int> selectedRoute = ValueNotifier<int>(0);
  ValueNotifier<Widget> widgetBottomSheet = ValueNotifier<Widget>(SizedBox());
  //Xe tự lái

  //Index chuyển trang
  int selectIndex = 0;
  //Xe tự lái

  //Chuyển Time thành String
  String formatTime(Time time) {
    return '${time.hours < 10 ? '0${time.hours}' : time.hours}:${time.minute == 0 ? '00' : time.minute}';
  }

  int count = 0;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    viewModelnew.startDate = car_Rental_Period.start_day;
    viewModelnew.endDate = car_Rental_Period.end_day;
    viewModelnew.startTime = formatTime(car_Rental_Period.start_time);
    viewModelnew.endTime = formatTime(car_Rental_Period.end_time);
    viewModelnew.totalTimeRent = car_Rental_Period.total.hours;
    viewModelnew.addressController.text = locationPickUp.value;
    viewModelnew.pickUpLocation = locationPickUp.value;
    viewModelnew.dropOffLocation = locationDropOff.value;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      selectTime_Date(widget.vendorType);
    });
    print('Setstate${count++}');
    return BasePage(
      showAppBar: true,
      showLeadingAction: !AppStrings.isSingleVendorMode,
      elevation: 0,
      title: "${widget.vendorType.name}".tr(),
      appBarColor: context.theme.colorScheme.surface,
      //appBarItemColor: AppColor.primaryColor,
      showCart: true,
      actions: [
        InkWell(
          onTap: () {
            context.nextPage(TripPage());
          },
          child: Container(
            margin: EdgeInsets.only(right: 10),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColor.primaryColor,
            ),
            child: ColorFiltered(
                colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                child: Image.asset(
                  'assets/images/icons/trip.png',
                  width: 10,
                  height: 10,
                  fit: BoxFit.contain,
                )),
          ),
        ),
      ],
      body: Column(
        children: [
          //
          AnimatedContainer(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            duration: Duration(milliseconds: 1000),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Color.fromARGB(255, 255, 238, 238),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20))),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      child: TabBar(
                        labelStyle: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                        onTap: (index) {
                          setState(() {
                            selectIndex = index;
                            _tabController.animateTo(index);
                          });
                        },
                        unselectedLabelColor: Colors.black,
                        indicator: BoxDecoration(
                          color: AppColor.primaryColor,
                        ),
                        tabs: [
                          Tab(
                              height: MediaQuery.of(context).size.height / 14,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ColorFiltered(
                                    colorFilter: ColorFilter.mode(
                                        selectIndex == 0
                                            ? Colors.white
                                            : Colors.black,
                                        BlendMode.srcIn),
                                    child: Image.asset(
                                      'assets/images/icons/Self_drive_car_rental.png',
                                      width: 30,
                                      height: 30,
                                    ),
                                  ),
                                  "Self drive"
                                      .tr()
                                      .text
                                      .black
                                      .make()
                                      .pOnly(left: 10),
                                ],
                              )),
                          Tab(
                              child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                    selectIndex == 1
                                        ? Colors.white
                                        : Colors.black,
                                    BlendMode.srcIn),
                                child: Image.asset(
                                  'assets/images/icons/Car_rental_with_drive.png',
                                  width: 30,
                                  height: 30,
                                ),
                              ),
                              "With driver"
                                  .tr()
                                  .text
                                  .black
                                  .make()
                                  .pOnly(left: 10),
                            ],
                          )),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    // height: (selectIndex == 0)
                    //     ? MediaQuery.of(context).size.height / 3.4
                    //     : selectedRoute.value == 0 && selectIndex == 1
                    //         ? MediaQuery.of(context).size.height / 2.4
                    //         : MediaQuery.of(context).size.height / 1.9,
                    height: MediaQuery.of(context).size.height,
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      child: TabBarView(
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          Container(
                              height: MediaQuery.of(context).size.height / 2.5,
                              padding: EdgeInsets.all(9),
                              color: Colors.white,
                              child: Column(
                                children: [
                                  // selection_location(
                                  selection_location(
                                      'Pick up point'.tr(), widget.vendorType),
                                  selection_date(false, "self_driving"),
                                  CustomButton(
                                    title: 'Find a car'.tr(),
                                    onPressed: () {
                                      selectTime_Date(widget.vendorType);
                                      if (locationPickUp.value ==
                                              'Nhập địa điểm'.tr() ||
                                          locationPickUp.value == '') {
                                        AlertService.warning(
                                          title: "Notifications".tr(),
                                          text:
                                              "You have not entered the full address"
                                                  .tr(),
                                        );
                                      } else {
                                        viewModelnew.endTime =
                                            '${formatTime(viewModelnew.self_driving.end_time)}';
                                        viewModelnew.startTime =
                                            '${formatTime(viewModelnew.self_driving.start_time)}';
                                        viewModelnew.totalTimeRent =
                                            viewModelnew
                                                .self_driving.total.hours;
                                        viewModelnew.type = 'xe tự lái';
                                        CarSearchPage nextPage = CarSearchPage(
                                          selectedRoute: selectedRoute,
                                          model: viewModelnew,
                                          bottomSheet: widgetBottomSheet,
                                          pickUpLocation: locationPickUp,
                                          dropOffLocation: locationDropOff,
                                        );
                                        context.nextPage(nextPage);
                                      }
                                    },
                                  ),
                                ],
                              )),
                          Container(
                            height: MediaQuery.of(context).size.height / 3,
                            padding: EdgeInsets.symmetric(horizontal: 9),
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                "Route"
                                    .tr()
                                    .text
                                    .semiBold
                                    .textStyle(TextStyle(color: Colors.black))
                                    .make()
                                    .pOnly(top: 20, left: 10, right: 10),
                                buildDeliveryOptionsWidget(),
                                selection_location(
                                    'Pick up point'.tr(), widget.vendorType),
                                selectIndex == 1 && selectedRoute.value != 0
                                    ? selection_location(
                                        'Destination'.tr(), widget.vendorType)
                                    : SizedBox(),
                                selectIndex == 1
                                    ? "Time"
                                        .tr()
                                        .text
                                        .color(Colors.black)
                                        .semiBold
                                        .make()
                                        .pOnly(top: 20, left: 10, right: 10)
                                    : SizedBox(),
                                selectIndex == 1
                                    ? selection_date(true, null)
                                    : SizedBox(),
                                selectIndex == 1
                                    ? CustomButton(
                                        title: 'Find a car'.tr(),
                                        onPressed: () {
                                          selectTime_Date(widget.vendorType);
                                          if ((locationPickUp.value ==
                                                      'Nhập địa điểm'.tr() ||
                                                  locationPickUp.value == '' ||
                                                  locationDropOff ==
                                                      'Nhập địa điểm'.tr() ||
                                                  locationDropOff == '') &&
                                              selectedRoute.value != 0) {
                                            AlertService.warning(
                                              title: "Notifications".tr(),
                                              text:
                                                  "You have not entered the full address"
                                                      .tr(),
                                            );
                                          } else if ((locationPickUp.value ==
                                                      'Nhập địa điểm'.tr() ||
                                                  locationPickUp.value == '') &&
                                              selectedRoute.value == 0) {
                                            AlertService.warning(
                                              title: "Notifications".tr(),
                                              text:
                                                  "You have not entered the full address"
                                                      .tr(),
                                            );
                                          } else {
                                            viewModelnew.endTime =
                                                '${formatTime(viewModelnew.self_driving.end_time)}';
                                            viewModelnew.startTime =
                                                '${formatTime(viewModelnew.self_driving.start_time)}';
                                            viewModelnew.type = 'xe có tài xế';
                                            viewModelnew.totalTimeRent =
                                                viewModelnew
                                                    .with_driver.total.hours;
                                            CarSearchPage nextPage =
                                                CarSearchPage(
                                              selectedRoute: selectedRoute,
                                              model: viewModelnew,
                                              bottomSheet: widgetBottomSheet,
                                              pickUpLocation: locationPickUp,
                                              dropOffLocation: locationDropOff,
                                            );
                                            context.nextPage(nextPage);
                                          }
                                        },
                                      )
                                    : SizedBox(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ).scrollVertical(),
    );
  }

//Tùy chọn theo xe tự lái hoặc xe có tài xế
  void selectTime_Date(VendorType vendorType) {
    selectIndex == 0
        ? widgetBottomSheet.value = Container(
            height: MediaQuery.of(context).size.height / 2.5,
            padding: EdgeInsets.all(9),
            color: Colors.white,
            child: Column(
              children: [
                selection_location('Pick up point'.tr(), vendorType),
                selection_date(false, "self_driving"),
              ],
            ))
        : widgetBottomSheet.value = Container(
            padding: EdgeInsets.symmetric(horizontal: 0),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                "Route"
                    .tr()
                    .text
                    .xl
                    .semiBold
                    .textStyle(TextStyle(color: Colors.black))
                    .make()
                    .pOnly(top: 20, left: 10, right: 10),
                buildDeliveryOptionsWidget(),
                selection_location('Pick up point'.tr(), vendorType),
                // //selection_location("Điểm đón".tr(), viewModel),
                selectIndex == 1 && selectedRoute.value != 0
                    ? selection_location('Destination'.tr(), vendorType)
                    : SizedBox(),

                selectIndex == 1
                    ? "Time"
                        .tr()
                        .text
                        .xl
                        .color(Colors.black)
                        .semiBold
                        .make()
                        .pOnly(top: 20, left: 10, right: 10)
                    : SizedBox(),
                selectIndex == 1 ? selection_date(true, null) : SizedBox(),
              ],
            ),
          );
  }

//Selection location
//Chọn lộ trình
  // int selectedRoute = 0;
  Widget buildDeliveryOptionsWidget() {
    return ValueListenableBuilder<int>(
        valueListenable: selectedRoute,
        builder: (context, value, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Radio<int>(
                    value: 0,
                    groupValue: value,
                    onChanged: (newValue) {
                      setState(() {
                        selectedRoute.value = newValue!;
                        selectTime_Date(widget.vendorType);
                        print(selectedRoute.value);
                      });
                    },
                  ),
                  "City center"
                      .tr()
                      .text
                      .semiBold
                      .color(selectedRoute == 0
                          ? Colors.black
                          : AppColor.cancelledColor)
                      .sm
                      .make(),
                ],
              ),
              Row(
                children: [
                  Radio<int>(
                    value: 1,
                    groupValue: value,
                    onChanged: (newValue) {
                      setState(() {
                        selectedRoute.value = newValue!;
                        selectTime_Date(widget.vendorType);
                        print(selectedRoute.value);
                      });
                    },
                  ),
                  "Interprov"
                      .tr()
                      .text
                      .semiBold
                      .color(selectedRoute == 1
                          ? Colors.black
                          : AppColor.cancelledColor)
                      .sm
                      .make(),
                ],
              ),
              Row(
                children: [
                  Radio<int>(
                    value: 2,
                    groupValue: value,
                    onChanged: (newValue) {
                      setState(() {
                        selectedRoute.value = newValue!;
                        selectTime_Date(widget.vendorType);
                        print(selectedRoute.value);
                      });
                    },
                  ),
                  "Interprov (One way)"
                      .tr()
                      .text
                      .semiBold
                      .color(selectedRoute == 2
                          ? Colors.black
                          : AppColor.cancelledColor)
                      .sm
                      .make(),
                ],
              ),
            ],
          );
        });
  }

  String formatDate(String dateString, bool year) {
    DateTime date = DateTime.parse(dateString);
    DateFormat formatter =
        year ? DateFormat('dd/MM/yyyy') : DateFormat('dd/MM');
    String formattedDate = formatter.format(date);
    return formattedDate;
  }

//Chọn ngày
  Widget selection_date(bool year, String? rentalType) {
    return HStack(
      [
        //
        HStack(
          [
            //location icon
            Icon(
              Icons.date_range_outlined,
              size: 24,
            ),

            //
            VStack(
              [
                //
                HStack(
                  [
                    //
                    "Rental period".tr().text.sm.semiBold.make(),

                    //
                    Icon(
                      FlutterIcons.chevron_down_fea,
                    ).px4(),
                  ],
                ),
                selectIndex == 0
                    ? "${formatTime(viewModelnew.self_driving.start_time)}, ${formatDate(viewModelnew.self_driving.start_day.toString(), year)} - ${formatTime(viewModelnew.self_driving.end_time)}, ${formatDate(viewModelnew.self_driving.end_day.toString(), year)}"
                        .text
                        .semiBold
                        .maxLines(1)
                        .ellipsis
                        .base
                        .make()
                    : "${formatTime(viewModelnew.with_driver.start_time)}, ${formatDate(viewModelnew.with_driver.start_day.toString(), year)} - ${formatTime(viewModelnew.with_driver.end_time)}, ${formatDate(viewModelnew.with_driver.end_day.toString(), year)}"
                        .text
                        .semiBold
                        .maxLines(1)
                        .ellipsis
                        .base
                        .make(),
                Divider(),
              ],
            )
                .onInkTap(() {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => rentalType == "self_driving"
                              ? SelectionDay(
                                  model: viewModelnew,
                                  car_Rental_Period: viewModelnew.self_driving,
                                  update_self_driving:
                                      viewModelnew.update_self_driving,
                                  update_with_driver:
                                      viewModelnew.update_with_driver,
                                )
                              : SelectionDay(
                                  model: viewModelnew,
                                  car_Rental_Period: viewModelnew.with_driver,
                                  update_self_driving:
                                      viewModelnew.update_self_driving,
                                  update_with_driver:
                                      viewModelnew.update_with_driver,
                                ))).then((value) => {setState(() {})});
                })
                .px12()
                .expand(),
          ],
        ).expand(),
      ],
    )
        .box
        .color(context.theme.colorScheme.surface)
        // .border(
        //   color: AppColor.cancelledColor,
        //   width: 2,
        // )
        // .bottomRounded()
        .outerShadowSm
        .make()
        .pOnly(top: Vx.dp20, left: 10, right: 10, bottom: 20);
  }

  ValueNotifier<String> locationPickUp =
      ValueNotifier<String>('Nhập địa điểm'.tr());
  ValueNotifier<String> locationDropOff =
      ValueNotifier<String>('Nhập địa điểm'.tr());
//Update location
  void updatePickUpLocation(String _location) {
    setState(() {
      locationPickUp.value = _location;
      viewModelnew.pickUpLocation = _location;
      //localPickUp
    });
  }

  void updateDropOffLocation(String _location) {
    setState(() {
      locationDropOff.value = _location;
      viewModelnew.dropOffLocation = _location;
    });
  }

//Chọn địa điểm
  Widget selection_location(String? localString, VendorType vendorType) {
    return HStack(
      [
        //
        HStack(
          [
            //location icon
            Icon(
              FlutterIcons.location_pin_sli,
              size: 24,
            ),

            //
            VStack(
              [
                //
                HStack(
                  [
                    //
                    localString!.tr().text.sm.semiBold.make(),

                    //
                    Icon(
                      FlutterIcons.chevron_down_fea,
                    ).px4(),
                  ],
                ),
                localString == 'Pick up point'.tr()
                    ? (locationPickUp.value == ''
                        ? 'Nhập địa điểm'.text.maxLines(1).ellipsis.base.make()
                        : locationPickUp.value.text
                            .maxLines(1)
                            .ellipsis
                            .base
                            .make())
                    : (locationDropOff.value == ''
                        ? 'Nhập địa điểm'.text.maxLines(1).ellipsis.base.make()
                        : locationDropOff.value.text
                            .maxLines(1)
                            .ellipsis
                            .base
                            .make()),
                Divider(),
              ],
            )
                .onInkTap(() {
                  context.nextPage(LocationWidget(
                    updateDropOffLocation: updateDropOffLocation,
                    updatePickUpLocation: updatePickUpLocation,
                    context: context,
                    vendorType: vendorType,
                    type: localString,
                    pickUpLocation: locationPickUp.value,
                    dropOffLocation: locationDropOff.value,
                  ));
                })
                .px12()
                .expand(),
          ],
        ).expand(),
        Icon(
          FlutterIcons.search_fea,
          size: 20,
        )
            .p8()
            .onInkTap(() {
              context.nextPage(LocationWidget(
                updateDropOffLocation: updateDropOffLocation,
                updatePickUpLocation: updatePickUpLocation,
                context: context,
                vendorType: vendorType,
                type: localString,
                pickUpLocation: locationPickUp.value,
                dropOffLocation: locationDropOff.value,
              ));
            })
            .box
            .roundedSM
            .clip(Clip.antiAlias)
            .color(context.theme.colorScheme.surface)
            .outerShadowSm
            .make(),
      ],
    )
        .box
        .color(context.theme.colorScheme.surface)
        .outerShadowSm
        .make()
        .pOnly(top: Vx.dp20, left: 10, right: 10, bottom: 5);
  }

  @override
  bool get wantKeepAlive => true;
}

class LocationWidget extends StatefulWidget {
  const LocationWidget({
    required this.context,
    required this.vendorType,
    required this.type,
    required this.updatePickUpLocation,
    required this.updateDropOffLocation,
    required this.pickUpLocation,
    required this.dropOffLocation,
  });
  final Function(String) updatePickUpLocation;
  final Function(String) updateDropOffLocation;
  final BuildContext context;
  final VendorType? vendorType;
  final String type;
  final String pickUpLocation;
  final String dropOffLocation;
  @override
  _LocationWidgetState createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> {
  TaxiViewModel? taxiViewModel;
  @override
  void initState() {
    super.initState();
    taxiViewModel = TaxiViewModel(
      widget.context,
      widget.vendorType,
    );
    if (widget.pickUpLocation == 'Nhập địa điểm' ||
        widget.pickUpLocation == '') {
      taxiViewModel?.pickupLocationTEC.text = '';
      taxiViewModel!.initialise();
    } else {
      taxiViewModel?.pickupLocationTEC.text = widget.pickUpLocation;
    }
    if (widget.dropOffLocation == 'Nhập địa điểm' ||
        widget.dropOffLocation == '') {
      taxiViewModel?.dropoffLocationTEC.text = '';
    } else {
      taxiViewModel?.dropoffLocationTEC.text = widget.dropOffLocation;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<TaxiViewModel>.reactive(
        viewModelBuilder: () => taxiViewModel!,
        builder: (context, vm, child) {
          return ViewModelBuilder<NewTaxiOrderLocationEntryViewModel>.reactive(
              viewModelBuilder: () =>
                  NewTaxiOrderLocationEntryViewModel(context, vm),
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
                  body: VStack(
                    [
                      widget.type == 'Pick up point'.tr()
                          ? TaxiCustomTextFormField(
                              hintText: "Pickup Location".tr(),
                              controller: taxiViewModel!.pickupLocationTEC,
                              focusNode: taxiViewModel!.pickupLocationFocusNode,
                              onChanged: taxiNewOrderViewModel.searchPlace,
                              clear: true,
                            )
                          : TaxiCustomTextFormField(
                              hintText: "Drop-off Location".tr(),
                              controller: taxiViewModel!.dropoffLocationTEC,
                              focusNode:
                                  taxiViewModel!.dropoffLocationFocusNode,
                              onChanged: taxiNewOrderViewModel.searchPlace,
                              clear: true,
                            ).pOnly(top: 5),
                      CustomListView(
                        padding: EdgeInsets.zero,
                        isLoading: taxiNewOrderViewModel
                            .busy(taxiNewOrderViewModel.places),
                        dataSet: taxiNewOrderViewModel.places != null
                            ? taxiNewOrderViewModel.places!
                            : [],
                        itemBuilder: (contex, index) {
                          final place = taxiNewOrderViewModel.places![index];
                          return AddressListItem(
                            place,
                            onAddressSelected:
                                taxiNewOrderViewModel.onAddressSelected,
                          );
                        },
                        separatorBuilder: (ctx, index) => UiSpacer.divider(),
                      ).expand(),
                      NewTaxiPickOnMapButton(
                        taxiNewOrderViewModel: taxiNewOrderViewModel,
                      ),
                      CustomButton(
                        title: 'Completed'.tr(),
                        onPressed: () {
                          widget.type == 'Pick up point'.tr()
                              ? widget.updatePickUpLocation(
                                  taxiViewModel!.pickupLocationTEC.text)
                              : widget.updateDropOffLocation(
                                  taxiViewModel!.dropoffLocationTEC.text);
                          Navigator.pop(context);
                        },
                      ).pSymmetric(v: 10, h: 10),
                    ],
                  ).pOnly(bottom: context.mq.viewInsets.bottom),
                );
              });
        });
  }
}
