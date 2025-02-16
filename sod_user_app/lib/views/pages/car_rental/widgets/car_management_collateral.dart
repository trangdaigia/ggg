import 'package:flutter/material.dart';
import 'package:sod_user/models/car_rental.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/view_models/car_management.view_model.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:sod_user/constants/app_colors.dart';

class CarManagementCollateral extends StatefulWidget {
  const CarManagementCollateral({
    super.key,
    required this.model,
    required this.data,
  });

  final CarManagementViewModel model;
  final CarRental data;
  @override
  State<CarManagementCollateral> createState() =>
      _CarManagementCollateralState();
}

class _CarManagementCollateralState extends State<CarManagementCollateral> {
  bool mortgageExemption = false;
  bool isLoading = false;

  initState() {
    super.initState();
    mortgageExemption = !widget.data.mortgageExemption!;
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
        showAppBar: true,
        showLeadingAction: true,
        title: 'Collateral'.tr(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                'Collateral setup required when renting a car.'
                    .tr()
                    .text
                    .make(),
              ],
            ).pOnly(bottom: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 1.5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      '15 million VND (cash/transfer to owner upon receiving vehicle) or Motorcycle (with original registration) worth 15 million VND'
                          .tr()
                          .text
                          .color(Colors.grey)
                          .make(),
                    ],
                  ),
                ),
                Switch(
                    activeColor: AppColor.primaryColor,
                    value: mortgageExemption,
                    onChanged: (value) {
                      setState(() {
                        mortgageExemption = value;
                      });
                    })
              ],
            ),
          ]),
        ),
        bottomNavigationBar: CustomButton(
          loading: isLoading,
          title: 'update'.tr(),
          onPressed: () async {
            setState(() {
              isLoading = true;
            });
            await widget.model.changeStatusMortgageExemption(
              id: widget.data.id.toString(),
              status: mortgageExemption ? '0' : '1',
            );
            widget.data.mortgageExemption = !mortgageExemption;
            setState(() {
              isLoading = false;
            });
          },
        ).p(12));
  }
}
