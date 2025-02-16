import 'package:flutter/material.dart';
import "package:localize_and_translate/localize_and_translate.dart";
import 'package:sod_user/constants/app_routes.dart';
import 'package:sod_user/models/real_estate_category.dart';
import 'package:sod_user/utils/utils.dart';
import 'package:velocity_x/velocity_x.dart';

class RealEstateCategoryListItem extends StatelessWidget {
  const RealEstateCategoryListItem(
    this.category, {
    Key? key,
  }) : super(key: key);

  final RealEstateCategory category;
  @override
  Widget build(BuildContext context) {
    //
    final textColor = Utils.textColorByColor(context.theme.colorScheme.primary);
    //
    return InkWell(
      onTap: () => Navigator.pushNamed(context, AppRoutes.realEstateSearch, arguments: {
        "category_id": category.category.id.toString()
      }),
      child: Container(
        height: 180,
        width: 300,
        decoration: BoxDecoration(
            color: Colors.white, // Background color
            borderRadius: BorderRadius.circular(5), // Rounded corners
            image: DecorationImage(
              image: NetworkImage('https://picsum.photos/200'),
              fit: BoxFit.cover,
            )),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: VStack(
          [
            category.category.name
                .tr()
                .text
                .sm
                .color(textColor)
                .bold
                .size(20)
                .make(),
            "${category.totalQuantity} ${"Post".tr()}"
                .tr()
                .text
                .lg
                .color(textColor)
                .semiBold
                .size(20)
                .make()
          ],
          alignment: MainAxisAlignment.spaceBetween,
        ),
      ),
    );
  }
}
