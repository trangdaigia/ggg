import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/models/car_rental.dart';
import 'package:sod_user/view_models/car_management.view_model.dart';
import 'package:sod_user/views/pages/car_rental/add_rental_car/add_address.dart';
import 'package:sod_user/views/pages/car_rental/add_rental_car/add_car_detail.dart';
import 'package:sod_user/views/pages/car_rental/add_rental_car/add_car_photos.dart';
import 'package:sod_user/views/pages/car_rental/add_rental_car/add_price.dart';
import 'package:sod_user/views/pages/car_rental/add_rental_car/add_rental_options.dart';
import 'package:sod_user/views/pages/car_rental/add_rental_car/add_requirement.dart';
import 'package:sod_user/views/pages/car_rental/add_rental_car/add_utilities.dart';
import 'package:sod_user/views/pages/car_rental/widgets/car_management_description.dart';
import 'package:sod_user/views/pages/car_rental/widgets/car_management_collateral.dart';
import 'package:sod_user/views/pages/car_rental/widgets/car_management_rental_status.dart';
import 'package:sod_user/views/pages/car_rental/widgets/car_management_quick_booking.dart';
import 'package:sod_user/views/pages/car_rental/widgets/car_management_delivery.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/widgets/busy_indicator.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:sod_user/services/alert.service.dart';

class MyCarDetailPage extends StatefulWidget {
  const MyCarDetailPage({
    super.key,
    required this.model,
    required this.data,
    required this.index,
  });
  final CarManagementViewModel model;
  final CarRental data;
  final int index;

  @override
  State<MyCarDetailPage> createState() => _MyCarDetailPageState();
}

class _MyCarDetailPageState extends State<MyCarDetailPage> {
  late final Map<String, Widget> informationOptions;
  late final Map<String, List<Map<String, Widget>>> settingOptions;

  @override
  void initState() {
    super.initState();
    informationOptions = {
      'Vehicle images': AddCarPhotosPage(
        showNext: false,
        model: widget.model,
        data: widget.data,
      ),
      'Vehicle address': AddAddressPage(
        data: widget.data,
        updateLocation: updateLocation,
        latitude: widget.data.latitude,
        longitude: widget.data.longitude,
        showNext: false,
        model: widget.model,
        index: widget.index,
      ),
      'Vehicle amenities': AddUtilitiesPage(
        model: widget.model,
        data: widget.data,
        showNext: false,
        index: widget.index,
      ),
      'Vehicle description': CarManagementDescription(
        model: widget.model,
        data: widget.data,
      ),
      'Image of vehicle documents': ImageOfVehicleDocuments(
        model: widget.model,
        data: widget.data,
      ),
      'Manage services': AddCarDetailPage(
        model: widget.model,
        data: widget.data,
        showNext: false,
      ),
    };

    settingOptions = {
      // 'Pricing' is title of this group
      'Pricing': [
        // 'Price per day' is the first option in 'Pricing' group
        {
          'Price per day': AddPricePage(
            model: widget.model,
            data: widget.data,
            showNext: false,
          ),
        }
      ],
      // 'Book a car' is title of this group
      'Book a car': [
        // 'Documents when renting a car' is the first option in 'Book a car' group
        {
          'Documents when renting a car': AddRequirementPage(
            model: widget.model,
            data: widget.data,
            showNext: false,
          )
        },
        // 'Collateral' is the second option in 'Book a car' group
        {
          'Collateral': CarManagementCollateral(
            model: widget.model,
            data: widget.data,
          )
        },
      ],
      // ... and so on
      'Manager': [
        {
          'Car rental status': CarManagementRentalStatus(
            model: widget.model,
            data: widget.data,
          )
        },
        {
          'Quick booking': CarManagementQuickBooking(
            model: widget.model,
            data: widget.data,
          )
        },
        {
          'Car delivery': CarManagementDelivery(
            model: widget.model,
            data: widget.data,
          )
        },
        {
          'Rental options': AddRentalOptions(
            showNext: false,
            model: widget.model,
            data: widget.data,
          )
        }
      ]
    };
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CarManagementViewModel>.reactive(
        disposeViewModel: false,
        viewModelBuilder: () => widget.model,
        builder: (context, viewModel, child) {
          print('Giá trị của rental_options: ${widget.data.rental_options}');
          return BasePage(
              showLeadingAction: true,
              showAppBar: true,
              title: 'Vehicle management'.tr(),
              body: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      unselectedLabelStyle:
                          TextStyle(fontWeight: FontWeight.normal),
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      labelColor: context.textTheme.bodyLarge?.color,
                      tabs: [
                        Tab(
                          text: 'Information'.tr(),
                        ),
                        Tab(text: 'Settings'.tr()),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          ListView.builder(
                            itemCount: informationOptions.length,
                            itemBuilder: (context, index) {
                              return informationOptions.entries
                                  .map((e) => Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                                color: Colors.grey
                                                    .withOpacity(0.5)),
                                          ),
                                        ),
                                        child: ListTile(
                                            title: Text(
                                              e.key.tr(),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            trailing: Icon(
                                                Icons
                                                    .arrow_forward_ios_outlined,
                                                color: AppColor.primaryColor,
                                                size: 20),
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) => e.value,
                                                ),
                                              );
                                            }),
                                      ))
                                  .toList()[index];
                            },
                          ),
                          // Tab Cài đặt
                          ListView(
                            children: settingOptions.entries
                                .map((e) => Column(
                                      children: [
                                        e.key
                                            .tr()
                                            .text
                                            .xl
                                            .bold
                                            .align(TextAlign.left)
                                            .make()
                                            .pOnly(top: 12, left: 12, right: 12)
                                            .wFull(context),
                                        ...e.value
                                            .map((option) => Column(
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        border: Border(
                                                          bottom: BorderSide(
                                                              color: Colors.grey
                                                                  .withOpacity(
                                                                      0.5)),
                                                        ),
                                                      ),
                                                      child: ListTile(
                                                        title: Text(
                                                          option.keys.first
                                                              .tr(),
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        ),
                                                        trailing: Icon(
                                                            Icons
                                                                .arrow_forward_ios_outlined,
                                                            color: AppColor
                                                                .primaryColor,
                                                            size: 20),
                                                        onTap: () {
                                                          Navigator.of(context)
                                                              .push(
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      option
                                                                          .values
                                                                          .first,
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ))
                                            .toList(),
                                      ],
                                    ))
                                .toList(),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ).backgroundColor(AppColor.onboarding1Color));
        });
  }

  void updateLocation(String? latitude, String? longitude) {
    setState(() {
      widget.data.latitude = latitude;
      widget.data.longitude = longitude;
    });
  }
}

class ImageOfVehicleDocuments extends StatefulWidget {
  const ImageOfVehicleDocuments({
    super.key,
    required this.model,
    required this.data,
  });
  final CarManagementViewModel model;
  final CarRental data;
  @override
  State<ImageOfVehicleDocuments> createState() =>
      _ImageOfVehicleDocumentsState();
}

class _ImageOfVehicleDocumentsState extends State<ImageOfVehicleDocuments> {
  bool check = false;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    widget.model.newCarParrotPhotos = [];
    widget.model.newCivilLiabilityInsurancePhotos = [];
    widget.model.newRegistrationPhotos = [];
    widget.model.newVehicleBodyInsurancePhotos = [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.model.fetchData(widget.data).then((value) {
        setState(() {
          check = value;
          print('Xong');
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      title: 'Image of vehicle documents'.tr(),
      body: check
          ? Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    'Please take photos of both sides of the vehicle documents related to your rental car'
                        .tr()
                        .text
                        .make(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        'Giấy cà vẹt xe'.tr().text.bold.make(),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        addPicture(context, 'Giấy cà vẹt xe'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        'Giấy đăng kiểm'.tr().text.bold.make(),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        addPicture(context, 'Giấy đăng kiểm'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        'Bảo hiểm trách nhiệm dân sự'.tr().text.bold.make(),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        addPicture(context, 'Bảo hiểm trách nhiệm dân sự'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        'Bảo hiểm vật chất thân xe'.tr().text.bold.make(),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        addPicture(context, 'Bảo hiểm vật chất thân xe'),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: CustomButton(
                        title: 'Completed'.tr(),
                        loading: isUpdating,
                        onPressed: () async {
                          setState(() {
                            isUpdating = true;
                          });
                          bool checkUpdate = false;
                          checkUpdate = await widget.model.updateCar(
                            id: widget.data.id!,
                            newCarParrotPhotos: widget.model.newCarParrotPhotos,
                            newRegistrationPhotos:
                                widget.model.newRegistrationPhotos,
                            newCivilLiabilityInsurancePhotos:
                                widget.model.newCivilLiabilityInsurancePhotos,
                            newVehicleBodyInsurancePhotos:
                                widget.model.newVehicleBodyInsurancePhotos,
                          );
                          if (checkUpdate) {
                            await AlertService.success(
                              title: "Sửa thành công".tr(),
                              text: "Sửa giấy tờ xe thành công".tr(),
                            );
                            // cập nhật lại danh sách giấy tờ xe local
                            widget.model.tempNewCarParrotPhotos =
                                widget.model.newCarParrotPhotos;
                            widget.model.tempNewRegistrationPhotos =
                                widget.model.newRegistrationPhotos;
                            widget.model.tempNewCivilLiabilityInsurancePhotos =
                                widget.model.newCivilLiabilityInsurancePhotos;
                            widget.model.tempNewVehicleBodyInsurancePhotos =
                                widget.model.newVehicleBodyInsurancePhotos;
                            print('Sửa thành công');
                            Navigator.pop(context);
                          } else {
                            print('Sửa thất bại');
                          }
                          setState(() {
                            isUpdating = false;
                          });
                        },
                      ).wFull(context),
                    )
                  ],
                ),
              ),
            )
          : BusyIndicator().centered(),
    );
  }

  Row addPicture(BuildContext context, String type) {
    List<File>? photos = [];
    if (type == 'Giấy cà vẹt xe') {
      photos = widget.model.newCarParrotPhotos;
    } else if (type == 'Giấy đăng kiểm') {
      photos = widget.model.newRegistrationPhotos;
    } else if (type == 'Bảo hiểm trách nhiệm dân sự') {
      photos = widget.model.newCivilLiabilityInsurancePhotos;
    } else {
      photos = widget.model.newVehicleBodyInsurancePhotos;
    }

    print('Chiều dài hình: ${photos!.length}');

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: photos.length == 0
              ? DottedBorder(
                  color: Colors.black,
                  strokeWidth: 1,
                  child: InkWell(
                    onTap: () {
                      if (type == 'Giấy cà vẹt xe') {
                        widget.model.chooseCarParrotPhotos().whenComplete(
                          () {
                            setState(() {
                              photos = widget.model.newCarParrotPhotos;
                              print('Thêm ảnh ${type} thành công');
                            });
                          },
                        );
                      } else if (type == 'Giấy đăng kiểm') {
                        widget.model.chooseRegistrationPhotos().whenComplete(
                          () {
                            setState(() {
                              photos = widget.model.newRegistrationPhotos;
                              print('Thêm ảnh ${type} thành công');
                            });
                          },
                        );
                      } else if (type == 'Bảo hiểm trách nhiệm dân sự') {
                        widget.model
                            .chooseCivilLiabilityInsurancePhotos()
                            .whenComplete(
                          () {
                            setState(() {
                              photos =
                                  widget.model.newCivilLiabilityInsurancePhotos;
                              print('Thêm ảnh ${type} thành công');
                            });
                          },
                        );
                      } else if (type == 'Bảo hiểm vật chất thân xe') {
                        widget.model
                            .chooseVehicleBodyInsurancePhotos()
                            .whenComplete(
                          () {
                            setState(() {
                              photos =
                                  widget.model.newVehicleBodyInsurancePhotos;
                              print('Thêm ảnh ${type} thành công');
                            });
                          },
                        );
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width / 3.5,
                      height: MediaQuery.of(context).size.width / 3.5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_outline_outlined)
                              .pOnly(bottom: 10),
                          Text(
                            'Add picture'.tr(),
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Container(
                  width: MediaQuery.of(context).size.width / 3.5,
                  height: MediaQuery.of(context).size.width / 3.5,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        child: Image.file(
                          photos[0],
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: Icon(Icons.cancel_outlined),
                          onPressed: () {
                            setState(() {
                              if (type == 'Giấy cà vẹt xe') {
                                if (widget.model.newCarParrotPhotos!.length -
                                        1 ==
                                    0) {
                                  widget.model.newCarParrotPhotos = null;
                                } else {
                                  widget.model.newCarParrotPhotos!.removeAt(0);
                                }
                              } else if (type == 'Giấy đăng kiểm') {
                                if (widget.model.newRegistrationPhotos!.length -
                                        1 ==
                                    0) {
                                  widget.model.newRegistrationPhotos = null;
                                } else {
                                  widget.model.newRegistrationPhotos!
                                      .removeAt(0);
                                }
                              } else if (type ==
                                  'Bảo hiểm trách nhiệm dân sự') {
                                if (widget
                                            .model
                                            .newCivilLiabilityInsurancePhotos!
                                            .length -
                                        1 ==
                                    0) {
                                  widget.model
                                      .newCivilLiabilityInsurancePhotos = null;
                                } else {
                                  widget.model.newCivilLiabilityInsurancePhotos!
                                      .removeAt(0);
                                }
                              } else {
                                if (widget.model.newVehicleBodyInsurancePhotos!
                                            .length -
                                        1 ==
                                    0) {
                                  widget.model.newVehicleBodyInsurancePhotos =
                                      null;
                                } else {
                                  widget.model.newVehicleBodyInsurancePhotos!
                                      .removeAt(0);
                                }
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: (photos != null && photos!.length < 2)
              ? DottedBorder(
                  color: Colors.black,
                  strokeWidth: 1,
                  child: InkWell(
                    onTap: () {
                      if (type == 'Giấy cà vẹt xe') {
                        widget.model.chooseCarParrotPhotos().whenComplete(
                          () {
                            setState(() {
                              photos = widget.model.newCarParrotPhotos;
                              print('Thêm ảnh ${type} thành công');
                            });
                          },
                        );
                      } else if (type == 'Giấy đăng kiểm') {
                        widget.model.chooseRegistrationPhotos().whenComplete(
                          () {
                            setState(() {
                              photos = widget.model.newRegistrationPhotos;
                              print('Thêm ảnh ${type} thành công');
                            });
                          },
                        );
                      } else if (type == 'Bảo hiểm trách nhiệm dân sự') {
                        widget.model
                            .chooseCivilLiabilityInsurancePhotos()
                            .whenComplete(
                          () {
                            setState(() {
                              photos =
                                  widget.model.newCivilLiabilityInsurancePhotos;
                              print('Thêm ảnh ${type} thành công');
                            });
                          },
                        );
                      } else if (type == 'Bảo hiểm vật chất thân xe') {
                        widget.model
                            .chooseVehicleBodyInsurancePhotos()
                            .whenComplete(
                          () {
                            setState(() {
                              photos =
                                  widget.model.newVehicleBodyInsurancePhotos;
                              print('Thêm ảnh ${type} thành công');
                            });
                          },
                        );
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width / 3.5,
                      height: MediaQuery.of(context).size.width / 3.5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_outline_outlined)
                              .pOnly(bottom: 10),
                          Text(
                            'Add picture'.tr(),
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Container(
                  width: MediaQuery.of(context).size.width / 3.5,
                  height: MediaQuery.of(context).size.width / 3.5,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        child: Image.file(
                          photos![1],
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: Icon(Icons.cancel_outlined),
                          onPressed: () {
                            setState(() {
                              if (type == 'Giấy cà vẹt xe') {
                                widget.model.newCarParrotPhotos!.removeAt(1);
                              } else if (type == 'Giấy đăng kiểm') {
                                widget.model.newRegistrationPhotos!.removeAt(1);
                              } else if (type ==
                                  'Bảo hiểm trách nhiệm dân sự') {
                                widget.model.newCivilLiabilityInsurancePhotos!
                                    .removeAt(1);
                              } else {
                                widget.model.newVehicleBodyInsurancePhotos!
                                    .removeAt(1);
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
