import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/driver_lib/constants/app_colors.dart';
import 'package:sod_user/driver_lib/models/address.dart';
import 'package:sod_user/driver_lib/models/coordinates.dart';
import 'package:sod_user/driver_lib/models/vehicle.dart';
import 'package:sod_user/driver_lib/services/alert.service.dart';
import 'package:sod_user/driver_lib/services/geocoder.service.dart';
import 'package:sod_user/driver_lib/view_models/new_vehicle.vm.dart';
import 'package:sod_user/driver_lib/views/pages/vehicle/add_address_detail.dart';
import 'package:sod_user/driver_lib/widgets/base.page.dart';
import 'package:sod_user/driver_lib/widgets/busy_indicator.dart';
import 'package:sod_user/driver_lib/widgets/buttons/custom_button.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class AddAddressPage extends StatefulWidget {
  final NewVehicleViewModel model;
  const AddAddressPage({
    super.key,
    required this.model,
    this.showNext = true,
    this.longitude,
    this.latitude,
    this.data,
    this.updateLocation,
  });
  final bool showNext;
  final Vehicle? data;
  final String? latitude;
  final String? longitude;
  final Function(String, String)? updateLocation;
  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

bool isAddressSet = false;

class _AddAddressPageState extends State<AddAddressPage>
    with AutomaticKeepAliveClientMixin {
  String? location;
  Address? address;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isAddressSet = false;
    if (widget.latitude != null && widget.longitude != null) {
      widget.model.latitude = double.parse(widget.latitude!);
      widget.model.longitude = double.parse(widget.longitude!);
    }
  }

  Widget build(BuildContext context) {
    super.build(context);
    if (widget.latitude != null && widget.longitude != null) {
      return FutureBuilder<Address?>(
        future: getAddressFromCoordinates(
          double.parse(widget.latitude!),
          double.parse(widget.longitude!),
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: BusyIndicator().centered(),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading address'));
          } else if (snapshot.hasData) {
            if (!isAddressSet) {
              Address? address = snapshot.data;
              widget.model.addressTEC.text =
                  '${address!.subAdminArea ?? ''} ${address.adminArea}';
              isAddressSet = true;
            }
            return buildAddressWidget();
          } else {
            return Center(child: Text('No data'));
          }
        },
      );
    } else {
      return ViewModelBuilder<NewVehicleViewModel>.nonReactive(
        viewModelBuilder: () => widget.model,
        builder: (context, viewModel, child) {
          return SafeArea(
              child: Scaffold(
            backgroundColor: AppColor.onboarding3Color,
            appBar: AppBar(
              backgroundColor: context.backgroundColor,
              title: Text("Address".tr(),
                  style: TextStyle(color: context.textTheme.bodyLarge!.color)),
              centerTitle: true,
              iconTheme:
                  IconThemeData(color: context.textTheme.bodyLarge!.color),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: widget.model.addressTEC,
                    onTap: () => context.nextPage(
                      AddAddressDetailPage(model: widget.model),
                    ),
                    readOnly: true,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                      label: Text(
                        'Detailed address'.tr(),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),
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
                            if (widget.model.addressTEC.text != '') {
                              Navigator.pop(context);
                            } else {
                              AlertService.error(
                                title: "Error".tr(),
                                text: "Field is required".tr(),
                              );
                            }
                          }),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(10),
                    child: Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        child: CustomButton(
                          title: 'update'.tr(),
                          onPressed: () async {
                            bool checkUpdate = false;
                            // await widget.model.getLongLatFromAddress(
                            //     widget.model.addressTEC.text);
                            // checkUpdate = await widget.model.updateCar(
                            //   id: widget.data!.id!,
                            //   longitude: widget.model.longitude.toString(),
                            //   latitude: widget.model.latitude.toString(),
                            // );
                            // if (checkUpdate) {
                            //   widget.updateLocation!(
                            //       widget.model.latitude.toString(),
                            //       widget.model.longitude.toString());
                            //   await AlertService.success(
                            //     title: "Sửa thành công".tr(),
                            //     text: "Sửa địa chỉ xe thành công".tr(),
                            //   );
                            //   print('Sửa thành công');
                            //   Navigator.pop(context);
                            // } else {
                            //   print('Sửa thất bại');
                            // }
                            Navigator.pop(context);
                          },
                        )),
                  ),
          ));
        },
      );
    }
  }

  Widget buildAddressWidget() {
    return BasePage(
      showAppBar: true,
      title: 'Địa chỉ xe'.tr(),
      showLeadingAction: true,
      onBackPressed: () {
        isAddressSet = false;
        print('pop');
        print('${widget.model.latitude.toString()}');
        widget.updateLocation!(widget.model.latitude.toString(),
            widget.model.longitude.toString());
        Navigator.pop(context);
      },
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'Please provide the exact location of the vehicle you are renting'
                  .tr(),
            ),
          ),
          TextFormField(
            controller: widget.model.addressTEC,
            onTap: () {
              context.nextPage(AddAddressDetailPage(model: widget.model));
            },
            readOnly: true,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            decoration: InputDecoration(
              label: Text(
                'Detailed address'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
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
                      if (widget.model.addressTEC.text != '') {
                        Navigator.pop(context);
                      } else {
                        AlertService.error(
                          title: "Error".tr(),
                          text: "Field is required".tr(),
                        );
                      }
                    }),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  child: CustomButton(
                    title: 'Completed'.tr(),
                    onPressed: () async {
                      // bool checkUpdate = false;
                      // await widget.model.getLongLatFromAddress(
                      //     widget.model.addressTEC.text);
                      // checkUpdate = await widget.model.updateCar(
                      //   id: widget.data!.id!,
                      //   longitude: widget.model.longitude.toString(),
                      //   latitude: widget.model.latitude.toString(),
                      // );
                      // if (checkUpdate) {
                      //   widget.updateLocation!(widget.model.latitude.toString(),
                      //       widget.model.longitude.toString());
                      //   await AlertService.success(
                      //     title: "Sửa thành công".tr(),
                      //     text: "Sửa địa chỉ xe thành công".tr(),
                      //   );
                      //   print('Sửa thành công');
                      //   Navigator.pop(context);
                      // } else {
                      //   print('Sửa thất bại');
                      // }
                    },
                  )),
            ),
    );
  }

  Future<Address?> getAddressFromCoordinates(
      double latitude, double longitude) async {
    if (latitude > 90) {
      latitude = 90.0;
    }
    final coordinates = Coordinates(latitude, longitude);
    var addresses =
        await GeocoderService().findAddressesFromCoordinates(coordinates);
    if (addresses.isNotEmpty) {
      return addresses.first;
    }
    return null;
  }

  @override
  bool get wantKeepAlive => true;
}
