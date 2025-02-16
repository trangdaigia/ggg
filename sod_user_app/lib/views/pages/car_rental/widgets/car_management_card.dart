import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/extensions/string.dart';
import 'package:sod_user/models/car_rental.dart';
import 'package:sod_user/view_models/car_management.view_model.dart';
import 'package:sod_user/views/pages/car_rental/car_manage.dart/car_detail.page.dart';
import 'package:velocity_x/velocity_x.dart';

class CarManagementCard extends StatefulWidget {
  final CarRental data;
  final Function()? onDelete;
  final CarManagementViewModel model;
  final int index;

  const CarManagementCard({
    super.key,
    required this.data,
    this.onDelete,
    required this.model,
    required this.index,
  });

  @override
  State<CarManagementCard> createState() => _CarManagementCardState();
}

class _CarManagementCardState extends State<CarManagementCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MyCarDetailPage(
                    model: widget.model,
                    data: widget.data,
                    index: widget.index,
                  )),
        );
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: CachedNetworkImage(
                width: MediaQuery.of(context).size.width / 2.5,
                height: MediaQuery.of(context).size.height / 7,
                imageUrl: widget.data.photo!.isNotEmpty
                    ? widget.data.photo!.first
                    : "",
                fit: BoxFit.fitWidth,
                placeholder: (context, url) =>
                    CircularProgressIndicator(color: AppColor.cancelledColor),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  '${widget.data.carModel?.carMake?.name} ${widget.data.carModel?.name}'
                      .text
                      .xl
                      .bold
                      .make(),
                  Row(
                    children: [
                      '${'Giá thuê'.tr()}: '.text.lg.make(),
                      '${'${AppStrings.currencySymbol} ${widget.data.vehicleRentPrice?.priceMondayFriday ?? 122000}'.currencyFormat()}'
                          .text
                          .xl
                          .color(Colors.red)
                          .make(),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatCurrency(int? number) {
    var formatCurrency =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    return formatCurrency.format(number);
  }
}
