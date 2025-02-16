import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_ui_sizes.dart';
import 'package:sod_user/requests/taxi.request.dart';
import 'package:sod_user/services/geocoder.service.dart';
import 'package:sod_user/view_models/base.view_model.dart';
import 'package:sod_user/view_models/taxi.vm.dart';
import 'package:sod_user/views/shared/payment_method_selection.page.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import "package:velocity_x/velocity_x.dart";
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:sod_user/models/taxi_ship_package_type.dart';
import 'package:sod_user/services/validator.service.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:supercharged/supercharged.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NewTaxiShipOrderInforViewModel extends MyBaseViewModel {
  //
  NewTaxiShipOrderInforViewModel(BuildContext context, this.taxiViewModel) {
    this.viewContext = context;
  }

  TaxiRequest taxiRequest = TaxiRequest();
  GeocoderService geocoderService = GeocoderService();
  final TaxiViewModel taxiViewModel;
  PanelController panelController = PanelController();
  double customViewHeight = AppUISizes.taxiNewOrderSummaryHeight;
  TextEditingController weightController = TextEditingController();

  final picker = ImagePicker();

  List<TaxiShipPackageType>? taxiShipPackageTypeList = [
    TaxiShipPackageType(id: 1, name: "food"),
    TaxiShipPackageType(id: 2, name: "cloth"),
    TaxiShipPackageType(id: 3, name: "electric"),
    TaxiShipPackageType(id: 4, name: "fragile"),
    TaxiShipPackageType(id: 5, name: "other"),
  ];

  Map<dynamic, IconData> packageTypeIconMap = {
    "food": FontAwesomeIcons.utensilSpoon,
    "cloth": FontAwesomeIcons.tshirt,
    "electric": FontAwesomeIcons.mobile,
    "fragile": FontAwesomeIcons.wineGlass,
    "other": FontAwesomeIcons.ellipsisH,
    "default": FontAwesomeIcons.boxOpen
  };

  initialise() {}

  //
  updateLoadingheight() {
    customViewHeight = AppUISizes.taxiNewOrderHistoryHeight;
    notifyListeners();
  }

  resetStateViewheight([double height = 0]) {
    customViewHeight = AppUISizes.taxiNewOrderIdleHeight + height;
    notifyListeners();
  }

  closeInforForm() async {
    clearFocus();
    taxiViewModel.setCurrentStep(2);
    notifyListeners();
  }

  clearFocus() {
    FocusScope.of(taxiViewModel.viewContext).requestFocus(new FocusNode());
  }

  void openPaymentMethodSelection() async {
    //
    if (taxiViewModel.paymentMethods.isEmpty) {
      await taxiViewModel.fetchTaxiPaymentOptions();
    }
    final mPaymentMethod = await Navigator.push(
      viewContext,
      MaterialPageRoute(
        builder: (context) => PaymentMethodSelectionPage(
          list: taxiViewModel.paymentMethods,
        ),
      ),
    );
    if (mPaymentMethod != null) {
      taxiViewModel.changeSelectedPaymentMethod(
        mPaymentMethod,
        callTotal: false,
      );
    }

    notifyListeners();
  }

  void changeShipPackagePhotoByCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      taxiViewModel.shipPackagePhoto = File(pickedFile.path);
    } else {
      taxiViewModel.shipPackagePhoto = null;
    }

    notifyListeners();
  }

  void changeShipPackagePhotoByGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      taxiViewModel.shipPackagePhoto = File(pickedFile.path);
    } else {
      taxiViewModel.shipPackagePhoto = null;
    }

    notifyListeners();
  }

  imagePickerBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Card(
            child: HStack(
          [
            VxBox(
              child: InkWell(
                onTap: () {
                  changeShipPackagePhotoByGallery();
                  Navigator.pop(context);
                },
                child: HStack(
                  [
                    VxBox().height(context.mq.size.height / 24).make(),
                    const Icon(Icons.image),
                    VxBox().height(12).make(),
                    const Text(
                      "Gallery",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    )
                  ],
                  alignment: MainAxisAlignment.center,
                ).w(context.mq.size.width * 0.3),
              ),
            ).width(context.mq.size.width * 0.3).make(),
            VxBox(
              child: InkWell(
                onTap: () {
                  changeShipPackagePhotoByCamera();
                  Navigator.pop(context);
                },
                child: HStack(
                  [
                    VxBox().height(context.mq.size.height / 24).make(),
                    const Icon(Icons.camera),
                    VxBox().height(12).make(),
                    const Text(
                      "Camera",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    )
                  ],
                  alignment: MainAxisAlignment.center,
                ).w(context.mq.size.width * 0.3),
              ),
            ).width(context.mq.size.width * 0.3).make()
          ],
          alignment: MainAxisAlignment.center,
        ).w(context.mq.size.width * 0.8).h(context.mq.size.height / 5));
      },
    );
  }

  weightFormBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  "Approximate weight"
                      .tr()
                      .text
                      .size(20)
                      .fontWeight(FontWeight.w600)
                      .make()
                      .p(12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                          keyboardType: TextInputType.number,
                          controller: weightController,
                          validator: FormValidator.validateEmpty,
                          autofocus: true,
                        ).expand(),
                      "kg".text.size(18).make().pOnly(left: 8),
                    ],
                  ).w(context.mq.size.width / 4).px(16),
                  "Selected vehicle can take up to: 400kg".tr().text.make().pOnly(top: 8, bottom: 16),
                  CustomButton(
                    title: "Accept".tr(),
                    shapeRadius: 8,
                    onPressed: () =>
                      taxiViewModel.onPackageWeightChange(weightController.text.toInt())
                    ,
                  ).w32(context).pOnly(top: 8, bottom: 16),
                ],
              ).wFull(context),
            ));
      },
    );
  }

  updateTaxiShipPackageType(TaxiShipPackageType packageType) {
    taxiViewModel.selectedPackageType = packageType;
    notifyListeners();
  }
}
