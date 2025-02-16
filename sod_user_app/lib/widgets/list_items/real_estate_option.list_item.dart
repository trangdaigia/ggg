
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/constants/app_ui_styles.dart';
import 'package:sod_user/utils/utils.dart';
import 'package:sod_user/widgets/custom_image.view.dart';
import 'package:velocity_x/velocity_x.dart';

class RealEstateOptionListItem extends StatelessWidget {
  const RealEstateOptionListItem(
    this.option,
    this.index, {
    Key? key,
  }) : super(key: key);

  final String option;
  final int index;
  @override
  Widget build(BuildContext context) {
    //
    final textColor =
        Utils.textColorByColor(context.theme.colorScheme.background);
    //
    return AnimationConfiguration.staggeredList(
      position: this.index + 8,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: InkWell(
            child: VStack(
              [
                //image + details
                Visibility(
                  visible: !AppStrings.showVendorTypeImageOnly,
                  child: VStack(
                    [
                      //
                      CustomImage(
                        imageUrl: "https://picsum.photos/200",
                        boxFit: AppUIStyles.vendorTypeImageStyle,
                        height: AppUIStyles.vendorTypeHeight,
                        width: AppUIStyles.vendorTypeWidth,
                      )
                          .box
                          .height(
                            AppStrings.categoryImageHeight,
                          )
                          .width(
                            AppStrings.categoryImageWidth,
                          )
                          .outerShadow
                          .clip(Clip.antiAlias)
                          .withRounded(value: 15)
                          .make()
                          .p12()
                          .centered(),
                      //
                      VStack(
                        [
                          option
                              .tr()
                              .text
                              .lg
                              .color(textColor)
                              .semiBold
                              .size(5)
                              .center
                              .makeCentered(),
                        ],
                      ),
                    ],
                  ).pOnly(top: 0, bottom: 12).centered(),
                ),

                //image only
                Visibility(
                  visible: AppStrings.showVendorTypeImageOnly,
                  child: CustomImage(
                    imageUrl: "https://picsum.photos/200",
                    boxFit: AppUIStyles.vendorTypeImageStyle,
                    height: AppUIStyles.vendorTypeHeight,
                    width: AppUIStyles.vendorTypeWidth,
                  )
                      .box
                      .height(60)
                      .width(60)
                      .outerShadow
                      .clip(Clip.antiAlias)
                      .withRounded(value: 15)
                      .make(),
                ),
              ],
            ),
          )
        ),
      ),
    );
  }
}
