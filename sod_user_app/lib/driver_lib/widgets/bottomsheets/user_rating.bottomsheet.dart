import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:sod_user/driver_lib/constants/app_images.dart';
import 'package:sod_user/driver_lib/constants/app_strings.dart';
import 'package:sod_user/driver_lib/extensions/dynamic.dart';
import 'package:sod_user/driver_lib/models/order.dart';
import 'package:sod_user/driver_lib/utils/ui_spacer.dart';
import 'package:sod_user/driver_lib/view_models/user_rating.vm.dart';
import 'package:sod_user/driver_lib/widgets/base.page.dart';
import 'package:sod_user/driver_lib/widgets/buttons/custom_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
//import 'package:sod_user/driver_lib/widgets/custom_text_form_field.dart';

class UserRatingBottomSheet extends StatelessWidget {
  const UserRatingBottomSheet({
    Key? key,
    required this.onSubmitted,
    required this.order,
  }) : super(key: key);

  //
  final Order order;
  final Function onSubmitted;

  //
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<UserRatingViewModel>.reactive(
      viewModelBuilder: () => UserRatingViewModel(context, order, onSubmitted),
      builder: (context, vm, child) {
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: BasePage(
            body: VStack(
              [
                //price
                UiSpacer.verticalSpace(),
                UiSpacer.verticalSpace(),
                "Total".tr().text.medium.xl.makeCentered(),
                "${order.taxiOrder?.currency != null ? order.taxiOrder?.currency?.symbol : AppStrings.currencySymbol} ${order.total}"
                    .currencyFormat()
                    .text
                    .xl4
                    .bold
                    .makeCentered(),
                UiSpacer.verticalSpace(),
                UiSpacer.divider().py12(),
                UiSpacer.verticalSpace(),

                //
                Image.asset(
                  AppImages.user,
                  width: 60,
                  height: 60,
                ).centered(),
                //
                "Rate Rider".tr().text.center.xl.medium.makeCentered().py12(),
                //
                RatingBar.builder(
                  initialRating: 3,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.yellow[700],
                  ),
                  onRatingUpdate: (rating) {
                    vm.updateRating(rating.toInt().toString());
                  },
                ).centered().py12(),

                // driver không được comment khách hàng?

                // CustomTextFormField(
                //   minLines: 1,
                //   maxLines: 4,
                //   textEditingController: vm.reviewTEC,
                //   labelText: "Comment".tr(),
                //   textInputAction: TextInputAction.newline,
                //   keyboardType: TextInputType.multiline,
                // ).py12(),

                //
                SafeArea(
                  child: CustomButton(
                    title: "Submit".tr(),
                    onPressed: vm.submitRating,
                    loading: vm.isBusy,
                  ).centered(),
                ),
              ],
            ).p20().scrollVertical(),
          ).hTwoThird(context).pOnly(bottom: context.mq.viewInsets.bottom),
        );
      },
    );
  }
}
