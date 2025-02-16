import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/models/car_rental.dart';
import 'package:sod_user/services/alert.service.dart';
import 'package:sod_user/services/navigation.service.dart';
import 'package:sod_user/view_models/car_management.view_model.dart';
import 'package:sod_user/view_models/shared_ride.vm.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:velocity_x/velocity_x.dart';

class AddPricePage extends StatefulWidget {
  final CarManagementViewModel model;
  const AddPricePage(
      {super.key,
      required this.model,
      this.showNext = true,
      this.data,
      this.shareRideModel});
  final bool showNext;
  final CarRental? data;
  final SharedRideViewModel? shareRideModel;

  @override
  State<AddPricePage> createState() => _AddPricePageState();
}

class _AddPricePageState extends State<AddPricePage> {
  bool showDiscount = false;
  bool isUpdating = false;
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    _focusNodes.forEach((element) {
      element.dispose();
    });
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      widget.model.price26Controller.text = CurrencyTextInputFormatter.currency(
        locale: 'vi',
        decimalDigits: 0,
      ).formatString(
          widget.data!.vehicleRentPrice!.priceMondayFriday.toString());

      widget.model.price7cnController.text =
          CurrencyTextInputFormatter.currency(
        locale: 'vi',
        decimalDigits: 0,
      ).formatString(
              widget.data!.vehicleRentPrice!.priceSaturdaySunday.toString());
//
      widget.model.price26WithDriverController.text =
          CurrencyTextInputFormatter.currency(
        locale: 'vi',
        decimalDigits: 0,
      ).formatString(widget.data!.vehicleRentPrice!.priceMondayFridayWithDriver
              .toString());
      widget.model.price26WithDriverController.text =
          widget.model.price26WithDriverController.text + "/${'hour'.tr()}";

      widget.model.price7cnWithDriverController.text =
          CurrencyTextInputFormatter.currency(
        locale: 'vi',
        decimalDigits: 0,
      ).formatString(widget
              .data!.vehicleRentPrice!.priceSaturdaySundayWithDriver
              .toString());
      widget.model.price7cnWithDriverController.text =
          widget.model.price7cnWithDriverController.text + "/${'hour'.tr()}";

      widget.model.drivingFeeController.text =
          CurrencyTextInputFormatter.currency(
        locale: 'vi',
        decimalDigits: 0,
      ).formatString(widget.data!.vehicleRentPrice!.drivingFee.toString());
      widget.model.drivingFeeController.text =
          widget.model.drivingFeeController.text + "/${'hour'.tr()}";

      widget.model.price1kmController.text =
          CurrencyTextInputFormatter.currency(
        locale: 'vi',
        decimalDigits: 0,
      ).formatString(widget.data!.vehicleRentPrice!.priceOneKm.toString());
      widget.model.price1kmController.text =
          widget.model.price1kmController.text + "/${'km'.tr()}";

      widget.data!.vehicleRentPrice!.discountSevenDays != null
          ? widget.data!.vehicleRentPrice!.discountSevenDays
          : widget.data!.vehicleRentPrice!.discountSevenDays = 0;
      widget.data!.vehicleRentPrice!.discountThreeDays != null
          ? widget.data!.vehicleRentPrice!.discountThreeDays
          : widget.data!.vehicleRentPrice!.discountThreeDays = 0;
      widget.model.discountSevenDays =
          widget.data?.vehicleRentPrice?.discountSevenDays;
      widget.model.discountThreeDays =
          widget.data?.vehicleRentPrice?.discountThreeDays;
      widget.data!.vehicleRentPrice!.discountSevenDays == 0 &&
              widget.data!.vehicleRentPrice!.discountSevenDays == 0
          ? showDiscount = false
          : showDiscount = true;
    } else {
      widget.model.discountThreeDays = 0;
      widget.model.discountSevenDays = 0;
    }
    _focusNodes[0].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColor.onboarding3Color,
        appBar: AppBar(
          backgroundColor: context.backgroundColor,
          title: Text("Determine the rental price per day".tr(),
              style: TextStyle(color: context.textTheme.bodyLarge!.color)),
          centerTitle: true,
          iconTheme: IconThemeData(color: context.textTheme.bodyLarge!.color),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10),
                  child: Text(
                    'Please regulate issues related to prices and programs related to car rental prices'
                        .tr(),
                  ),
                ),
                Text(
                  'Base fare for self-drive car rental'.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Text('${'Monday'.tr()} - ${'Friday'.tr()}'),
                const SizedBox(height: 5),
                TextField(
                  inputFormatters: <TextInputFormatter>[
                    CurrencyTextInputFormatter.currency(
                      locale: 'vi',
                      decimalDigits: 0,
                    ),
                  ],
                  controller: widget.model.price26Controller,
                  keyboardType: TextInputType.number,
                  onChanged: (value) => print(value),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '',
                  ),
                  textInputAction: TextInputAction.next,
                  focusNode: _focusNodes[0],
                  onSubmitted: (_) {
                    _focusNodes[1].requestFocus();
                  },
                ),
                const SizedBox(height: 20),
                Text('${'Saturday'.tr()} - ${'Sunday'.tr()}'),
                const SizedBox(height: 5),
                TextField(
                  inputFormatters: <TextInputFormatter>[
                    CurrencyTextInputFormatter.currency(
                      locale: 'vi',
                      decimalDigits: 0,
                    ),
                  ],
                  controller: widget.model.price7cnController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) => print(value),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '',
                  ),
                  textInputAction: TextInputAction.next,
                  focusNode: _focusNodes[1],
                  onSubmitted: (_) {
                    _focusNodes[2].requestFocus();
                  },
                ),
                Divider(thickness: 5).pSymmetric(v: 20),
                Text(
                  'Base fare for chauffeured car rental'.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Text('${'Monday'.tr()} - ${'Friday'.tr()}'),
                const SizedBox(height: 5),
                TextField(
                  inputFormatters: <TextInputFormatter>[
                    CurrencyTextInputFormatter.currency(
                      locale: 'vi',
                      decimalDigits: 0,
                    ),
                  ],
                  controller: widget.model.price26WithDriverController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      // Thêm "/giờ" vào cuối
                      value += "/${'hour'.tr()}";
                    }
                    // Cập nhật giá trị vào TextField
                    widget.model.price26WithDriverController.value =
                        widget.model.price26WithDriverController.value.copyWith(
                      text: value,
                      selection: TextSelection.collapsed(offset: value.length),
                    );
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '',
                  ),
                  textInputAction: TextInputAction.next,
                  focusNode: _focusNodes[2],
                  onSubmitted: (_) {
                    _focusNodes[3].requestFocus();
                  },
                ),
                const SizedBox(height: 20),
                Text('${'Saturday'.tr()} - ${'Sunday'.tr()}'),
                const SizedBox(height: 5),
                TextField(
                  inputFormatters: <TextInputFormatter>[
                    CurrencyTextInputFormatter.currency(
                      locale: 'vi',
                      decimalDigits: 0,
                    ),
                  ],
                  controller: widget.model.price7cnWithDriverController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      value += "/${'hour'.tr()}";
                    }
                    // Cập nhật giá trị vào TextField
                    widget.model.price7cnWithDriverController.value = widget
                        .model.price7cnWithDriverController.value
                        .copyWith(
                      text: value,
                      selection: TextSelection.collapsed(offset: value.length),
                    );
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '',
                  ),
                  textInputAction: TextInputAction.next,
                  focusNode: _focusNodes[3],
                  onSubmitted: (_) {
                    _focusNodes[4].requestFocus();
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'Driving fee'.tr(),
                ),
                const SizedBox(height: 5),
                TextField(
                  inputFormatters: <TextInputFormatter>[
                    CurrencyTextInputFormatter.currency(
                      locale: 'vi',
                      decimalDigits: 0,
                    ),
                  ],
                  controller: widget.model.drivingFeeController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      value += "/${'hour'.tr()}";
                    }
                    // Cập nhật giá trị vào TextField
                    widget.model.drivingFeeController.value =
                        widget.model.drivingFeeController.value.copyWith(
                      text: value,
                      selection: TextSelection.collapsed(offset: value.length),
                    );
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '',
                  ),
                  textInputAction: TextInputAction.next,
                  focusNode: _focusNodes[4],
                  onSubmitted: (_) {
                    _focusNodes[5].requestFocus();
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'Price per kilometer'.tr(),
                ),
                const SizedBox(height: 5),
                TextField(
                  inputFormatters: <TextInputFormatter>[
                    CurrencyTextInputFormatter.currency(
                      locale: 'vi',
                      decimalDigits: 0,
                    ),
                  ],
                  controller: widget.model.price1kmController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      value += "/${'km'.tr()}";
                    }
                    // Cập nhật giá trị vào TextField
                    widget.model.price1kmController.value =
                        widget.model.price1kmController.value.copyWith(
                      text: value,
                      selection: TextSelection.collapsed(offset: value.length),
                    );
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '',
                  ),
                  textInputAction: TextInputAction.done,
                  focusNode: _focusNodes[5],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Discount'.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    CupertinoSwitch(
                      activeColor: AppColor.primaryColor,
                      value: showDiscount,
                      onChanged: (bool value) {
                        setState(() {
                          showDiscount = value;
                        });
                      },
                    )
                  ],
                ),
                const SizedBox(height: 20),
                showDiscount
                    ? Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              'Thuê từ 3 ngày (% giảm)'.tr().text.xl.make(),
                              upDowNumber(
                                widget.model.discountThreeDays!,
                                () {
                                  setState(() {
                                    widget.model.discountThreeDays =
                                        widget.model.discountThreeDays! - 1;
                                  });
                                },
                                () {
                                  setState(() {
                                    widget.model.discountThreeDays =
                                        widget.model.discountThreeDays! + 1;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              'Thuê từ 7 ngày (% giảm)'.tr().text.xl.make(),
                              upDowNumber(
                                widget.model.discountSevenDays!,
                                () {
                                  setState(() {
                                    widget.model.discountSevenDays =
                                        widget.model.discountSevenDays! - 1;
                                  });
                                },
                                () {
                                  setState(() {
                                    widget.model.discountSevenDays =
                                        widget.model.discountSevenDays! + 1;
                                  });
                                },
                              ),
                            ],
                          )
                        ],
                      )
                    : SizedBox(),
                widget.showNext
                    ? Padding(
                        padding: const EdgeInsets.all(10),
                        child: Container(
                            height: 50,
                            width: MediaQuery.of(context).size.width,
                            child: CustomButton(
                              title: 'next'.tr().capitalized,
                              onPressed: () {
                                if (widget.model.price26Controller.text != '' &&
                                    widget.model.price7cnController.text !=
                                        '' &&
                                    widget.model.drivingFeeController.text !=
                                        '' &&
                                    widget.model.price1kmController.text !=
                                        '' &&
                                    widget.model.price26WithDriverController
                                            .text !=
                                        '' &&
                                    widget.model.price7cnWithDriverController
                                            .text !=
                                        '') {
                                  widget.model.price26 = widget
                                      .model.price26Controller.text
                                      .replaceAll('.', '')
                                      .replaceAll('VND', '');
                                  widget.model.price7cn = widget
                                      .model.price7cnController.text
                                      .replaceAll('.', '')
                                      .replaceAll('VND', '');
                                  widget.model.price26WithDriver = widget
                                      .model.price26WithDriverController.text
                                      .replaceAll('.', '')
                                      .replaceAll('VND', '')
                                      .replaceAll('/${'hour'.tr()}', '');
                                  widget.model.price7cnWithDriver = widget
                                      .model.price7cnWithDriverController.text
                                      .replaceAll('.', '')
                                      .replaceAll('VND', '')
                                      .replaceAll('/${'hour'.tr()}', '');
                                  widget.model.drivingFee = widget
                                      .model.drivingFeeController.text
                                      .replaceAll('.', '')
                                      .replaceAll('VND', '')
                                      .replaceAll('/${'hour'.tr()}', '');
                                  widget.model.price1km = widget
                                      .model.price1kmController.text
                                      .replaceAll('.', '')
                                      .replaceAll('VND', '')
                                      .replaceAll('/${'km'.tr()}', '');
                                  if (!showDiscount) {
                                    widget.model.discountSevenDays = 0;
                                    widget.model.discountThreeDays = 0;
                                  }
                                  context.nextPage(
                                    NavigationService().addCarRentalPage(
                                      shareRideModel: widget.shareRideModel,
                                      model: widget.model,
                                      type: "rental_options",
                                    ),
                                  );
                                } else {
                                  AlertService.error(
                                    title: "Error".tr(),
                                    text: "Field is required".tr(),
                                  );
                                }
                              },
                            )),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(10),
                        child: Container(
                            height: 50,
                            width: MediaQuery.of(context).size.width,
                            child: CustomButton(
                              loading: isUpdating,
                              title: 'Completed'.tr(),
                              onPressed: () async {
                                setState(() {
                                  isUpdating = true;
                                });
                                if (widget.model.price26Controller.text != '' &&
                                    widget.model.price7cnController.text !=
                                        '' &&
                                    widget.model.drivingFeeController.text !=
                                        '' &&
                                    widget.model.price1kmController.text !=
                                        '' &&
                                    widget.model.price26WithDriverController
                                            .text !=
                                        '' &&
                                    widget.model.price7cnWithDriverController
                                            .text !=
                                        '') {
                                  widget.model.price26 = widget
                                      .model.price26Controller.text
                                      .replaceAll('.', '')
                                      .replaceAll('VND', '');
                                  widget.model.price7cn = widget
                                      .model.price7cnController.text
                                      .replaceAll('.', '')
                                      .replaceAll('VND', '');
                                  widget.model.price26WithDriver = widget
                                      .model.price26WithDriverController.text
                                      .replaceAll('.', '')
                                      .replaceAll('VND', '')
                                      .replaceAll('/${'hour'.tr()}', '');
                                  widget.model.price7cnWithDriver = widget
                                      .model.price7cnWithDriverController.text
                                      .replaceAll('.', '')
                                      .replaceAll('VND', '')
                                      .replaceAll('/${'hour'.tr()}', '');
                                  widget.model.drivingFee = widget
                                      .model.drivingFeeController.text
                                      .replaceAll('.', '')
                                      .replaceAll('VND', '')
                                      .replaceAll('/${'hour'.tr()}', '');
                                  widget.model.price1km = widget
                                      .model.price1kmController.text
                                      .replaceAll('.', '')
                                      .replaceAll('VND', '')
                                      .replaceAll('/${'km'.tr()}', '');
                                  bool checkUpdate = false;
                                  if (!showDiscount) {
                                    widget.model.discountSevenDays = 0;
                                    widget.model.discountThreeDays = 0;
                                    checkUpdate = await widget.model.updateCar(
                                      id: widget.data!.id!,
                                      rentPrice1: widget.model.price26,
                                      rentPrice2: widget.model.price7cn,
                                      discountThreeDays:
                                          widget.model.discountThreeDays,
                                      discountSevenDays:
                                          widget.model.discountSevenDays,
                                      rentPrice1WithDriver:
                                          widget.model.price26WithDriver,
                                      rentPrice2WithDriver:
                                          widget.model.price7cnWithDriver,
                                      drivingFee: widget.model.drivingFee,
                                      price1km: widget.model.price1km,
                                    );
                                    if (checkUpdate) {
                                      await AlertService.success(
                                        title: "Sửa thành công".tr(),
                                        text: "Sửa giá xe thành công".tr(),
                                      );
                                      print('Sửa thành công');
                                      Navigator.pop(context);
                                    } else {
                                      print('Sửa thất bại');
                                    }
                                  } else {
                                    checkUpdate = await widget.model.updateCar(
                                      id: widget.data!.id!,
                                      rentPrice1: widget.model.price26,
                                      rentPrice2: widget.model.price7cn,
                                      discountThreeDays:
                                          widget.model.discountThreeDays,
                                      discountSevenDays:
                                          widget.model.discountSevenDays,
                                      rentPrice1WithDriver:
                                          widget.model.price26WithDriver,
                                      rentPrice2WithDriver:
                                          widget.model.price7cnWithDriver,
                                      drivingFee: widget.model.drivingFee,
                                      price1km: widget.model.price1km,
                                    );
                                    if (checkUpdate) {
                                      await AlertService.success(
                                        title: "Sửa thành công".tr(),
                                        text: "Sửa giá xe thành công".tr(),
                                      );
                                      print('Sửa thành công');
                                      Navigator.pop(context);
                                    } else {
                                      print('Sửa thất bại');
                                    }
                                  }
                                } else {
                                  AlertService.error(
                                    title: "Error".tr(),
                                    text: "Field is required".tr(),
                                  );
                                }
                                setState(() {
                                  isUpdating = false;
                                });
                              },
                            )),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget upDowNumber(int count, Function() onDecrease, Function() onIncrease) {
    return Row(
      children: [
        Icon(
          Icons.remove,
          size: 20,
          color: count == 0 ? Colors.grey : Colors.black,
        ).onTap(() {
          if (count > 0) onDecrease();
        }),
        SizedBox(
          width: 8,
        ),
        '${count}'.text.xl2.make(),
        SizedBox(
          width: 8,
        ),
        Icon(
          Icons.add,
          size: 20,
          color: count == 100 ? Colors.grey : Colors.black,
        ).onTap(() {
          if (count < 100) onIncrease();
        }),
      ],
    );
  }
}
