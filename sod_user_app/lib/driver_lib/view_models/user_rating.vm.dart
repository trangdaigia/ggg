import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:sod_user/driver_lib/models/order.dart';
import 'package:sod_user/driver_lib/requests/order.request.dart';
import 'package:sod_user/driver_lib/requests/taxi.request.dart';
import 'package:sod_user/driver_lib/view_models/base.view_model.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class UserRatingViewModel extends MyBaseViewModel {
  //
  OrderRequest orderRequest = OrderRequest();
  Order order;
  int rating = 1;
  Function onsubmitted;
  TextEditingController reviewTEC = TextEditingController();

  //
  UserRatingViewModel(
    BuildContext context,
    this.order,
    this.onsubmitted,
  ) {
    this.viewContext = context;
  }

  void updateRating(String value) {
    rating = double.parse(value).ceil();
  }

  submitRating() async {
    setBusy(true);
    //
    final apiResponse = await TaxiRequest().rateUser(
      order.id,
      order.userId,
      rating.toDouble(),
      reviewTEC.text,
    );
    setBusy(false);

    //
    CoolAlert.show(
      context: viewContext,
      type: apiResponse.allGood ? CoolAlertType.success : CoolAlertType.error,
      title: "Rider Rating".tr(),
      text: apiResponse.message,
      onConfirmBtnTap: apiResponse.allGood
          ? () {
              //
              Navigator.pop(viewContext);
              onsubmitted();
            }
          : null,
    );
  }
}
