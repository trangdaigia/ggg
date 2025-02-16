import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/services/alert.service.dart';
import 'package:sod_user/view_models/car_rental.view_model.dart';
import 'package:sod_user/views/pages/car_rental/car_rental/car_rental.page.dart';

class PickAddressPage extends StatefulWidget {
  const PickAddressPage({super.key});

  @override
  State<PickAddressPage> createState() => _PickAddressPageState();
}

class _PickAddressPageState extends State<PickAddressPage> {
  late CarRentalViewModel model;

  @override
  void initState() {
    super.initState();
    model = CarRentalViewModel();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Địa chỉ".tr()),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 10,
          ),
          child: SingleChildScrollView(
            controller: ScrollController(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.1,
                      child: IconButton(
                        icon: Icon(Icons.add_location),
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Tên thành phố hoặc địa điểm cụ thể'.tr(),
                        ),
                        controller: model.addressController,
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
                          'Sử dụng vị trí hiện tại của tôi'.tr(),
                          style: TextStyle(fontSize: 16),
                        ),
                        onTap: () async {
                          model.getCurrentLocation().whenComplete(
                            () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CarRentalPage(
                                    model: model,
                                  ),
                                ),
                              );
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
                          model
                              .getLongLatFromAddress(
                                  'Chợ Bến Thành, Quận 1, TP HCM')
                              .whenComplete(
                            () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CarRentalPage(
                                    model: model,
                                  ),
                                ),
                              );
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
                          model
                              .getLongLatFromAddress(
                                  'Thành phố Đà Lạt, Lâm Đồng')
                              .whenComplete(
                            () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CarRentalPage(
                                    model: model,
                                  ),
                                ),
                              );
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
                          model
                              .getLongLatFromAddress('Bến xe Miền Đông, TP HCM')
                              .whenComplete(
                            () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CarRentalPage(
                                    model: model,
                                  ),
                                ),
                              );
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
                          model
                              .getLongLatFromAddress(
                                  'Sân bay Tân Sơn Nhất, TP HCM')
                              .whenComplete(
                            () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CarRentalPage(
                                    model: model,
                                  ),
                                ),
                              );
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
            child: ElevatedButton(
              child: Text('Xong'.tr()),
              onPressed: () {
                if (model.addressController.text != '') {
                  model
                      .getLongLatFromAddress(model.addressController.text)
                      .whenComplete(
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CarRentalPage(
                            model: model,
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  AlertService.error(
                    title: "Error".tr(),
                    text: "Vui lòng chọn địa điểm cụ thể".tr(),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
