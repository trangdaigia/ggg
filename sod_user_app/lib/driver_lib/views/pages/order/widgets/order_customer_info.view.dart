import 'package:flutter/material.dart';
import 'package:sod_user/driver_lib/constants/app_colors.dart';
import 'package:sod_user/driver_lib/models/order.dart';
import 'package:sod_user/driver_lib/utils/ui_spacer.dart';
import 'package:sod_user/driver_lib/widgets/custom_image.view.dart';
import 'package:velocity_x/velocity_x.dart';

class OrderCustomerInfoView extends StatelessWidget {
  OrderCustomerInfoView(this.order, {Key? key}) : super(key: key);

  final Order order;

  @override
  Widget build(BuildContext context) {
    double avatarSize = 40;

    //
    return VxBox(
      child: HStack(
        [
          //customer profile
          CustomImage(
            imageUrl: order.user.photo,
            width: avatarSize,
            height: avatarSize,
          ),
          UiSpacer.hSpace(12),

          VStack(
            [
              "${order.user.name}".text.medium.make(),
              VxRating(
                isSelectable: false,
                onRatingUpdate: (value) {},
                maxRating: 5.0,
                count: 5,
                size: 16,
                value: order.user.rating,
                selectionColor: AppColor.ratingColor,
              ),
            ],
          ).expand(),
        ],
        crossAlignment: CrossAxisAlignment.center,
      ).px20().py12(),
    ).shadowXs.color(context.theme.colorScheme.background).make();
  }
}
