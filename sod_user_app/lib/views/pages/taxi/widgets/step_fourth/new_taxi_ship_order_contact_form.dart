import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:masonry_grid/masonry_grid.dart';
import 'package:sod_user/services/validator.service.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/view_models/taxi.vm.dart';
import 'package:sod_user/view_models/taxi_new_order_summary.vm.dart';
import 'package:sod_user/view_models/taxi_new_ship_order_contact.vm.dart';
import 'package:sod_user/view_models/taxi_new_ship_order_infor.vm.dart';
import 'package:sod_user/views/pages/taxi/widgets/order_taxi.button.dart';
import 'package:sod_user/views/pages/taxi/widgets/step_two/new_taxi_order_payment_method.selection_view.dart';
import 'package:sod_user/views/pages/taxi/widgets/taxi_discount_section.dart';
import 'package:sod_user/views/pages/taxi/widgets/step_two/new_taxi_order_vehicle_type.list_view.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:sod_user/widgets/buttons/custom_text_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:measure_size/measure_size.dart';
import 'package:sod_user/widgets/buttons/custom_toggle_buttons.dart';
import 'package:sod_user/widgets/custom_text_form_field.dart';
import 'package:sod_user/widgets/custom_checkbox.dart';

import 'package:sod_user/widgets/list_items/taxi_ship_package_type.list_item.dart';
import 'package:velocity_x/velocity_x.dart';

class NewTaxiShipOrderContactForm extends StatelessWidget {
  const NewTaxiShipOrderContactForm(
    this.newTaxiShipOrderContactViewModel, {
    Key? key,
  }) : super(key: key);

  final NewTaxiShipOrderContactViewModel newTaxiShipOrderContactViewModel;

  @override
  Widget build(BuildContext context) {
    final TaxiViewModel vm = newTaxiShipOrderContactViewModel.taxiViewModel;
    vm.addressController.text = vm.dropoffLocationTEC.text;
    return MeasureSize(
      onChange: (size) {
        vm.updateGoogleMapPadding(height: size.height + Vx.dp40);
      },
      child: Container(
        child: Stack(children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: VStack([
                HStack(
                  [
                    //previous
                    CustomTextButton(
                      padding: EdgeInsets.zero,
                      title: "Back".tr(),
                      onPressed: () =>
                          newTaxiShipOrderContactViewModel.closeContactform(),
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
                "Receiver".tr().text.fontWeight(FontWeight.w600).make(),
                UiSpacer.vSpace(10),
                "Address *".tr().text.make(),
                CustomTextFormField(
                  isReadOnly: true,
                  keyboardType: TextInputType.text,
                  textEditingController: vm.addressController,
                  validator: FormValidator.validateEmpty,
                ),
                UiSpacer.vSpace(10),
                "Floor number or building number".tr().text.make(),
                CustomTextFormField(
                  keyboardType: TextInputType.text,
                  textEditingController:
                      vm.floorNumberOrBuildingNumberController,
                  validator: FormValidator.validateEmpty,
                ),
                UiSpacer.vSpace(10),
                "Contact name *".tr().text.make(),
                CustomTextFormField(
                  onChanged: (value) {
                    newTaxiShipOrderContactViewModel.textformOnChange();
                  },
                  onTap: () {
                    newTaxiShipOrderContactViewModel
                        .showContactsDialog(context);
                  },
                  keyboardType: TextInputType.text,
                  textEditingController: vm.contactName,
                  validator: FormValidator.validateEmpty,
                ),
                UiSpacer.vSpace(10),
                "Contact number *".tr().text.make(),
                CustomTextFormField(
                  onChanged: (value) {
                    newTaxiShipOrderContactViewModel.textformOnChange();
                  },
                  onTap: () {
                    newTaxiShipOrderContactViewModel
                        .showContactsDialog(context);
                  },
                  keyboardType: TextInputType.phone,
                  textEditingController: vm.contactNumber,
                  validator: FormValidator.validateEmpty,
                ),
                UiSpacer.vSpace(10),
                "Note for driver".tr().text.make(),
                CustomTextFormField(
                  keyboardType: TextInputType.text,
                  textEditingController: vm.noteForDriver,
                  validator: FormValidator.validateEmpty,
                ),
                HStack(
                  [
                    CustomCheckbox(
                      twoWay: vm.twoWay,
                      onChanged: (){
                        bool oldValueTwoWay = vm.twoWay;
                        vm.twoWay = vm.twoWay == true ? false : true;
                        if (vm.twoWay != oldValueTwoWay){
                          vm.calculateTotalAmount();
                        }
                      },
                    ),
                    "Two-way delivery".tr().text.make(),
                  ],
                  alignment: MainAxisAlignment.start,
                ),
                UiSpacer.vSpace(10),
                vm.addressController.text.isEmpty ||
                        vm.contactName.text.isEmpty ||
                        vm.contactNumber.text.isEmpty
                    ? OrderTaxiButton(vm).disabled(true)
                    : OrderTaxiButton(vm),
              ]).p20(),
            ),
          ),
        ])
            .h(700)
            .box
            .color(context.theme.colorScheme.background)
            .topRounded(value: 20)
            .outerShadowXl
            .make(),
      ),
    );
  }
}
