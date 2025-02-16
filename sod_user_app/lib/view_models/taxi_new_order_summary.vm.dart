import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_map_settings.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/constants/app_ui_sizes.dart';
import 'package:sod_user/requests/taxi.request.dart';
import 'package:sod_user/services/geocoder.service.dart';
import 'package:sod_user/view_models/base.view_model.dart';
import 'package:sod_user/view_models/taxi.vm.dart';
import 'package:sod_user/views/shared/driver_gender_selection.page.dart';
import 'package:sod_user/views/shared/payment_method_selection.page.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import "package:velocity_x/velocity_x.dart";
import 'package:http/http.dart' as http;

class NewTaxiOrderSummaryViewModel extends MyBaseViewModel {
  //
  NewTaxiOrderSummaryViewModel(BuildContext context, this.taxiViewModel) {
    this.viewContext = context;
  }

  TaxiRequest taxiRequest = TaxiRequest();
  GeocoderService geocoderService = GeocoderService();
  final TaxiViewModel taxiViewModel;
  PanelController panelController = PanelController();
  double customViewHeight = AppUISizes.taxiNewOrderSummaryHeight;
  double distance = 0.0;
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

  closePanel() async {
    clearFocus();
    await panelController.close();
    notifyListeners();
  }

  clearFocus() {
    FocusScope.of(taxiViewModel.viewContext).requestFocus(new FocusNode());
  }

  openPanel() async {
    await panelController.open();
    notifyListeners();
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

  void openDriverGenderSelection() async {
    //

    final selectDriverGender = await Navigator.push(
      viewContext,
      MaterialPageRoute(
        builder: (context) => DriverGenderSelectionPage(taxiViewModel),
      ),
    );

    if (selectDriverGender != null) {
      taxiViewModel.changeRequestDriverGender(selectDriverGender);
    }

    notifyListeners();
  }

  Future<double> calculateDistance(
      double lat1, double lon1, double lat2, double lon2) async {
    //vietmapcheck
    if (AppMapSettings.isUsingVietmap) {
      final apiKey = AppStrings.vietMapMapApiKey;
      final url =
          'https://maps.vietmap.vn/api/matrix?api-version=1.1&apikey=$apiKey&point=$lat1,$lon1&point=$lat2,$lon2';
      setBusy(true);
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final distanceValue = data["distances"][0][1];
        setBusy(false);
        distance = distanceValue.toDouble();
        return distanceValue.toDouble();
      } else {
        throw Exception('Failed to calculate distance');
      }
    } else {
      final apiKey = AppStrings.googleMapApiKey;
      final url =
          'https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=$lat1,$lon1&destinations=$lat2,$lon2&key=$apiKey';
      setBusy(true);
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final distanceText = data['rows'][0]['elements'][0]['distance']['text'];
        final distanceValue =
            data['rows'][0]['elements'][0]['distance']['value'];
        print('Distance: $distanceText');
        setBusy(false);
        distance = distanceValue.toDouble();
        return distanceValue.toDouble();
      } else {
        throw Exception('Failed to calculate distance');
      }
    }
  }
}
