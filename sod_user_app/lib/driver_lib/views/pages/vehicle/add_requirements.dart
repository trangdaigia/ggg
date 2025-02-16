import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/driver_lib/constants/app_colors.dart';
import 'package:sod_user/driver_lib/models/vehicle.dart';
import 'package:sod_user/driver_lib/view_models/new_vehicle.vm.dart';
import 'package:sod_user/driver_lib/widgets/buttons/custom_button.dart';
import 'package:velocity_x/velocity_x.dart';

class AddRequirementsPage extends StatefulWidget {
  final NewVehicleViewModel model;
  final Vehicle? data;
  const AddRequirementsPage(
      {super.key, required this.model, this.showNext = true, this.data});
  final bool showNext;
  @override
  State<AddRequirementsPage> createState() => _AddRequirementsPageState();
}

class _AddRequirementsPageState extends State<AddRequirementsPage> {
  List<String> requirement = ["Giấy CMND/CCCD", "Giấy phép lái xe", "Hộ chiếu"];

  List<bool>? checkbox = [];

  @override
  void initState() {
    super.initState();
    if (widget.model.utilities!.length == 0) {
      checkbox = List.filled(requirement.length, false);
    } else {
      checkbox = List.generate(requirement.length,
          (index) => widget.model.requirements!.contains(requirement[index]));
    }
  }

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView.separated(
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
                  List<String> newRequirement = [];
                  for (int i = 0; i < requirement.length; i++) {
                    if (checkbox![i]) {
                      newRequirement.add(requirement[i]);
                    }
                  }
                  widget.model.onRequirementSelected(newRequirement);
                  Navigator.pop(context);
                },
              )),
        ),
      ),
    );
  }
}
