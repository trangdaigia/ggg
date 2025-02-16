import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/models/driver.dart';
import 'package:sod_user/widgets/custom_image.view.dart';
import 'package:velocity_x/velocity_x.dart';

class TaxiDriverInfoView extends StatelessWidget {
  const TaxiDriverInfoView(this.driver, {Key? key}) : super(key: key);

  final Driver driver;
  @override
  Widget build(BuildContext context) {
    return HStack(
      [
        //
        CustomImage(
          imageUrl: driver.user.photo,
          width: 50,
          height: 50,
        ).box.roundedFull.clip(Clip.antiAlias).make(),
        //driver info
        VStack(
          [
            "${driver.user.name}".text.medium.xl.make(),
            //rating
            VxRating(
              size: 14,
              maxRating: 5.0,
              value: double.parse(driver.rating),
              isSelectable: false,
              onRatingUpdate: (value) {},
              selectionColor: AppColor.ratingColor,
            ),
          ],
        ).px12().expand(),
        //vehicle info
        VStack(
          [
            "${driver.vehicle?.regNo}".text.xl2.semiBold.make(),
            "${driver.vehicle?.vehicleInfo}".text.medium.sm.make(),
          ],
          crossAlignment: CrossAxisAlignment.end,
        ),
      ],
    );
  }
}
