import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/models/order.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/utils/utils.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:sod_user/widgets/custom_image.view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class OrderDriverInfoView extends StatelessWidget {
  OrderDriverInfoView(
    this.order, {
    required this.rateDriverAction,
    Key? key,
  }) : super(key: key);

  final Order order;
  final Function rateDriverAction;

  @override
  Widget build(BuildContext context) {
    double avatarSize = context.percentWidth * 14;

    //
    return order.driver != null
        ? VxBox(
            child: VStack(
              [
                //driver info
                HStack(
                  [
                    //driver profile
                    Stack(
                      children: [
                        CustomImage(
                          imageUrl: order.driver!.user.photo,
                          width: avatarSize,
                          height: avatarSize,
                        ),
                        //rating
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: HStack(
                            [
                              Icon(
                                FlutterIcons.star_ant,
                                size: 14,
                                color: Utils.textColorByTheme(),
                              ),
                              UiSpacer.hSpace(2),
                              //
                              "${order.driver?.rating}"
                                  .text
                                  .sm
                                  .color(Utils.textColorByTheme())
                                  .make(),
                            ],
                            crossAlignment: CrossAxisAlignment.center,
                            alignment: MainAxisAlignment.center,
                          )
                              .pSymmetric(v: 2, h: 6)
                              .box
                              .roundedLg
                              .color(AppColor.ratingColor)
                              .makeCentered(),
                        ),
                      ],
                    ),
                    UiSpacer.hSpace(12),

                    VStack(
                      [
                        "${order.driver?.user.name}".text.medium.xl.make(),
                        VxRating(
                          isSelectable: false,
                          onRatingUpdate: (value) {},
                          maxRating: 5.0,
                          count: 5,
                          value:
                              double.parse(order.driver!.user.rating ?? "0.0"),
                          selectionColor: AppColor.ratingColor,
                        ),
                      ],
                    ).expand(),
                  ],
                  crossAlignment: CrossAxisAlignment.center,
                ),
                //vehicle info
                Visibility(
                  visible: order.driver?.vehicle != null,
                  child: VStack(
                    [
                      UiSpacer.divider().py8(),
                      HStack(
                        [
                          "${order.driver?.vehicle!.carModel?.carMake ?? ""} - ${order.driver?.vehicle!.carModel?.name ?? ""}"
                              .text
                              .medium
                              .make(),
                          UiSpacer.expandedSpace(),
                          "${order.driver?.vehicle?.regNo}"
                              .text
                              .lg
                              .semiBold
                              .make(),
                        ],
                      ),
                    ],
                  ),
                ),

                //has driver been rated
                Visibility(
                  visible: order.canRateDriver,
                  child: VStack(
                    [
                      //rate driver button with action
                      UiSpacer.divider().py8(),
                      CustomButton(
                        title: "Rate Driver".tr(),
                        onPressed: rateDriverAction,
                      ),
                    ],
                  ),
                ),
              ],
            ).px20().py12(),
          ).shadowXs.color(context.theme.colorScheme.background).make()
        : 0.heightBox;
  }
}
