import 'package:flutter/material.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/widgets/custom_text_form_field.dart';
import 'package:velocity_x/velocity_x.dart';

class ParcelFormInput extends StatelessWidget {
  const ParcelFormInput({
    this.iconData,
    this.iconColor,
    this.labelText,
    this.hintText,
    this.isReadOnly = true,
    this.onInputTap,
    required this.tec,
    this.keyboardType,
    this.icon,
    this.content,
    this.suffix,
    this.centered = false,
    this.formValidator,
    Key? key,
  }) : super(key: key);

  final IconData? iconData;
  final Color? iconColor;
  final String? labelText;
  final String? hintText;
  final bool isReadOnly;
  final Function()? onInputTap;
  final TextEditingController tec;
  final TextInputType? keyboardType;

  //
  final Widget? icon;
  final Widget? suffix;
  final Widget? content;
  final bool centered;
  final String? Function(String?)? formValidator;
  @override
  Widget build(BuildContext context) {
    return HStack(
      [
        //
        icon ??
            Icon(
              iconData,
              color: iconColor,
              size: 20,
            ),
        UiSpacer.horizontalSpace(),

        //
        VStack(
          [
            labelText != null
                ? labelText!.text.semiBold.make()
                : UiSpacer.emptySpace(),
            content ??
                CustomTextFormField(
                  maxLines: 1,
                  hintText: hintText ?? "",
                  isReadOnly: isReadOnly,
                  underline: true,
                  onTap: onInputTap,
                  textEditingController: tec,
                  textInputAction: TextInputAction.next,
                  keyboardType: keyboardType,
                  validator: formValidator,
                ),
          ],
        ).expand(),

        //
        suffix ?? UiSpacer.emptySpace(),
      ],
      crossAlignment:
          centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
    );
  }
}
