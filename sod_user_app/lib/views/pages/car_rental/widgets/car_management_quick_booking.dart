import 'package:flutter/material.dart';
import 'package:sod_user/models/car_rental.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/view_models/car_management.view_model.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:sod_user/constants/app_colors.dart';

class CarManagementQuickBooking extends StatefulWidget {
  const CarManagementQuickBooking({
    super.key,
    required this.model,
    required this.data,
  });

  final CarManagementViewModel model;
  final CarRental data;
  @override
  State<CarManagementQuickBooking> createState() =>
      _CarManagementQuickBookingState();
}

class _CarManagementQuickBookingState extends State<CarManagementQuickBooking> {
  bool fastBooking = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fastBooking = widget.data.fastBooking!;
  }

  @override
  Widget build(BuildContext context) {
     return BasePage(
        showAppBar: true,
        showLeadingAction: true,
        title: 'Quick booking'.tr(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
          child: Column(children: [
            'Car rental requests from renters will be automatically accepted within the time period you set.'
                .tr()
                .text
                .make(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                'Quick booking'.tr().toUpperCase().text.make(),
                Switch(
                    activeColor: AppColor.primaryColor,
                    value: fastBooking,
                    onChanged: (value) {
                      setState(() {
                        fastBooking = value;
                      });
                    })
              ],
            ),
          ]),
        ),
        bottomNavigationBar: CustomButton(
          title: 'update'.tr(),
          loading: isLoading,
          onPressed: () async {
            setState(() {
              isLoading = true;
            });
            await widget.model.changeStatusFastBooking(
              id: widget.data.id.toString(),
              status: fastBooking ? '1' : '0',
            );
            widget.data.fastBooking = fastBooking;
            setState(() {
              isLoading = false;
            });
          },
        ).p12());
          
  }
}
