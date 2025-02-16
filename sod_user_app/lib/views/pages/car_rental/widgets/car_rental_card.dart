import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/extensions/string.dart';
import 'package:sod_user/models/car_rental.dart';
import 'package:sod_user/services/alert.service.dart';
import 'package:sod_user/view_models/car_rental.view_model.dart';
import 'package:sod_user/views/pages/car_rental/widgets/car_rental_detail.dart';
import 'package:sod_user/widgets/buttons/global_button.dart';
import 'package:intl/intl.dart';

class CarRentalCard extends StatelessWidget {
  final CarRental data;
  final CarRentalViewModel model;
  CarRentalCard({super.key, required this.data, required this.model});
  final GlobalKey<FormState> _contactKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        model.getCarDetail(id: data.id!).whenComplete(
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CarRentalDetailPage(
                  model: model,
                ),
              ),
            );
          },
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.width * (50 / 100),
                  // imageUrl: data.photo!.isNotEmpty ? data.photo!.first : '',
                  imageUrl:
                      "https://carshop.vn/wp-content/uploads/2022/07/hinh-nen-xe-oto-dep-1.jpg",
                  fit: BoxFit.fill,
                  placeholder: (context, url) =>
                      CircularProgressIndicator(color: AppColor.primaryColor),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                "${data.carModel?.carMake?.name ?? ""} - ${data.carModel?.name}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        WidgetSpan(
                          child: Icon(Icons.social_distance, size: 20),
                        ),
                        TextSpan(
                          text: " ${data.distance! / 1000} km",
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    "${"Chỉ từ".tr()} ${NumberFormat.currency(locale: "vi_VN", symbol: "").format(data.vehicleRentPrice != null ? data.vehicleRentPrice!.priceMondayFriday! > data.vehicleRentPrice!.priceSaturdaySunday! ? data.vehicleRentPrice?.priceSaturdaySunday : data.vehicleRentPrice?.priceMondayFriday : 0).trim()}đ/${"ngày".tr()}",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
