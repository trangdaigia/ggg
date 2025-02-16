import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_user/driver_lib/constants/app_page_settings.dart';
import 'package:sod_user/driver_lib/models/vehicle.dart';
import 'package:sod_user/driver_lib/services/custom_form_builder_validator.service.dart';
import 'package:sod_user/driver_lib/utils/ui_spacer.dart';
import 'package:sod_user/driver_lib/view_models/new_vehicle.vm.dart';
import 'package:sod_user/driver_lib/widgets/base.page.dart';
import 'package:sod_user/driver_lib/widgets/buttons/custom_button.dart';
import 'package:sod_user/driver_lib/widgets/cards/document_selection.view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';

class DetailVehiclePage extends StatefulWidget {
  const DetailVehiclePage({
    Key? key,
    required this.vehicle,
  }) : super(key: key);
  final Vehicle vehicle;
  @override
  State<DetailVehiclePage> createState() => _DetailVehiclePageState();
}

class _DetailVehiclePageState extends State<DetailVehiclePage> {
  bool showDiscount = false;
  bool fastBooking = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //
    final inputDec = InputDecoration(
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
          color: AppColor.cancelledColor,
        )),
        focusedBorder: OutlineInputBorder(
            //Chỉnh màu cho border khi nhấn vào
            borderSide: BorderSide(
          color: AppColor.cancelledColor,
          //
        )),
        //Đổi cỡ chữ hintText
        hintStyle: AppTextStyle.hintStyle()
        //
        );
    final style = AppTextStyle.h5TitleTextStyle(
      color: Theme.of(context).textTheme.bodyLarge!.color,
      fontWeight: FontWeight.w600,
    );
    final labelStyle = AppTextStyle.h5TitleTextStyle(
        color: Theme.of(context).textTheme.bodyLarge!.color,
        fontWeight: FontWeight.w600);
    return ViewModelBuilder<NewVehicleViewModel>.reactive(
      viewModelBuilder: () => NewVehicleViewModel(context),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        return BasePage(
          showAppBar: true,
          showLeadingAction: true,
          title: "Service details".tr(),
          body: vm.isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : FormBuilder(
                  key: vm.formBuilderKey,
                  child: VStack(
                    [
                      "Service details".tr().text.semiBold.xl.make().py12(),
                      UiSpacer.vSpace(10),
                      FormBuilderTextField(
                        name: "service_type",
                        decoration: inputDec.copyWith(
                          prefixIcon: Icon(
                            MaterialIcons.directions_car,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                          labelText: widget.vehicle.service?.name ?? "",
                          labelStyle: labelStyle,
                        ),
                        style: style,
                        enabled: false,
                      ),
                      FormBuilderTextField(
                        initialValue: widget.vehicle.vehicleType!.name,
                        readOnly: true,
                        name: "vehicletype",
                        validator: CustomFormBuilderValidator.required,
                        decoration: inputDec.copyWith(
                          prefixIcon: Icon(
                            MaterialIcons.directions_car,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                          labelText: "Vehicle Type".tr(),
                          labelStyle: labelStyle,
                        ),
                        style: style,
                        textInputAction: TextInputAction.next,
                      ),
                      ...((widget.vehicle.service?.slug == "rental driver")
                          ? [const SizedBox()]
                          : [
                              FormBuilderTextField(
                                initialValue:
                                    widget.vehicle.carModel?.carMake?.name ??
                                        '',
                                //readOnly: true,
                                name: "carmake",
                                validator: CustomFormBuilderValidator.required,
                                decoration: inputDec.copyWith(
                                  prefixIcon: Icon(
                                    MaterialIcons.directions_car,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color,
                                  ),
                                  labelText: "Car Make".tr(),
                                  labelStyle: labelStyle,
                                ),
                                style: style,
                                textInputAction: TextInputAction.next,
                              ).py20(),
                              FormBuilderTextField(
                                initialValue:
                                    widget.vehicle.carModel?.name ?? '',
                                //readOnly: true,
                                name: "carmodel",
                                validator: CustomFormBuilderValidator.required,
                                decoration: inputDec.copyWith(
                                  prefixIcon: Icon(
                                    MaterialIcons.directions_car,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color,
                                  ),
                                  labelText: "Car Model".tr(),
                                  labelStyle: labelStyle,
                                ),
                                style: style,
                                textInputAction: TextInputAction.next,
                              ),
                              FormBuilderTextField(
                                initialValue: vm
                                    .getVendorTypeById(widget
                                        .vehicle.vehicleType!.vendorTypeId!)
                                    .tr(),
                                readOnly: true,
                                name: "vehicleclass",
                                validator: CustomFormBuilderValidator.required,
                                decoration: inputDec.copyWith(
                                  prefixIcon: Icon(
                                    MaterialIcons.directions_car,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color,
                                  ),
                                  labelText: "Vehicle Classification".tr(),
                                  labelStyle: labelStyle,
                                ),
                                style: style,
                                textInputAction: TextInputAction.next,
                              ).py20(),
                              FormBuilderTextField(
                                initialValue: widget.vehicle.regNo,
                                readOnly: true,
                                name: "reg_no",
                                validator: CustomFormBuilderValidator.required,
                                decoration: inputDec.copyWith(
                                  prefixIcon: Icon(
                                    MaterialIcons.format_list_numbered,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color,
                                  ),
                                  hintText:
                                      "Enter your registration number".tr(),
                                  labelText: "Registration Number".tr(),
                                  labelStyle: labelStyle,
                                ),
                                style: style,
                                textInputAction: TextInputAction.next,
                              ).py20(),
                              FormBuilderTextField(
                                initialValue: widget.vehicle.color,
                                readOnly: true,
                                name: "color",
                                validator: CustomFormBuilderValidator.required,
                                decoration: inputDec.copyWith(
                                  prefixIcon: Icon(
                                    Icons.color_lens_outlined,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color,
                                  ),
                                  labelText: "Color".tr(),
                                  labelStyle: labelStyle,
                                ),
                                style: style,
                                textInputAction: TextInputAction.next,
                              ),
                            ]),

                      // FormBuilderTextField(
                      //   inputFormatters: <TextInputFormatter>[
                      //     CurrencyTextInputFormatter(
                      //       locale: 'vi',
                      //       decimalDigits: 0,
                      //     ),
                      //   ],
                      //   controller: vm.carPrice1TEC,
                      //   name: "price1",
                      //   keyboardType: TextInputType.number,
                      //   validator: CustomFormBuilderValidator.required,
                      //   decoration: inputDec.copyWith(
                      //     prefixIcon: Icon(
                      //       MaterialIcons.attach_money,
                      //       color: Theme.of(context).textTheme.bodyLarge!.color,
                      //     ),
                      //     hintText:
                      //         "${'Price'.tr()} ${'Monday'.tr()} - ${'Friday'.tr()}"
                      //             .toLowerCase()
                      //             .capitalized,
                      //     labelText: "${'Monday'.tr()} - ${'Friday'.tr()}",
                      //     labelStyle: labelStyle,
                      //   ),
                      //   style: style,
                      //   textInputAction: TextInputAction.next,
                      // ).py20(),
                      // FormBuilderTextField(
                      //   inputFormatters: <TextInputFormatter>[
                      //     CurrencyTextInputFormatter(
                      //       locale: 'vi',
                      //       decimalDigits: 0,
                      //     ),
                      //   ],
                      //   controller: vm.carPrice2TEC,
                      //   keyboardType: TextInputType.number,
                      //   name: "price2",
                      //   validator: CustomFormBuilderValidator.required,
                      //   decoration: inputDec.copyWith(
                      //     prefixIcon: Icon(
                      //       MaterialIcons.attach_money,
                      //       color: Theme.of(context).textTheme.bodyLarge!.color,
                      //     ),
                      //     hintText:
                      //         "${'Price'.tr()} ${'Saturday'.tr()} - ${'Sunday'.tr()}"
                      //             .toLowerCase()
                      //             .capitalized,
                      //     labelText: "${'Saturday'.tr()} - ${'Sunday'.tr()}",
                      //     labelStyle: labelStyle,
                      //   ),
                      //   style: style,
                      //   textInputAction: TextInputAction.next,
                      // ),

                      // FormBuilderTextField(
                      //   readOnly: true,
                      //   controller: vm.utilitiesTEC,
                      //   name: "utilities",
                      //   validator: CustomFormBuilderValidator.required,
                      //   decoration: inputDec.copyWith(
                      //     prefixIcon: Icon(
                      //       MaterialIcons.format_list_numbered,
                      //       color: Theme.of(context).textTheme.bodyLarge!.color,
                      //     ),
                      //     hintText: "Nhấp vào để chọn tiện ích xe".tr(),
                      //     labelText: "Tiện ích".tr(),
                      //     labelStyle: labelStyle,
                      //   ),
                      //   style: style,
                      //   onTap: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //           builder: (context) => AddUtilitiesPage(model: vm)),
                      //     );
                      //   },
                      //   textInputAction: TextInputAction.next,
                      // ).py20(),
                      // FormBuilderTextField(
                      //   readOnly: true,
                      //   controller: vm.requirementsTEC,
                      //   name: "requirement",
                      //   validator: CustomFormBuilderValidator.required,
                      //   decoration: inputDec.copyWith(
                      //     prefixIcon: Icon(
                      //       MaterialIcons.format_list_numbered,
                      //       color: Theme.of(context).textTheme.bodyLarge!.color,
                      //     ),
                      //     hintText: "Nhấp vào để chọn giấy tờ khi thuê ".tr(),
                      //     labelText: "Documents when renting".tr(),
                      //     labelStyle: labelStyle,
                      //   ),
                      //   style: style,
                      //   onTap: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //           builder: (context) => AddRequirementsPage(model: vm)),
                      //     );
                      //   },
                      //   textInputAction: TextInputAction.next,
                      // ),
                      // FormBuilderTextField(
                      //   initialValue: widget.vehicle.yearMade,
                      //   readOnly: true,
                      //   name: "yearMade",
                      //   validator: CustomFormBuilderValidator.required,
                      //   decoration: inputDec.copyWith(
                      //     prefixIcon: Icon(
                      //       Icons.calendar_today,
                      //       color: Theme.of(context).textTheme.bodyLarge!.color,
                      //     ),
                      //     hintText: "Nhấp vào để chọn năm sản xuất ".tr(),
                      //     labelText: "Năm sản xuất".tr(),
                      //     labelStyle: labelStyle,
                      //   ),
                      //   style: style,
                      //   textInputAction: TextInputAction.next,
                      // ).py20(),
                      // FormBuilderTextField(
                      //   readOnly: true,
                      //   controller: vm.addressTEC,
                      //   name: "address",
                      //   validator: CustomFormBuilderValidator.required,
                      //   decoration: inputDec.copyWith(
                      //     prefixIcon: Icon(
                      //       Icons.location_on_outlined,
                      //       color: Theme.of(context).textTheme.bodyLarge!.color,
                      //     ),
                      //     hintText: "Nhấp để chọn địa điểm".tr(),
                      //     labelText: "Địa điểm".tr(),
                      //     labelStyle: labelStyle,
                      //   ),
                      //   style: style,
                      //   onTap: () {
                      //     context
                      //         .nextPage(AddAddressPage(model: vm, showNext: false));
                      //   },
                      //   textInputAction: TextInputAction.next,
                      // ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     Text(
                      //       'Discount'.tr(),
                      //       style: TextStyle(
                      //         fontSize: 16,
                      //         fontWeight: FontWeight.w600,
                      //       ),
                      //     ),
                      //     CupertinoSwitch(
                      //       activeColor: AppColor.primaryColor,
                      //       value: showDiscount,
                      //       onChanged: (bool value) {
                      //         setState(() {
                      //           showDiscount = value;
                      //         });
                      //       },
                      //     )
                      //   ],
                      // ).py20(),
                      // showDiscount
                      //     ? Column(
                      //         children: [
                      //           Row(
                      //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //             children: [
                      //               'Thuê từ 3 ngày (% giảm)'.tr().text.xl.make(),
                      //               upDowNumber(
                      //                 vm.discountThreeDays,
                      //                 () {
                      //                   setState(() {
                      //                     vm.discountThreeDays =
                      //                         vm.discountThreeDays - 1;
                      //                   });
                      //                 },
                      //                 () {
                      //                   setState(() {
                      //                     vm.discountThreeDays =
                      //                         vm.discountThreeDays + 1;
                      //                   });
                      //                 },
                      //               ),
                      //             ],
                      //           ),
                      //           const SizedBox(height: 20),
                      //           Row(
                      //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //             children: [
                      //               'Thuê từ 7 ngày (% giảm)'.tr().text.xl.make(),
                      //               upDowNumber(
                      //                 vm.discountSevenDays,
                      //                 () {
                      //                   setState(() {
                      //                     vm.discountSevenDays =
                      //                         vm.discountSevenDays - 1;
                      //                   });
                      //                 },
                      //                 () {
                      //                   setState(() {
                      //                     vm.discountSevenDays =
                      //                         vm.discountSevenDays + 1;
                      //                   });
                      //                 },
                      //               ),
                      //             ],
                      //           )
                      //         ],
                      //       )
                      //     : SizedBox(),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     Text(
                      //       'Đặt xe nhanh'.tr(),
                      //       style: TextStyle(
                      //         fontSize: 16,
                      //         fontWeight: FontWeight.w600,
                      //       ),
                      //     ),
                      //     CupertinoSwitch(
                      //       activeColor: AppColor.primaryColor,
                      //       value: fastBooking,
                      //       onChanged: (bool value) {
                      //         setState(() {
                      //           fastBooking = value;
                      //         });
                      //       },
                      //     )
                      //   ],
                      // ),
                      UiSpacer.divider().py20(),
                      //business documents
                      DocumentSelectionView(
                        title: widget.vehicle.service?.slug == "rental driver"
                            ? "Driver License & Documents".tr()
                            : "Driver License".tr(),
                        instruction: AppPageSettings.driverDocumentInstructions,
                        max: AppPageSettings.maxDriverDocumentCount,
                        onSelected: vm.onDocumentsSelected,
                      ).py20(),
                      //
                      Visibility(
                          visible: !(widget.vehicle.verified ?? false),
                          child: VStack([
                            UiSpacer.divider().py12(),
                            CustomButton(
                                title: "Save".tr(),
                                //loading: vm.isBusy,
                                onPressed: () async {
                                  print('Nhấn save');
                                  await vm.processSave();
                                } //vm.processSave,
                                ).centered().py20(),
                          ]))
                    ],
                  )
                      .scrollVertical(padding: EdgeInsets.all(20))
                      .pOnly(bottom: context.mq.viewInsets.bottom),
                ),
        );
      },
    );
  }

  yearDialog(BuildContext context, NewVehicleViewModel model) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("select_year".tr()),
            ],
          ),
          content: SizedBox(
            width: 300,
            height: 300,
            child: YearPicker(
              currentDate:
                  DateTime(int.parse(model.yearMadeTEC.text.toString()), 1),
              firstDate: DateTime(DateTime.now().year - 30, 1),
              lastDate: DateTime(DateTime.now().year, 1),
              initialDate:
                  DateTime(int.parse(model.yearMadeTEC.text.toString()), 1),
              selectedDate:
                  DateTime(int.parse(model.yearMadeTEC.text.toString()), 1),
              onChanged: (DateTime dateTime) {
                model.onCarYearMadeSelected(dateTime.year.toString());
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }

  Widget upDowNumber(int count, Function() onDecrease, Function() onIncrease) {
    return Row(
      children: [
        Icon(
          Icons.remove,
          size: 20,
          color: count == 0 ? Colors.grey : Colors.black,
        ).onTap(() {
          if (count > 0) onDecrease();
        }),
        SizedBox(
          width: 8,
        ),
        '${count}'.text.xl2.make(),
        SizedBox(
          width: 8,
        ),
        Icon(
          Icons.add,
          size: 20,
          color: count == 100 ? Colors.grey : Colors.black,
        ).onTap(() {
          if (count < 100) onIncrease();
        }),
      ],
    );
  }
}
