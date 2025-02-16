import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/constants/app_ui_styles.dart';
import 'package:sod_user/models/vendor_type.dart';
import 'package:sod_user/utils/utils.dart';
import 'package:sod_user/widgets/custom_image.view.dart';
import 'package:velocity_x/velocity_x.dart';

class VendorTypeListItem extends StatelessWidget {
  const VendorTypeListItem(
    this.vendorType, {
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  final VendorType vendorType;
  final Function onPressed;
  @override
  Widget build(BuildContext context) {
    //
    final textColor = Utils.textColorByColor(context.theme.colorScheme.background);
    //
    return AnimationConfiguration.staggeredList(
      position: vendorType.id,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: InkWell(
            onTap: () => this.onPressed(),
            child: VStack(
              [
                //image + details
                Visibility(
                  visible: !AppStrings.showVendorTypeImageOnly,
                  child: HStack(
                    [
                      //
                      CustomImage(
                        imageUrl: vendorType.logo,
                        boxFit: AppUIStyles.vendorTypeImageStyle,
                        height: AppUIStyles.vendorTypeHeight,
                        width: AppUIStyles.vendorTypeWidth,
                      ).box.height(60).width(60).outerShadow.clip(Clip.antiAlias).withRounded(value: 15).make().pOnly(left:4, top: 12, bottom: 12, right: 16),
                      //

                      VStack(
                        [
                          vendorType.name.text.xl
                              .color(textColor)
                              .semiBold
                              .make(),
                          Visibility(
                            visible: vendorType.description.isNotEmpty,
                            child: "${vendorType.description}"
                                .text
                                .color(textColor)
                                .sm
                                .make()
                                .pOnly(top: 5),
                          ),
                        ],
                      ).expand(),
                    ],
                  ).p12(),
                ),

                //image only
                Visibility(
                  visible: AppStrings.showVendorTypeImageOnly,
                  child: CustomImage(
                    imageUrl: vendorType.logo,
                    boxFit: AppUIStyles.vendorTypeImageStyle,
                    height: AppUIStyles.vendorTypeHeight,
                    width: AppUIStyles.vendorTypeWidth,
                  ).box.height(60).width(60).outerShadow.clip(Clip.antiAlias).withRounded(value: 15).make(),
                ),
              ],
            ),
          )
              .box
              .clip(Clip.antiAlias)
              .withRounded(value: 10)
              // .outerShadow
              // .color(Vx.hexToColor(vendorType.color))
              .color(context.theme.colorScheme.background)
              .make()
              .pOnly(bottom: Vx.dp20),
        ),
      ),
    );
  }
}
