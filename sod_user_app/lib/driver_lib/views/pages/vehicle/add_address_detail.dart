import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/driver_lib/services/alert.service.dart';
import 'package:sod_user/driver_lib/view_models/new_vehicle.vm.dart';
import 'package:sod_user/driver_lib/widgets/buttons/custom_button.dart';

class AddAddressDetailPage extends StatefulWidget {
  final NewVehicleViewModel model;
  const AddAddressDetailPage({super.key, required this.model});

  @override
  State<AddAddressDetailPage> createState() => _AddAddressDetailPageState();
}

class _AddAddressDetailPageState extends State<AddAddressDetailPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 5,
          ),
          child: SingleChildScrollView(
            controller: ScrollController(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.1,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.1,
                      child: IconButton(
                        icon: Icon(Icons.add_location),
                        onPressed: () {
                          if (widget.model.addressTEC.text != '') {
                            widget.model
                                .getLongLatFromAddress(
                                    widget.model.addressTEC.text)
                                .whenComplete(
                              () {
                                Navigator.pop(context);
                              },
                            );
                          } else {
                            AlertService.error(
                              title: "Error".tr(),
                              text: "Please select a specific location".tr(),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Name of a specific city or location'.tr(),
                        ),
                        controller: widget.model.addressTEC,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.1,
                      child: IconButton(
                        icon: Icon(Icons.my_location),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: GestureDetector(
                        child: Text(
                          'Use my current location'.tr(),
                          style: TextStyle(fontSize: 16),
                        ),
                        onTap: () async {
                          widget.model.getCurrentLocation().whenComplete(
                            () {
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.1,
                      child: IconButton(
                        icon: Icon(Icons.av_timer),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: GestureDetector(
                        child: Text(
                          'Chợ Bến Thành, Quận 1, TP HCM'.tr(),
                          style: TextStyle(fontSize: 16),
                        ),
                        onTap: () async {
                          widget.model
                              .getLongLatFromAddress(
                                  'Chợ Bến Thành, Quận 1, TP HCM')
                              .whenComplete(
                            () {
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.1,
                      child: IconButton(
                        icon: Icon(Icons.apartment),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: GestureDetector(
                        child: Text(
                          'Thành phố Đà Lạt, Lâm Đồng'.tr(),
                          style: TextStyle(fontSize: 16),
                        ),
                        onTap: () async {
                          widget.model
                              .getLongLatFromAddress(
                                  'Thành phố Đà Lạt, Lâm Đồng')
                              .whenComplete(
                            () {
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.1,
                      child: IconButton(
                        icon: Icon(Icons.directions_bus),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: GestureDetector(
                        child: Text(
                          'Bến xe Miền Đông, TP HCM'.tr(),
                          style: TextStyle(fontSize: 16),
                        ),
                        onTap: () async {
                          widget.model
                              .getLongLatFromAddress('Bến xe Miền Đông, TP HCM')
                              .whenComplete(
                            () {
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.1,
                      child: IconButton(
                        icon: Icon(Icons.local_airport),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: GestureDetector(
                        child: Text(
                          'Sân bay Tân Sơn Nhất, TP HCM'.tr(),
                          style: TextStyle(fontSize: 16),
                        ),
                        onTap: () async {
                          widget.model
                              .getLongLatFromAddress(
                                  'Sân bay Tân Sơn Nhất, TP HCM')
                              .whenComplete(
                            () {
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              // child: ElevatedButton(
              //   child: Text('Xong'.tr()),
              //   onPressed: () {
              //     if (widget.model.addressTEC.text != '') {
              //       widget.model
              //           .getLongLatFromAddress(
              //               widget.model.addressTEC.text)
              //           .whenComplete(
              //         () {
              //           Navigator.pop(context);
              //         },
              //       );
              //     } else {
              //       AlertService.error(
              //         title: "Error".tr(),
              //         text: "Vui lòng chọn địa điểm cụ thể".tr(),
              //       );
              //     }
              //   },
              //   style: ElevatedButton.styleFrom(
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(25),
              //     ),
              //   ),
              // ),
              child: CustomButton(
                title: 'Xong'.tr(),
                onPressed: () {
                  if (widget.model.addressTEC.text != '') {
                    widget.model
                        .getLongLatFromAddress(widget.model.addressTEC.text)
                        .whenComplete(
                      () {
                        Navigator.pop(context);
                      },
                    );
                  } else {
                    AlertService.error(
                      title: "Error".tr(),
                      text: "Please select a specific location".tr(),
                    );
                  }
                },
              )),
        ),
      ),
    );
  }
}
