// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/models/driver.dart';
import 'package:sod_user/view_models/car_rental.view_model.dart';
import 'package:sod_user/views/pages/car_rental/car_rental.model.dart';
import 'package:sod_user/views/pages/car_rental/widgets/selection_day.dart';
import 'package:sod_user/views/pages/car_search/car_detail.dart';
import 'package:sod_user/views/pages/car_search/car_rental_card.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/widgets/custom_list_view.dart';
import 'package:sod_user/widgets/states/error.state.dart';
import 'package:sod_user/widgets/states/loading.shimmer.dart';
import 'package:stacked/stacked.dart';
import 'package:timelines/timelines.dart';
import 'package:velocity_x/velocity_x.dart';

// ignore: must_be_immutable
class CarSearchPage extends StatefulWidget {
  CarSearchPage({
    super.key,
    required this.dropOffLocation,
    required this.pickUpLocation,
    required this.bottomSheet,
    required this.model,
    required this.selectedRoute,
  });
  final CarRentalViewModel model;
  final ValueNotifier<String> dropOffLocation;
  final ValueNotifier<String> pickUpLocation;
  ValueNotifier<Widget> bottomSheet;
  ValueNotifier<int> selectedRoute;

  @override
  State<CarSearchPage> createState() => _CarSearchPageState();
}

bool checkLoai = false;

class _CarSearchPageState extends State<CarSearchPage> {
  late CarRentalViewModel modelCarManage;
  @override
  void initState() {
    super.initState();
    modelCarManage = CarRentalViewModel();
    modelCarManage = widget.model;
    modelCarManage.startTime = widget.model.startTime;
  }

  @override
  void dispose() {
    super.dispose();
  }

  String formatDateTimeString(String dateTimeString) {
    List<String> parts = dateTimeString.split(" - ");

    List<String> startDateTimeParts = parts[0].split(", ");
    String startTime = startDateTimeParts[0];
    String startDate = startDateTimeParts[1].substring(0, 5);

    List<String> endDateTimeParts = parts[1].split(", ");
    String endTime = endDateTimeParts[0];
    String endDate = endDateTimeParts[1].substring(0, 5);

    return "$startTime, $startDate - $endTime, $endDate";
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CarRentalViewModel>.reactive(
        disposeViewModel: false,
        viewModelBuilder: () => widget.model,
        onViewModelReady: (viewModel) => viewModel.initialise(),
        builder: (context, viewModel, child) {
          modelCarManage = viewModel;
          return BasePage(
              showAppBar: true,
              showLeadingAction: true,
              title: Container(
                height: 60,
                margin: EdgeInsets.symmetric(horizontal: 5),
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            widget.model.pickUpLocation!,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          widget.model.type == "xe tự lái"
                              ? Text(
                                  '${formatTime(widget.model.self_driving.start_time)}, ${formatDate(widget.model.self_driving.start_day.toString(), false)} - ${formatTime(widget.model.self_driving.end_time)}, ${formatDate(widget.model.self_driving.end_day.toString(), false)}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey.shade700,
                                  ),
                                )
                              : Text(
                                  '${formatTime(widget.model.with_driver.start_time)}, ${formatDate(widget.model.with_driver.start_day.toString(), false)} - ${formatTime(widget.model.with_driver.end_time)}, ${formatDate(widget.model.with_driver.end_day.toString(), false)}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey.shade700,
                                  ),
                                )
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.search,
                        color: Colors.black,
                        size: 30,
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          barrierColor: Colors.transparent,
                          enableDrag: false,
                          isScrollControlled: true,
                          useRootNavigator: true,
                          context: context,
                          useSafeArea: true,
                          builder: (context) => ValueListenableBuilder<Widget>(
                              valueListenable: widget.bottomSheet,
                              builder: (context, value, child) {
                                return Container(
                                    padding: EdgeInsets.only(top: 20),
                                    height: MediaQuery.of(context).size.height,
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(left: 10),
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.grey),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50)),
                                              child: Icon(Icons.close,
                                                  color: Colors.black),
                                            ).onTap(() {
                                              bool check = true;
                                              Navigator.pop(context);
                                              setState(() {
                                                check = !check;
                                              });
                                              viewModel.pickUpLocation =
                                                  widget.model.pickUpLocation;
                                              viewModel.getCarRental(
                                                rental_options:
                                                    viewModel.type ==
                                                            "xe tự lái"
                                                        ? "0"
                                                        : "1",
                                                brand_id: brand_id,
                                                rating: rating,
                                                color: color,
                                                fast_booking: fastBooking,
                                                mortgage_exemption:
                                                    mortgageExemption,
                                                year_made: yearMake.toString(),
                                                discount: discount,
                                                vehicle_type_id:
                                                    '${getStringId(modelCarManage)}',
                                                free_delivery: free_delivery,
                                              );
                                            })
                                          ],
                                        ),
                                        value,
                                      ],
                                    ));
                              }),
                        );
                      },
                    )
                  ],
                ),
              ),
              body: Column(
                children: [
                  SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: filtertype(modelCarManage)),
                  Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      height: MediaQuery.of(context).size.height - 150,
                      child: CustomListView(
                          separator: 10,
                          canRefresh: true,
                          refreshController: viewModel.refreshController,
                          onRefresh: () => viewModel.getCarRental(
                                rental_options:
                                    viewModel.type == "xe tự lái" ? "0" : "1",
                                brand_id: brand_id,
                                rating: rating,
                                color: color,
                                fast_booking: fastBooking,
                                mortgage_exemption: mortgageExemption,
                                year_made: yearMake.toString(),
                                discount: discount,
                                vehicle_type_id:
                                    '${getStringId(modelCarManage)}',
                                free_delivery: free_delivery,
                              ),
                          isLoading: viewModel.isBusy,
                          dataSet: viewModel.carRental,
                          hasError: viewModel.hasError,
                          errorWidget: LoadingError(
                            onrefresh: viewModel.getCarRental,
                          ),
                          emptyWidget: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Center(
                                heightFactor: 40,
                                child: Text(
                                  'no_data'.tr(),
                                ),
                              ),
                            ],
                          ),
                          itemBuilder: (context, index) {
                            return CarRentalCard(
                              index: index,
                              dropOffLocation: widget.dropOffLocation,
                              selectedRoute: widget.selectedRoute,
                              bottomSheet: widget.bottomSheet,
                              pickUpLocation: widget.pickUpLocation,
                              model: modelCarManage,
                              carRental: modelCarManage.carRental[index],
                            );
                          })),
                ],
              ));
        });
  }

  String formatDate(String dateString, bool year) {
    DateTime date = DateTime.parse(dateString);
    DateFormat formatter =
        year ? DateFormat('dd/MM/yyyy') : DateFormat('dd/MM');
    String formattedDate = formatter.format(date);
    return formattedDate;
  }

  final List<String> items = [
    '',
    'Range of vehicle'.tr(),
    'Car company'.tr(),
    'Color'.tr(),
    '5 star car owner'.tr(),
    'Quick booking'.tr(),
    'Discount'.tr(),
    'Year of manufacture'.tr(),
    'Mortgage free'.tr(),
    'Free delivery'.tr(),
  ];
  final List<IconData> Iconitems = [
    Icons.repeat_outlined,
    Icons.directions_car_outlined,
    Icons.language_outlined,
    Icons.color_lens_outlined,
    Icons.stars_outlined,
    Icons.flash_on_outlined,
    Icons.local_offer_outlined,
    MaterialIcons.date_range,
    FontAwesome.handshake_o,
    Icons.location_on_outlined,
  ];
  final List<bool> select = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
  ];

  String yearMake = '';
  yearDialog(BuildContext context, CarRentalViewModel model, int index) {
    if (yearMake == '') {
      select[index] = true;
      model.getCarRental(
        rental_options: modelCarManage.type == "xe tự lái" ? "0" : "1",
        brand_id: brand_id,
        color: color,
        rating: rating,
        discount: discount,
        fast_booking: fastBooking,
        mortgage_exemption: mortgageExemption,
        year_made: '2024',
        free_delivery: free_delivery,
        vehicle_type_id: '${getStringId(modelCarManage)}',
      );
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, _setState) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("select_year".tr()),
              ],
            ),
            content: SizedBox(
              width: 300,
              height: 350,
              child: Column(
                children: [
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: YearPicker(
                      currentDate: DateTime(
                          yearMake == ''
                              ? DateTime.now().year
                              : int.parse(yearMake == '' ? '2024' : yearMake),
                          1),
                      firstDate: DateTime(DateTime.now().year - 30, 1),
                      lastDate: DateTime(DateTime.now().year, 1),
                      initialDate: DateTime(DateTime.now().year, 1),
                      selectedDate: DateTime(
                          yearMake == ''
                              ? DateTime.now().year
                              : int.parse(yearMake == '' ? '2024' : yearMake),
                          1),
                      onChanged: (DateTime dateTime) {
                        _setState(() {
                          yearMake = dateTime.year.toString();
                          model.getCarRental(
                            rental_options:
                                modelCarManage.type == "xe tự lái" ? "0" : "1",
                            brand_id: brand_id,
                            color: color,
                            rating: rating,
                            fast_booking: fastBooking,
                            discount: discount,
                            mortgage_exemption: mortgageExemption,
                            free_delivery: free_delivery,
                            year_made: yearMake.toString(),
                            vehicle_type_id: '${getStringId(modelCarManage)}',
                          );
                        });
                      },
                    ),
                  ),
                  TextButton(
                      onPressed: () {
                        select[index] = false;
                        yearMake = '';
                        model.getCarRental(
                          rental_options:
                              modelCarManage.type == "xe tự lái" ? "0" : "1",
                          brand_id: brand_id,
                          color: color,
                          rating: rating,
                          fast_booking: fastBooking,
                          discount: discount,
                          mortgage_exemption: mortgageExemption,
                          vehicle_type_id: '${getStringId(model)}',
                          year_made: yearMake.toString(),
                          free_delivery: free_delivery,
                        );
                      },
                      child: Text('All'.tr()))
                ],
              ),
            ),
          );
        });
      },
    );
  }

  String discount = '';
  String fastBooking = '';
  String mortgageExemption = '';
  String free_delivery = '';
  String rating = '';
  Widget filtertype(CarRentalViewModel model) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: Iconitems.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: select[index] ? Colors.red.shade100 : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: Colors.grey.shade300),
          ),
          margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          padding: EdgeInsets.symmetric(horizontal: 13),
          child: Center(
            child: Row(
              children: [
                Icon(Iconitems[index]).pOnly(right: index != 8 ? 3 : 10),
                Text(
                  items[index],
                  style: TextStyle(
                    color: context.textTheme.bodyLarge!.color,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ).onTap(() {
          setState(() {
            if (index == 0) {
              select.fillRange(0, select.length, false);
              for (var vehicle in model.vehicleType) {
                vehicle.onSelect = false;
              }
              selectedColor = -1;
              selectedBrand = -1;
              color = '';
              brand_id = '';
              yearMake = '';
              rating = '';
              fastBooking = '';
              mortgageExemption = '';
              rating = '';
              free_delivery = '';
              discount = '';
              modelCarManage.getCarRental(
                rental_options: modelCarManage.type == "xe tự lái" ? "0" : "1",
              );
            }
            if (index == 1) {
              bottomsheet_select_RangeOfVehicle(context, model);
            }
            if (index == 2) {
              bottomsheet_select_BrandOfVehicle(context);
            }
            if (index == 3) {
              bottomsheet_select_ColorOfVehicle(context);
            }
            if (index == 4) {
              select[index] = !select[index];

              if (select[index]) {
                rating = '5';
              } else {
                rating = '';
              }
              modelCarManage.getCarRental(
                  discount: discount,
                  rental_options:
                      modelCarManage.type == "xe tự lái" ? "0" : "1",
                  brand_id: brand_id,
                  color: color,
                  fast_booking: fastBooking,
                  mortgage_exemption: mortgageExemption,
                  year_made: yearMake.toString(),
                  vehicle_type_id: '${getStringId(model)}',
                  free_delivery: free_delivery,
                  rating: rating);
            }

            if (index == 5) {
              select[index] = !select[index];
              if (select[index]) {
                fastBooking = '1';
              } else {
                fastBooking = '';
              }
              modelCarManage.getCarRental(
                  rental_options:
                      modelCarManage.type == "xe tự lái" ? "0" : "1",
                  brand_id: brand_id,
                  color: color,
                  fast_booking: fastBooking,
                  discount: discount,
                  mortgage_exemption: mortgageExemption,
                  year_made: yearMake.toString(),
                  vehicle_type_id: '${getStringId(model)}',
                  free_delivery: free_delivery,
                  rating: rating);
            }
            if (index == 6) {
              select[index] = !select[index];
              if (select[index]) {
                discount = '1';
              } else {
                discount = '';
              }
              modelCarManage.getCarRental(
                  rental_options:
                      modelCarManage.type == "xe tự lái" ? "0" : "1",
                  brand_id: brand_id,
                  color: color,
                  fast_booking: fastBooking,
                  mortgage_exemption: mortgageExemption,
                  year_made: yearMake.toString(),
                  vehicle_type_id: '${getStringId(model)}',
                  discount: discount,
                  free_delivery: free_delivery,
                  rating: rating);
            }
            if (index == 7) {
              yearDialog(context, model, index);
            }
            if (index == 8) {
              select[index] = !select[index];
              if (select[index]) {
                mortgageExemption = '1';
              } else {
                mortgageExemption = '';
              }
              modelCarManage.getCarRental(
                  rental_options:
                      modelCarManage.type == "xe tự lái" ? "0" : "1",
                  brand_id: brand_id,
                  color: color,
                  fast_booking: fastBooking,
                  mortgage_exemption: mortgageExemption,
                  year_made: yearMake.toString(),
                  vehicle_type_id: '${getStringId(model)}',
                  free_delivery: free_delivery,
                  discount: discount,
                  rating: rating);
            }
            if (index == 9) {
              select[index] = !select[index];
              if (select[index]) {
                free_delivery = '1';
              } else {
                free_delivery = '';
              }
              modelCarManage.getCarRental(
                  rental_options:
                      modelCarManage.type == "xe tự lái" ? "0" : "1",
                  brand_id: brand_id,
                  color: color,
                  fast_booking: fastBooking,
                  mortgage_exemption: mortgageExemption,
                  year_made: yearMake.toString(),
                  vehicle_type_id: '${getStringId(model)}',
                  free_delivery: free_delivery,
                  discount: discount,
                  rating: rating);
            }
            if (select.skip(1).contains(true)) {
              select[0] = true;
            } else {
              select[0] = false;
            }
          });
        });
      },
    );
  }

  String? brand_id = '';
  int selectedBrand = -1;
  Future<dynamic> bottomsheet_select_BrandOfVehicle(BuildContext context) {
    //modelCarManage = CarManagementViewModel();
    return showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        isScrollControlled: true,
        context: context,
        builder: (context) => StatefulBuilder(
              builder: (BuildContext context,
                  void Function(void Function()) _setState) {
                return Container(
                    height: MediaQuery.of(context).size.height / 1.2,
                    padding: EdgeInsets.all(20),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.close).onTap(() {
                                Navigator.pop(context);
                              })
                            ],
                          ),
                          'Car company'.tr().text.xl2.semiBold.make(),
                          Container(
                              height: MediaQuery.of(context).size.height / 1.5,
                              child: modelCarManage.carBrand.isNotEmpty
                                  ? ListView.builder(
                                      itemCount:
                                          modelCarManage.carBrand.length + 1,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        if (index == 0) {
                                          return Row(
                                            children: [
                                              Radio<int>(
                                                groupValue: selectedBrand,
                                                value: -1,
                                                onChanged: (value) {
                                                  brand_id = '';
                                                  // Handle radio button selection here
                                                  setState(() {
                                                    _setState(() {
                                                      selectedBrand = value!;
                                                      if (selectedBrand == -1) {
                                                        setState(() {
                                                          select[2] = false;
                                                        });
                                                      } else {
                                                        setState(() {
                                                          select[2] = true;
                                                        });
                                                      }
                                                      if (select
                                                          .skip(1)
                                                          .contains(true)) {
                                                        select[0] = true;
                                                      } else {
                                                        select[0] = false;
                                                      }
                                                    });
                                                  });
                                                  modelCarManage.getCarRental(
                                                      rental_options:
                                                          modelCarManage.type ==
                                                                  "xe tự lái"
                                                              ? "0"
                                                              : "1",
                                                      brand_id: brand_id,
                                                      year_made: yearMake
                                                          .toString(),
                                                      color: color,
                                                      fast_booking: fastBooking,
                                                      vehicle_type_id:
                                                          '${getStringId(modelCarManage)}',
                                                      mortgage_exemption:
                                                          mortgageExemption,
                                                      discount: discount,
                                                      free_delivery:
                                                          free_delivery,
                                                      rating: rating);
                                                },
                                              ),
                                              Container(
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 10),
                                                child:
                                                    'All'.tr().text.xl2.make(),
                                              ),
                                            ],
                                          );
                                        } else {
                                          int carBrandIndex = index - 1;
                                          return Row(
                                            children: [
                                              Radio<int>(
                                                groupValue: selectedBrand,
                                                value: carBrandIndex,
                                                onChanged: (value) {
                                                  brand_id =
                                                      '${modelCarManage.carBrand[carBrandIndex].id}';
                                                  // Handle radio button selection here
                                                  setState(() {
                                                    _setState(() {
                                                      selectedBrand = value!;
                                                      if (selectedBrand == -1) {
                                                        setState(() {
                                                          select[2] = false;
                                                        });
                                                      } else {
                                                        setState(() {
                                                          select[2] = true;
                                                        });
                                                      }
                                                      if (select
                                                          .skip(1)
                                                          .contains(true)) {
                                                        select[0] = true;
                                                      } else {
                                                        select[0] = false;
                                                      }
                                                    });
                                                  });
                                                  print(
                                                      'Năm sản xuất: ${yearMake.toString()}');
                                                  print(
                                                      'Id brand: ${modelCarManage.carBrand[carBrandIndex].id}');

                                                  modelCarManage.getCarRental(
                                                      rental_options:
                                                          modelCarManage.type ==
                                                                  "xe tự lái"
                                                              ? "0"
                                                              : "1",
                                                      brand_id: brand_id,
                                                      year_made: yearMake
                                                          .toString(),
                                                      color: color,
                                                      fast_booking: fastBooking,
                                                      discount: discount,
                                                      vehicle_type_id:
                                                          '${getStringId(modelCarManage)}',
                                                      mortgage_exemption:
                                                          mortgageExemption,
                                                      free_delivery:
                                                          free_delivery,
                                                      rating: rating);
                                                },
                                              ),
                                              Container(
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 10),
                                                child:
                                                    '${modelCarManage.carBrand[carBrandIndex].name}'
                                                        .text
                                                        .xl2
                                                        .make(),
                                              ),
                                            ],
                                          );
                                        }
                                      },
                                    )
                                  : Column(
                                      children: [
                                        LoadingShimmer().px20().centered(),
                                        LoadingShimmer().px20().centered(),
                                        LoadingShimmer().px20().centered(),
                                        LoadingShimmer().px20().centered(),
                                        LoadingShimmer().px20().centered(),
                                      ],
                                    )),
                        ]));
              },
            ));
  }

//Color
  int selectedColor = -1;
  String? color = '';
  List<String> colorList = [
    'Trắng',
    'Đen',
    'Đỏ',
    'Xám',
    'Vàng',
    'Bạc',
    'Nâu',
    'Xanh',
  ];
  Future<dynamic> bottomsheet_select_ColorOfVehicle(BuildContext context) {
    //modelCarManage = CarManagementViewModel();
    return showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        isScrollControlled: true,
        context: context,
        builder: (context) => StatefulBuilder(
              builder: (BuildContext context,
                  void Function(void Function()) _setState) {
                return Container(
                    height: MediaQuery.of(context).size.height / 1.2,
                    padding: EdgeInsets.all(20),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.close).onTap(() {
                                Navigator.pop(context);
                              })
                            ],
                          ),
                          'Màu sắc'.tr().text.xl2.semiBold.make(),
                          Container(
                              height: MediaQuery.of(context).size.height / 1.5,
                              child: colorList.isNotEmpty
                                  ? ListView.builder(
                                      itemCount: colorList.length + 1,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        if (index == 0) {
                                          return Row(
                                            children: [
                                              Radio<int>(
                                                groupValue: selectedColor,
                                                value: -1,
                                                onChanged: (value) {
                                                  color = '';
                                                  // Handle radio button selection here
                                                  setState(() {
                                                    _setState(() {
                                                      selectedColor = value!;
                                                      if (selectedColor == -1) {
                                                        setState(() {
                                                          select[3] = false;
                                                        });
                                                      } else {
                                                        setState(() {
                                                          select[3] = true;
                                                        });
                                                      }
                                                      if (select
                                                          .skip(1)
                                                          .contains(true)) {
                                                        select[0] = true;
                                                      } else {
                                                        select[0] = false;
                                                      }
                                                    });
                                                  });
                                                  modelCarManage.getCarRental(
                                                      rental_options:
                                                          modelCarManage.type ==
                                                                  "xe tự lái"
                                                              ? "0"
                                                              : "1",
                                                      brand_id: brand_id,
                                                      year_made:
                                                          yearMake.toString(),
                                                      color: color,
                                                      fast_booking: fastBooking,
                                                      mortgage_exemption:
                                                          mortgageExemption,
                                                      discount: discount,
                                                      free_delivery:
                                                          free_delivery,
                                                      vehicle_type_id:
                                                          '${getStringId(modelCarManage)}',
                                                      rating: rating);
                                                },
                                              ),
                                              Container(
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 10),
                                                child:
                                                    'All'.tr().text.xl2.make(),
                                              ),
                                            ],
                                          );
                                        } else {
                                          int carColorIndex = index - 1;
                                          return Row(
                                            children: [
                                              Radio<int>(
                                                groupValue: selectedColor,
                                                value: carColorIndex,
                                                onChanged: (value) {
                                                  color =
                                                      colorList[carColorIndex];
                                                  setState(() {
                                                    _setState(() {
                                                      selectedColor = value!;
                                                      if (selectedColor == -1) {
                                                        setState(() {
                                                          select[3] = false;
                                                        });
                                                      } else {
                                                        setState(() {
                                                          select[3] = true;
                                                        });
                                                      }
                                                      if (select
                                                          .skip(1)
                                                          .contains(true)) {
                                                        select[0] = true;
                                                      } else {
                                                        select[0] = false;
                                                      }
                                                    });
                                                  });
                                                  modelCarManage.getCarRental(
                                                      rental_options:
                                                          modelCarManage.type ==
                                                                  "xe tự lái"
                                                              ? "0"
                                                              : "1",
                                                      brand_id: brand_id,
                                                      year_made:
                                                          yearMake.toString(),
                                                      color: color,
                                                      fast_booking: fastBooking,
                                                      discount: discount,
                                                      mortgage_exemption:
                                                          mortgageExemption,
                                                      free_delivery:
                                                          free_delivery,
                                                      vehicle_type_id:
                                                          '${getStringId(modelCarManage)}',
                                                      rating: rating);
                                                },
                                              ),
                                              Container(
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 10),
                                                child:
                                                    '${colorList[carColorIndex].tr()}'
                                                        .text
                                                        .xl2
                                                        .make(),
                                              ),
                                            ],
                                          );
                                        }
                                      },
                                    )
                                  : Column(
                                      children: [
                                        LoadingShimmer().px20().centered(),
                                        LoadingShimmer().px20().centered(),
                                        LoadingShimmer().px20().centered(),
                                        LoadingShimmer().px20().centered(),
                                        LoadingShimmer().px20().centered(),
                                      ],
                                    )),
                        ]));
              },
            ));
  }

  String getStringId(CarRentalViewModel model) {
    List<int> selectType = [];
    model.vehicleType.forEach((type) {
      if (type.onSelect) {
        selectType.add(type.id!);
      }
    });
    return selectType.join(",");
  }

  Future<dynamic> bottomsheet_select_RangeOfVehicle(
      BuildContext context, CarRentalViewModel model) {
    return showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        isScrollControlled: true,
        // useRootNavigator: true,
        context: context,
        builder: (context) => Container(
              height: MediaQuery.of(context).size.height / 1.2,
              padding: EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.close).onTap(() {
                          Navigator.pop(context);
                        })
                      ],
                    ),
                    'Range of vehicle'.tr().text.xl2.semiBold.make(),
                    Container(
                      height: MediaQuery.of(context).size.height / 1.5,
                      child: GridView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                        ),
                        itemCount: model.vehicleType.length,
                        itemBuilder: (BuildContext context, int index) {
                          return StatefulBuilder(
                            builder: (BuildContext context,
                                void Function(void Function()) _setState) {
                              return Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 10),
                                decoration: BoxDecoration(
                                    color: model.vehicleType[index].onSelect
                                        ? Colors.red.shade100
                                        : Colors.transparent,
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(20)),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    model.vehicleType[index].photo!.substring(
                                                model.vehicleType[index].photo!
                                                        .length -
                                                    3) !=
                                            "svg"
                                        ? Image.network(
                                            model.vehicleType[index].photo!,
                                            width: 50,
                                            height: 40,
                                          )
                                        : SvgPicture.network(
                                            model.vehicleType[index].photo!,
                                            width: 50,
                                            height: 40,
                                          ),
                                    '${model.vehicleType[index].name}'
                                        .text
                                        .semiBold
                                        .make(),
                                  ],
                                ),
                              ).onTap(() {
                                _setState(() {
                                  model.vehicleType[index].onSelect =
                                      !model.vehicleType[index].onSelect;
                                  checkLoai = model.vehicleType
                                      .where((RangeVehicle) =>
                                          RangeVehicle.onSelect == true)
                                      .isNotEmpty;
                                  if (checkLoai) {
                                    setState(() {
                                      select[1] = true;
                                    });
                                  } else {
                                    setState(() {
                                      select[1] = false;
                                    });
                                  }
                                  if (select.skip(1).contains(true)) {
                                    select[0] = true;
                                  } else {
                                    select[0] = false;
                                  }
                                });
                                print('Id tìm: ${getStringId(model)}');
                                print('aaaaa');
                                modelCarManage.getCarRental(
                                    rental_options:
                                        modelCarManage.type == "xe tự lái"
                                            ? "0"
                                            : "1",
                                    brand_id: brand_id,
                                    year_made: yearMake.toString(),
                                    color: color,
                                    fast_booking: fastBooking,
                                    mortgage_exemption: mortgageExemption,
                                    discount: discount,
                                    free_delivery: free_delivery,
                                    vehicle_type_id: '${getStringId(model)}',
                                    rating: rating);
                              });
                            },
                          );
                        },
                      ),
                    )
                  ]),
            ));
  }
}

double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double earthRadius = 6371; // Đường kính Trái Đất (đơn vị: km)

  double dLat = _toRadians(lat2 - lat1);
  double dLon = _toRadians(lon2 - lon1);

  double a = pow(sin(dLat / 2), 2) +
      cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * pow(sin(dLon / 2), 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  double distance = earthRadius * c;
  return distance;
}

double _toRadians(double degree) {
  return degree * pi / 180;
}

String formatNumber(int number) {
  if (number >= 1000) {
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
    return '${formattedNumber}K';
  } else {
    return number.toString();
  }
}

class Location {
  final double latitude;
  final double longitude;

  Location(this.latitude, this.longitude);
}

class RangeOfVehicle {
  RangeOfVehicle({
    required this.img,
    required this.name,
    this.describe,
    required this.quantity,
    this.onSelect,
  });
  String img;
  String name;
  String? describe;
  int quantity;
  bool? onSelect = false;
}
