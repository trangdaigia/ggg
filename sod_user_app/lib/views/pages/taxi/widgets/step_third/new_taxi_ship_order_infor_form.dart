import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:masonry_grid/masonry_grid.dart';
import 'package:sod_user/constants/app_text_styles.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/view_models/taxi.vm.dart';
import 'package:sod_user/view_models/taxi_new_order_summary.vm.dart';
import 'package:sod_user/view_models/taxi_new_ship_order_infor.vm.dart';
import 'package:sod_user/views/pages/taxi/widgets/order_taxi.button.dart';
import 'package:sod_user/views/pages/taxi/widgets/step_two/new_taxi_order_payment_method.selection_view.dart';
import 'package:sod_user/views/pages/taxi/widgets/taxi_discount_section.dart';
import 'package:sod_user/views/pages/taxi/widgets/step_two/new_taxi_order_vehicle_type.list_view.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:sod_user/widgets/buttons/custom_text_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:measure_size/measure_size.dart';
import 'package:sod_user/widgets/custom_text_form_field.dart';
import 'package:sod_user/widgets/list_items/taxi_ship_package_type.list_item.dart';
import 'package:velocity_x/velocity_x.dart';

class NewTaxiShipOrderInforForm extends StatelessWidget {
  const NewTaxiShipOrderInforForm(
    this.newTaxiShipOrderInforViewModel, {
    Key? key,
  }) : super(key: key);

  final NewTaxiShipOrderInforViewModel newTaxiShipOrderInforViewModel;

  @override
  Widget build(BuildContext context) {
    final TaxiViewModel vm = newTaxiShipOrderInforViewModel.taxiViewModel;
    return MeasureSize(
      onChange: (size) {
        vm.updateGoogleMapPadding(height: size.height + Vx.dp40);
      },
      child: Stack(children: [
        VStack(
          [
            HStack(
              [
                //previous
                CustomTextButton(
                  padding: EdgeInsets.zero,
                  title: "Back".tr(),
                  onPressed: () =>
                      newTaxiShipOrderInforViewModel.closeInforForm(),
                ).h(24),
                UiSpacer.swipeIndicator().px12().expand(),
                //cancel book
                CustomTextButton(
                  padding: EdgeInsets.zero,
                  title: "Cancel".tr(),
                  titleColor: Colors.red,
                  onPressed: vm.closeOrderSummary,
                ).h(24),
              ],
            ),
            UiSpacer.vSpace(10),
            "Package detail".tr().text.fontWeight(FontWeight.w600).make(),
            UiSpacer.vSpace(10),
            vm.shipPackagePhoto != null
                ? SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height / 4,
                    child: Image.file(
                      vm.shipPackagePhoto!,
                      fit: BoxFit.cover,
                    )).p8()
                : const SizedBox.shrink(),
            CustomButton(
              icon: Icons.image,
              title: "Add picture".tr(),
              titleStyle: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
              onPressed: () {
                newTaxiShipOrderInforViewModel.imagePickerBottomSheet(context);
              },
            ).py8().safeArea(top: false),
            UiSpacer.vSpace(10),
            VStack([
              "Approximate weight".tr().text.fontWeight(FontWeight.w600).make(),
              "Selected vehicle can take up to: 400kg".tr().text.make(),
            ]),
            UiSpacer.vSpace(10),
            HStack([
              CustomButton(
                color: Color.fromARGB(255, 228, 228, 228),
                shapeRadius: 14,
                titleStyle:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${newTaxiShipOrderInforViewModel.weightController.text != "" ? newTaxiShipOrderInforViewModel.weightController.text : "--"} kg'
                          .tr(),
                      textAlign: TextAlign.center,
                      style: AppTextStyle.h3TitleTextStyle(
                        color: Colors.black,
                      ),
                    ).centered(),
                    SizedBox(width: 5),
                    Icon(Icons.edit, color: Colors.black, size: 20),
                  ],
                ),
                onPressed: () {
                  newTaxiShipOrderInforViewModel.weightFormBottomSheet(context);
                },
              ),
            ]),
            UiSpacer.vSpace(20),
            "Package type"
                .tr()
                .text
                .fontWeight(FontWeight.w600)
                .size(16)
                .make(),
            UiSpacer.vSpace(10),
            AnimationLimiter(
                child: MasonryGrid(
              column: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 2,
              children: List.generate(
                newTaxiShipOrderInforViewModel.taxiShipPackageTypeList!.length,
                (index) {
                  return TaxiShipPackageListItem(
                    newTaxiShipOrderInforViewModel,
                    newTaxiShipOrderInforViewModel
                        .taxiShipPackageTypeList![index],
                    onPressed: () {
                      newTaxiShipOrderInforViewModel.updateTaxiShipPackageType(
                          newTaxiShipOrderInforViewModel
                              .taxiShipPackageTypeList![index]);
                    },
                  );
                },
              ),
            )),
            UiSpacer.vSpace(10),
            CustomButton(
              title: "Next".tr(),
              titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              shapeRadius: 8,
              onPressed: () {
                if (vm.selectedPackageType != null &&
                    newTaxiShipOrderInforViewModel.weightController.text !=
                        "") {
                  vm.setCurrentStep(4);
                } else {
                  VxToast.show(
                    context,
                    msg: "Please select package type and provide weight".tr(),
                    bgColor: Colors.grey[100],
                  );
                }
              },
            ).py8().safeArea(top: false),
          ],
        ).p20(),
      ])
          .box
          .color(context.theme.colorScheme.background)
          .topRounded(value: 20)
          .outerShadowXl
          .make(),
    );
  }
}
