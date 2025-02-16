import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/constants/app_ui_styles.dart';
import 'package:sod_user/models/vendor_type.dart';
import 'package:sod_user/utils/utils.dart';
import 'package:sod_user/widgets/custom_image.view.dart';
import 'package:velocity_x/velocity_x.dart';

class VendorTypeVerticalListItem extends StatelessWidget {
  const VendorTypeVerticalListItem(
    this.vendorType, {
    required this.onPressed,
    required this.index,
    Key? key,
  }) : super(key: key);

  final VendorType vendorType;
  final Function onPressed;
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
            onTap: () => onPressed(),
            child: VStack(
              [
                //image + details
                Visibility(
                  visible: !AppStrings.showVendorTypeImageOnly,
                  child: VStack(
                    [
                      //
                      CustomImage(
                        imageUrl: vendorType.logo,
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
                          vendorType.name
                              .tr()
                              .text
                              .lg
                              .color(textColor)
                              .semiBold
                              .size(5)
                              .center
                              .makeCentered(),
                          Visibility(
                            visible: vendorType.description.tr().isNotEmpty,
                            child: "${vendorType.description.tr()}"
                                .text
                                .color(textColor)
                                .center
                                .xs
                                .makeCentered()
                                .pOnly(top: 5),
                          ),
                        ],
                      ),
                    ],
                  ).pOnly(top: 0, bottom: 12).centered(),
                ),

                //image only
                Visibility(
                  visible: AppStrings.showVendorTypeImageOnly,
                  child: CustomImage(
                    imageUrl: vendorType.logo,
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
              .box
              .clip(Clip.antiAlias)
              .withRounded(value: 15)
              // .outerShadow
              // .color(Vx.hexToColor(vendorType.color))
              .color(context.theme.colorScheme.background)
              //.color(Colors.grey.shade300)
              .make(),
        ),
      ),
    );
  }
}
