import 'package:flutter/material.dart';
import 'package:sod_user/models/car_rental.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/services/alert.service.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/view_models/car_management.view_model.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:sod_user/constants/app_colors.dart';

class CarManagementDelivery extends StatefulWidget {
  const CarManagementDelivery({
    super.key,
    required this.model,
    required this.data,
  });

  final CarManagementViewModel model;
  final CarRental data;
  @override
  State<CarManagementDelivery> createState() => _CarManagementDeliveryState();
}

class _CarManagementDeliveryState extends State<CarManagementDelivery> {
  bool deliveryToHome = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    deliveryToHome = widget.data.deliveryToHome!;
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
        showAppBar: true,
        showLeadingAction: true,
        title: 'Car delivery'.tr(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                'Car delivery'.tr().text.make(),
                Switch(
                    activeColor: AppColor.primaryColor,
                    value: deliveryToHome,
                    onChanged: (value) {
                      setState(() {
                        deliveryToHome = value;
                      });
                    })
              ],
            ),
            deliveryToHome
                ? Column(
                    children: [
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              'Deliver the car to your door within'.tr().text.make(),
                              '${widget.data.deliveryDistance} km'.text.make()
                            ],
                          ),
                          Slider(
                            inactiveColor: Colors.grey.shade300,
                            activeColor: AppColor.primaryColor,
                            thumbColor: Colors.white,
                            value: double.parse(
                                widget.data.deliveryDistance.toString()),
                            min: 0,
                            max: 60,
                            onChanged: (newValue) {
                              setState(() {
                                widget.data.deliveryDistance =
                                    int.parse(newValue.round().toString());
                              });
                            },
                            divisions: 100,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              'Car delivery fee (2 ways)'.tr().text.make(),
                              '${widget.data.deliveryFee == 0 ? 'Free'.tr() : '${(widget.data.deliveryFee! / 1000).round()} K/km'}'
                                  .text
                                  .make()
                            ],
                          ),
                          Slider(
                            inactiveColor: Colors.grey.shade300,
                            activeColor: AppColor.primaryColor,
                            thumbColor: Colors.white,
                            value: double.parse(
                                (widget.data.deliveryFee! / 1000).toString()),
                            min: 0,
                            max: 30,
                            onChanged: (newValue) {
                              setState(() {
                                widget.data.deliveryFee = int.parse(
                                    (newValue * 1000).round().toString());
                              });
                            },
                            divisions: 100,
                          ),
                        ],
                      ).pOnly(top: 20),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              'Free vehicle delivery within'
                                  .tr()
                                  .text
                                  .make(),
                              '${widget.data.deliveryFree} km'.text.make()
                            ],
                          ),
                          Slider(
                            inactiveColor: Colors.grey.shade300,
                            activeColor: AppColor.primaryColor,
                            thumbColor: Colors.white,
                            value: double.parse(
                                widget.data.deliveryFree.toString()),
                            min: 0,
                            max: 50,
                            onChanged: (newValue) {
                              setState(() {
                                widget.data.deliveryFree =
                                    int.parse(newValue.round().toString());
                              });
                            },
                            divisions: 100,
                          ),
                        ],
                      ).pOnly(top: 20),
                    ],
                  ).pOnly(top: 20)
                : SizedBox()
          ]),
        ),
        bottomNavigationBar: CustomButton(
          title: 'update'.tr(),
          loading: isLoading,
          onPressed: () async {
            bool notification = false;
            setState(() {
              isLoading = true;
            });
            if (deliveryToHome != widget.data.deliveryToHome) {
              await widget.model.changeStatusDeliveryToHome(
                id: widget.data.id.toString(),
                status: deliveryToHome ? '1' : '0',
              );
              notification = !notification;
            }
            if (deliveryToHome) {
              bool check = await widget.model.updateCar(
                id: widget.data.id!,
                deliveryDistance: widget.data.deliveryDistance,
                deliveryFee: widget.data.deliveryFee!,
                deliveryFree: widget.data.deliveryFree!,
              );
              if (check && !notification) {
                await AlertService.success(
                  title: "Cập nhật giao xe tận nơi thành công".tr(),
                );
              } else if (!check && !notification) {
                await AlertService.error(
                  title: "Cập nhật giao xe tận nơi không thành công".tr(),
                );
              }
            }
            widget.data.deliveryToHome = deliveryToHome;
            setState(() {
              isLoading = false;
            });
          },
        ).p12());
  }
}
