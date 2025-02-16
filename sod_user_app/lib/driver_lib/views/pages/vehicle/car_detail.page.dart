// import 'package:flutter/material.dart';
// import 'package:localize_and_translate/localize_and_translate.dart';
// import 'package:sod_user/driver_lib/constants/app_colors.dart';
// import 'package:sod_user/driver_lib/models/vehicle.dart';
// import 'package:sod_user/driver_lib/view_models/vehicles.vm.dart';
// import 'package:sod_user/driver_lib/widgets/base.page.dart';
// import 'package:stacked/stacked.dart';
// import 'package:velocity_x/velocity_x.dart';

// class MyCarDetailPage extends StatefulWidget {
//   const MyCarDetailPage({super.key, required this.model, required this.data});
//   final VehiclesViewModel model;
//   final Vehicle  data;

//   @override
//   State<MyCarDetailPage> createState() => _MyCarDetailPageState();
// }

// class _MyCarDetailPageState extends State<MyCarDetailPage> {
//   String? latitude;
//   String? longitude;
//   @override
//   Widget build(BuildContext context) {
//     return ViewModelBuilder<VehiclesViewModel>.reactive(
//         disposeViewModel: false,
//         viewModelBuilder: () => widget.model,
//         builder: (context, viewModel, child) {
//           return BasePage(
//               showLeadingAction: true,
//               showAppBar: true,
//               title: 'Quản lí xe'.tr(),
//               body: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 10.0),
//                 child: DefaultTabController(
//                   length: 2,
//                   child: Column(
//                     children: [
//                       TabBar(
//                         unselectedLabelStyle:
//                             TextStyle(fontWeight: FontWeight.normal),
//                         labelStyle: TextStyle(fontWeight: FontWeight.bold),
//                         labelColor: context.textTheme.bodyLarge?.color,
//                         tabs: [
//                           Tab(
//                             text: 'Thông tin'.tr(),
//                           ),
//                           Tab(text: 'Settings'.tr()),
//                         ],
//                       ),
//                       Expanded(
//                         child: TabBarView(
//                           children: [
//                             // Tab Thông tin
//                             ListView(
//                               children: [
//                                 CustomBtn(
//                                     'Hình ảnh xe'.tr(), context, viewModel),
//                                 CustomBtn(
//                                     'Địa chỉ xe'.tr(), context, viewModel),
//                                 CustomBtn('Tiện ích'.tr(), context, viewModel),
//                                 CustomBtn('Mô tả xe'.tr(), context, viewModel),
//                                 CustomBtn('Hình ảnh giấy tờ xe'.tr(), context,
//                                     viewModel),
//                                 CustomBtn(
//                                     'Chi tiết xe'.tr(), context, viewModel),
//                               ],
//                             ),
//                             // Tab Cài đặt
//                             ListView(
//                               children: [
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   children: [
//                                     'Định giá'.tr().text.bold.make(),
//                                   ],
//                                 ),
//                                 CustomBtn(
//                                     'Giá mỗi ngày'.tr(), context, viewModel),
//                                 //CustomBtn('Phụ phí', context),
//                                 SizedBox(
//                                   height: 10,
//                                 ),
//                                 // Row(
//                                 //   mainAxisAlignment: MainAxisAlignment.start,
//                                 //   children: [
//                                 //     'Lịch'.text.bold.make(),
//                                 //   ],
//                                 // ),
//                                 // CustomBtn('Thay đổi giá từng ngày', context),
//                                 // CustomBtn(
//                                 //     'Cài đặt nhanh các ngày bận', context),
//                                 // CustomBtn(
//                                 //     'Cài đặt các ngày bận định kỳ', context),
//                                 // SizedBox(
//                                 //   height: 10,
//                                 // ),
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   children: [
//                                     'Đặt xe'.tr().text.bold.make(),
//                                   ],
//                                 ),
//                                 CustomBtn('Giấy tờ khi thuê xe'.tr(), context,
//                                     viewModel),
//                                 CustomBtn('Tài sản thế chấp'.tr(), context,
//                                     viewModel),
//                                 //   'Thời gian thuê xe tối thiểu', context),
//                                 SizedBox(
//                                   height: 10,
//                                 ),
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   children: [
//                                     'Quản lí'.tr().text.bold.make(),
//                                   ],
//                                 ),
//                                 CustomBtn('Trạng thái thuê xe'.tr(), context,
//                                     viewModel),
//                                 CustomBtn(
//                                     'Đặt xe nhanh'.tr(), context, viewModel),
//                                 CustomBtn(
//                                     'Giao xe tận nơi'.tr(), context, viewModel),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ));
//         });
//   }

//   void updateLocation(String? latitude, String? longitude) {
//     setState(() {
//       widget.data.latitude = latitude;
//       widget.data.longitude = longitude;
//     });
//   }

//   bool deliveryToHome = false;
//   bool fastBooking = false;
//   bool mortgageExemption = false;
//   bool showBottomSheet = false;
//   Container CustomBtn(
//       String label, BuildContext context, VehiclesViewModel model) {
//     return Container(
//       decoration: BoxDecoration(
//         border: Border(
//           bottom: BorderSide(color: Colors.grey.withOpacity(0.5)),
//         ),
//       ),
//       child: ListTile(
//         //leading: Icon(icon),
//         title: Text(
//           label,
//           style: TextStyle(fontWeight: FontWeight.w500),
//         ),
//         trailing: Icon(Icons.arrow_forward_ios_outlined,
//             color: AppColor.primaryColor, size: 20),
//         onTap: () {
//           if (label == 'Hình ảnh xe'.tr()) {
//             showModalBottomSheet(
//               barrierColor: Colors.transparent,
//               useRootNavigator: true,
//               isScrollControlled: true,
//               context: context,
//               useSafeArea: true,
//               builder: (context) => AddCarPhotosPage(
//                 showNext: false,
//                 model: widget.model,
//               ),
//             );
//           } else if (label == 'Địa chỉ xe'.tr()) {
//             showModalBottomSheet(
//               barrierColor: Colors.transparent,
//               useRootNavigator: true,
//               isScrollControlled: true,
//               context: context,
//               useSafeArea: true,
//               builder: (context) => AddAddressPage(
//                 data: widget.data,
//                 updateLocation: updateLocation,
//                 latitude: widget.data.latitude,
//                 longitude: widget.data.longitude,
//                 showNext: false,
//                 model: widget.model,
//               ),
//             );
//           } else if (label == 'Tiện ích'.tr()) {
//             showModalBottomSheet(
//                 barrierColor: Colors.transparent,
//                 useRootNavigator: true,
//                 isScrollControlled: true,
//                 context: context,
//                 useSafeArea: true,
//                 builder: (context) => AddUtilitiesPage(
//                       model: widget.model,
//                       data: widget.data,
//                       showNext: false,
//                     ));
//           } else if (label == 'Mô tả xe'.tr()) {
//             showModalBottomSheet(
//                 barrierColor: Colors.transparent,
//                 useRootNavigator: true,
//                 isScrollControlled: true,
//                 context: context,
//                 useSafeArea: true,
//                 builder: (context) => BasePage(
//                       showAppBar: true,
//                       title: 'Mô tả xe'.tr(),
//                       showLeadingAction: true,
//                       body: Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 10.0, vertical: 20),
//                         child: Column(children: [
//                           'Vui lòng giới thiệu đôi lời về chiếc xe cho thuê của bạn. Điều này sẽ giúp khách hàng hiểu và dễ lựa chọn hơn'
//                               .tr()
//                               .text
//                               .make(),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: [
//                               'Mô tả xe'
//                                   .tr()
//                                   .text
//                                   .semiBold
//                                   .make()
//                                   .pOnly(top: 10, bottom: 10),
//                             ],
//                           ),
//                           TextFormField(
//                             maxLines: 4,
//                             controller: widget.model.describeController,
//                             decoration: InputDecoration(
//                               border: OutlineInputBorder(),
//                             ),
//                           ),
//                           SizedBox(
//                             height: 10,
//                           ),
//                           CustomButton(
//                             title: 'Completed'.tr(),
//                             onPressed: () {},
//                           ),
//                         ]),
//                       ),
//                     ));
//           } else if (label == 'Hình ảnh giấy tờ xe'.tr()) {
//             showModalBottomSheet(
//                 barrierColor: Colors.transparent,
//                 useRootNavigator: true,
//                 isScrollControlled: true,
//                 context: context,
//                 useSafeArea: true,
//                 builder: (context) => ImageOfVehicleDocuments(
//                       model: widget.model,
//                     ));
//           } else if (label == 'Giá mỗi ngày'.tr()) {
//             showModalBottomSheet(
//                 barrierColor: Colors.transparent,
//                 useRootNavigator: true,
//                 isScrollControlled: true,
//                 context: context,
//                 useSafeArea: true,
//                 builder: (context) => AddPricePage(
//                       model: widget.model,
//                       data: widget.data,
//                       showNext: false,
//                     ));
//           } else if (label == 'Giấy tờ khi thuê xe'.tr()) {
//             showModalBottomSheet(
//                 barrierColor: Colors.transparent,
//                 useRootNavigator: true,
//                 isScrollControlled: true,
//                 context: context,
//                 useSafeArea: true,
//                 builder: (context) => AddRequirementPage(
//                       model: widget.model,
//                       data: widget.data,
//                       showNext: false,
//                     ));
//           } else if (label == 'Tài sản thế chấp'.tr()) {
//             mortgageExemption = !widget.data.mortgageExemption!;
//             showModalBottomSheet(
//                 barrierColor: Colors.transparent,
//                 useRootNavigator: true,
//                 isScrollControlled: true,
//                 context: context,
//                 useSafeArea: true,
//                 builder: (context) => StatefulBuilder(
//                         builder: (BuildContext context, StateSetter _setState) {
//                       return BasePage(
//                           showAppBar: true,
//                           showLeadingAction: true,
//                           title: 'Tài sản thế chấp'.tr(),
//                           body: Padding(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 10.0, vertical: 20),
//                             child: Column(children: [
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 children: [
//                                   'Thiết lập tài sản thế chấp yêu cầu khi thuê xe.'
//                                       .tr()
//                                       .text
//                                       .make(),
//                                 ],
//                               ).pOnly(bottom: 20),
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   SizedBox(
//                                     width:
//                                         MediaQuery.of(context).size.width / 1.5,
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         '15 triệu (tiền mặt/chuyển khoản cho chủ xe khi nhận xe)'
//                                             .tr()
//                                             .text
//                                             .color(Colors.grey)
//                                             .make(),
//                                         'hoặc Xe máy (kèm cà vẹt gốc) giá trị 15 triệu'
//                                             .tr()
//                                             .text
//                                             .color(Colors.grey)
//                                             .make(),
//                                       ],
//                                     ),
//                                   ),
//                                   CupertinoSwitch(
//                                       activeColor: AppColor.primaryColor,
//                                       value: mortgageExemption,
//                                       onChanged: (value) {
//                                         _setState(() {
//                                           mortgageExemption = value;
//                                         });
//                                       })
//                                 ],
//                               ),
//                             ]),
//                           ),
//                           bottomNavigationBar: CustomButton(
//                             title: 'update'.tr(),
//                             onPressed: () {
//                               model.changeStatusMortgageExemption(
//                                 id: widget.data.id.toString(),
//                                 status: mortgageExemption ? '0' : '1',
//                               );
//                               widget.data.mortgageExemption =
//                                   !mortgageExemption;
//                             },
//                           ));
//                     }));
//           } else if (label == 'Trạng thái thuê xe'.tr()) {
//             showModalBottomSheet(
//                 barrierColor: Colors.transparent,
//                 useRootNavigator: true,
//                 isScrollControlled: true,
//                 context: context,
//                 useSafeArea: true,
//                 builder: (context) => StatefulBuilder(
//                         builder: (BuildContext context, StateSetter _setState) {
//                       return BasePage(
//                         showAppBar: true,
//                         showLeadingAction: true,
//                         title: 'Trạng thái thuê xe'.tr(),
//                         body: Padding(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 10.0, vertical: 20),
//                           child: Column(children: [
//                             translator.activeLanguageCode == "vi"
//                                 ? 'Thiết lập trạng thái hoạt động của xe ở chế độ đang hoạt động hoặc không'
//                                     .tr()
//                                     .text
//                                     .make()
//                                 : Row(
//                                     mainAxisAlignment: MainAxisAlignment.start,
//                                     children: [
//                                       'Thiết lập trạng thái hoạt động của xe ở chế độ đang hoạt động hoặc không'
//                                           .tr()
//                                           .text
//                                           .make(),
//                                     ],
//                                   ),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               children: [
//                                 'Thay đổi trạng thái xe cho thuê'
//                                     .tr()
//                                     .text
//                                     .bold
//                                     .make()
//                                     .pOnly(top: 10, bottom: 10),
//                               ],
//                             ),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 'Trạng thái hoạt động'.tr().text.make(),
//                                 CupertinoSwitch(
//                                     value: widget.data.rentStatus == 1
//                                         ? true
//                                         : false,
//                                     onChanged: (value) async {
//                                       widget.model
//                                           .changeStatusCarRental(
//                                         id: widget.data.id.toString(),
//                                         status: value == true ? "1" : "0",
//                                       )
//                                           .then((_) {
//                                         _setState(() {
//                                           widget.data.rentStatus =
//                                               value == true ? 1 : 0;
//                                         });
//                                       });
//                                     })
//                               ],
//                             ),
//                             SizedBox(
//                               height: 10,
//                             ),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 'Xóa xe cho thuê'.tr().text.make(),
//                                 IconButton(
//                                     onPressed: () async {
//                                       return showDialog(
//                                         context: context,
//                                         useSafeArea: true,
//                                         builder: (context) => AlertDialog(
//                                           title: Text('delete_warning'.tr()),
//                                           actions: [
//                                             Row(
//                                               children: [
//                                                 Expanded(
//                                                   child:
//                                                       GlobalButton.buildButton(
//                                                     context,
//                                                     title: 'Yes'.tr(),
//                                                     btnColor:
//                                                         AppColor.primaryColor,
//                                                     txtColor: Colors.white,
//                                                     onPress: () {
//                                                       widget.model.deleteCar(
//                                                         id: widget.data.id
//                                                             .toString(),
//                                                       );
//                                                       Navigator.pop(context);
//                                                       Navigator.pop(context);
//                                                       Navigator.pop(context);
//                                                     },
//                                                   ),
//                                                 ),
//                                                 const SizedBox(width: 10),
//                                                 Expanded(
//                                                   child:
//                                                       GlobalButton.buildButton(
//                                                     context,
//                                                     title: 'No'.tr(),
//                                                     btnColor: Colors.red,
//                                                     txtColor: Colors.white,
//                                                     onPress: () =>
//                                                         Navigator.pop(context),
//                                                   ),
//                                                 ),
//                                               ],
//                                             )
//                                           ],
//                                         ),
//                                       );
//                                     },
//                                     icon: Icon(Icons.delete))
//                               ],
//                             ),
//                           ]),
//                         ),
//                       );
//                     }));
//           } else if (label == 'Chi tiết xe'.tr()) {
//             showModalBottomSheet(
//                 barrierColor: Colors.transparent,
//                 useRootNavigator: true,
//                 isScrollControlled: true,
//                 context: context,
//                 useSafeArea: true,
//                 builder: (context) => AddCarDetailPage(
//                       model: widget.model,
//                       data: widget.data,
//                       showNext: false,
//                     ));
//           } else if (label == 'Đặt xe nhanh'.tr()) {
//             fastBooking = widget.data.fastBooking!;
//             showModalBottomSheet(
//                 barrierColor: Colors.transparent,
//                 useRootNavigator: true,
//                 isScrollControlled: true,
//                 context: context,
//                 useSafeArea: true,
//                 builder: (context) => StatefulBuilder(
//                         builder: (BuildContext context, StateSetter _setState) {
//                       return BasePage(
//                           showAppBar: true,
//                           showLeadingAction: true,
//                           title: 'Đặt xe nhanh'.tr(),
//                           body: Padding(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 10.0, vertical: 20),
//                             child: Column(children: [
//                               'Yêu cầu thuê xe từ khách thuê sẽ được tự động đồng ý trong khoản thời gian bạn cài đặt.'
//                                   .tr()
//                                   .text
//                                   .make(),
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   'Đặt xe nhanh'.tr().toUpperCase().text.make(),
//                                   CupertinoSwitch(
//                                       activeColor: AppColor.primaryColor,
//                                       value: fastBooking,
//                                       onChanged: (value) {
//                                         _setState(() {
//                                           fastBooking = value;
//                                         });
//                                       })
//                                 ],
//                               ),
//                             ]),
//                           ),
//                           bottomNavigationBar: CustomButton(
//                             title: 'update'.tr(),
//                             onPressed: () {
//                               model.changeStatusFastBooking(
//                                 id: widget.data.id.toString(),
//                                 status: fastBooking ? '1' : '0',
//                               );
//                               widget.data.fastBooking = fastBooking;
//                             },
//                           ));
//                     }));
//           } else if (label == "Giao xe tận nơi".tr()) {
//             deliveryToHome = widget.data.deliveryToHome!;
//             showModalBottomSheet(
//                 barrierColor: Colors.transparent,
//                 useRootNavigator: true,
//                 isScrollControlled: true,
//                 context: context,
//                 useSafeArea: true,
//                 builder: (context) => StatefulBuilder(
//                         builder: (BuildContext context, StateSetter _setState) {
//                       return BasePage(
//                           showAppBar: true,
//                           showLeadingAction: true,
//                           title: 'Giao xe tận nơi'.tr(),
//                           body: Padding(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 10.0, vertical: 20),
//                             child: Column(children: [
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   'Giao xe tận nơi'.tr().text.make(),
//                                   CupertinoSwitch(
//                                       activeColor: AppColor.primaryColor,
//                                       value: deliveryToHome,
//                                       onChanged: (value) {
//                                         _setState(() {
//                                           deliveryToHome = value;
//                                         });
//                                       })
//                                 ],
//                               ),
//                               deliveryToHome
//                                   ? Column(
//                                       children: [
//                                         Column(
//                                           children: [
//                                             Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment
//                                                       .spaceBetween,
//                                               children: [
//                                                 'Giao xe tận nơi trong vòng'
//                                                     .tr()
//                                                     .text
//                                                     .make(),
//                                                 '${widget.data.deliveryDistance} km'
//                                                     .text
//                                                     .make()
//                                               ],
//                                             ),
//                                             Slider(
//                                               inactiveColor:
//                                                   Colors.grey.shade300,
//                                               activeColor:
//                                                   AppColor.primaryColor,
//                                               thumbColor: Colors.white,
//                                               value: double.parse(widget
//                                                   .data.deliveryDistance
//                                                   .toString()),
//                                               min: 5,
//                                               max: 50,
//                                               onChanged: (newValue) {
//                                                 _setState(() {
//                                                   widget.data.deliveryDistance =
//                                                       int.parse(newValue
//                                                           .round()
//                                                           .toString());
//                                                 });
//                                               },
//                                               divisions: 100,
//                                             ),
//                                           ],
//                                         ),
//                                         Column(
//                                           children: [
//                                             Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment
//                                                       .spaceBetween,
//                                               children: [
//                                                 'Phí giao nhận xe (2 chiều)'
//                                                     .tr()
//                                                     .text
//                                                     .make(),
//                                                 '${widget.data.deliveryFee == 0 ? 'Miễn phí'.tr() : '${widget.data.deliveryFee} K/km'}'
//                                                     .text
//                                                     .make()
//                                               ],
//                                             ),
//                                             Slider(
//                                               inactiveColor:
//                                                   Colors.grey.shade300,
//                                               activeColor:
//                                                   AppColor.primaryColor,
//                                               thumbColor: Colors.white,
//                                               value: double.parse(widget
//                                                   .data.deliveryFee
//                                                   .toString()),
//                                               min: 0,
//                                               max: 30,
//                                               onChanged: (newValue) {
//                                                 _setState(() {
//                                                   widget.data.deliveryFee =
//                                                       int.parse(newValue
//                                                           .round()
//                                                           .toString());
//                                                 });
//                                               },
//                                               divisions: 100,
//                                             ),
//                                           ],
//                                         ).pOnly(top: 20),
//                                         Column(
//                                           children: [
//                                             Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment
//                                                       .spaceBetween,
//                                               children: [
//                                                 'Miễn phí giao nhận xe trong vòng'
//                                                     .tr()
//                                                     .text
//                                                     .make(),
//                                                 '${widget.data.deliveryFree} km'
//                                                     .text
//                                                     .make()
//                                               ],
//                                             ),
//                                             Slider(
//                                               inactiveColor:
//                                                   Colors.grey.shade300,
//                                               activeColor:
//                                                   AppColor.primaryColor,
//                                               thumbColor: Colors.white,
//                                               value: double.parse(widget
//                                                   .data.deliveryFree
//                                                   .toString()),
//                                               min: 0,
//                                               max: 50,
//                                               onChanged: (newValue) {
//                                                 _setState(() {
//                                                   widget.data.deliveryFree =
//                                                       int.parse(newValue
//                                                           .round()
//                                                           .toString());
//                                                 });
//                                               },
//                                               divisions: 100,
//                                             ),
//                                           ],
//                                         ).pOnly(top: 20),
//                                       ],
//                                     ).pOnly(top: 20)
//                                   : SizedBox()
//                             ]),
//                           ),
//                           bottomNavigationBar: CustomButton(
//                             title: 'update'.tr(),
//                             onPressed: () {
//                               model.changeStatusDeliveryToHome(
//                                 id: widget.data.id.toString(),
//                                 status: deliveryToHome ? '1' : '0',
//                               );
//                               widget.data.deliveryToHome = deliveryToHome;
//                             },
//                           ));
//                     }));
//           }
//         },
//       ),
//     );
//   }
// }

// class ImageOfVehicleDocuments extends StatefulWidget {
//   const ImageOfVehicleDocuments({super.key, required this.model});
//   final CarManagementViewModel model;
//   @override
//   State<ImageOfVehicleDocuments> createState() =>
//       _ImageOfVehicleDocumentsState();
// }

// class _ImageOfVehicleDocumentsState extends State<ImageOfVehicleDocuments> {
//   @override
//   Widget build(BuildContext context) {
//     return BasePage(
//       showAppBar: true,
//       showLeadingAction: true,
//       title: 'Hình ảnh giấy tờ xe'.tr(),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               'Vui lòng chụp ảnh 2 mặt của các loại giấy tờ xe liên quan đến chiếc xe cho thuê của bạn'
//                   .tr()
//                   .text
//                   .make(),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   'Giấy cà vẹt xe'.tr().text.bold.make(),
//                 ],
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   addPicture(context, 'Giấy cà vẹt xe'),
//                 ],
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   'Giấy đăng kiểm'.tr().text.bold.make(),
//                 ],
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   addPicture(context, 'Giấy đăng kiểm'),
//                 ],
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   'Bảo hiểm trách nhiệm dân sự'.tr().text.bold.make(),
//                 ],
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   addPicture(context, 'Bảo hiểm trách nhiệm dân sự'),
//                 ],
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   'Bảo hiểm vật chất thân xe'.tr().text.bold.make(),
//                 ],
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   addPicture(context, 'Bảo hiểm vật chất thân xe'),
//                 ],
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 10),
//                 child: CustomButton(
//                   title: 'Completed'.tr(),
//                   onPressed: () {},
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Row addPicture(BuildContext context, String type) {
//     List<File>? photos;
//     if (type == 'Giấy cà vẹt xe') {
//       photos = widget.model.newCarParrotPhotos;
//     } else if (type == 'Giấy đăng kiểm') {
//       photos = widget.model.newRegistrationPhotos;
//     } else if (type == 'Bảo hiểm trách nhiệm dân sự') {
//       photos = widget.model.newCivilLiabilityInsurancePhotos;
//     } else {
//       photos = widget.model.newVehicleBodyInsurance;
//     }
//     return Row(
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(10.0),
//           child: photos == null || photos == []
//               ? DottedBorder(
//                   color: Colors.black,
//                   strokeWidth: 1,
//                   child: InkWell(
//                     onTap: () {
//                       if (type == 'Giấy cà vẹt xe') {
//                         widget.model.chooseCarParrotPhotos().whenComplete(
//                           () {
//                             setState(() {
//                               photos = widget.model.newCarParrotPhotos;
//                               print('Thêm ảnh ${type} thành công');
//                             });
//                           },
//                         );
//                       } else if (type == 'Giấy đăng kiểm') {
//                         widget.model.chooseRegistrationPhotos().whenComplete(
//                           () {
//                             setState(() {
//                               photos = widget.model.newRegistrationPhotos;
//                               print('Thêm ảnh ${type} thành công');
//                             });
//                           },
//                         );
//                       } else if (type == 'Bảo hiểm trách nhiệm dân sự') {
//                         widget.model
//                             .chooseCivilLiabilityInsurancePhotos()
//                             .whenComplete(
//                           () {
//                             setState(() {
//                               photos =
//                                   widget.model.newCivilLiabilityInsurancePhotos;
//                               print('Thêm ảnh ${type} thành công');
//                             });
//                           },
//                         );
//                       } else if (type == 'Bảo hiểm vật chất thân xe') {
//                         widget.model
//                             .chooseVehicleBodyInsurancePhotos()
//                             .whenComplete(
//                           () {
//                             setState(() {
//                               photos = widget.model.newVehicleBodyInsurance;
//                               print('Thêm ảnh ${type} thành công');
//                             });
//                           },
//                         );
//                       }
//                     },
//                     child: Container(
//                       alignment: Alignment.center,
//                       width: MediaQuery.of(context).size.width / 3.5,
//                       height: MediaQuery.of(context).size.width / 3.5,
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.add_circle_outline_outlined)
//                               .pOnly(bottom: 10),
//                           Text(
//                             'Add picture'.tr(),
//                             style: TextStyle(fontWeight: FontWeight.w600),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 )
//               : Container(
//                   width: MediaQuery.of(context).size.width / 3.5,
//                   height: MediaQuery.of(context).size.width / 3.5,
//                   child: Stack(
//                     fit: StackFit.expand,
//                     children: [
//                       ClipRRect(
//                         child: Image.file(
//                           photos[0],
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                       Positioned(
//                         top: 0,
//                         right: 0,
//                         child: IconButton(
//                           icon: Icon(Icons.cancel_outlined),
//                           onPressed: () {
//                             setState(() {
//                               if (type == 'Giấy cà vẹt xe') {
//                                 if (widget.model.newCarParrotPhotos!.length -
//                                         1 ==
//                                     0) {
//                                   widget.model.newCarParrotPhotos = null;
//                                 } else {
//                                   widget.model.newCarParrotPhotos!.removeAt(0);
//                                 }
//                               } else if (type == 'Giấy đăng kiểm') {
//                                 if (widget.model.newRegistrationPhotos!.length -
//                                         1 ==
//                                     0) {
//                                   widget.model.newRegistrationPhotos = null;
//                                 } else {
//                                   widget.model.newRegistrationPhotos!
//                                       .removeAt(0);
//                                 }
//                               } else if (type ==
//                                   'Bảo hiểm trách nhiệm dân sự') {
//                                 if (widget
//                                             .model
//                                             .newCivilLiabilityInsurancePhotos!
//                                             .length -
//                                         1 ==
//                                     0) {
//                                   widget.model
//                                       .newCivilLiabilityInsurancePhotos = null;
//                                 } else {
//                                   widget.model.newCivilLiabilityInsurancePhotos!
//                                       .removeAt(0);
//                                 }
//                               } else {
//                                 if (widget.model.newVehicleBodyInsurance!
//                                             .length -
//                                         1 ==
//                                     0) {
//                                   widget.model.newVehicleBodyInsurance = null;
//                                 } else {
//                                   widget.model.newVehicleBodyInsurance!
//                                       .removeAt(0);
//                                 }
//                               }
//                             });
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//         ),
//         Padding(
//           padding: const EdgeInsets.all(10.0),
//           child: (photos == null || photos == []) ||
//                   (photos != null && photos!.length == 1)
//               ? DottedBorder(
//                   color: Colors.black,
//                   strokeWidth: 1,
//                   child: InkWell(
//                     onTap: () {
//                       if (type == 'Giấy cà vẹt xe') {
//                         widget.model.chooseCarParrotPhotos().whenComplete(
//                           () {
//                             setState(() {
//                               photos = widget.model.newCarParrotPhotos;
//                               print('Thêm ảnh ${type} thành công');
//                             });
//                           },
//                         );
//                       } else if (type == 'Giấy đăng kiểm') {
//                         widget.model.chooseRegistrationPhotos().whenComplete(
//                           () {
//                             setState(() {
//                               photos = widget.model.newRegistrationPhotos;
//                               print('Thêm ảnh ${type} thành công');
//                             });
//                           },
//                         );
//                       } else if (type == 'Bảo hiểm trách nhiệm dân sự') {
//                         widget.model
//                             .chooseCivilLiabilityInsurancePhotos()
//                             .whenComplete(
//                           () {
//                             setState(() {
//                               photos =
//                                   widget.model.newCivilLiabilityInsurancePhotos;
//                               print('Thêm ảnh ${type} thành công');
//                             });
//                           },
//                         );
//                       } else if (type == 'Bảo hiểm vật chất thân xe') {
//                         widget.model
//                             .chooseVehicleBodyInsurancePhotos()
//                             .whenComplete(
//                           () {
//                             setState(() {
//                               photos = widget.model.newVehicleBodyInsurance;
//                               print('Thêm ảnh ${type} thành công');
//                             });
//                           },
//                         );
//                       }
//                     },
//                     child: Container(
//                       alignment: Alignment.center,
//                       width: MediaQuery.of(context).size.width / 3.5,
//                       height: MediaQuery.of(context).size.width / 3.5,
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.add_circle_outline_outlined)
//                               .pOnly(bottom: 10),
//                           Text(
//                             'Add picture'.tr(),
//                             style: TextStyle(fontWeight: FontWeight.w600),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 )
//               : Container(
//                   width: MediaQuery.of(context).size.width / 3.5,
//                   height: MediaQuery.of(context).size.width / 3.5,
//                   child: Stack(
//                     fit: StackFit.expand,
//                     children: [
//                       ClipRRect(
//                         child: Image.file(
//                           photos![1],
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                       Positioned(
//                         top: 0,
//                         right: 0,
//                         child: IconButton(
//                           icon: Icon(Icons.cancel_outlined),
//                           onPressed: () {
//                             setState(() {
//                               if (type == 'Giấy cà vẹt xe') {
//                                 widget.model.newCarParrotPhotos!.removeAt(1);
//                               } else if (type == 'Giấy đăng kiểm') {
//                                 widget.model.newRegistrationPhotos!.removeAt(1);
//                               } else if (type ==
//                                   'Bảo hiểm trách nhiệm dân sự') {
//                                 widget.model.newCivilLiabilityInsurancePhotos!
//                                     .removeAt(1);
//                               } else {
//                                 widget.model.newVehicleBodyInsurance!
//                                     .removeAt(1);
//                               }
//                             });
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//         ),
//       ],
//     );
//   }
// }
