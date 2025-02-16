import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/models/car_brand.dart';
import 'package:sod_user/models/car_rental.dart';
import 'package:sod_user/services/alert.service.dart';
import 'package:sod_user/services/navigation.service.dart';
import 'package:sod_user/view_models/car_management.view_model.dart';
import 'package:sod_user/view_models/shared_ride.vm.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:sod_user/utils/utils.dart';
import 'package:cool_alert/cool_alert.dart';

class AddCarDetailPage extends StatefulWidget {
  final CarManagementViewModel model;
  const AddCarDetailPage({
    super.key,
    required this.model,
    this.showNext = true,
    this.data,
    this.shareRideModel,
  });
  final bool showNext;
  final CarRental? data;
  final SharedRideViewModel? shareRideModel;

  @override
  State<AddCarDetailPage> createState() => _AddCarDetailPageState();
}

class _AddCarDetailPageState extends State<AddCarDetailPage> {
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      widget.model.brandController.text =
          widget.data!.carModel!.carMake!.name ?? '';
      widget.model.brandId = widget.data!.carModel!.carMake!.id.toString();
      widget.model.carModelController.text = widget.data!.carModel!.name ?? '';
      widget.model.carModelId = widget.data!.carModel!.id.toString();
      if (widget.data!.yearMade == null) {
        widget.data!.yearMade = DateTime.now().year.toString();
      }
      widget.model.yearMade = widget.data!.yearMade.toString();
      widget.model.yearMadeController.text = widget.data!.yearMade.toString();
      widget.model.colorController.text = widget.data!.color!;
      widget.model.regNoController.text = widget.data!.regNo!;
      widget.model.rangeOfVehicleTranslateController.text =
          widget.data!.rangeOfVehicle!.tr();
    }
    widget.model.yearMade = DateTime.now().year.toString();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColor.onboarding3Color,
        appBar: AppBar(
          backgroundColor: context.backgroundColor,
          title: Text("Service details".tr(),
              style: TextStyle(color: context.textTheme.bodyLarge!.color)),
          centerTitle: true,
          iconTheme: IconThemeData(color: context.textTheme.bodyLarge!.color),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Opacity(
                    opacity: 0.8,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "Range of vehicle".tr(),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    height: 25,
                    child: TextFormField(
                      decoration:
                          InputDecoration(hintText: 'Chọn loại xe'.tr()),
                      controller:
                          widget.model.rangeOfVehicleTranslateController,
                      readOnly: true,
                      onTap: () => rangeOfVehicleDialog(context),
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
                        "brand".tr(),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    height: 25,
                    child: TextFormField(
                      decoration:
                          InputDecoration(hintText: 'select_brand'.tr()),
                      controller: widget.model.brandController,
                      readOnly: true,
                      onTap: () {
                        if (widget.model.rangeOfVehicleTranslateController.text
                            .isEmpty) {
                          CoolAlert.show(
                            context: context,
                            type: CoolAlertType.warning,
                            title: "Notifications".tr(),
                            text: "Please select a vehicle type first".tr(),
                          );
                        } else {
                          if (widget.model.carBrand.isNotEmpty) {
                            brandDialog(context, widget.model.carBrand);
                          } else {
                            print('no_data');
                          }
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
                        "Model".tr(),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    height: 25,
                    child: TextFormField(
                      decoration:
                          InputDecoration(hintText: 'Select Model'.tr()),
                      controller: widget.model.carModelController,
                      readOnly: true,
                      onTap: () {
                        if (widget.model.brandController.text.isEmpty) {
                          CoolAlert.show(
                            context: context,
                            type: CoolAlertType.warning,
                            title: "Notifications".tr(),
                            text: "Please select a brand first".tr(),
                          );
                        } else {
                          if (widget.model.carModel.isNotEmpty) {
                            modelDialog(context, widget.model.carModel);
                          } else {
                            print('no_data');
                          }
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
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    height: 25,
                    child: TextFormField(
                      decoration: InputDecoration(hintText: 'select_year'.tr()),
                      controller: widget.model.yearMadeController,
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
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 200,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Opacity(
                    opacity: 0.8,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "License plate".tr(),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    height: 40,
                    child: TextFormField(
                      controller: widget.model.regNoController,
                    ),
                  ),
                ],
              ),
            ],
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
                      if (widget.model.brandController.text != '' &&
                          widget.model.carModelController.text != '' &&
                          widget.model.regNoController.text != '' &&
                          widget.model.colorController.text != '' &&
                          widget.model.yearMadeController.text != '') {
                        // check forbidden words
                        final forbiddenWord = Utils.checkForbiddenWordsInString(
                            widget.model.regNoController.text);
                        if (forbiddenWord != null) {
                          CoolAlert.show(
                            context: context,
                            type: CoolAlertType.error,
                            title: "Warning forbidden words".tr(),
                            text: "Vehicle information contains forbidden word"
                                    .tr() +
                                ": $forbiddenWord",
                          );
                          return;
                        }
                        context.nextPage(NavigationService().addCarRentalPage(
                          shareRideModel: widget.shareRideModel,
                          model: widget.model,
                          type: "price",
                        ));
                      } else {
                        AlertService.error(
                          title: "Error".tr(),
                          text: "Field is required".tr(),
                        );
                      }
                    },
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    child: CustomButton(
                      loading: isLoading,
                      title: 'Completed'.tr(),
                      onPressed: () async {
                        bool checkUpdate = false;
                        setState(() {
                          isLoading = true;
                        });
                        checkUpdate = await widget.model.updateCar(
                          rangeOfVehicle:
                              widget.model.rangeOfVehicleController.text,
                          id: widget.data!.id!,
                          carModelId: widget.model.carModelId,
                          carModel: CarModel(
                            id: int.parse(widget.model.carModelId.toString()),
                            name: widget.model.carModelController.text,
                            carMakeId:
                                int.parse(widget.model.brandId.toString()),
                            carMake: CarMake(
                              id: int.parse(widget.model.brandId.toString()),
                              name: widget.model.brandController.text,
                            ),
                          ),
                          yearMade: widget.model.yearMade,
                          color: widget.model.colorController.text,
                          regNo: widget.model.regNoController.text,
                        );
                        setState(() {
                          isLoading = false;
                        });
                        if (checkUpdate) {
                          await AlertService.success(
                            title: "Sửa thành công".tr(),
                            text: "Sửa chi tiết xe thành công".tr(),
                          );
                          widget.data!.rangeOfVehicle =
                              widget.model.rangeOfVehicleTranslateController.text;
                          widget.data!.carModel!.carMake!.name =
                              widget.model.brandController.text;
                          widget.data!.carModel!.name = widget.model.carModelController.text;
                          widget.data!.yearMade = widget.model.yearMade;
                          widget.data!.color = widget.model.colorController.text;
                          widget.data!.regNo = widget.model.regNoController.text;
                          print('Sửa thành công');
                          Navigator.pop(context);
                        } else {
                          print('Sửa thất bại');
                        }
                      },
                    )),
              ),
      ),
    );
  }

  brandDialog(BuildContext context, List<CarBrandModel>? brandList) {
    List<CarBrandModel>? filteredList;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            void filterBrands(String keyword) {
              setState(() {
                filteredList = brandList
                    ?.where((brand) =>
                        brand.name
                            ?.toLowerCase()
                            .contains(keyword.toLowerCase()) ==
                        true)
                    .toList();
              });
            }

            return AlertDialog(
              title: Text('brand_list'.tr()),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) {
                      filterBrands(value);
                    },
                    decoration: InputDecoration(
                      labelText: 'Search'.tr(),
                      labelStyle:
                          TextStyle(color: context.textTheme.bodyLarge!.color),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    height: 300, // Change as per your requirement
                    width: 300, // Change as per your requirement
                    child: filteredList == null || filteredList!.isEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: brandList!.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                height: 50,
                                margin: EdgeInsets.symmetric(vertical: 5),
                                color: Colors.grey.shade200,
                                alignment: Alignment.center,
                                child: Text(brandList[index].name.toString()),
                              ).onTap(() {
                                widget.model.brandController.text =
                                    brandList[index].name ?? '';
                                widget.model.brandId =
                                    brandList[index].id.toString();
                                widget.model.carModel = [];
                                widget.model.getCarModel(
                                  carMakeId: widget.model.brandId.toString(),
                                );
                                Navigator.pop(context);
                              });
                            },
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: filteredList!.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                height: 50,
                                margin: EdgeInsets.symmetric(vertical: 5),
                                color: Colors.grey.shade200,
                                alignment: Alignment.center,
                                child:
                                    Text(filteredList![index].name.toString()),
                              ).onTap(() {
                                widget.model.brandController.text =
                                    filteredList![index].name ?? '';
                                widget.model.brandId =
                                    filteredList![index].id.toString();
                                widget.model.carModel = [];
                                widget.model.getCarModel(
                                  carMakeId: widget.model.brandId.toString(),
                                );
                                Navigator.pop(context);
                              });
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  modelDialog(BuildContext context, List<CarModel>? carModel) {
    List<CarModel>? filteredList;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            void filterModels(String keyword) {
              setState(() {
                filteredList = carModel
                    ?.where((model) =>
                        model.name
                            ?.toLowerCase()
                            .contains(keyword.toLowerCase()) ==
                        true)
                    ?.toList();
              });
            }

            return AlertDialog(
              title: Text('model_list'.tr()),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) {
                      filterModels(value);
                    },
                    decoration: InputDecoration(
                      labelText: 'Search'.tr(),
                      labelStyle:
                          TextStyle(color: context.textTheme.bodyLarge!.color),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    height: 300, // Change as per your requirement
                    width: 300, // Change as per your requirement
                    child: filteredList == null || filteredList!.isEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: carModel!.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                height: 50,
                                margin: EdgeInsets.symmetric(vertical: 5),
                                color: Colors.grey.shade200,
                                alignment: Alignment.center,
                                child: carModel[index].name!.text.make(),
                              ).onTap(() {
                                widget.model.carModelController.text =
                                    carModel[index].name ?? '';
                                widget.model.carModelId =
                                    carModel[index].id.toString();
                                Navigator.pop(context);
                              });
                            },
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: filteredList!.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                height: 50,
                                margin: EdgeInsets.symmetric(vertical: 5),
                                color: Colors.grey.shade200,
                                alignment: Alignment.center,
                                child: filteredList![index].name!.text.make(),
                              ).onTap(() {
                                widget.model.carModelController.text =
                                    filteredList![index].name ?? '';
                                widget.model.carModelId =
                                    filteredList![index].id.toString();
                                Navigator.pop(context);
                              });
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  colorDialog(BuildContext context) {
    List<String> colorList = [
      'Trắng',
      'Đen',
      'Đỏ',
      'Xám',
      'Vàng',
      'Bạc',
      'Nâu',
      'Xanh',
    ];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('color_list'.tr()),
            ],
          ),
          content: SizedBox(
            height: 300,
            width: 300,
            // ignore: unnecessary_null_comparison
            child: colorList == null
                ? Container()
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: colorList.length,
                    itemBuilder: (context, index) => Container(
                      height: 50,
                      margin: EdgeInsets.symmetric(vertical: 5),
                      color: Colors.grey.shade200,
                      alignment: Alignment.center,
                      child: colorList[index].tr().text.make(),
                    ).onTap(() {
                      widget.model.colorController.text = colorList[index];
                      Navigator.pop(context);
                    }),
                  ),
          ),
        );
      },
    );
  }

  rangeOfVehicleDialog(BuildContext context) {
    List<String> list = ['Motorbike', 'Car', 'Truck'];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('List of vehicle types'.tr()),
            ],
          ),
          content: SizedBox(
            height: 300,
            width: 300,
            // ignore: unnecessary_null_comparison
            child: list == null
                ? Container()
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: list.length,
                    itemBuilder: (context, index) => Container(
                      height: 50,
                      margin: EdgeInsets.symmetric(vertical: 5),
                      color: Colors.grey.shade200,
                      alignment: Alignment.center,
                      child: list[index].tr().text.make(),
                    ).onTap(() {
                      widget.model.rangeOfVehicleController.text = list[index];
                      widget.model.rangeOfVehicleTranslateController.text =
                          list[index].tr();
                      Navigator.pop(context);
                    }),
                  ),
          ),
        );
      },
    );
  }

  yearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        print('Year made: ${widget.model.yearMade.toString()}');
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
              currentDate: widget.data != null
                  ? DateTime(int.parse(widget.data!.yearMade.toString()), 1)
                  : DateTime(int.parse(widget.model.yearMade.toString()), 1),
              firstDate: DateTime(DateTime.now().year - 30, 1),
              lastDate: DateTime(DateTime.now().year, 1),
              initialDate: DateTime(
                  widget.data != null
                      ? int.parse(widget.data!.yearMade.toString())
                      : int.parse(widget.model.yearMade.toString()),
                  1),
              selectedDate: widget.data != null
                  ? DateTime(int.parse(widget.data!.yearMade.toString()), 1)
                  : DateTime(int.parse(widget.model.yearMade.toString()), 1),
              onChanged: (DateTime dateTime) {
                widget.model.yearMade = dateTime.year.toString();
                widget.model.yearMadeController.text =
                    widget.model.yearMade ?? '';
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }
}
