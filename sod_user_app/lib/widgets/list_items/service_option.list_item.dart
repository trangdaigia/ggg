import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/extensions/string.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/models/service_option.dart';
import 'package:sod_user/models/service_option_group.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/view_models/service_details.vm.dart';
import 'package:sod_user/widgets/currency_hstack.dart';
import 'package:sod_user/widgets/custom_image.view.dart';
import 'package:velocity_x/velocity_x.dart';

class ServiceOptionListItem extends StatelessWidget {
  const ServiceOptionListItem({
    required this.option,
    required this.optionGroup,
    required this.model,
    Key? key,
  }) : super(key: key);

  final ServiceOption option;
  final ServiceOptionGroup optionGroup;
  final ServiceDetailsViewModel model;

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
              width: Vx.dp32,
              height: Vx.dp32,
              canZoom: true,
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
            option.name.text.medium.base.make(),
            option.description.isEmptyOrNull
                ? "${option.description}"
                    .text
                    .lg
                    .maxLines(3)
                    .overflow(TextOverflow.ellipsis)
                    .make()
                : UiSpacer.emptySpace(),
          ],
        ).px12().expand(),

        //price
        CurrencyHStack(
          [
            currencySymbol.text.sm.medium.make(),
            option.price.currencyValueFormat().text.sm.bold.make(),
          ],
          crossAlignment: CrossAxisAlignment.end,
        ),
      ],
      crossAlignment: CrossAxisAlignment.center,
    ).onInkTap(() => model.toggleOptionSelection(optionGroup, option));
  }
}
