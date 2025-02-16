import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/driver_lib/constants/app_colors.dart';
import 'package:sod_user/driver_lib/models/vehicle.dart';
import 'package:sod_user/driver_lib/view_models/new_vehicle.vm.dart';
import 'package:sod_user/driver_lib/widgets/buttons/custom_button.dart';
import 'package:velocity_x/velocity_x.dart';

class AddUtilitiesPage extends StatefulWidget {
  final NewVehicleViewModel model;
  final Vehicle? data;
  const AddUtilitiesPage(
      {super.key, required this.model, this.showNext = true, this.data});
  final bool showNext;
  @override
  State<AddUtilitiesPage> createState() => _AddUtilitiesPageState();
}

class _AddUtilitiesPageState extends State<AddUtilitiesPage> {
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

  @override
  void initState() {
    super.initState();
    if (widget.model.utilities!.length == 0) {
      checkbox = List.filled(utilities.length, false);
    } else {
      checkbox = List.generate(utilities.length,
          (index) => widget.model.utilities!.contains(utilities[index]));
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    utilities[index].tr(),
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
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              child: CustomButton(
                title: 'Completed'.tr(),
                onPressed: () async {
                  List<String> utilitiesNew = [];
                  for (int i = 0; i < utilities.length; i++) {
                    if (checkbox![i]) {
                      utilitiesNew.add(utilities[i]);
                    }
                  }
                  widget.model.onUtilitiesSelected(utilitiesNew);
                  Navigator.pop(context);
                },
              )),
        ),
      ),
    );
  }
}
