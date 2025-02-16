import 'package:flutter/material.dart';

class CarDropDownButton extends StatelessWidget {
  final List<DropdownMenuItem<String>> items;
  final String? labelText;
  final Widget prefixIcon;
  final Function(String?) onChanged;
  final EdgeInsetsGeometry? contentPadding;
  final String value;
  const CarDropDownButton({
    Key? key,
    required this.items,
    this.labelText,
    this.contentPadding,
    required this.prefixIcon,
    required this.onChanged,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      dropdownColor: Colors.white,
      isExpanded: true,
      focusColor: Colors.transparent,
      decoration: InputDecoration(
        contentPadding: contentPadding,
        labelText: labelText,
        prefixIcon: prefixIcon,
        suffix: null,
        fillColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.grey),
        ),
      ),
      value: value,
      items: items,
      onChanged: onChanged,
    );
  }
}
