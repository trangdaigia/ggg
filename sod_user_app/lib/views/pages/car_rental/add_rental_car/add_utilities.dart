import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/models/car_rental.dart';
import 'package:sod_user/services/alert.service.dart';
import 'package:sod_user/services/navigation.service.dart';
import 'package:sod_user/view_models/car_management.view_model.dart';
import 'package:sod_user/view_models/shared_ride.vm.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:velocity_x/velocity_x.dart';

class AddUtilitiesPage extends StatefulWidget {
  final CarManagementViewModel model;
  final CarRental? data;
  const AddUtilitiesPage({
    super.key,
    required this.model,
    this.showNext = true,
    this.data,
    this.shareRideModel,
    this.index,
  });

  final bool showNext;
  final SharedRideViewModel? shareRideModel;
  final int? index;

  @override
  State<AddUtilitiesPage> createState() => _AddUtilitiesPageState();
}

class _AddUtilitiesPageState extends State<AddUtilitiesPage> {
  // final List<String> utilities = [
  //   "Camera journey",
  //   "Reverse camera",
  //   "Sunroof",
  //   "Navigation map",
  //   "Collision sensor",
  //   "Wifi",
  //   "Bluetooth",
  //   "USB slot",
  //   "GPS positioning",
  //   "VietMap map",
  //   "Camera 360",
  //   "Safety airbags",
  //   "Android screen",
  //   "Speed warning",
  //   "Spare tire",
  // ];

  // API trả về tiếng Việt nên dùng tiếng Việt
  final List<String> utilities = [
    "Camera hành trình",
    "Camera lùi",
    "Cửa sổ trời",
    "Bản đồ chỉ đường",
    "Cảm biến va chạm",
    "Wifi",
    "Bluetooth",
    "Khe cắm USB",
    "Định vị GPS",
    "Bản đồ VietMap",
    "Camera 360",
    "Túi khí an toàn",
    "Màn hình Android",
    "Cảnh báo tốc độ",
    "Lốp xe dự phòng",
  ];
  List<bool>? checkbox = [];
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    if (widget.data == null) {
      checkbox = List<bool>.filled(utilities.length, false);
    } else {
      checkbox = List.generate(
          utilities.length,
          (index) => widget.model.carRental[widget.index!].utilites!
              .contains(utilities[index]));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColor.onboarding3Color,
        appBar: AppBar(
          backgroundColor: context.backgroundColor,
          title: Text("Vehicle amenities".tr(),
              style: TextStyle(color: context.textTheme.bodyLarge!.color)),
          centerTitle: true,
          iconTheme: IconThemeData(color: context.textTheme.bodyLarge!.color),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView.separated(
            itemCount: utilities.length,
            separatorBuilder: (context, index) => Divider(),
            shrinkWrap: true,
            itemBuilder: (context, index) => GestureDetector(
              onTap: () {
                setState(() {
                  checkbox?[index] = !(checkbox?[index] ?? false);
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Checkbox(
                    value: checkbox?[index],
                    onChanged: (value) {
                      setState(() {
                        checkbox?[index] = value!;
                      });
                    },
                  ),
                  Text(
                    utilities[index].tr(),
                    style: TextStyle(fontSize: 16),
                  ).expand(),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: widget.showNext
            ? Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    child: CustomButton(
                      title: 'next'.tr().capitalized,
                      onPressed: () {
                        widget.model.utilities?.clear();
                        for (int i = 0; i < utilities.length; i++) {
                          if (checkbox?[i] == true) {
                            widget.model.utilities?.add(utilities[i]);
                          }
                        }
                        context.nextPage(
                          NavigationService().addCarRentalPage(
                            shareRideModel: widget.shareRideModel,
                            model: widget.model,
                            type: "choose_photo",
                          ),
                        );
                      },
                    )),
              )
            : Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    child: CustomButton(
                      title: 'Completed'.tr(),
                      loading: isUpdating,
                      onPressed: () async {
                        setState(() {
                          isUpdating = true;
                        });
                        List<String> utilitiesNew = [];
                        for (int i = 0; i < utilities.length; i++) {
                          if (checkbox![i]) {
                            utilitiesNew.add(utilities[i]);
                          }
                        }
                        bool checkUpdate = false;
                        checkUpdate = await widget.model.updateCar(
                            id: widget.data!.id!, utilities: utilitiesNew);
                        if (checkUpdate) {
                          await AlertService.success(
                            title: "Sửa thành công".tr(),
                            text: "Sửa tiện ích xe thành công".tr(),
                          );
                          // cập nhật lại danh sách tiện ích local
                          widget.model.carRental[widget.index!].utilites =
                              utilitiesNew;
                          print('Sửa thành công');
                          Navigator.pop(context);
                        } else {
                          print('Sửa thất bại');
                        }
                        setState(() {
                          isUpdating = false;
                        });
                      },
                    )),
              ),
      ),
    );
  }
}
