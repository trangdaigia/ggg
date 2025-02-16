import 'package:flutter/material.dart';
import 'package:sod_user/models/car_rental.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/view_models/car_management.view_model.dart';
import 'package:sod_user/widgets/busy_indicator.dart';
import 'package:sod_user/widgets/buttons/global_button.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:sod_user/constants/app_colors.dart';

class CarManagementRentalStatus extends StatefulWidget {
  const CarManagementRentalStatus({
    super.key,
    required this.model,
    required this.data,
  });

  final CarManagementViewModel model;
  final CarRental data;
  @override
  State<CarManagementRentalStatus> createState() =>
      _CarManagementRentalStatusState();
}

class _CarManagementRentalStatusState extends State<CarManagementRentalStatus> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      title: 'Car rental status'.tr(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
        child: Column(children: [
          "Set the vehicle's operating status to active mode or not"
              .tr()
              .text
              .align(TextAlign.start)
              .make()
              .wFull(context),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              'Change rental car status'
                  .tr()
                  .text
                  .bold
                  .make()
                  .pOnly(top: 10, bottom: 10),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              'Operating status'.tr().text.make(),
              isLoading
                  ? BusyIndicator().p(16)
                  : Switch(
                      value: widget.data.rentStatus == 1 ? true : false,
                      onChanged: (value) async {
                        setState(() {
                          isLoading = true;
                        });
                        bool success = await widget.model.changeStatusCarRental(
                          id: widget.data.id.toString(),
                          status: value == true ? "1" : "0",
                        );
                        if (success) {
                          setState(() {
                            widget.data.rentStatus = value == true ? 1 : 0;
                          });
                        }
                        setState(() {
                          isLoading = false;
                        });
                      },
                    )
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              'Delete rental car'.tr().text.make(),
              IconButton(
                  onPressed: () async {
                    return showDialog(
                      context: context,
                      useSafeArea: true,
                      builder: (context) => AlertDialog(
                        title: Text('delete_warning'.tr()),
                        actions: [
                          Row(
                            children: [
                              Expanded(
                                child: GlobalButton.buildButton(
                                  context,
                                  title: 'Yes'.tr(),
                                  btnColor: AppColor.primaryColor,
                                  txtColor: Colors.white,
                                  onPress: () {
                                    widget.model.deleteCar(
                                      id: widget.data.id.toString(),
                                    );
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: GlobalButton.buildButton(
                                  context,
                                  title: 'No'.tr(),
                                  btnColor: Colors.red,
                                  txtColor: Colors.white,
                                  onPress: () => Navigator.pop(context),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                  icon: Icon(Icons.delete))
            ],
          ),
        ]),
      ),
    );
  }
}
