import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/extensions/dynamic.dart';
import 'package:sod_user/models/order.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:jiffy/jiffy.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class OrderListItem extends StatelessWidget {
  const OrderListItem({
    required this.order,
    required this.onPayPressed,
    required this.orderPressed,
    Key? key,
  }) : super(key: key);

  final Order order;
  final Function onPayPressed;
  final Function orderPressed;
  @override
  Widget build(BuildContext context) {
    DateFormat vietnameseFormat = DateFormat("dd MMM yyyy HH:mm", "vi_VN");
    return VStack(
      [
        HStack(
          [
            //
            VStack(
              [
                //
                HStack(
                  [
                    "#${order.code}".text.medium.make().expand(),
                    "${AppStrings.currencySymbol} ${(order.total ?? 0) + (order.tip ?? 0)}"
                        .currencyFormat()
                        .text
                        .lg
                        .semiBold
                        .make(),
                  ],
                ),
                Divider(height: 6),

                //
                "${order.vendor?.name}".text.lg.medium.make().py4(),
                //amount and total products

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    (order.isPackageDelivery
                            ? order.packageType?.name
                            : order.isSerice
                                ? "${order.orderService?.service?.category?.name}"
                                : "%s Product(s)"
                                    .tr()
                                    .fill([order.orderProducts?.length ?? 0]))!
                        .text
                        .medium
                        .make(),
                    translator.activeLanguageCode == 'vi'
                        ? '${vietnameseFormat.format(order.createdAt)}'
                            .text
                            .sm
                            .make()
                        : VxTextBuilder(Jiffy(order.createdAt)
                                .format('dd E, MMM y HH:mm'))
                            .sm
                            .make(),
                  ],
                ),
                //time & status
                HStack(
                  [
                    //time
                    Visibility(
                      visible: order.paymentMethod != null,
                      child: "${order.paymentMethod?.name}".text.medium.make(),
                    ).expand(),
                    "${order.status}"
                        .tr()
                        .capitalized
                        .text
                        .color(AppColor.getStausColor(order.status))
                        .medium
                        .make()
                  ],
                ),
                //time & status\
                HStack(
                  [
                    "Order Type".tr().text.make().expand(),
                    order.vendor != null
                        ? "${order.vendor!.vendorType.name}"
                            .text
                            .semiBold
                            .lg
                            .make()
                        : "".text.semiBold.lg.make()
                  ],
                ).pOnly(top: 10),
              ],
            ).p12().expand(),
          ],
        ),

        //
        //payment is pending
        order.isPaymentPending
            ? CustomButton(
                title: "PAY FOR ORDER".tr(),
                titleStyle: context.textTheme.bodyLarge!.copyWith(
                  color: Colors.white,
                ),
                icon: FlutterIcons.credit_card_fea,
                iconSize: 18,
                onPressed: onPayPressed,
                shapeRadius: 0,
              )
            : UiSpacer.emptySpace(),
      ],
    )
        .box
        .border(color: Colors.grey.shade200)
        .make()
        .card
        .elevation(0.5)
        .clip(Clip.antiAlias)
        .roundedSM
        .make()
        .onInkTap(() => orderPressed());
  }

  String formatDate(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    String formattedDate =
        "${dateTime.day}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
    return formattedDate;
  }
}
