import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/constants/app_ui_styles.dart';
import 'package:sod_user/models/category.dart';
import 'package:sod_user/utils/utils.dart';
import 'package:sod_user/widgets/cards/custom.visibility.dart';
import 'package:sod_user/widgets/custom_image.view.dart';
import 'package:velocity_x/velocity_x.dart';

class CategoryListItem extends StatelessWidget {
  const CategoryListItem({
    required this.category,
    required this.onPressed,
    this.maxLine = true,
    this.h,
    Key? key,
  }) : super(key: key);

  final Function(Category) onPressed;
  final Category category;
  final bool maxLine;
  final double? h;
  @override
  Widget build(BuildContext context) {
    final textColor =
        Utils.textColorByColor(context.theme.colorScheme.background);

    return VStack(
      [
        //max line applied
        CustomVisibilty(
          visible: maxLine,
          child: VStack(
            [
              //
              CustomImage(
                imageUrl: category.imageUrl ?? "",
                boxFit: BoxFit.fill,
                width: AppStrings.categoryImageWidth,
                height: AppStrings.categoryImageHeight,
              )
                  .box
                  .roundedSM
                  .clip(Clip.antiAlias)
                  .color(Vx.hexToColor(category.color ?? "#ffffff"))
                  .make()
                  .p12(),

              category
                  .name
                  .text
                  .
                  // .minFontSize(AppStrings.categoryTextSize)
                  // .size(AppStrings.categoryTextSize)
                  // .center
                  // .maxLines(1)
                  // .overflow(TextOverflow.ellipsis)
                  // .make()
                  // .p2()
                  lg
                  .color(textColor)
                  .semiBold
                  .size(5)
                  .center
                  .makeCentered()
              //.expand(),
            ],
            crossAlignment: CrossAxisAlignment.center,
            alignment: MainAxisAlignment.start,
          )
              .w((AppStrings.categoryImageWidth * 1.8) +
                  AppStrings.categoryTextSize)
              .h(h ??
                  ((AppStrings.categoryImageHeight * 1.8) +
                      AppStrings.categoryImageHeight))
              .onInkTap(
                () => this.onPressed(this.category),
              )
              .px4(),
        ),

        //no max line applied
        CustomVisibilty(
          visible: !maxLine,
          child: VStack(
            [
              //
              CustomImage(
                imageUrl: category.imageUrl ?? "",
                boxFit: AppUIStyles.vendorTypeImageStyle,
                width: AppStrings.categoryImageWidth,
                height: AppStrings.categoryImageHeight,
              )
                  .box
                  .roundedSM
                  .clip(Clip.antiAlias)
                  .color(Vx.hexToColor(category.color ?? "#ffffff"))
                  .make()
                  .p12(),

              //
              category
                  .name
                  .text
                  // .size(AppStrings.categoryTextSize)
                  // .wrapWords(true)
                  // .center
                  // .make()
                  // .p2(),
                  .lg
                  .color(textColor)
                  .semiBold
                  .size(5)
                  .center
                  .makeCentered()
            ],
            crossAlignment: CrossAxisAlignment.center,
            alignment: MainAxisAlignment.start,
          )
              .w((AppStrings.categoryImageWidth * 1.8) +
                  AppStrings.categoryTextSize)
              .onInkTap(
                () => this.onPressed(this.category),
              )
              .px4(),
        )

        //
      ],
    );
  }
}
