import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_vendor/constants/app_colors.dart';
import 'package:sod_vendor/models/delivery_address.dart';
import 'package:sod_vendor/models/order_stop.dart';
import 'package:sod_vendor/utils/ui_spacer.dart';
import 'package:sod_vendor/widgets/buttons/custom_button.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class ParcelOrderStopListView extends StatefulWidget {
  const ParcelOrderStopListView(
    this.title,
    this.stop, {
    Key? key,
    this.canCall = false,
    this.routeToLocation,
  }) : super(key: key);

  final OrderStop stop;
  final String title;
  final bool canCall;
  final Function(DeliveryAddress)? routeToLocation;

  @override
  _ParcelOrderStopListViewState createState() =>
      _ParcelOrderStopListViewState();
}

class _ParcelOrderStopListViewState extends State<ParcelOrderStopListView> {
  bool isOpen = false;

  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        VStack(
          [
            "${widget.title}".text.gray500.medium.sm.make(),
            "${widget.stop.deliveryAddress?.name}".text.xl.medium.make(),
            "${widget.stop.deliveryAddress?.address}".text.make(),
          ],
        ),
        //route
        Visibility(
          visible: widget.canCall,
          child: CustomButton(
            icon: FlutterIcons.navigation_fea,
            iconColor: Colors.white,
            color: AppColor.primaryColor,
            shapeRadius: Vx.dp20,
            onPressed: (widget.routeToLocation != null)
                ? () => widget.routeToLocation!(widget.stop.deliveryAddress!)
                : null,
          ).wh(Vx.dp64, Vx.dp40).p12(),
        ),

        //
        HStack(
          [
            "Contact Info".tr().text.gray500.medium.sm.make().expand(),
            //
            Icon(
              isOpen ? FlutterIcons.caret_up_faw : FlutterIcons.caret_down_faw,
              color: AppColor.primaryColor,
            ),
          ],
        ).onInkTap(() {
          setState(() {
            isOpen = !isOpen;
          });
        }),
        //
        Visibility(
          visible: isOpen,
          child: HStack(
            [
              //
              VStack(
                [
                  "Recipient Name".tr().text.gray500.medium.sm.make(),
                  "${widget.stop.name}"
                      .text
                      .medium
                      .xl
                      .make()
                      .pOnly(bottom: Vx.dp20),
                  "Note".tr().text.gray500.medium.sm.make(),
                  "${widget.stop.note}"
                      .text
                      .medium
                      .xl
                      .make()
                      .pOnly(bottom: Vx.dp20),
                ],
              ).expand(),
              //call
              (widget.stop.phone != null && widget.canCall)
                  ? CustomButton(
                      icon: FlutterIcons.phone_call_fea,
                      iconColor: Colors.white,
                      title: "",
                      color: AppColor.primaryColor,
                      shapeRadius: Vx.dp24,
                      onPressed: () async {
                        final phoneNumber = "${widget.stop.phone}";
                        if (await canLaunchUrlString(phoneNumber)) {
                          launchUrlString(phoneNumber);
                        }
                      },
                    ).wh(Vx.dp64, Vx.dp40).p12()
                  : UiSpacer.emptySpace(),
            ],
          ),
        ),
      ],
    )
        .wFull(context)
        .p12()
        .box
        .roundedSM
        .border(color: AppColor.primaryColor)
        .make()
        .pOnly(bottom: Vx.dp12);
  }
}
