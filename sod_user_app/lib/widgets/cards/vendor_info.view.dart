import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/models/vendor.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/widgets/custom_image.view.dart';
import 'package:velocity_x/velocity_x.dart';

class VendorInfoView extends StatelessWidget {
  const VendorInfoView(this.vendor, {Key? key}) : super(key: key);

  final Vendor vendor;

  @override
  Widget build(BuildContext context) {
    return HStack(
      [
        // Hình ảnh logo nhà cung cấp
        CustomImage(
          imageUrl: vendor.logo,
          width: 25,
          height: 25,
        ).box.roundedFull.clip(Clip.antiAlias).make(),

        // Khoảng cách ngang
        UiSpacer.hSpace(10),

        // Thông tin nhà cung cấp
        VStack(
          [
            // Tên nhà cung cấp
            "${vendor.name}".text.base.maxLines(1).ellipsis.make(),

            // Đánh giá của nhà cung cấp
            VxRating(
              maxRating: 5,
              value: vendor.rating.toDouble(),
              size: 10,
              isSelectable: false,
              onRatingUpdate: (value) {},
              selectionColor: AppColor.ratingColor,
            ),
          ],
        ).expand(),
      ],
    );
  }
}
