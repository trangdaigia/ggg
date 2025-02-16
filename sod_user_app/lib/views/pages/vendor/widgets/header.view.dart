import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/view_models/base.view_model.dart';
import 'package:sod_user/widgets/cards/custom.visibility.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class VendorHeader extends StatefulWidget {
  const VendorHeader({
    Key? key,
    required this.model,
    this.showSearch = true,
    required this.onrefresh,
    this.location,
    this.type,
  }) : super(key: key);

  final MyBaseViewModel model;
  final bool showSearch;
  final Function onrefresh;
  final String? location;
  final String? type;
  @override
  _VendorHeaderState createState() => _VendorHeaderState();
}

class _VendorHeaderState extends State<VendorHeader> {
  @override
  void initState() {
    super.initState();
    //
    if (widget.model.deliveryaddress == null) {
      widget.model.fetchCurrentLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return HStack(
      [
        //
        HStack(
          [
            //location icon
            Icon(
              FlutterIcons.location_pin_sli,
              size: 24,
            ).onInkTap(
              widget.model.useUserLocation,
            ),

            //
            VStack(
              [
                //
                HStack(
                  [
                    //
                    widget.location == null
                        ? "Location".tr().text.sm.semiBold.make()
                        : widget.location!.tr().text.sm.semiBold.make(),
                    //
                    Icon(
                      FlutterIcons.chevron_down_fea,
                    ).px4(),
                  ],
                ),
                "${widget.model.deliveryaddress?.address}"
                    .text
                    .maxLines(1)
                    .ellipsis
                    .base
                    .make(),
                Divider(),
              ],
            )
                .onInkTap(() {
                  widget.model.pickDeliveryAddress(
                    vendorCheckRequired: false,
                    onselected: widget.onrefresh,
                  );
                })
                .px12()
                .expand(),
          ],
        ).expand(),

        //
        CustomVisibilty(
          visible: widget.showSearch,
          child: Icon(
            FlutterIcons.search_fea,
            size: 20,
          )
              .p8()
              .onInkTap(() {
                widget.model.openSearch();
              })
              .box
              .roundedSM
              .clip(Clip.antiAlias)
              .color(context.theme.colorScheme.background)
              .outerShadowSm
              .make(),
        ),
      ],
    )
        .box
        .color(context.theme.colorScheme.background)
        // .border(
        //   color: AppColor.cancelledColor,
        //   width: 2,
        // )
        // .bottomRounded()
        .outerShadowSm
        .make()
        .pOnly(top: Vx.dp20, left: 10, right: 10);
  }
}
