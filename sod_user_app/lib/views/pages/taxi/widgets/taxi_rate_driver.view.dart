import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/extensions/string.dart';
import 'package:sod_user/models/order.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/view_models/taxi.vm.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:sod_user/widgets/buttons/custom_text_button.dart';
import 'package:sod_user/widgets/custom_image.view.dart';
import 'package:sod_user/widgets/custom_text_form_field.dart';
import 'package:sod_user/widgets/states/loading_indicator.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:measure_size/measure_size.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:velocity_x/velocity_x.dart';

class TaxiRateDriverView extends StatefulWidget {
  const TaxiRateDriverView(this.vm, {Key? key}) : super(key: key);
  final TaxiViewModel vm;

  @override
  State<TaxiRateDriverView> createState() => _TaxiRateDriverViewState();
}

class _TaxiRateDriverViewState extends State<TaxiRateDriverView> {
  late Future<Order?> _futureOrder;

  @override
  void initState() {
    super.initState();
    _futureOrder = widget.vm.taxiRequest.getOnGoingTrip(forceRefresh: false);
  }

  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
      backdropColor: Colors.transparent,
      minHeight: 600,
      maxHeight: context.percentHeight * 80,
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(30),
        topLeft: Radius.circular(30),
      ),
      panel: MeasureSize(
        onChange: (size) {
          widget.vm.updateGoogleMapPadding(height: 320);
        },
        child: FutureBuilder<Order?>(
            future: _futureOrder,
            builder: (context, snapshot) {
              //assign the order model from the one fetched from the server on order completed
              if (snapshot.hasData) {
                widget.vm.onGoingOrderTrip = snapshot.data;
              }

              if (snapshot.data == null) {
                return Container();
              }

              return LoadingIndicator(
                loading: snapshot.connectionState == ConnectionState.waiting,
                child: VStack(
                  [
                    Text('Tổng', style: TextStyle(fontSize: 20)),
                    "${widget.vm.onGoingOrderTrip!.taxiOrder!.currency != null ? widget.vm.onGoingOrderTrip?.taxiOrder?.currency?.symbol : AppStrings.currencySymbol} ${widget.vm.onGoingOrderTrip?.total}"
                        .currencyFormat()
                        .text
                        .medium
                        .xl3
                        .make()
                        .py12(),
                    UiSpacer.divider(),
                    UiSpacer.verticalSpace(),
                    UiSpacer.verticalSpace(),
                    //driver details
                    CustomImage(
                      imageUrl: widget.vm.onGoingOrderTrip!.driver!.user.photo,
                      width: 80,
                      height: 80,
                    ).box.roundedSM.clip(Clip.antiAlias).makeCentered(),
                    UiSpacer.verticalSpace(),

                    //
                    "${widget.vm.onGoingOrderTrip!.driver!.user.name}"
                        .text
                        .xl
                        .medium
                        .make(),

                    "${widget.vm.onGoingOrderTrip!.driver!.vehicle!.vehicleInfo}"
                        .text
                        .light
                        .make(),
                    //
                    UiSpacer.verticalSpace(),
                    "Rate Driver".tr().text.make(),
                    RatingBar.builder(
                      initialRating: 3,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemCount: 5,
                      itemSize: 30,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => Icon(
                        FlutterIcons.star_ant,
                        color: Colors.yellow[700],
                      ),
                      onRatingUpdate: (rating) {
                        //
                        widget.vm.newTripRating = rating;
                      },
                    ).py8(),
                    UiSpacer.verticalSpace(),
                    CustomTextFormField(
                      hintText: "Review".tr(),
                      textEditingController: widget.vm.tripReviewTEC,
                      minLines: 3,
                      maxLines: 5,
                    ),
                    //submit button
                    UiSpacer.verticalSpace(),
                    CustomButton(
                      title: "Submit Rating".tr(),
                      loading: widget.vm.busy(widget.vm.newTripRating),
                      onPressed: widget.vm.submitTripRating,
                    ),
                    UiSpacer.verticalSpace(space: 10),
                    SafeArea(
                      child: CustomTextButton(
                        title: "Cancel".tr(),
                        titleColor: Colors.red,
                        onPressed: widget.vm.dismissTripRating,
                      ),
                    ),
                  ],
                  crossAlignment: CrossAxisAlignment.center,
                )
                    .p20()
                    .scrollVertical()
                    .box
                    .color(context.theme.colorScheme.background)
                    .topRounded(value: 30)
                    .shadow5xl
                    .make()
                    .pOnly(bottom: context.mq.viewInsets.bottom),
              );
            }),
      ),
    );
  }
}
