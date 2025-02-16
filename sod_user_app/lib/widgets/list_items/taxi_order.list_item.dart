import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_images.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/extensions/string.dart';
import 'package:sod_user/models/order.dart';
import 'package:sod_user/models/order_status.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/widgets/currency_hstack.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class TaxiOrderListItem extends StatelessWidget {
  const TaxiOrderListItem({
    required this.order,
    this.onPayPressed,
    required this.orderPressed,
    Key? key,
  }) : super(key: key);

  final Order order;
  final Function? onPayPressed;
  final Function orderPressed;
  @override
  Widget build(BuildContext context) {
    //
    final currencySymbol = order.taxiOrder?.currency != null
        ? order.taxiOrder?.currency?.symbol
        : AppStrings.currencySymbol;
    //
    DateFormat vietnameseFormat = DateFormat("dd MMM yyyy HH:mm", "vi_VN");
    return VStack(
      [
        //
        VStack(
          [
            //
            HStack(
              [
                Image.asset(AppImages.pickupLocation).wh(12, 12),
                UiSpacer.horizontalSpace(space: 10),
                "${order.taxiOrder?.pickupAddress}"
                    .text
                    .medium
                    .overflow(TextOverflow.ellipsis)
                    .make()
                    .expand(),
              ],
            ),
            DottedLine(
              direction: Axis.vertical,
              lineThickness: 2,
              dashGapLength: 1,
              dashColor: AppColor.primaryColor,
            ).wh(1, 15).px4(),
            HStack(
              [
                Image.asset(AppImages.dropoffLocation).wh(12, 12),
                UiSpacer.horizontalSpace(space: 10),
                "${order.taxiOrder?.dropoffAddress}"
                    .text
                    .medium
                    .overflow(TextOverflow.ellipsis)
                    .make()
                    .expand(),
              ],
            ),
          ],
        ).p20(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            translator.activeLanguageCode == 'vi'
                ? '${vietnameseFormat.format(order.createdAt)}'.text.sm.make()
                : VxTextBuilder(
                        Jiffy(order.createdAt).format('dd E, MMM y HH:mm'))
                    .sm
                    .make(),
          ],
        ).pOnly(right: 12),
        //price
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CurrencyHStack(
              [
                "$currencySymbol ".text.semiBold.xl.make(),
                "${order.total.currencyValueFormat()}".text.semiBold.xl.make()
              ],
            ),
            "${order.Taxistatus}"
                .tr()
                .capitalized
                .text
                .color(AppColor.getStausColor(order.status))
                .make(),
          ],
        ).py8().px12(),
      ],
    )
        .onInkTap(
          () => orderPressed(),
        )
        .box
        .border(color: Colors.grey.shade200)
        .make()
        .card
        .elevation(0.5)
        .clip(Clip.antiAlias)
        .roundedSM
        .make();
  }

  String formatDate(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    String formattedDate =
        "${dateTime.day}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
    return formattedDate;
  }
}
