import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/utils/utils.dart';
import 'package:velocity_x/velocity_x.dart';

class PropertyTypeListItem extends StatelessWidget {
  const PropertyTypeListItem(
    this.propertyType, {
    Key? key,
  }) : super(key: key);

  final String propertyType;
  @override
  Widget build(BuildContext context) {
    //
    final textColor =
        Utils.textColorByColor(context.theme.colorScheme.background);
    //
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Background color
        borderRadius: BorderRadius.circular(50), // Rounded corners

      ),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: propertyType
          .tr()
          .text
          .sm
          .color(textColor)
          .medium
          .size(15)
          .center
          .make(),
    );
  }
}
