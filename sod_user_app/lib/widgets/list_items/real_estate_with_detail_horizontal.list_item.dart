import 'package:flutter/material.dart';
import 'package:sod_user/extensions/dynamic.dart';
import 'package:sod_user/constants/app_routes.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/models/real_estate.dart';
import 'package:sod_user/utils/utils.dart';
import 'package:velocity_x/velocity_x.dart';

class RealEstateWithDetailHorizontal extends StatelessWidget {
  RealEstateWithDetailHorizontal(this.realEstate, {super.key});
  final currencySymbol = AppStrings.currencySymbol;

  final RealEstate realEstate;
  @override
  Widget build(BuildContext context) {
    return Container(
        child: InkWell(
            onTap: () => Navigator.pushNamed(context, AppRoutes.realEstate,
                arguments: realEstate),
            child: HStack([
              // Image with overlay (number and heart icon)
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  realEstate.photo, // Replace with your image URL
                  height: 150,
                  width: 150, // Makes the width fill available space
                  fit: BoxFit.cover,
                ),
              ),
              VStack([
                // Description text
                realEstate.shortDescription.text
                    .size(16)
                    .semiBold
                    .color(Colors.black87)
                    .maxLines(2)
                    .ellipsis
                    .make()
                    .p8(),
                // Sub-description text
                realEstate.name.text
                    .size(14)
                    .color(Colors.black54)
                    .make()
                    .px8(),
                // Price and area info
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text:
                            "${currencySymbol}${realEstate.sellPrice.currencyValueFormat()}",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColor.primaryColor,
                        ),
                      ),
                      TextSpan(
                        text: "| ${realEstate.area} ${realEstate.areaUnit}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ).px8().py4(),
                // Footer with time and location
                HStack([
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.black54,
                  ),
                  4.widthBox,
                  (realEstate.createdAt == null
                      ? SizedBox.shrink()
                      : Utils.timeDifference(realEstate.createdAt!)
                          .text
                          .size(12)
                          .color(Colors.black54)
                          .make()),
                ]).px8(),
                HStack([
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.black54,
                  ),
                  4.widthBox,
                  "Tp Hồ Chí Minh".text.size(12).color(Colors.black54).make(),
                ]).px8()
              ]),
            ])));
  }
}
