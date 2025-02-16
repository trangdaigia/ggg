// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:intl/intl.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/services/alert.service.dart';
import 'package:sod_user/view_models/car_rental.view_model.dart';
import 'package:sod_user/views/pages/car_rental/car_rental.model.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:velocity_x/velocity_x.dart';

// ignore: must_be_immutable
class SelectionDay extends StatefulWidget {
  SelectionDay({
    super.key,
    required this.car_Rental_Period,
    this.update_self_driving,
    this.update_with_driver,
    this.model,
  });
  CarRentalViewModel? model;
  final CarRentalPeriod car_Rental_Period;
  final Function(CarRentalPeriod)? update_self_driving;
  final Function(CarRentalPeriod)? update_with_driver;
  @override
  State<SelectionDay> createState() => _SelectionDayState();
}

String select_Day_Time = "";
//Tạo biến nhận giá trị của CarRentalPeriod để xử lí
CarRentalPeriod car_Rental_Period = CarRentalPeriod(
  start_time: Time(hours: 21, minute: 00),
  end_time: Time(hours: 20, minute: 00),
  start_day: DateTime.now(),
  end_day: DateTime.now().add(Duration(days: 1)),
  total: Time(hours: 24, minute: 00),
  type: 'self_driving',
);
DateTime selectedDate = DateTime.now();
DatePeriod selectedPeriod = DatePeriod(
    DateTime.now(), //.subtract(Duration(days: 350)),
    DateTime.now().add(Duration(days: 1)));
int mode_showModalBottomSheet = 0;
final DateTime _firstDate =
    DateTime.now(); //.subtract(Duration(days: 3450, hours: 21));
final DateTime _lastDate = DateTime.now().add(Duration(days: 345, hours: 20));
FixedExtentScrollController scrollController_receive =
    FixedExtentScrollController(initialItem: 0);
FixedExtentScrollController scrollController_pay =
    FixedExtentScrollController(initialItem: 0);
FixedExtentScrollController scrollController_pay_day =
    FixedExtentScrollController(initialItem: 0);
List<String> hours = List.empty(growable: true);

class _SelectionDayState extends State<SelectionDay> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedPeriod = DatePeriod(
        widget.car_Rental_Period.start_day, //.subtract(Duration(days: 350)),
        widget.car_Rental_Period.end_day);
    car_Rental_Period = widget.car_Rental_Period;
    hours = generateHoursList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.car_Rental_Period.type == "self_driving") {
      return BasePage(
        showAppBar: true,
        showLeadingAction: true,
        onBackPressed: () async {
          setState(() {
            widget.update_self_driving!(car_Rental_Period);
            widget.model!.startDate = car_Rental_Period.start_day;
            widget.model!.endDate = car_Rental_Period.end_day;
            widget.model!.startTime = formatTime(car_Rental_Period.start_time);
            widget.model!.endTime = formatTime(car_Rental_Period.end_time);
            widget.model!.totalTimeRent = car_Rental_Period.total.hours;
          });
          if ((car_Rental_Period.end_day.year ==
                  car_Rental_Period.start_day.year) &&
              (car_Rental_Period.end_day.month ==
                  car_Rental_Period.start_day.month) &&
              (car_Rental_Period.end_day.day ==
                  car_Rental_Period.start_day.day)) {
            await AlertService.warning(
              title: "Notifications".tr(),
              text: "You have not selected an end date".tr(),
            );
          } else {
            Navigator.pop(context);
          }
        },
        title: "TIME".tr(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              child: RangePicker(
                datePickerStyles: DatePickerRangeStyles(
                    dayHeaderStyle: DayHeaderStyle(
                      textStyle:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    defaultDateTextStyle:
                        TextStyle(fontWeight: FontWeight.w600),
                    selectedDateStyle: TextStyle(color: Colors.white),
                    selectedPeriodMiddleTextStyle:
                        TextStyle(color: Colors.black),
                    selectedPeriodMiddleDecoration:
                        BoxDecoration(color: Colors.red.shade100)),
                initiallyShowDate: DateTime.now(),
                selectedPeriod: selectedPeriod,
                onChanged: _onSelectedDateChanged,
                firstDate: _firstDate,
                lastDate: _lastDate,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      _showBottomSheet(context, 'start_end_time');
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      width: MediaQuery.of(context).size.width / 2,
                      height: 60,
                      decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text("Receive the car".tr()),
                              ],
                            ),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    formatTime(car_Rental_Period.start_time)
                                                .length ==
                                            3
                                        ? '${formatTime(car_Rental_Period.start_time)}0'
                                        : formatTime(
                                            car_Rental_Period.start_time),
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  Icon(Icons.keyboard_arrow_down_rounded)
                                ])
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      _showBottomSheet(context, 'start_end_time');
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 10),
                      width: MediaQuery.of(context).size.width / 2,
                      height: 60,
                      decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text("Give car back".tr()),
                              ],
                            ),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      formatTime(car_Rental_Period.end_time)
                                                  .length ==
                                              3
                                          ? '${formatTime(car_Rental_Period.end_time)}0'
                                          : formatTime(
                                              car_Rental_Period.end_time),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  Icon(Icons.keyboard_arrow_down_rounded)
                                ])
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ).pOnly(top: 40),
          ],
        ),
        bottomSheet: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(border: Border(top: BorderSide())),
          width: double.infinity,
          height: MediaQuery.of(context).size.height / 10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  "${formatTime(car_Rental_Period.start_time)}, ${formatDate(car_Rental_Period.start_day.toString(), false)} - ${(car_Rental_Period.end_day.year == car_Rental_Period.start_day.year) && (car_Rental_Period.end_day.month == car_Rental_Period.start_day.month) && (car_Rental_Period.end_day.day == car_Rental_Period.start_day.day) ? 'Select an end date'.tr() : '${formatTime(car_Rental_Period.end_time)}, ${formatDate(car_Rental_Period.end_day.toString(), false)}'} "
                      .text
                      .semiBold
                      .maxLines(1)
                      .ellipsis
                      .lg
                      .make(),
                  "${'Number of rental days'.tr()}: ${(car_Rental_Period.end_day.year == car_Rental_Period.start_day.year) && (car_Rental_Period.end_day.month == car_Rental_Period.start_day.month) && (car_Rental_Period.end_day.day == car_Rental_Period.start_day.day) ? '?' : numberofrentaldays()} ${'day'.tr()} "
                      .text
                      .make(),
                ],
              ),
              CustomButton(
                onPressed: () async {
                  setState(() {
                    widget.update_self_driving!(car_Rental_Period);
                    widget.model!.startDate = car_Rental_Period.start_day;
                    widget.model!.endDate = car_Rental_Period.end_day;
                    widget.model!.startTime =
                        formatTime(car_Rental_Period.start_time);
                    widget.model!.endTime =
                        formatTime(car_Rental_Period.end_time);
                    widget.model!.totalTimeRent = car_Rental_Period.total.hours;
                  });
                  if ((car_Rental_Period.end_day.year ==
                          car_Rental_Period.start_day.year) &&
                      (car_Rental_Period.end_day.month ==
                          car_Rental_Period.start_day.month) &&
                      (car_Rental_Period.end_day.day ==
                          car_Rental_Period.start_day.day)) {
                    await AlertService.warning(
                      title: "Notifications".tr(),
                      text: "Bạn chưa chọn ngày kết thúc".tr(),
                    );
                  } else {
                    Navigator.pop(context);
                  }
                },
                title: "next".tr().capitalized,
              )
            ],
          ),
        ),
      );
    } else {
      return BasePage(
        showAppBar: true,
        title: "TIME".tr(),
        showLeadingAction: true,
        onBackPressed: () {
          setState(() {
            widget.update_with_driver!(car_Rental_Period);
            widget.model!.startDate = car_Rental_Period.start_day;
            widget.model!.endDate = car_Rental_Period.end_day;
            widget.model!.startTime = formatTime(car_Rental_Period.start_time);
            widget.model!.endTime = formatTime(car_Rental_Period.end_time);
            widget.model!.totalTimeRent = car_Rental_Period.total.hours;
            Navigator.pop(context);
          });
        },
        body: Column(
          children: [
            InkWell(
              onTap: () {
                mode_showModalBottomSheet = 0;
                _showBottomSheet(context, 'start_day');
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                width: MediaQuery.of(context).size.width,
                height: 60,
                decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("start_date".tr()),
                        ],
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                "${formatTime(car_Rental_Period.start_time)}, ${formatDate(car_Rental_Period.start_day.toString(), true)}",
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            Icon(Icons.keyboard_arrow_down_rounded)
                          ]),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      _showBottomSheet(context, 'start_time');
                    },
                    child: Container(
                      height: 60,
                      margin: EdgeInsets.only(left: 10),
                      width: MediaQuery.of(context).size.width / 2,
                      decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Car picks up at time".tr(),
                              //style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            "${formatTime(car_Rental_Period.start_time)}"
                                .text
                                .semiBold
                                .make()
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    _showBottomSheet(context, 'end_day_time');
                  },
                  child: Container(
                    height: 60,
                    margin: EdgeInsets.all(10),
                    width: MediaQuery.of(context).size.width / 2,
                    decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Rental period".tr(),
                          ),
                          Row(
                            children: [
                              '${car_Rental_Period.total.hours}'
                                  .text
                                  .semiBold
                                  .make(),
                              ' ${'hours'.tr()}'.text.semiBold.make(),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
        bottomSheet: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(border: Border(top: BorderSide())),
          width: double.infinity,
          child: Wrap(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      "${formatTime(car_Rental_Period.start_time)}, ${formatDate(car_Rental_Period.start_day.toString(), false)} - ${formatTime(car_Rental_Period.end_time)}, ${formatDate(car_Rental_Period.end_day.toString(), false)}"
                          .text
                          .semiBold
                          .maxLines(1)
                          .ellipsis
                          .lg
                          .make(),
                      "${'Total rental period'.tr()}: ${car_Rental_Period.total.hours} ${'hours'.tr()}"
                          .text
                          .make(),
                    ],
                  ).expand(),
                  CustomButton(
                    onPressed: () {
                      print('-----------');
                      print(formatDate(selectedDate.toString(), true));

                      setState(() {
                        widget.update_with_driver!(car_Rental_Period);
                        widget.model!.startDate = car_Rental_Period.start_day;
                        widget.model!.endDate = car_Rental_Period.end_day;
                        widget.model!.startTime =
                            formatTime(car_Rental_Period.start_time);
                        widget.model!.endTime =
                            formatTime(car_Rental_Period.end_time);
                        widget.model!.totalTimeRent =
                            car_Rental_Period.total.hours;
                        Navigator.pop(context);
                      });
                    },
                    title: "next".tr().capitalized,
                  )
                ],
              ),
            ],
          ).py12(),
        ),
      );
    }
  }

  void _showBottomSheet(BuildContext context, String mode) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        if (mode == "start_end_time") {
          return bottomSheet_start_end_time(context);
        } else if (mode == 'start_day') {
          return bottomSheet_startDay();
        } else if (mode == 'start_time') {
          return bottomSheet_start_time(context);
        } else {
          List<String> times;
          times = createSubItems(
            car_Rental_Period.start_time,
            selectedDate,
          );
          return bottomSheet_end_day_time(context, times);
        }
      },
    );
  }

  StatefulBuilder bottomSheet_end_day_time(
      BuildContext context, List<String> times) {
    return StatefulBuilder(
      builder: (BuildContext _context, StateSetter _setState) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                height: 200,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "Return time".tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 30),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            height: 50,
                          ),
                          ScrollableHourPicker(
                            scrollController: scrollController_pay,
                            hours: times,
                            type: "end_day_time",
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: CustomButton(
                        onPressed: () {
                          setState(() {
                            if (checkCustom) {
                              Navigator.pop(context);
                              showModalBottomSheet(
                                context: context,
                                builder: (BuildContext context) {
                                  return bottomSheet_custom(context);
                                },
                              );
                            } else {
                              _setState(() {});
                              Navigator.pop(context);
                            }
                          });
                        },
                        title: "Select".tr(),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  SizedBox bottomSheet_start_time(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          Container(
            width: double.infinity,
            height: 200,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    "Pick up client".tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                Expanded(
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 30),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        width: 200,
                        height: 50,
                      ),
                      ScrollableHourPicker(
                        scrollController: scrollController_pay,
                        hours: hours,
                        type: "start_time",
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CustomButton(
                    onPressed: () {
                      setState(() {});
                      Navigator.pop(context);
                    },
                    title: "Save".tr(),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  StatefulBuilder bottomSheet_startDay() {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter _setState) {
        return Container(
          width: double.infinity,
          child: Column(
            children: [
              DayPicker.single(
                datePickerStyles: DatePickerRangeStyles(
                  dayHeaderStyle: DayHeaderStyle(
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  defaultDateTextStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                  selectedDateStyle: TextStyle(
                    color: Colors.white,
                  ),
                  selectedSingleDateDecoration: BoxDecoration(
                    color: AppColor.primaryColor,
                  ),
                ),
                selectedDate: selectedDate,
                onChanged: (DateTime newDateTime) {
                  _setState(() {
                    selectedDate = newDateTime;
                    car_Rental_Period.start_day = newDateTime;
                    car_Rental_Period.end_day = car_Rental_Period.start_day.add(
                        Duration(
                            hours: car_Rental_Period.total.hours,
                            minutes:
                                car_Rental_Period.total.getTotalMinutes()));
                  });
                },
                firstDate: _firstDate,
                lastDate: _lastDate,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CustomButton(
                  onPressed: () {
                    setState(() {
                      widget.car_Rental_Period.start_day = selectedDate;
                    });
                    Navigator.pop(context);
                  },
                  title: "Save".tr(),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  //Bottomsheet tùy chỉnh
  Container bottomSheet_custom(BuildContext context) {
    List<String> dates = generateDates();
    return Container(
      height: 300,
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  height: 200,
                  margin: EdgeInsets.only(left: 20, right: 10),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          "hour".tr().capitalized,
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                      ),
                      Expanded(
                        child: Stack(
                            alignment: AlignmentDirectional.center,
                            children: [
                              Container(
                                margin: EdgeInsets.only(bottom: 30),
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(10)),
                                width: 200,
                                height: 50,
                              ),
                              ScrollableHourPicker(
                                scrollController: scrollController_pay,
                                hours: hours,
                                type: "end_time",
                              ),
                            ]),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  height: 200,
                  margin: EdgeInsets.only(right: 20, left: 10),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          "day".tr().capitalized,
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                      ),
                      Expanded(
                        child: Stack(
                            alignment: AlignmentDirectional.center,
                            children: [
                              Container(
                                margin: EdgeInsets.only(bottom: 30),
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(10)),
                                width: 200,
                                height: 50,
                              ),
                              ScrollableHourPicker(
                                scrollController: scrollController_pay_day,
                                hours: dates,
                                type: "end_day",
                              ),
                            ]),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: CustomButton(
              onPressed: () {
                car_Rental_Period.total = calculateHours(
                  car_Rental_Period.start_time,
                  car_Rental_Period.start_day,
                  car_Rental_Period.end_time,
                  car_Rental_Period.end_day,
                );
                setState(() {});
                Navigator.pop(context);
              },
              title: "Save".tr(),
            ),
          )
        ],
      ),
    );
  }

//Tính số ngày thuê
  int numberofrentaldays() {
    DateTime start = car_Rental_Period.start_day;
    DateTime end = car_Rental_Period.end_day;

    Duration difference = end.difference(start);
    int days = difference.inDays;
    int hours = difference.inHours % 24;
    if (days == 0 && hours < 24) {
      car_Rental_Period.total = Time(hours: 24, minute: 0);
      return 1;
    } else {
      if ((car_Rental_Period.end_time.hours >
              car_Rental_Period.start_time.hours) ||
          ((car_Rental_Period.end_time.hours ==
                  car_Rental_Period.start_time.hours) &&
              (car_Rental_Period.end_time.minute >
                  car_Rental_Period.start_time.minute))) {
        days++;
      }
      car_Rental_Period.total = Time(hours: days * 24, minute: 0);
      return days;
    }
  }

  //Lấy giờ phút
  List<String> generateHoursList() {
    List<String> hoursList = [];
    for (int hour = 0; hour < 24; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        String formattedHour = hour.toString().padLeft(2, '0');
        String formattedMinute = minute.toString().padLeft(2, '0');
        String time = '$formattedHour:$formattedMinute';
        hoursList.add(time);
      }
    }
    return hoursList;
  }

//Tính giờ theo tùy chọn
  Time calculateHours(
      Time startTime, DateTime startDate, Time endTime, DateTime endDate) {
    DateTime startDateTime = DateTime(startDate.year, startDate.month,
        startDate.day, startTime.hours, startTime.minute);
    DateTime endDateTime = DateTime(endDate.year, endDate.month, endDate.day,
        endTime.hours, endTime.minute);

    int totalMinutes = endDateTime.difference(startDateTime).inMinutes;
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;

    return Time(hours: hours, minute: minutes);
  }

//Lấy ngày
  List<String> generateDates() {
    List<String> dates = [];
    DateTime currentDate = car_Rental_Period.start_day;

    for (int i = 0; i < 120; i++) {
      DateTime date = currentDate.add(Duration(days: i + 1));
      String formattedDate =
          "${date.day.padLeft(2, '0')}/${date.month.padLeft(2, '0')}/${date.year}";
      dates.add(formattedDate);
    }

    return dates;
  }
//get list thời gian thuê

  List<String> createSubItems(
    Time pickupTime,
    DateTime startDate,
  ) {
    List<String> subItems = [];
    List<int> times = [2, 4, 6, 8, 10, 12, 16, 24, 36, 48];
    int endDay = startDate.day;
    times.forEach((duration) {
      int endHour = pickupTime.hours + duration;

      // Kiểm tra nếu giờ kết thúc vượt qua 24h
      if (endHour >= 24) {
        int extraDays = endHour ~/ 24;
        endHour -= extraDays * 24;
        endDay = startDate.add(Duration(days: extraDays)).day;
      }
      subItems.add(
          '${duration} ${'hours'.tr()} (${'End'.tr()}: ${endHour.toString().padLeft(2, '0')}:${pickupTime.minute.toString().padLeft(2, '0')}, ${endDay.toString().padLeft(2, '0')}/${startDate.month.toString().padLeft(2, '0')}/${startDate.year})');
    });
    subItems.add('Custom'.tr());
    return subItems;
  }

  //Bottomsheet xe tự lái
  Container bottomSheet_start_end_time(BuildContext context) {
    return Container(
      height: 300,
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  height: 200,
                  margin: EdgeInsets.only(left: 20, right: 10),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          "Receive the car".tr(),
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                      ),
                      Expanded(
                        child: Stack(
                            alignment: AlignmentDirectional.center,
                            children: [
                              Container(
                                margin: EdgeInsets.only(bottom: 30),
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(10)),
                                width: 200,
                                height: 50,
                              ),
                              ScrollableHourPicker(
                                scrollController: scrollController_receive,
                                hours: hours,
                                type: "start_time",
                              ),
                            ]),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  height: 200,
                  margin: EdgeInsets.only(right: 20, left: 10),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          "Give car back".tr(),
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                      ),
                      Expanded(
                        child: Stack(
                            alignment: AlignmentDirectional.center,
                            children: [
                              Container(
                                margin: EdgeInsets.only(bottom: 30),
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(10)),
                                width: 200,
                                height: 50,
                              ),
                              ScrollableHourPicker(
                                scrollController: scrollController_pay,
                                hours: hours,
                                type: "end_time",
                              ),
                            ]),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: CustomButton(
              onPressed: () {
                setState(() {});
                Navigator.pop(context);
              },
              title: "Save".tr(),
            ),
          )
        ],
      ),
    );
  }

  void _onSelectedDateChanged(DatePeriod newPeriod) {
    setState(() {
      selectedPeriod = newPeriod;
      widget.car_Rental_Period.start_day = newPeriod.start;
      widget.car_Rental_Period.end_day = newPeriod.end;
    });
  }
}

String formatDate(String dateString, bool year) {
  DateTime date = DateTime.parse(dateString);
  DateFormat formatter = year ? DateFormat('dd/MM/yyyy') : DateFormat('dd/MM');
  String formattedDate = formatter.format(date);
  return formattedDate;
}

String formatDateTimeToString(DateTime dateTime) {
  final formatter = DateFormat('HH:mm E, dd/MM/yyyy');
  String formattedString = formatter.format(dateTime);

  // Thay thế viết tắt ngày trong tuần
  if (translator.activeLanguageCode == 'vi') {
    formattedString = formattedString
        .replaceAll('Mon', 'T2')
        .replaceAll('Tue', 'T3')
        .replaceAll('Wed', 'T4')
        .replaceAll('Thu', 'T5')
        .replaceAll('Fri', 'T6')
        .replaceAll('Sat', 'T7')
        .replaceAll('Sun', 'CN');
  }

  return formattedString;
}

String formatTime(Time time) {
  return '${time.hours < 10 ? '0${time.hours}' : time.hours}:${time.minute == 0 ? '00' : time.minute}';
}

Time formatString_Time(String time) {
  return Time(
      hours: int.parse(time.split(':')[0]),
      minute: int.parse(time.split(':')[1]));
}

bool checkCustom = false;

class ScrollableHourPicker extends StatefulWidget {
  ScrollableHourPicker({
    required this.scrollController,
    required this.hours,
    required this.type,
  });
  FixedExtentScrollController scrollController;
  List<String> hours;
  String type;
  @override
  _ScrollableHourPickerState createState() => _ScrollableHourPickerState();
}

String selected = '';

class _ScrollableHourPickerState extends State<ScrollableHourPicker> {
  @override
  void initState() {
    super.initState();
    int defaultHourIndex = -1;
    if (widget.type == 'end_time') {
      selected = '${formatTime(car_Rental_Period.end_time)}';
      defaultHourIndex =
          widget.hours.indexOf(formatTime(car_Rental_Period.end_time));
      if (defaultHourIndex == -1) {
        defaultHourIndex = 0;
      }
      // Đặt vị trí cuộn mặc định
      widget.scrollController =
          FixedExtentScrollController(initialItem: defaultHourIndex);
    } else if (widget.type == 'start_time') {
      selected = '${formatTime(car_Rental_Period.start_time)}';
      defaultHourIndex =
          widget.hours.indexOf(formatTime(car_Rental_Period.start_time));
      if (defaultHourIndex == -1) {
        defaultHourIndex = 0;
      }
      // Đặt vị trí cuộn mặc định
      widget.scrollController =
          FixedExtentScrollController(initialItem: defaultHourIndex);
    } else if (widget.type == "end_day_time") {
      car_Rental_Period.total.hours > 48
          ? selected = 'Custom'.tr()
          : selected =
              '${car_Rental_Period.total.hours} ${'hours'.tr()} (${'End'.tr()}: ${formatTime(car_Rental_Period.end_time)}, ${formatDate(car_Rental_Period.end_day.toString(), true)})';
      defaultHourIndex = widget.hours.indexOf(selected);
      if (defaultHourIndex == -1) {
        defaultHourIndex = 0;
        print('không có');
      }
      print(defaultHourIndex);
      // Đặt vị trí cuộn mặc định
      widget.scrollController =
          FixedExtentScrollController(initialItem: defaultHourIndex);
      // Lưu giá trị ngày giờ end
    } else if (widget.type == "end_day") {
      selected = '${formatDate(car_Rental_Period.end_day.toString(), true)}';
      defaultHourIndex = widget.hours
          .indexOf(formatDate(car_Rental_Period.end_day.toString(), true));
      if (defaultHourIndex == -1) {
        defaultHourIndex = 0;
      }
      // Đặt vị trí cuộn mặc định
      widget.scrollController =
          FixedExtentScrollController(initialItem: defaultHourIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    int defaultHourIndex = -1;
    if (widget.type == 'end_time') {
      selected = '${formatTime(car_Rental_Period.end_time)}';
      defaultHourIndex =
          widget.hours.indexOf(formatTime(car_Rental_Period.end_time));
      if (defaultHourIndex == -1) {
        defaultHourIndex = 0;
      }
      // Đặt vị trí cuộn mặc định
      widget.scrollController =
          FixedExtentScrollController(initialItem: defaultHourIndex);
    } else if (widget.type == 'start_time') {
      selected = '${formatTime(car_Rental_Period.start_time)}';
      defaultHourIndex =
          widget.hours.indexOf(formatTime(car_Rental_Period.start_time));
      if (defaultHourIndex == -1) {
        defaultHourIndex = 0;
      }
      // Đặt vị trí cuộn mặc định
      widget.scrollController =
          FixedExtentScrollController(initialItem: defaultHourIndex);
    } else if (widget.type == "end_day_time") {
      car_Rental_Period.total.hours > 48
          ? selected = 'Custom'.tr()
          : selected =
              '${car_Rental_Period.total.hours} ${'hours'.tr()} (${'End'.tr()}: ${formatTime(car_Rental_Period.end_time)}, ${formatDate(car_Rental_Period.end_day.toString(), true)})';
      defaultHourIndex = widget.hours.indexOf(selected);
      if (defaultHourIndex == -1) {
        defaultHourIndex = 0;
      }
      // Đặt vị trí cuộn mặc định
      widget.scrollController =
          FixedExtentScrollController(initialItem: defaultHourIndex);
      // Lưu giá trị ngày giờ end
    } else if (widget.type == "end_day") {
      selected = '${formatDate(car_Rental_Period.end_day.toString(), true)}';
      defaultHourIndex = widget.hours
          .indexOf(formatDate(car_Rental_Period.end_day.toString(), true));
      if (defaultHourIndex == -1) {
        defaultHourIndex = 0;
      }
      // Đặt vị trí cuộn mặc định
      widget.scrollController =
          FixedExtentScrollController(initialItem: defaultHourIndex);
    }
    return Rental_period();
  }

  ListWheelScrollView Rental_period() {
    return ListWheelScrollView(
      controller: widget.scrollController,
      itemExtent: 50,
      physics: FixedExtentScrollPhysics().applyTo(
        ClampingScrollPhysics(),
      ),
      // looping: true,
      children: widget.hours.map((hour) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(1.0)),
          child: Text(
            hour.toString(),
            style: TextStyle(
              fontSize: 20,
              color: hour == selected ? AppColor.primaryColor : Colors.black,
            ),
          ),
        );
      }).toList(),
      onSelectedItemChanged: (index) {
        selected = widget.hours[index];
        // Handle selected hour
        setState(() {
          if (widget.type == "end_time") {
            print('End time: (${widget.hours[index]})');
            car_Rental_Period.end_time = formatString_Time(widget.hours[index]);
          } else if (widget.type == "start_time") {
            car_Rental_Period.start_time =
                formatString_Time(widget.hours[index]);
            int total = car_Rental_Period.start_time.hours +
                car_Rental_Period.total.hours;
            if (total >= 24) {
              car_Rental_Period.end_day =
                  car_Rental_Period.start_day.add(Duration(days: total ~/ 24));
            } else {
              car_Rental_Period.end_day = car_Rental_Period.start_day;
            }
            car_Rental_Period.end_time = Time(
                hours: total % 24, minute: car_Rental_Period.start_time.minute);
          } else if (widget.type == "end_day_time") {
            if (widget.hours[index] == 'Custom'.tr()) {
              checkCustom = true;
              print('Tùy chỉnh');
            } else {
              checkCustom = false;
              car_Rental_Period.end_time = Time(
                  hours:
                      int.parse(widget.hours[index].split(":")[1].toString()),
                  minute: int.parse(widget.hours[index]
                      .split(":")[2]
                      .toString()
                      .substring(0, 2)));
              car_Rental_Period.end_day = DateFormat("dd/MM/yyyy").parse(widget
                  .hours[index]
                  .split(":")[2]
                  .toString()
                  .split(',')[1]
                  .replaceAll(')', '')
                  .trim());
              car_Rental_Period.total = Time(
                  hours: int.parse(widget.hours[index].substring(0, 2).trim()),
                  minute: 0);
              print('End time (${formatTime(car_Rental_Period.end_time)})');
              print('total (${formatTime(car_Rental_Period.total)})');
              print('end day ${car_Rental_Period.end_day.toString()}');
            }
          } else if (widget.type == "end_day") {
            print('End day: (${widget.hours[index]})');
            car_Rental_Period.end_day =
                DateFormat("dd/MM/yyyy").parse(widget.hours[index]);
          }
        });
      },
    );
  }
}
