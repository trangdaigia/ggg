import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_user/models/search.dart';
import 'package:sod_user/services/navigation.service.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class SearchBarInput extends StatelessWidget {
  const SearchBarInput({
    this.hintText,
    this.onTap,
    this.onFilterPressed,
    this.onSubmitted,
    this.readOnly = true,
    this.showFilter = false,
    this.search,
    this.searchTEC,
    Key? key,
  }) : super(key: key);

  final String? hintText;
  final Function? onTap;
  final Function? onFilterPressed;
  final Function(String)? onSubmitted;
  final bool readOnly;
  final Search? search;
  final bool? showFilter;
  final TextEditingController? searchTEC;
  @override
  Widget build(BuildContext context) {
    return HStack(
      [
        //
        TextFormField(
          readOnly: readOnly,
          onTap: () {
            if (search != null) {
              //pages
              final page = NavigationService().searchPageWidget(search!);
              context.nextPage(page);
            } else if (onTap != null) {
              onTap!();
            }
          },
          controller: searchTEC,
          onFieldSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: hintText ?? "Search".tr(),
            hintStyle: context.textTheme.bodyMedium!.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w100,
              color: Colors.grey.shade400,
            ),
            border: InputBorder.none,
            prefixIcon: Icon(
              FlutterIcons.search_fea,
              size: 20,
              
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 15),
            filled: true,
            fillColor: context.theme.colorScheme.background,
          ),
        )
            .box
            .color(context.theme.colorScheme.background)
            .outerShadowSm
            .roundedSM
            .clip(Clip.antiAlias)
            .make()
            .expand(),
        Visibility(
          visible: showFilter ?? true,
          child: HStack(
            [
              UiSpacer.horizontalSpace(),
              //filter icon
              IconButton(
                onPressed: null,
                color: context.theme.colorScheme.background,
                icon: Icon(
                  FlutterIcons.sliders_faw,
                  color: context.primaryColor,
                  size: 20,
                ),
              )
                  .onInkTap(
                    onFilterPressed != null ? () => onFilterPressed!() : () {},
                  )
                  .material(color: context.theme.colorScheme.background)
                  .box
                  .color(context.theme.colorScheme.background)
                  .outerShadowSm
                  .roundedSM
                  .clip(Clip.antiAlias)
                  .make(),
            ],
          ),
        ),
      ],
    );
  }
}
