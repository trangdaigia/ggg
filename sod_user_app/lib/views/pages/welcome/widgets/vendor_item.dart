import 'package:flutter/material.dart';
import 'package:sod_user/models/vendor_type.dart';
import 'package:sod_user/services/navigation.service.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:sod_user/widgets/custom_image.view.dart';

class VendorItem extends StatelessWidget {
  VendorItem({
    super.key,
    required this.vendorType,
  });

  final VendorType vendorType;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CustomImage(
        imageUrl: vendorType.logo,
        boxFit: BoxFit.cover,
        height: 50,
        width: 50,
      ),
      Text(
        vendorType.name,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    ]).onTap(() {
      NavigationService.pageSelected(vendorType, context: context);
    });
  }
}
