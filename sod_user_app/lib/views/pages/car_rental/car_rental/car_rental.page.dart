import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/models/car_brand.dart';
import 'package:sod_user/view_models/car_rental.view_model.dart';
import 'package:sod_user/views/pages/car_rental/car_rental/pick_address.dart';
import 'package:sod_user/views/pages/car_rental/widgets/car_rental_card.dart';
import 'package:sod_user/widgets/busy_indicator.dart';
import 'package:sod_user/widgets/buttons/global_button.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class CarRentalPage extends StatefulWidget {
  final CarRentalViewModel model;
  const CarRentalPage({super.key, required this.model});

  @override
  State<CarRentalPage> createState() => _CarRentalPageState();
}

class _CarRentalPageState extends State<CarRentalPage>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ViewModelBuilder<CarRentalViewModel>.reactive(
      viewModelBuilder: () => widget.model,
      onViewModelReady: (model) => model.initialise(),
      builder: (context, viewModel, child) {
        return SafeArea(
          child: Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(
                  icon: Icon(Icons.filter_alt, size: 30),
                  onPressed: () => buildFilterVehicle(context),
                ),
              ],
              backgroundColor: AppColor.primaryColor,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("car_rental".tr()),
                ],
              ),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: widget.model.isBusy == false
                    ? widget.model.carRental.isNotEmpty
                        ? Column(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PickAddressPage(),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.1,
                                      child: IconButton(
                                        icon: Icon(Icons.add_location),
                                        onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PickAddressPage(),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      child: TextFormField(
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          hintText:
                                              'Tên thành phố hoặc địa điểm cụ thể'
                                                  .tr(),
                                        ),
                                        controller:
                                            widget.model.addressController,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ListView.builder(
                                controller: ScrollController(),
                                itemCount: widget.model.carRental.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return CarRentalCard(
                                    data: widget.model.carRental[index],
                                    model: widget.model,
                                  );
                                },
                              ),
                            ],
                          )
                        : Center(
                            child: Text(
                              'no_data'.tr(),
                            ),
                          )
                    : Visibility(
                        visible: widget.model.isBusy,
                        child: BusyIndicator().centered(),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  buildFilterVehicle(BuildContext context) {
    widget.model.colorController.text = '';
    widget.model.brandController.text = '';
    widget.model.yearMakeController.text = '';
    return showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(15), topLeft: Radius.circular(15))),
        context: context,
        isDismissible: false,
        isScrollControlled: true,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
            child: Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "filter".tr(),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Opacity(
                        opacity: 0.8,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            "brand".tr(),
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        height: 25,
                        child: TextFormField(
                          decoration:
                              InputDecoration(hintText: 'select_brand'.tr()),
                          controller: widget.model.brandController,
                          readOnly: true,
                          onTap: () {
                            if (widget.model.carBrand.isNotEmpty) {
                              brandDialog(context, widget.model.carBrand);
                            } else {
                              print('no_data');
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Opacity(
                        opacity: 0.8,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            "car_registration_year".tr(),
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        height: 25,
                        child: TextFormField(
                          decoration:
                              InputDecoration(hintText: 'select_year'.tr()),
                          controller: widget.model.yearMakeController,
                          readOnly: true,
                          onTap: () => yearDialog(context),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Opacity(
                        opacity: 0.8,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            "color".tr(),
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        height: 25,
                        child: TextFormField(
                          decoration:
                              InputDecoration(hintText: 'select_color'.tr()),
                          controller: widget.model.colorController,
                          readOnly: true,
                          onTap: () => colorDialog(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: GlobalButton.buildButton(
                          context,
                          btnHeight: 40,
                          title: "update".tr(),
                          btnColor: AppColor.primaryColor,
                          txtColor: Colors.white,
                          onPress: () {
                            widget.model.getCarRental(
                              brand_id: widget.model.selectedBrandId ?? '',
                              year_made: widget.model.selectedYearMake ?? '',
                              color: widget.model.colorController.text,
                            );
                            widget.model.selectedBrandId = '';
                            widget.model.carMake = '';
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: GlobalButton.buildButton(
                            context,
                            btnHeight: 40,
                            title: "cancel".tr(),
                            btnColor: Color(0xffEAA501),
                            txtColor: Colors.black,
                            onPress: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20)
                ],
              ),
            ),
          );
        });
  }

  yearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("select_year".tr()),
          content: SizedBox(
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(DateTime.now().year - 30, 1),
              lastDate: DateTime(DateTime.now().year, 1),
              initialDate: DateTime(DateTime.now().year, 1),
              selectedDate: DateTime(DateTime.now().year, 1),
              onChanged: (DateTime dateTime) {
                widget.model.selectedYearMake = dateTime.year.toString();
                widget.model.yearMakeController.text =
                    widget.model.selectedYearMake ?? '';
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }

  colorDialog(BuildContext context) {
    List<String> colorList = [
      'Trắng',
      'Đen',
      'Xanh lam',
      'Đỏ',
      'Xám',
      'Vàng',
      'Bạc',
      'Nâu',
      'Xanh',
      'Ghi'
    ];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('color_list'.tr()),
          content: SizedBox(
            height: 300,
            width: 300,
            child: colorList == null
                ? Container()
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: colorList.length,
                    itemBuilder: (context, index) => ListTile(
                      title: InkWell(
                        onTap: () {
                          widget.model.colorController.text = colorList[index];
                          Navigator.pop(context);
                        },
                        child: Text(colorList[index].tr()),
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }

  brandDialog(BuildContext context, List<CarBrandModel>? brandList) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('brand_list'.tr()),
          content: SizedBox(
            height: 300, // Change as per your requirement
            width: 300, // Change as per your requirement
            child: brandList == null
                ? Container()
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: brandList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title: InkWell(
                            onTap: () {
                              widget.model.brandController.text =
                                  brandList[index].name ?? '';
                              widget.model.selectedBrandId =
                                  brandList[index].id.toString();
                              Navigator.pop(context);
                            },
                            child: Text(brandList[index].name.toString())),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
