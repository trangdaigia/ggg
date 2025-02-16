import 'dart:io';

import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_file_limit.dart';
import 'package:sod_user/extensions/dynamic.dart';
import 'package:sod_user/models/checkout.dart';
import 'package:sod_user/models/vendor.dart';
import 'package:sod_user/requests/vendor.request.dart';
import 'package:sod_user/view_models/checkout_base.vm.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:sod_user/utils/utils.dart';

class PharmacyUploadPrescriptionViewModel extends CheckoutBaseViewModel {
  //
  PharmacyUploadPrescriptionViewModel(BuildContext context, this.vendor) {
    this.viewContext = context;
    this.checkout = CheckOut(subTotal: 0.00);
    this.canSelectPaymentOption = true;
  }

  //
  VendorRequest vendorRequest = VendorRequest();
  Vendor? vendor;
  final picker = ImagePicker();
  List<File> prescriptionPhotos = [];

  void initialise() async {
    calculateTotal = false;
    super.initialise();
  }

  //
  fetchVendorDetails() async {
    //
    setBusyForObject(vendor, true);
    try {
      vendor = await vendorRequest.vendorDetails(vendor!.id);
    } catch (error) {
      print("Error ==> $error");
    }
    setBusyForObject(vendor, false);
  }

  //
  void changePhoto() async {
    //
    final pickedFiles = await picker.pickMultiImage();
    if (prescriptionPhotos.isNotEmpty) {
      prescriptionPhotos.addAll(
        pickedFiles.map((e) => File(e.path)).toList(),
      );
    } else {
      prescriptionPhotos = pickedFiles.map((e) => File(e.path)).toList();
    }

    //
    if (prescriptionPhotos.length > AppFileLimit.prescriptionFileLimit) {
      prescriptionPhotos = prescriptionPhotos.sublist(
        0,
        AppFileLimit.prescriptionFileLimit,
      );
      //
      CoolAlert.show(
        context: viewContext,
        type: CoolAlertType.warning,
        title: "Prescription".tr(),
        text: "You can only upload %s prescription at a time"
            .tr()
            .fill([AppFileLimit.prescriptionFileLimit]),
      );
    }
    //
    notifyListeners();
  }

  void removePhoto(int index) {
    prescriptionPhotos.removeAt(index);
    //refresh list to have new index
    prescriptionPhotos = prescriptionPhotos.toList();
    notifyListeners();
  }

  //
  placeOrder({bool ignore = false}) async {
    //
    if (!isPickup && deliveryAddress == null) {
      //
      CoolAlert.show(
        context: viewContext,
        type: CoolAlertType.error,
        title: "Delivery address".tr(),
        text: "Please select delivery address".tr(),
      );
    } else if (delievryAddressOutOfRange && !isPickup) {
      //
      CoolAlert.show(
        context: viewContext,
        type: CoolAlertType.error,
        title: "Delivery address".tr(),
        text: "Delivery address is out of vendor delivery range".tr(),
      );
    } else if (prescriptionPhotos.isEmpty) {
      //
      CoolAlert.show(
        context: viewContext,
        type: CoolAlertType.error,
        title: "Prescription".tr(),
        text: "Please upload prescription".tr(),
      );
    }
    //process the new order
    else {
      processOrderPlacement();
    }
  }

  //
  processOrderPlacement() async {
    setBusy(true);

    try {
      //set the total with discount as the new total
      checkout!.total = checkout!.totalWithTip;

      final forbiddenWord = Utils.checkForbiddenWordsInString(noteTEC.text);
      if (forbiddenWord != null) {
        await CoolAlert.show(
          context: viewContext,
          type: CoolAlertType.error,
          title: "Warning forbidden words".tr(),
          text: "Your information contains forbidden word".tr() +
              ": $forbiddenWord",
        );
        setBusy(false);
        return;
      }

      //
      final apiResponse = await checkoutRequest.newPrescriptionOrder(
        checkout!,
        vendor!,
        photos: prescriptionPhotos,
        note: noteTEC.text,
      );
      //not error
      if (apiResponse.allGood) {
        //cash payment

        final paymentLink = "";
        // apiResponse.body["link"].toString();
        if (!paymentLink.isEmptyOrNull) {
          Navigator.pop(viewContext);
          showOrdersTab(context: viewContext);
          openWebpageLink(paymentLink);
        }
        //cash payment
        else {
          CoolAlert.show(
            context: viewContext,
            type: CoolAlertType.success,
            title: "Checkout".tr(),
            text: apiResponse.message,
            barrierDismissible: false,
            onConfirmBtnTap: () {
              showOrdersTab(context: viewContext);
              if (Navigator.of(viewContext).canPop()) {
                Navigator.pop(viewContext);
              }
            },
          );
        }
      } else {
        CoolAlert.show(
          context: viewContext,
          type: CoolAlertType.error,
          title: "Checkout".tr(),
          text: apiResponse.message,
        );
      }
    } catch (error) {
      toastError("$error");
    }
    setBusy(false);
  }
}
