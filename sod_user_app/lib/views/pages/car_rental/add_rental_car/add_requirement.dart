import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/models/car_rental.dart';
import 'package:sod_user/services/alert.service.dart';
import 'package:sod_user/view_models/car_management.view_model.dart';
import 'package:sod_user/view_models/shared_ride.vm.dart';
import 'package:sod_user/views/pages/shared_ride/post_ride_info.page.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';

class AddRequirementPage extends StatefulWidget {
  final CarManagementViewModel model;
  const AddRequirementPage(
      {super.key,
      required this.model,
      this.showNext = true,
      this.data,
      this.shareRideModel});
  final bool showNext;
  final CarRental? data;
  final SharedRideViewModel? shareRideModel;

  @override
  State<AddRequirementPage> createState() => _AddRequirementPageState();
}

class _AddRequirementPageState extends State<AddRequirementPage> {
  List<String> requirement = ["Giấy CMND/CCCD", "Giấy phép lái xe", "Hộ chiếu"];
  List<bool>? checkbox;
  bool loadingAddCar = false;
  @override
  void initState() {
    if (widget.data == null) {
      checkbox = List<bool>.filled(requirement.length, true);
    } else {
      checkbox = List.generate(
          requirement.length,
          (index) =>
              widget.data!.requirementsForRent!.contains(requirement[index]));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    widget.model.requirements = [];
    return SafeArea(
        child: Scaffold(
      backgroundColor: AppColor.onboarding3Color,
      appBar: AppBar(
        backgroundColor: context.backgroundColor,
        title: Text("Documents when renting".tr(),
            style: TextStyle(color: context.textTheme.bodyLarge!.color)),
        centerTitle: true,
        iconTheme: IconThemeData(color: context.textTheme.bodyLarge!.color),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Please describe the necessary procedures that you want to prescribe for customers to rent this car'
                  .tr(),
            ),
            ListView.separated(
              itemCount: requirement.length,
              separatorBuilder: (context, index) => Divider(),
              shrinkWrap: true,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () {
                  setState(() {
                    checkbox?[index] = !(checkbox?[index] ?? false);
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      requirement[index].tr(),
                      style: TextStyle(fontSize: 16),
                    ),
                    Checkbox(
                      value: checkbox?[index],
                      onChanged: (value) {
                        setState(() {
                          checkbox?[index] = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ).expand(),
            widget.showNext
                ? Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    child: CustomButton(
                      title: 'next'.tr().capitalized,
                      loading: loadingAddCar,
                      onPressed: () {
                        setState(() {
                          loadingAddCar = true;
                        });
                        for (int i = 0; i < requirement.length; i++) {
                          if (checkbox?[i] == true) {
                            widget.model.requirements?.add(requirement[i]);
                          }
                        }
                        widget.model
                            .addCarRental(
                          carModelId: widget.model.carModelId!,
                          color: widget.model.colorController.text,
                          longitude: widget.model.longitude.toString(),
                          latitude: widget.model.latitude.toString(),
                          regNo: widget.model.regNoController.text,
                          rentPrice1: widget.model.price26 ?? '',
                          rentPrice2: widget.model.price7cn ?? '',
                          rentPrice1WithDriver:
                              widget.model.price26WithDriver ?? '',
                          rentPrice2WithDriver:
                              widget.model.price7cnWithDriver ?? '',
                          drivingFee: widget.model.drivingFee ?? '',
                          price1km: widget.model.price1km ?? '',
                          requirementsForRent: widget.model.requirements ?? [],
                          utilities: widget.model.utilities ?? [],
                          vehicleTypeId: '1',
                          yearMade: widget.model.yearMadeController.text,
                          photo: widget.model.newPhotos!,
                          discountSevenDays: widget.model.discountSevenDays!,
                          discountThreeDays: widget.model.discountThreeDays!,
                          rental_options: widget.model.rental_options!,
                          rangeOfVehicle:
                              widget.model.rangeOfVehicleController.text,
                        )
                            .then((value) {
                          if (value == true) {
                            widget.model.avatar = null;
                            Navigator.pop(context);
                            Navigator.pop(context);
                            Navigator.pop(context);
                            Navigator.pop(context);
                            Navigator.pop(context);
                            Navigator.pop(context);
                            Navigator.pop(context);
                            if (widget.shareRideModel != null) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PostRideInfoPage(
                                          model: widget.shareRideModel!)));
                            }
                            AlertService.success(
                              title: "Success".tr(),
                              text: "Car added successfully".tr(),
                            );
                          } else {
                            AlertService.error(
                              title: "Error".tr(),
                              text: "Car added unsuccessfully".tr(),
                            );
                          }
                          setState(() {
                            loadingAddCar = false;
                          });
                        });
                      },
                    ))
                : Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    child: CustomButton(
                      title: 'Completed'.tr(),
                      loading: loadingAddCar,
                      onPressed: () async {
                        setState(() {
                          loadingAddCar = true;
                        });
                        List<String> requirementNew = [];
                        for (int i = 0; i < checkbox!.length; i++) {
                          if (checkbox![i]) {
                            requirementNew.add(requirement[i]);
                          }
                        }
                        bool checkUpdate = false;
                        checkUpdate = await widget.model.updateCar(
                            id: widget.data!.id!,
                            requirementsForRent: requirementNew);
                        if (checkUpdate) {
                          await AlertService.success(
                            title: "Sửa thành công".tr(),
                            text: "Sửa yêu cầu cho thuê thành công".tr(),
                          );
                          widget.data!.requirementsForRent = requirementNew;
                          print('Sửa thành công');
                          Navigator.pop(context);
                        } else {
                          print('Sửa thất bại');
                        }
                        setState(() {
                          loadingAddCar = false;
                        });
                      },
                    )),
          ],
        ),
      ),
    ));
  }
}
