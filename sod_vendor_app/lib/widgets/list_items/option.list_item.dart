import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_vendor/constants/app_colors.dart';
import 'package:sod_vendor/extensions/dynamic.dart';
import 'package:sod_vendor/models/option.dart';
import 'package:sod_vendor/models/option_group.dart';
import 'package:sod_vendor/constants/app_strings.dart';
import 'package:sod_vendor/utils/ui_spacer.dart';
import 'package:sod_vendor/view_models/product_details.vm.dart';
import 'package:sod_vendor/widgets/currency_hstack.dart';
import 'package:sod_vendor/widgets/custom_image.view.dart';
import 'package:velocity_x/velocity_x.dart';

class OptionListItem extends StatelessWidget {
  const OptionListItem({
    required this.option,
    this.optionGroup,
    required this.model,
    Key? key,
  }) : super(key: key);

  final Option option;
  final OptionGroup? optionGroup;
  final ProductDetailsViewModel model;

  @override
  Widget build(BuildContext context) {
    //
    final currencySymbol = AppStrings.currencySymbol;
    return HStack(
      [
        //image/photo
        Stack(
          children: [
            //
            CustomImage(
              imageUrl: option.photo,
              width: Vx.dp48,
              height: Vx.dp48,
            ).card.clip(Clip.antiAlias).roundedSM.make(),

            //
            model.isOptionSelected(option)
                ? Positioned(
                    top: 5,
                    bottom: 5,
                    left: 5,
                    right: 5,
                    child: Icon(
                      FlutterIcons.check_ant,
                    ).box.color(AppColor.accentColor).roundedSM.make(),
                  )
                : UiSpacer.emptySpace(),
          ],
        ),

        //details
        VStack(
          [
            //
            option.name.text.medium.xl.make(),
            option.description != null && option.description.isEmptyOrNull
                ? "${option.description}"
                    .text
                    .sm
                    .maxLines(3)
                    .overflow(TextOverflow.ellipsis)
                    .make()
                : UiSpacer.emptySpace(),
          ],
        ).px12().expand(),

        //price
        CurrencyHStack(
          [
            currencySymbol.text.base.medium.make(),
            option.price.currencyValueFormat().text.xl.bold.make(),
          ],
          crossAlignment: CrossAxisAlignment.end,
        ),
      ],
      crossAlignment: CrossAxisAlignment.center,
    );
  }
}
