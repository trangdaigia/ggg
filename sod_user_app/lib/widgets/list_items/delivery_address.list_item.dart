import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_user/models/delivery_address.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/widgets/cards/custom.visibility.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class DeliveryAddressListItem extends StatelessWidget {
  const DeliveryAddressListItem({
    required this.deliveryAddress,
    this.onEditPressed,
    this.onDeletePressed,
    this.action = false,
    this.border = true,
    this.delete = true,
    this.borderColor,
    this.showDefault = true,
    Key? key,
  }) : super(key: key);

  final DeliveryAddress deliveryAddress;
  final Function? onEditPressed;
  final Function? onDeletePressed;
  final bool delete;
  final bool action;
  final bool border;
  final bool showDefault;
  final Color? borderColor;
  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        //
        HStack(
          [
            deliveryAddress.name?.toString().toLowerCase() == "home"
                ? Icon(
                    FlutterIcons.home_ant, // Choose the appropriate heart icon
                    size: 16,
                    color: Colors.green, // Choose the color you want
                  )
                    .box
                    .padding(EdgeInsets.symmetric(vertical: 12, horizontal: 8))
                    .make()
                : (deliveryAddress.name?.toString().toLowerCase() == "work")
                    ? Icon(
                        FlutterIcons
                            .work_mdi, // Choose the appropriate heart icon
                        size: 16,
                        color: Colors.green, // Choose the color you want
                      )
                        .box
                        .padding(
                            EdgeInsets.symmetric(vertical: 12, horizontal: 8))
                        .make()
                    :
                    //icon heart
                    Icon(
                        FlutterIcons
                            .heart_ant, // Choose the appropriate heart icon
                        size: 16,
                        color: Colors.red, // Choose the color you want
                      )
                        .box
                        .padding(
                            EdgeInsets.symmetric(vertical: 12, horizontal: 8))
                        .make(),
            //
            VStack(
              [
                "${deliveryAddress.name.toString().allWordsCapitilize()}"
                    .text
                    .semiBold
                    .lg
                    .make(),
                // "${deliveryAddress.address}"
                //     .text
                //     .sm
                //     .maxLines(3)
                //     .overflow(TextOverflow.ellipsis)
                //     .make(),

                "${deliveryAddress.address}"
                    .text
                    .sm
                    .maxLines(3)
                    .overflow(TextOverflow.ellipsis)
                    .make(),

                "${deliveryAddress.description}".text.sm.make(),
                (deliveryAddress.defaultDeliveryAddress && showDefault)
                    ? "Default"
                        .tr()
                        .text
                        .xs
                        .italic
                        .maxLines(3)
                        .overflow(TextOverflow.ellipsis)
                        .make()
                    : UiSpacer.emptySpace(),
              ],
            ).p12().expand(),
            //

            this.action
                ? VStack(
                    [
                      delete
                          ?
                          //delete icon
                          Icon(
                              FlutterIcons.delete_ant,
                              size: 16,
                              color: Colors.black,
                            )
                              .wFull(context)
                              .onInkTap(
                                this.onDeletePressed != null
                                    ? () => this.onDeletePressed!()
                                    : () {},
                              )
                              .py12()
                              .box
                              .make()
                          :
                          // move to next page icon
                          Icon(
                              FlutterIcons.arrow_right_bold_mco,
                              size: 16,
                              color: Colors.white,
                            )
                              .wFull(context)
                              .onInkTap(
                              this.onEditPressed != null
                                  ? () => this.onEditPressed!()
                                  : () {},
                              )
                              .box
                              .padding(EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 8))
                              .make(),
                      //edit icon
                      // Icon(
                      //   FlutterIcons.edit_ent,
                      //   size: 16,
                      //   color: Colors.white,
                      // )
                      //     .wFull(context)
                      //     .onInkTap(
                      //       this.onEditPressed != null
                      //           ? () => this.onEditPressed!()
                      //           : () {},
                      //     )
                      //     .py12()
                      //     .box
                      //     .blue500
                      //     .make(),
                    ],
                    axisSize: MainAxisSize.max,
                    crossAlignment: CrossAxisAlignment.center,
                  ).w(context.percentWidth * 15)
                : UiSpacer.emptySpace(),
          ],
        )
            .wFull(context)
            .onInkTap(
              this.onEditPressed != null ? () => this.onEditPressed!() : null,
            )
            .box
            .roundedSM
            .clip(Clip.antiAlias)
            .border(
              color: borderColor != null
                  ? borderColor!
                  : (border ? context.accentColor : Colors.transparent),
              width: border ? 1 : 0,
            )
            .make(),

        //
        //can deliver
        CustomVisibilty(
          visible: deliveryAddress.can_deliver != null &&
              !(deliveryAddress.can_deliver ?? true),
          child: "Vendor does not service this location"
              .tr()
              .text
              .red500
              .xs
              .thin
              .make()
              .px12()
              .py2(),
        ),
      ],
    );
  }
}
