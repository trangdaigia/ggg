import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_vendor/utils/ui_spacer.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:sod_vendor/utils/utils.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class MenuItem extends StatelessWidget {
  const MenuItem({
    this.title,
    this.child,
    this.divider = true,
    this.topDivider = false,
    this.suffix,
    this.prefix,
    this.trailing,
    this.onPressed,
    this.isExpanded = true,
    this.textColor = Colors.black, 
    this.borderColor = Colors.grey, 
    Key? key,
  }) : super(key: key);

  final String? title;
  final Widget? child;
  final bool divider;
  final bool topDivider;
  final Widget? suffix;
  final Widget? trailing;
  final Widget? prefix;
  final Function? onPressed;
  final bool isExpanded;
  final Color textColor; 
  final Color borderColor; 

  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        topDivider
            ? Divider(
                height: 1,
                thickness: 2,
              )
            : SizedBox.shrink(),

        Container(
          decoration: isExpanded
              ? null
              : BoxDecoration(
                  border: Border.all(
                    color: borderColor, 
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                
          child: HStack(
            [
              suffix ?? 
                  Icon(
                    !Utils.isArabic
                        ? FlutterIcons.right_ant
                        : FlutterIcons.left_ant,
                    size: 16,
                    color: AppColor.cancelledColor,
                  ),
                  
                  SizedBox(width: 15),
              prefix ?? UiSpacer.emptySpace(),
              isExpanded
                  ? (child ?? 
                      "$title"
                          .text
                          .lg
                          .textStyle(AppTextStyle.h6TitleTextStyle(
                              fontWeight: FontWeight.w500,
                              color: textColor, 
                          ))
                          .make())
                      .expand()
                  : child ?? 
                      "$title"
                          .text
                          .lg
                          .textStyle(AppTextStyle.h6TitleTextStyle(
                              fontWeight: FontWeight.w500,
                              color: textColor, 
                          ))
                          .make()
                          .pOnly(right: 8),
              trailing ?? 
                  Icon(
                    !Utils.isArabic
                        ? FlutterIcons.right_ant
                        : FlutterIcons.left_ant,
                    size: 16,
                    color: AppColor.cancelledColor,
                  ),
                          
              
            ],
          ).py4().px8(),
        ),

        divider
            ? Divider(
                height: 1,
                thickness: 2,
                color: Colors.grey.shade300,
              )
            : SizedBox.shrink(),
      ],
    ).onInkTap(
      onPressed != null ? () => onPressed!() : null,
    );
  }
}
