import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/models/address.dart';
import 'package:sod_user/models/car_rental.dart';
import 'package:sod_user/services/alert.service.dart';
import 'package:sod_user/services/navigation.service.dart';
import 'package:sod_user/utils/utils.dart';
import 'package:sod_user/view_models/car_management.view_model.dart';
import 'package:sod_user/view_models/shared_ride.vm.dart';
import 'package:sod_user/views/pages/shared_ride/post_ride_info.page.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/widgets/busy_indicator.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:sod_user/services/geocoder.service.dart' as geocoderService;

class AddAddressPage extends StatefulWidget {
  final CarManagementViewModel model;
  const AddAddressPage({
    super.key,
    required this.model,
    this.showNext = true,
    this.longitude,
    this.latitude,
    this.data,
    this.updateLocation,
    this.shareRideModel,
    this.index,
  });

  final bool showNext;
  final CarRental? data;
  final String? latitude;
  final String? longitude;
  final Function(String, String)? updateLocation;
  final SharedRideViewModel? shareRideModel;
  final int? index;

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

bool isAddressSet = false;

class _AddAddressPageState extends State<AddAddressPage>
    with AutomaticKeepAliveClientMixin {
  bool isLoading = false;
  String? location;
  Address? address;

  @override
  void initState() {
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
      var latitudeToGet = widget.latitude!;
      var longitudeToGet = widget.longitude!;
      if (widget.index != null) {
        latitudeToGet = widget.model.carRental[widget.index!].latitude!;
        longitudeToGet = widget.model.carRental[widget.index!].longitude!;
      }
      return FutureBuilder<Address?>(
        //
        future: getAddressFromCoordinates(
          double.parse(latitudeToGet),
          double.parse(longitudeToGet),
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return BasePage(
              showAppBar: true,
              title: 'Vehicle address'.tr(),
              body: BusyIndicator().centered(),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading address'));
          } else if (snapshot.hasData) {
            if (!isAddressSet) {
              Address? address = snapshot.data;
              widget.model.addressController.text =
                  '${address!.addressLine ?? ''}';
              isAddressSet = true;
            }
            return buildAddressWidget();
          } else {
            return Center(child: Text('No data'));
          }
        },
      );
    } else {
      return ViewModelBuilder<CarManagementViewModel>.nonReactive(
        viewModelBuilder: () => widget.model,
        builder: (context, viewModel, child) {
          return SafeArea(
              child: Scaffold(
            backgroundColor: AppColor.onboarding3Color,
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(
                  !Utils.isArabic
                      ? FlutterIcons.arrow_left_fea
                      : FlutterIcons.arrow_right_fea,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
                onPressed: widget.shareRideModel != null
                    ? () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PostRideInfoPage(
                                model: widget.shareRideModel!)))
                    : () => Navigator.pop(context),
              ),
              backgroundColor: context.backgroundColor,
              title: Text("Add Car".tr(),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'Please provide the exact location of the vehicle you are renting'
                          .tr(),
                    ),
                  ),
                  TextFormField(
                    controller: widget.model.addressController,
                    onTap: () => context.nextPage(
                      NavigationService().addCarRentalPage(
                        shareRideModel: widget.shareRideModel,
                        model: widget.model,
                        type: "address_detail",
                      ),
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
                            if (widget.model.addressController.text != '') {
                              context.nextPage(
                                  NavigationService().addCarRentalPage(
                                shareRideModel: widget.shareRideModel,
                                model: widget.model,
                                type: "utilities",
                              ));
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
                          title: 'Cập nhật'.tr(),
                          onPressed: () async {
                            bool checkUpdate = false;
                            await widget.model.getLongLatFromAddress(
                                widget.model.addressController.text);
                            checkUpdate = await widget.model.updateCar(
                              id: widget.data!.id!,
                              longitude: widget.model.longitude.toString(),
                              latitude: widget.model.latitude.toString(),
                            );
                            if (checkUpdate) {
                              widget.updateLocation!(
                                  widget.model.latitude.toString(),
                                  widget.model.longitude.toString());
                              await AlertService.success(
                                title: "Sửa thành công".tr(),
                                text: "Sửa địa chỉ xe thành công".tr(),
                              );
                              print('Sửa thành công');
                              Navigator.pop(context);
                            } else {
                              print('Sửa thất bại');
                            }
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
      title: 'Vehicle address'.tr(),
      showLeadingAction: true,
      onBackPressed: () {
        isAddressSet = false;
        widget.updateLocation!(widget.model.latitude.toString(),
            widget.model.longitude.toString());
        Navigator.pop(context);
      },
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
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
              controller: widget.model.addressController,
              onTap: () {
                context.nextPage(
                  NavigationService().addCarRentalPage(
                    model: widget.model,
                    type: "address_detail",
                  ),
                );
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
                      // if (widget.model.addressController.text != '') {
                      context.nextPage(NavigationService().addCarRentalPage(
                        model: widget.model,
                        type: "utilities",
                      ));
                      // } else {
                      //   AlertService.error(
                      //     title: "Error".tr(),
                      //     text: "Field is required".tr(),
                      //   );
                      // }
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
                    loading: isLoading,
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      bool checkUpdate = false;
                      await widget.model.getLongLatFromAddress(
                          widget.model.addressController.text);
                      checkUpdate = await widget.model.updateCar(
                        id: widget.data!.id!,
                        longitude: widget.model.longitude.toString(),
                        latitude: widget.model.latitude.toString(),
                      );
                      if (checkUpdate) {
                        widget.updateLocation!(widget.model.latitude.toString(),
                            widget.model.longitude.toString());
                        await AlertService.success(
                          title: "Sửa thành công".tr(),
                          text: "Sửa địa chỉ xe thành công".tr(),
                        );
                        final thisCarDataIndex = widget.model.carRental.indexWhere((element) => element.id == widget.data!.id);
                        widget.model.carRental[thisCarDataIndex].latitude = widget.model.latitude.toString();
                        widget.model.carRental[thisCarDataIndex].longitude = widget.model.longitude.toString();
                        print('Sửa thành công');
                        Navigator.pop(context);
                      } else {
                        print('Sửa thất bại');
                      }
                      setState(() {
                        isLoading = false;
                      });
                    },
                  )),
            ),
    );
  }

  Future<geocoderService.Address?> getAddressFromCoordinates(
      double latitude, double longitude) async {
    if (latitude > 90) {
      latitude = 90.0;
    }
    final coordinates = geocoderService.Coordinates(latitude, longitude);
    geocoderService.GeocoderService service = geocoderService.GeocoderService();
    List<geocoderService.Address> lstAddress = [];
    lstAddress = await service.findAddressesFromCoordinates(coordinates);
    return lstAddress.first;
  }

  @override
  bool get wantKeepAlive => true;
}
