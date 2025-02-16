import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:velocity_x/velocity_x.dart';

class RealEstateDropDownButton<T> extends StatefulWidget {
  final List<T> options;
  final String Function(T option) tranformOption;
  final void Function(T? option) onChange;
  final String name;
  final T? initialValue;
  final IconData? startIcon;
  const RealEstateDropDownButton(
      {super.key,
      required this.options,
      required this.tranformOption,
      this.initialValue,
      required this.onChange,
      required this.name,
      this.startIcon});
  @override
  _RealEstateDropDownButtonState<T> createState() =>
      _RealEstateDropDownButtonState();
}

class _RealEstateDropDownButtonState<T>
    extends State<RealEstateDropDownButton<T>> {
  T? selectedOption = null;
  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      selectedOption = widget.initialValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: selectedOption == null
            ? Colors.white
            : AppColor.primaryColor.withOpacity(0.1), // Background color
        borderRadius: BorderRadius.circular(25), // Rounded edges

        border: Border.all(
            color: selectedOption == null
                ? AppColor.iconHintColor
                : AppColor.primaryColorDark,
            width: 1), // Border color
      ),
      height: 40,
      child: HStack([
        widget.startIcon != null
            ? Icon(widget.startIcon,
                color: selectedOption == null
                    ? AppColor.iconHintColor
                    : AppColor.primaryColorDark)
            : SizedBox.shrink(),
        DropdownButton<T>(
          value: selectedOption,
          hint: widget.name
              .tr()
              .text
              .sm
              .bold
              .color(AppColor.iconHintColor)
              .make(),
          icon: Icon(Icons.arrow_drop_down,
              color: selectedOption == null
                  ? AppColor.iconHintColor
                  : AppColor.accentColor), // Dropdown arrow
          underline: SizedBox(), // Removes the default underline
          items: widget.options.map((T value) {
            return DropdownMenuItem<T>(
              value: value,
              child: (value != null ? widget.tranformOption(value) : "")
                  .tr()
                  .text
                  .sm
                  .bold
                  .color(selectedOption == null
                      ? AppColor.iconHintColor
                      : AppColor.primaryColorDark)
                  .make(),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              if (selectedOption != newValue) {
                selectedOption = newValue!;
              } else {
                selectedOption = null;
              }
              widget.onChange(selectedOption);
            });
          },
          dropdownColor: Colors.white, // Background color for the dropdown
        )
      ]),
    );
  }
}
