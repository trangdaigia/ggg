import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_images.dart';
import 'package:sod_user/widgets/states/empty.state.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class EmptyVendor extends StatelessWidget {
  const EmptyVendor({this.showDescription = true, Key? key}) : super(key: key);

  final bool showDescription;
  @override
  Widget build(BuildContext context) {
    return EmptyState(
      imageUrl: AppImages.vendor,
      title: "No Vendor Found".tr(),
      description: showDescription
          ? "There seems to be no vendor around your selected location".tr()
          : "",
    );
  }
}
