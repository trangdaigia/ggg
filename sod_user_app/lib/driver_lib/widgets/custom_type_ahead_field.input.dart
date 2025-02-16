import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:sod_user/driver_lib/constants/app_colors.dart';
import 'package:sod_user/driver_lib/constants/app_text_styles.dart';
import 'package:velocity_x/velocity_x.dart';

class CustomTypeAheadField<T> extends StatelessWidget {
  const CustomTypeAheadField({
    this.title,
    this.hint,
    this.textEditingController,
    this.items,
    this.textFieldConfiguration,
    required this.suggestionsCallback,
    this.itemBuilder,
    required this.onSuggestionSelected,
    this.type,
    Key? key,
  }) : super(key: key);
  final String? type;
  final String? title;
  final String? hint;
  final List<dynamic>? items;
  final TextEditingController? textEditingController;
  final TextFieldConfiguration? textFieldConfiguration;
  final FutureOr<Iterable<T>> Function(String) suggestionsCallback;
  final void Function(T) onSuggestionSelected;
  final Widget Function(BuildContext, T)? itemBuilder;

  //
  //Đổi màu labelText khi focus

  TextStyle labelStyle(BuildContext context) {
    return AppTextStyle.h5TitleTextStyle(
      color: Theme.of(context).textTheme.bodyLarge!.color,
      fontWeight: FontWeight.w600,
    ).copyWith(
      fontStyle: FontStyle.italic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<T>(
      textFieldConfiguration: textFieldConfiguration ??
          TextFieldConfiguration(
            cursorColor: AppColor.cursorColor,
            controller: textEditingController,
            autofocus: false,
            style: DefaultTextStyle.of(context).style.copyWith(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                type != "color"
                    ? MaterialIcons.directions_car
                    : Icons.color_lens_outlined,
                color: Theme.of(context).textTheme.bodyLarge!.color,
              ),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                //Chỉnh màu cho border
                color: AppColor.cancelledColor,
              )),
              focusedBorder: OutlineInputBorder(
                //Chỉnh màu cho border khi bấm vào
                borderSide: BorderSide(
                  color: AppColor.cancelledColor,
                ),
              ),
              hintText: hint,
              hintStyle: AppTextStyle.hintStyle(),
              labelStyle: labelStyle(context),
              label: title != null ? "$title".text.make() : null,
            ),
          ),
      suggestionsCallback: suggestionsCallback,
      itemBuilder: itemBuilder ??
          (context, suggestion) {
            return ListTile(
              title: Text(
                  "${suggestion is Map ? suggestion['name'] : suggestion}"),
            );
          },
      onSuggestionSelected: onSuggestionSelected,
    );
  }
}
