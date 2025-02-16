import 'dart:io';

import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:sod_user/driver_lib/models/box.dart';
import 'package:sod_user/driver_lib/models/checkout.dart';
import 'package:sod_user/driver_lib/models/user.dart';
import 'package:sod_user/driver_lib/models/vehicle.dart';
import 'package:sod_user/driver_lib/requests/receive_behalf.request.dart';
import 'package:sod_user/requests/vehicle.request.dart';
import 'package:sod_user/driver_lib/services/alert.service.dart';
import 'package:sod_user/driver_lib/views/pages/vehicle/new_vehicle.page.dart';
import 'package:velocity_x/velocity_x.dart';

import 'base.view_model.dart';

class ReceiveBehalfViewModel extends MyBaseViewModel {
  List<Vehicle> vehicles = [];
  VehicleRequest vehicleRequest = VehicleRequest();
  RefreshController refreshController = RefreshController();
  TextEditingController userPhoneNumberController = TextEditingController();
  List<User> searchUserList = [];
  User? deliveryUser;
  ReceiveBehalfRequest request = ReceiveBehalfRequest();
  List<File> images = [];
  bool paidOrderCheck = false;
  int receiveBehalfOrderTotal = 0;
  int receiveBehalfOrderValue = 0;
  int receiveBehalfFee = 0;
  int serviceFeePercent = 5;
  CheckOut? checkOut;
  List<Box>? boxes = [];
  Box? selectedBox;
  bool isLoadingPlaceOrder = false;

  ReceiveBehalfViewModel(BuildContext context) {
    this.viewContext = context;
  }

  void initialise() async {
    boxes = await request.getBoxes();
    receiveBehalfFee = 5000;
  }

  void fetchVehicles() async {
    refreshController.refreshCompleted();
    setBusy(true);
    try {
      vehicles = await vehicleRequest.vehicles();
    } catch (error) {
      toastError("$error");
    }
    setBusy(false);
  }

  newVehicleCreate() async {
    await Navigator.of(viewContext).push(
      MaterialPageRoute(builder: (context) => NewVehiclePage()),
    );
    fetchVehicles();
  }

  // showPackageDetailsBottomSheet() {
  //   showModalBottomSheet(
  //     context: viewContext,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) {
  //       return Container(
  //         decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
  //         child: FormBuilder(
  //           key: this.formBuilderKey,
  //           child: VStack(
  //             axisSize: MainAxisSize.min,
  //             crossAlignment: CrossAxisAlignment.start,
  //             [
  //               UiSpacer.vSpace(4),
  //               "Receiver information".tr().text.xl.bold.make(),
  //               UiSpacer.vSpace(10),
  //               Row(
  //                 children: [
  //                   Expanded(
  //                     flex: 3,
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Row(
  //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                           children: [
  //                             '${"User phone number".tr()} *'.text.make(),
  //                           ],
  //                         ),
  //                         UiSpacer.vSpace(10),
  //                         FormBuilderTextField(
  //                           onChanged: (value) async {
  //                             searchUserList = await request.phoneSearch(value!);
  //                             notifyListeners();
  //                           },
  //                           name: "Phone number".tr(),
  //                           validator: CustomFormBuilderValidator.required,
  //                           decoration: InputDecoration(
  //                             border: OutlineInputBorder(),
  //                           ).copyWith(labelText: "User Phone Number".tr()),
  //                           textInputAction: TextInputAction.next,
  //                           controller: userPhoneNumberController,
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //               Visibility(
  //                 visible: hasErrorForKey('user') && (deliveryUser == null || images.isEmpty),
  //                 child: error('user').toString().text.fontWeight(FontWeight.w600).red600.make().py12(),
  //               ),
  //               VStack(
  //                 [
  //                   VStack(
  //                     alignment: MainAxisAlignment.center,
  //                     crossAlignment: CrossAxisAlignment.start,
  //                     axisSize: MainAxisSize.min,
  //                     [
  //                       userPhoneNumberController.text.isNotEmpty
  //                           ? Container(
  //                               height: 100,
  //                               decoration: const BoxDecoration(
  //                                 color: Colors.white,
  //                                 borderRadius: BorderRadius.all(Radius.circular(10)),
  //                               ),
  //                               padding: const EdgeInsets.all(10),
  //                               child: searchUserList.isNotEmpty
  //                                   ? Scrollbar(
  //                                       child: ListView.separated(
  //                                         separatorBuilder: (context, index) {
  //                                           return UiSpacer.divider(height: 10);
  //                                         },
  //                                         physics: const NeverScrollableScrollPhysics(),
  //                                         shrinkWrap: true,
  //                                         itemCount: searchUserList.length,
  //                                         itemBuilder: (context, index) {
  //                                           return GestureDetector(
  //                                             onTap: () async {
  //                                               userPhoneNumberController.text = searchUserList[index].phone!;
  //                                               deliveryUser = searchUserList[index];
  //                                               notifyListeners();
  //                                             },
  //                                             child: searchUserList[index].phone!.text.fontWeight(FontWeight.w500).xl.make(),
  //                                           );
  //                                         },
  //                                       ).scrollVertical(),
  //                                     )
  //                                   : UiSpacer.emptySpace())
  //                           : UiSpacer.emptySpace(),
  //                       deliveryUser != null
  //                           ? Container(
  //                               padding: const EdgeInsets.all(8),
  //                               decoration: BoxDecoration(
  //                                 borderRadius: BorderRadius.circular(10),
  //                                 color: Colors.blueGrey.shade50,
  //                               ),
  //                               child: Row(
  //                                 children: [
  //                                   CircleAvatar(radius: 35, backgroundImage: NetworkImage(deliveryUser!.photo)),
  //                                   UiSpacer.hSpace(10),
  //                                   VStack(
  //                                     crossAlignment: CrossAxisAlignment.start,
  //                                     [
  //                                       '${'Full name'.tr()}: ${deliveryUser!.name}'.text.make(),
  //                                       UiSpacer.vSpace(8),
  //                                       '${'Phone'.tr()}: ${deliveryUser!.phone}'.text.make(),
  //                                       UiSpacer.vSpace(8),
  //                                       // Text('${'Apartment'.tr}: ${deliveryUser.apartment?.name ?? ''}'),
  //                                     ],
  //                                   ),
  //                                 ],
  //                               ),
  //                             )
  //                           : UiSpacer.emptySpace(),
  //                       UiSpacer.vSpace(10),
  //                       '${'Product images'.tr()} *'.text.make(),
  //                       UiSpacer.vSpace(10),
  //                       images.isNotEmpty
  //                           ? CarouselSlider(
  //                               items: images
  //                                   .map(
  //                                     (element) => ClipRRect(
  //                                       borderRadius: BorderRadius.circular(10),
  //                                       child: Image.file(element, fit: BoxFit.cover, width: double.infinity),
  //                                     ),
  //                                   )
  //                                   .toList(),
  //                               options: CarouselOptions(autoPlay: true, viewportFraction: 1),
  //                             )
  //                           : UiSpacer.emptySpace(),
  //                       UiSpacer.vSpace(10),
  //                       CustomButton(
  //                         title: 'Picked from gallery'.tr(),
  //                         onPressed: () async {
  //                           final selectedImages = await ImagePicker().pickMultiImage(maxWidth: 1024, maxHeight: 1024);
  //                           if (selectedImages.isNotEmpty) {
  //                             images = selectedImages.map((e) => File(e.path)).toList();
  //                             notifyListeners();
  //                           }
  //                         },
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ).py12(),
  //               UiSpacer.vSpace(10),
  //               CustomButton(
  //                 title: 'Continue'.tr(),
  //                 onPressed: () {
  //                   if (deliveryUser == null) {
  //                     setErrorForObject('user', "User phone number is required".tr());
  //                     return;
  //                   }
  //                   if (images.isEmpty) {
  //                     setErrorForObject('user', "Please pick images".tr());
  //                     return;
  //                   }
  //                   confirmBottomSheet();
  //                 },
  //               )
  //             ],
  //           ),
  //         ).scrollVertical(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15)),
  //       ).pOnly(bottom: MediaQuery.of(context).viewInsets.bottom);
  //     },
  //   );
  // }

  // confirmBottomSheet() {
  //   paidOrderCheck = false;
  //   showModalBottomSheet(
  //     context: viewContext,
  //     isScrollControlled: false,
  //     isDismissible: false,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) {
  //       return Container(
  //         decoration: const BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
  //         ),
  //         child: VStack(
  //           crossAlignment: CrossAxisAlignment.start,
  //           axisSize: MainAxisSize.min,
  //           [
  //             "Confirm information".tr().text.xl.color(Colors.black).bold.make().py(10),
  //             UiSpacer.divider(),
  //             VStack(
  //               [
  //                 Row(
  //                   children: [
  //                     Expanded(
  //                       child: InkWell(
  //                         child: ReceiveBehalfUserDetailsView(
  //                           name: '${deliveryUser!.name}',
  //                           phone: deliveryUser!.phone!,
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ).py(8),
  //             UiSpacer.vSpace(8),
  //             'Address'.tr().text.xl.bold.make(),
  //             UiSpacer.vSpace(8),
  //             Container(
  //               padding: const EdgeInsets.symmetric(horizontal: 8.0),
  //               decoration: BoxDecoration(
  //                 border: Border.all(color: Colors.grey),
  //                 borderRadius: BorderRadius.circular(10),
  //               ),
  //               child: PopupMenuButton<String>(
  //                 position: PopupMenuPosition.under,
  //                 offset: Offset(0, MediaQuery.of(context).size.height),
  //                 shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
  //                 icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
  //                 onSelected: (String? newValue) {
  //                   receiveBehalfFee = int.parse(newValue!);
  //                   notifyListeners();
  //                 },
  //                 itemBuilder: (BuildContext context) {
  //                   return ['5000', '10000', '15000', '20000'].map((String value) {
  //                     return PopupMenuItem<String>(
  //                       value: value,
  //                       child: SizedBox(
  //                         width: MediaQuery.of(context).size.width,
  //                         child: Utils.formatCurrencyVND(double.parse(value)).text.make(),
  //                       ),
  //                     );
  //                   }).toList();
  //                 },
  //               ),
  //             ),
  //             // RecipientTextfield(
  //             //   hintText: 'box'.tr,
  //             //   readOnly: true,
  //             //   controller: boxController,
  //             //   suffixIcon: const Icon(Icons.arrow_drop_down),
  //             //   onTap: () async {
  //             //     BoxData? chosenData = await boxesOptions(context);
  //             //     if (chosenData != null) {
  //             //       chosenBoxData.value = chosenData;
  //             //       boxController.text = '${chosenBoxData.value.boxName ?? ''}, ${chosenBoxData.value.buildingName ?? ''}, ${chosenBoxData.value.address ?? ''}';
  //             //     }
  //             //   },
  //             // ),
  //             UiSpacer.vSpace(8),
  //             Row(children: ['Package images'.tr().text.xl.bold.make()]),
  //             UiSpacer.vSpace(12),
  //             CarouselSlider(
  //               items: images
  //                   .map(
  //                     (element) => ClipRRect(
  //                       borderRadius: BorderRadius.circular(10),
  //                       child: Image.file(element, fit: BoxFit.cover, width: double.infinity),
  //                     ),
  //                   )
  //                   .toList(),
  //               options: CarouselOptions(viewportFraction: 1, autoPlay: true),
  //             ),
  //             UiSpacer.vSpace(12),
  //             Transform.scale(
  //               scale: 1.1,
  //               child: CheckboxListTile(
  //                 checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
  //                 checkColor: Colors.white,
  //                 activeColor: AppColor.accentColor,
  //                 title: '${"Paid order".tr()} (${"Paid order explain".tr()})'.text.make(),
  //                 value: paidOrderCheck,
  //                 onChanged: (value) {
  //                   paidOrderCheck = value!;
  //                   if (paidOrderCheck) {
  //                     receiveBehalfOrderTotal = 0;
  //                   } else {
  //                     receiveBehalfOrderTotal = receiveBehalfOrderValue;
  //                   }
  //                   notifyListeners();
  //                 },
  //                 controlAffinity: ListTileControlAffinity.leading,
  //               ),
  //             ),
  //             !paidOrderCheck
  //                 ? FormBuilderTextField(
  //                     onChanged: (value) async {
  //                       if (value!.isEmpty) {
  //                         receiveBehalfOrderValue = 0;
  //                       } else {
  //                         receiveBehalfOrderValue = int.parse(value.replaceAll('.', ''));
  //                       }
  //                       receiveBehalfOrderTotal = receiveBehalfOrderValue;
  //                     },
  //                     name: "Price".tr(),
  //                     validator: CustomFormBuilderValidator.required,
  //                     decoration: InputDecoration(
  //                       border: OutlineInputBorder(),
  //                     ).copyWith(labelText: "Price".tr()),
  //                     textInputAction: TextInputAction.next,
  //                     inputFormatters: [
  //                       FilteringTextInputFormatter.digitsOnly,
  //                       VNTextFormatter(),
  //                     ],
  //                     keyboardType: TextInputType.number,
  //                   )
  //                 : UiSpacer.emptySpace(),
  //             UiSpacer.vSpace(10),
  //             Container(
  //               padding: const EdgeInsets.symmetric(horizontal: 8.0),
  //               decoration: BoxDecoration(
  //                 border: Border.all(color: Colors.grey),
  //                 borderRadius: BorderRadius.circular(10),
  //               ),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   "${"Receive behalf fee".tr()}: ${receiveBehalfFee != 0 ? Utils.formatCurrencyVND(double.parse(receiveBehalfFee.toString())) : ''}"
  //                       .text
  //                       .make(),
  //                   PopupMenuButton<String>(
  //                     position: PopupMenuPosition.under,
  //                     offset: Offset(0, MediaQuery.of(context).size.height),
  //                     shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
  //                     icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
  //                     onSelected: (String? newValue) {
  //                       receiveBehalfFee = int.parse(newValue!);
  //                       notifyListeners();
  //                     },
  //                     itemBuilder: (BuildContext context) {
  //                       return ['5000', '10000', '15000', '20000'].map((String value) {
  //                         return PopupMenuItem<String>(
  //                           value: value,
  //                           child: SizedBox(
  //                             width: MediaQuery.of(context).size.width,
  //                             child: Utils.formatCurrencyVND(double.parse(value)).text.make(),
  //                           ),
  //                         );
  //                       }).toList();
  //                     },
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             Visibility(
  //               visible: hasErrorForKey('confirm'),
  //               child: error('confirm').toString().text.fontWeight(FontWeight.w600).red600.make().py12(),
  //             ),
  //             UiSpacer.vSpace(10),
  //             Row(
  //               children: [
  //                 Expanded(
  //                   child: ReceiveBehalfDataDetails(
  //                     title: Utils.formatCurrencyVND(double.parse(receiveBehalfOrderTotal.toString())),
  //                     value: 'Order total'.tr(),
  //                   ),
  //                 ),
  //                 UiSpacer.hSpace(10),
  //                 Expanded(
  //                   child: ReceiveBehalfDataDetails(
  //                     title: Utils.formatCurrencyVND(double.parse((receiveBehalfFee + receiveBehalfOrderTotal * serviceFeePercent / 100).toString())),
  //                     value: paidOrderCheck ? "Receive behalf fee".tr() : "Service fee".tr(),
  //                   ),
  //                 ),
  //                 UiSpacer.hSpace(10),
  //                 Expanded(
  //                   child: ReceiveBehalfDataDetails(
  //                     title: Utils.formatCurrencyVND(
  //                       double.parse(
  //                         (receiveBehalfOrderTotal +
  //                                 (paidOrderCheck ? receiveBehalfFee : receiveBehalfFee + receiveBehalfOrderTotal * serviceFeePercent / 100))
  //                             .toString(),
  //                       ),
  //                     ),
  //                     value: 'Receiver payment'.tr(),
  //                     color: AppColor.primaryColor,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             UiSpacer.vSpace(20),
  //             paidOrderCheck
  //                 ? UiSpacer.emptySpace()
  //                 : Row(
  //                     children: [
  //                       Icon(Icons.info_outline, color: AppColor.primaryColor),
  //                       UiSpacer.hSpace(10),
  //                       "${"Service fee".tr()} = ${"Receive behalf fee".tr()} + ${"Payment fee".tr()} ($serviceFeePercent%)"
  //                           .text
  //                           .xs
  //                           .color(Colors.grey[350])
  //                           .make(),
  //                     ],
  //                   ),
  //             UiSpacer.vSpace(20),
  //             Row(
  //               children: [
  //                 CustomButton(
  //                   icon: Icons.arrow_back_ios,
  //                   iconColor: Colors.black,
  //                   title: "Back".tr(),
  //                   onPressed: () => viewContext.pop(),
  //                 ),
  //                 UiSpacer.hSpace(10),
  //                 Expanded(
  //                   child: CustomButton(
  //                     title: "Create ride".tr(),
  //                     color: AppColor.primaryColor,
  //                     onPressed: () async {
  //                       if (paidOrderCheck == false && receiveBehalfOrderTotal != 0 && receiveBehalfFee != 0) {
  //                         // createDeliveryRide();
  //                       } else if (paidOrderCheck) {
  //                         if (receiveBehalfFee == 0) {
  //                           setErrorForObject('confirm', "Please select receive behalf fee".tr());
  //                         } else {
  //                           // createDeliveryRide();
  //                         }
  //                       } else {
  //                         if (receiveBehalfOrderTotal == 0) {
  //                           setError("please_enter_receive_behalf_order_total".tr);
  //                         } else if (receiveBehalfFee == 0) {
  //                           setErrorForObject('confirm', "Please select receive behalf fee".tr());
  //                         }
  //                       }
  //                     },
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ).scrollVertical(padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10)),
  //       );
  //     },
  //   );
  // }

  placeOrder() async {
    setBusy(true);
    final params = {
      "box_id": selectedBox!.id,
      "user_id": deliveryUser!.id,
      "sub_total": receiveBehalfOrderTotal,
      "total": receiveBehalfOrderTotal +
          (paidOrderCheck
              ? receiveBehalfFee
              : receiveBehalfFee +
                  receiveBehalfOrderTotal * serviceFeePercent / 100),
      "service_fee_percent": serviceFeePercent,
      "order_value": receiveBehalfOrderTotal,
      "payment_fee": (receiveBehalfOrderTotal * serviceFeePercent / 100),
      "service_fee": (paidOrderCheck
          ? receiveBehalfFee
          : receiveBehalfFee +
              receiveBehalfOrderTotal * serviceFeePercent / 100),
      "paid_order": paidOrderCheck ? 1 : 0,
    };

    final apiResponse =
        await request.newReceiveBehalfOrder(photos: images, params: params);
    //if there was an issue placing the order
    if (!apiResponse.allGood) {
      await AlertService.error(
        title: "Order failed".tr(),
        text: apiResponse.message!,
      );
    } else {
      setBusy(false);
      await AlertService.success(
        title: "Receive behalf order successfully created".tr(),
        text: apiResponse.message!,
      );
      Navigator.pop(viewContext);
      //viewContext.nextPage(HomePage());
    }
  }
}
