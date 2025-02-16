import 'dart:io';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:sod_vendor/models/product_category.dart';
import 'package:sod_vendor/requests/product.request.dart';
import 'package:sod_vendor/requests/service.request.dart';
import 'package:sod_vendor/requests/vendor.request.dart';
import 'package:sod_vendor/services/auth.service.dart';
import 'package:sod_vendor/utils/utils.dart';
import 'package:sod_vendor/view_models/base.view_model.dart';
import 'package:sod_vendor/views/pages/shared/text_editor.page.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class NewServiceViewModel extends MyBaseViewModel {
  //
  NewServiceViewModel(BuildContext context) {
    this.viewContext = context;
  }

  //
  ServiceRequest serviceRequest = ServiceRequest();
  ProductRequest productRequest = ProductRequest();
  VendorRequest vendorRequest = VendorRequest();
  String? description;
  //
  int? selectedCategoryId;
  int? selectedSubCategoryId;
  String? selectedServiceDuration;
  //
  List<ProductCategory> categories = [];
  List<ProductCategory> subcategories = [];
  List<String> serviceDurations = [];
  List<File>? selectedPhotos = [];

  void initialise() {
    fetchVendorTypeCategories();
    fetchServiceDurations();
  }

  //
  fetchVendorTypeCategories() async {
    setBusyForObject(categories, true);

    try {
      categories = await productRequest.getProductCategories(
        vendorTypeId:
            (await AuthServices.getCurrentVendor(force: true))?.vendorType?.id,
      );
      clearErrors();
    } catch (error) {
      print("Categories Error ==> $error");
      setError(error);
    }

    setBusyForObject(categories, false);
  }

  fetchSubCategories(int? categoryId) async {
    selectedCategoryId = categoryId;
    setBusyForObject(subcategories, true);

    try {
      subcategories = await productRequest.fetchSubCategories(
        categoryId: categoryId,
      );
      clearErrors();
    } catch (error) {
      print("Categories Error ==> $error");
      setError(error);
    }

    setBusyForObject(subcategories, false);
  }

  fetchServiceDurations() async {
    setBusyForObject(serviceDurations, true);

    try {
      serviceDurations = await serviceRequest.getServiceDurations();
      clearErrors();
    } catch (error) {
      print("serviceDurations Error ==> $error");
      setError(error);
    }

    setBusyForObject(serviceDurations, false);
  }

  //
  onImagesSelected(List<File> files) {
    selectedPhotos = files;
    notifyListeners();
  }

  //
  processNewService() async {
    if (formBuilderKey.currentState!.saveAndValidate() &&
        validateSelectedPhotos()) {
      //
      setBusy(true);

      final serviceData = formBuilderKey.currentState!.value;

      final forbiddenWord = Utils.checkForbiddenWordsInMap(serviceData);
      if (forbiddenWord != null) {
        await CoolAlert.show(
          context: viewContext,
          type: CoolAlertType.error,
          title: "Warning forbidden words".tr(),
          text: "Service information contains forbidden word".tr() +
              ": $forbiddenWord",
        );
        setBusy(false);
        return;
      }

      try {
        final apiResponse = await serviceRequest.newService(
          data: {
            ...serviceData,
            "description": description,
          },
          photos: selectedPhotos,
        );

        //show dialog to present state
        CoolAlert.show(
            context: viewContext,
            type: apiResponse.allGood
                ? CoolAlertType.success
                : CoolAlertType.error,
            title: "New Service".tr(),
            text: apiResponse.message,
            onConfirmBtnTap: () {
              Navigator.pop(viewContext);
              if (apiResponse.allGood) {
                Navigator.pop(viewContext, true);
              }
            });
        clearErrors();
      } catch (error) {
        print("new service Error ==> $error");
        setError(error);
      }

      setBusy(false);
    }
  }

  bool validateSelectedPhotos() {
    if (selectedPhotos == null || selectedPhotos!.isEmpty) {
      CoolAlert.show(
        context: viewContext,
        type: CoolAlertType.warning,
        title: "Update Service".tr(),
        text: "Please select at least one photo for service".tr(),
      );
      return false;
    }
    return true;
  }

  handleDescriptionEdit() async {
    //get the description
    final result = await Navigator.push(
      viewContext,
      MaterialPageRoute(
        builder: (context) => CustomTextEditorPage(
          title: "Service Description".tr(),
          content: description ?? "",
        ),
      ),
    );
    //
    if (result != null) {
      description = result;
      notifyListeners();
    }
  }
}
