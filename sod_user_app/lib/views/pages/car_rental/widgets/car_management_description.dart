import 'package:flutter/material.dart';
import 'package:sod_user/models/car_rental.dart';
import 'package:sod_user/services/alert.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/view_models/car_management.view_model.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:velocity_x/velocity_x.dart';

class CarManagementDescription extends StatefulWidget {
  const CarManagementDescription({
    super.key,
    required this.model,
    required this.data,
  });

  final CarManagementViewModel model;
  final CarRental data;
  @override
  State<CarManagementDescription> createState() =>
      _CarManagementDescriptionState();
}

class _CarManagementDescriptionState extends State<CarManagementDescription> {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      title: 'Vehicle description'.tr(),
      showLeadingAction: true,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
        child: Column(children: [
          'Please tell us a few words about your rental car. This will help customers understand and make choices easier'
              .tr()
              .text
              .make(),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              'Vehicle description'.tr().text.semiBold.make().pOnly(top: 10, bottom: 10),
            ],
          ),
          TextFormField(
            maxLines: 4,
            controller: widget.model.describeController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          CustomButton(
            title: 'update'.tr(),
            onPressed: () async {
              bool checkUpdate;
              checkUpdate = await widget.model.updateCar(
                id: widget.data.id!,
                describe: widget.model.describeController.text,
              );
              if (checkUpdate) {
                await AlertService.success(
                  title: "Cập nhật mô tả xe thành công".tr(),
                );
              } else {
                await AlertService.error(
                  title: "Cập nhật mô tả xe thất bại".tr(),
                );
              }
            },
          ),
        ]),
      ),
    );
  }
}
