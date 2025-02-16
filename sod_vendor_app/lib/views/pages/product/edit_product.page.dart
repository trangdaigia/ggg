import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_vendor/constants/app_colors.dart';
import 'package:sod_vendor/constants/app_text_styles.dart';
import 'package:sod_vendor/models/product.dart';
import 'package:sod_vendor/services/custom_form_builder_validator.service.dart';
import 'package:sod_vendor/utils/ui_spacer.dart';
import 'package:sod_vendor/view_models/edit_products.vm.dart';
import 'package:sod_vendor/widgets/base.page.dart';
import 'package:sod_vendor/widgets/busy_indicator.dart';
import 'package:sod_vendor/widgets/buttons/custom_button.dart';
import 'package:sod_vendor/widgets/cards/multi_image_selector.dart';
import 'package:sod_vendor/widgets/html_text_view.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class EditProductPage extends StatelessWidget {
  const EditProductPage(this.product, {Key? key}) : super(key: key);
  final Product product;
  @override
  Widget build(BuildContext context) {
    final style = AppTextStyle.h5TitleTextStyle(
      fontWeight: FontWeight.w600,
    );
    _getDecoratedInputDecoration(String labelText) {
      return InputDecoration(
        fillColor: Colors.black,
        labelText: labelText,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
      );
    }

    return ViewModelBuilder<EditProductViewModel>.reactive(
      viewModelBuilder: () => EditProductViewModel(context, product),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        return BasePage(
          showLeadingAction: true,
          showAppBar: true,
          title: "Edit Product".tr(),
          body: FormBuilder(
            key: vm.formBuilderKey,
            child: ListView(
              children: [
                //name
                FormBuilderTextField(
                  name: 'name',
                  initialValue: product.name,
                  decoration: _getDecoratedInputDecoration('Name'.tr()),
                  style: style,
                  onChanged: (value) {},
                  validator: CustomFormBuilderValidator.required,
                ),
                UiSpacer.verticalSpace(),
                //image
                MultiImageSelectorView(
                  links: product.photos,
                  onImagesSelected: vm.onImagesSelected,
                ),
                UiSpacer.verticalSpace(),
                VStack(
                  [
                    //hstack with Description text expanded and edit button
                    HStack(
                      [
                        "Description".tr().text.make().expand(),
                        CustomButton(
                          title: vm.product.description == null
                              ? "Add".tr()
                              : "Edit".tr(),
                          onPressed: vm.handleDescriptionEdit,
                          icon: vm.product.description == null
                              ? FlutterIcons.add_mdi
                              : FlutterIcons.edit_mdi,
                        ).h(30),
                      ],
                    ),
                    UiSpacer.vSpace(10),
                    //preview description
                    HtmlTextView(vm.product.description, padding: 0),
                  ],
                ).p(10).box.border().roundedSM.make(),
                UiSpacer.verticalSpace(),
                //pricing
                HStack(
                  [
                    //price
                    FormBuilderTextField(
                      name: 'price',
                      initialValue: product.price.toString(),
                      decoration: _getDecoratedInputDecoration("Price".tr()),
                      style: style,
                      onChanged: (value) {},
                      validator: (value) => CustomFormBuilderValidator.compose([
                        CustomFormBuilderValidator.required(value),
                        CustomFormBuilderValidator.numeric(value),
                      ]),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                    ).expand(),
                    UiSpacer.horizontalSpace(),
                    //Discount price
                    FormBuilderTextField(
                      name: 'discount_price',
                      decoration:
                          _getDecoratedInputDecoration("Discount Price".tr()),
                      style: style,
                      onChanged: (value) {},
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                    ).expand(),
                  ],
                ),
                //
                UiSpacer.verticalSpace(),
                //packaging
                HStack(
                  [
                    //Capacity
                    FormBuilderTextField(
                      name: 'capacity',
                      initialValue: product.capacity,
                      decoration: _getDecoratedInputDecoration("Capacity".tr()),
                      style: style,
                      onChanged: (value) {},
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                    ).expand(),
                    UiSpacer.horizontalSpace(),
                    //unit
                    FormBuilderTextField(
                      name: 'unit',
                      initialValue: product.unit,
                      decoration: _getDecoratedInputDecoration("Unit".tr()),
                      style: style,
                      onChanged: (value) {},
                    ).expand(),
                  ],
                ),
                //
                UiSpacer.verticalSpace(),
                //pricing
                HStack(
                  [
                    //package_count
                    FormBuilderTextField(
                      name: 'package_count',
                      initialValue: product.packageCount,
                      decoration:
                          _getDecoratedInputDecoration("Package Count".tr()),
                      style: style,
                      onChanged: (value) {},
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                    ).expand(),
                    UiSpacer.horizontalSpace(),
                    //available_qty
                    FormBuilderTextField(
                      name: 'available_qty',
                      initialValue: product.availableQty != null
                          ? product.availableQty.toString()
                          : "",
                      decoration:
                          _getDecoratedInputDecoration("Available Qty".tr()),
                      style: style,
                      onChanged: (value) {},
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.number,
                    ).expand(),
                  ],
                ),
                //
                UiSpacer.vSpace(10),
                HStack(
                  [
                    //deliverable
                    FormBuilderCheckbox(
                      initialValue: product.deliverable == 1,
                      name: 'deliverable',
                      onChanged: (value) {},
                      valueTransformer: (value) => (value ?? false) ? 1 : 0,
                      title: "Can be delivered".tr().text.make(),
                    ).expand(),
                    20.widthBox,
                    //Active
                    FormBuilderCheckbox(
                      initialValue: product.isActive == 1,
                      name: 'is_active',
                      onChanged: (value) {},
                      valueTransformer: (value) => (value ?? false) ? 1 : 0,
                      title: "Active".tr().text.make(),
                    ).expand(),
                  ],
                ),
                //
                UiSpacer.vSpace(10),

                //categories
                vm.busy(vm.categories)
                    ? BusyIndicator().centered()
                    : FormBuilderFilterChip<String>(
                        name: 'category_ids',
                        initialValue: product.categories
                            .map((category) => category.id.toString())
                            .toList(),
                        decoration:
                            _getDecoratedInputDecoration("Category".tr()),
                        spacing: 5,
                        // selectedColor: AppColor.primaryColor,
                        checkmarkColor: AppColor.primaryColor,
                        options: vm.categories
                            .map(
                              (category) => FormBuilderChipOption<String>(
                                value: '${category.id}',
                                child: '${category.name}'.text.make(),
                              ),
                            )
                            .toList(),
                        onChanged: vm.filterSubcategories,
                      ),
                UiSpacer.vSpace(10),
                //subcategories
                vm.busy(vm.subCategories)
                    ? BusyIndicator().centered()
                    : FormBuilderFilterChip<String>(
                        name: 'sub_category_ids',
                        initialValue: product.subCategories
                            .map((category) => category.id.toString())
                            .toList(),
                        decoration:
                            _getDecoratedInputDecoration("Sub-Category".tr()),
                        spacing: 5,
                        selectedColor: AppColor.primaryColor,
                        options: vm.subCategories
                            .map(
                              (category) => FormBuilderChipOption<String>(
                                value: '${category.id}',
                                child: Text('${category.name}'),
                              ),
                            )
                            .toList(),
                        valueTransformer: (newValue) {
                          if (newValue == null || newValue.isEmpty) {
                            return [];
                          }
                          //make the value a list of int
                          return newValue
                              .map((value) => int.parse(value))
                              .toList();
                        },
                      ),
                UiSpacer.verticalSpace(),
                //menus
                vm.busy(vm.menus)
                    ? BusyIndicator().centered()
                    : FormBuilderFilterChip(
                        name: 'menu_ids',
                        initialValue: product.menus
                            .map((menu) => menu.id.toString())
                            .toList(),
                        decoration:
                            _getDecoratedInputDecoration("Menus".tr()),
                        spacing: 5,
                        selectedColor: AppColor.primaryColor,
                        options: vm.menus
                            .map(
                              (menu) => FormBuilderChipOption<String>(
                                value: '${menu.id}',
                                child: Text('${menu.name}'),
                              ),
                            )
                            .toList(),
                      ),
                UiSpacer.verticalSpace(),
                //
                CustomButton(
                  title: "Save Product".tr(),
                  loading: vm.isBusy,
                  onPressed: vm.processUpdateProduct,
                ).centered().py12(),
              ],
            ),
          ).px20().pOnly(bottom: context.mq.viewInsets.bottom),
        );
      },
    );
  }
}
