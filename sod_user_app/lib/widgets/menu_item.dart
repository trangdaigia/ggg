import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_images.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/widgets/cards/custom.visibility.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:google_fonts/google_fonts.dart';

class MenuItem extends StatelessWidget {
  const MenuItem({
    this.title,
    this.child,
    this.divider = true,
    this.topDivider = false,
    this.suffix,
    this.onPressed,
    this.ic,
    this.direction = true,
    this.border = true,
    this.isExpanded = true,
    this.showSuffix = true,
    this.padV = 12,
    Key? key,
  }) : super(key: key);

  final String? title;
  final Widget? child;
  final bool divider;
  final bool topDivider;
  final Widget? suffix;
  final Function? onPressed;
  final String? ic;
  final bool direction;
  final bool border;
  final bool isExpanded;
  final bool showSuffix;
  final double padV;

  @override
  Widget build(BuildContext context) {
    return direction ? Container(
      child: border ? MaterialButton(
      onPressed: onPressed != null ? () => onPressed!() : null,
      elevation: 0.6, 
      color: context.theme.colorScheme.background,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: padV),
      child: HStack(
        [
          CustomVisibilty(
            visible: ic != null,
            child: HStack(
              [
                Image.asset(
                  ic ?? AppImages.appLogo,
                  width: 24,
                  height: 24,
                ),
                UiSpacer.horizontalSpace(),
              ],
            ),
          ),
          isExpanded
              ? Expanded(child: child ?? Text(
                "$title",
                style: GoogleFonts.roboto(
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ).text.lg.light.make())
              : (child ?? Text(
                "$title",
                style: GoogleFonts.roboto(
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ).text.lg.light.make()),
          if (showSuffix) 
            suffix ??
                Icon(
                  FlutterIcons.right_ant,
                  size: 16,
                ),
        ],
      ) 
    ).pOnly(bottom: Vx.dp3)
    : Container(
      decoration: BoxDecoration(
        border: Border.all(
            //color: const Color.fromARGB(163, 143, 138, 138),
            color: AppColor.iconHintColor,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10),
      ),
      child: MaterialButton(
        onPressed: onPressed != null ? () => onPressed!() : null,
        elevation: 0, 
        color: context.theme.colorScheme.background,
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        child: HStack(
            [
              CustomVisibilty(
                visible: ic != null,
                child: HStack(
                  [
                    Image.asset(
                      ic ?? AppImages.appLogo,
                      width: 24,
                      height: 24,
                    ),
                    UiSpacer.horizontalSpace(),
                  ],
                ),
              ),
              isExpanded
                ? Expanded(child: child ?? Text(
                  "$title",
                  style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ).text.lg.light.make())
                : (child ?? Text(
                  "$title",
                  style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w400,
                      
                    ),
                  ),
                ).text.lg.light.make()),
              if (showSuffix) 
                suffix ??
                    Icon(
                      FlutterIcons.right_ant,
                      size: 16,
                    ),
            ],
          ),
        
        
      ).pOnly(bottom: Vx.dp3),
    )
    )
    : Container(
      child: border ? MaterialButton(
      onPressed: onPressed != null ? () => onPressed!() : null,
      elevation: 0.6, 
      color: context.theme.colorScheme.background,
      padding: EdgeInsets.symmetric(horizontal: 2, vertical: padV),
      child: VStack(
        [
          CustomVisibilty(
            visible: ic != null,
            child: Align(
              alignment: Alignment.center, 
              child: Padding(
                padding:EdgeInsets.only(left: 15),
                child: HStack(
                  [
                    Image.asset(
                      ic ?? AppImages.appLogo,
                      width: 24,
                      height: 24,
                    ),
                    UiSpacer.horizontalSpace(),
                  ],
                ),
              ),
               
              )
            
          ),
          UiSpacer.vSpace(5),
          Align(
            alignment: Alignment.center, 
            child: Text(
              "$title",
              style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w400
                    ),
                  ),
              ).text
                .lg
                .light
                .softWrap(true)
                .size(13.5)
                .make(),
          ),
        ],
         alignment: MainAxisAlignment.center,
      ).box.height(67).make()
    ).pOnly(bottom: Vx.dp3)
    : MaterialButton(
      onPressed: onPressed != null ? () => onPressed!() : null,
      elevation: 0.6, 
      color: context.theme.colorScheme.background,
      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 0),
      child:  Container(
        decoration: BoxDecoration(
          border: Border.all(
            //color: const Color.fromARGB(163, 143, 138, 138),
            color: AppColor.iconHintColor,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: VStack(
          [
            CustomVisibilty(
              visible: ic != null,
              child: Align(
                alignment: Alignment.center, 
                child: Padding(
                  padding:EdgeInsets.only(left: 15),
                  child: HStack(
                    [
                      Image.asset(
                        ic ?? AppImages.appLogo,
                        width: 24,
                        height: 24,
                      ),
                      UiSpacer.horizontalSpace(),
                    ],
                  ),
                ),
                
                )
              
            ),
            UiSpacer.vSpace(5),
            Align(
              alignment: Alignment.center, 
              child: Text(
              "$title",
              style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w400
                    ),
                  ),
              ).text
                .lg
                .light
                .softWrap(true)
                .size(13.5)
                .make(),
            ),
          ],
          alignment: MainAxisAlignment.center,
        ).box.height(67).make(),
      ), 
    ).pOnly(bottom: Vx.dp3),
    );
  }
}
