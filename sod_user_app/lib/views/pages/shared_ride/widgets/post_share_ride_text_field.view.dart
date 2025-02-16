// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sod_user/constants/app_colors.dart';

class PostShareRideTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final Widget prefixIcon;
  void Function()? onTap;
  final Widget? suffix;
  bool? enabled;
  List<TextInputFormatter>? inputFormatters;
  TextInputType? keyboardType;
  String? Function(String?)? validator;
  void Function(String)? onChanged;
  double? fontSize;

  PostShareRideTextField({
    Key? key,
    this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.onTap,
    this.enabled,
    this.suffix,
    this.fontSize,
    this.inputFormatters,
    this.keyboardType,
    this.validator,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: TextFormField(
        onChanged: onChanged,
        validator: validator,
        inputFormatters: inputFormatters,
        enabled: enabled,
        keyboardType: keyboardType,
        controller: controller,
        style: TextStyle(color: AppColor.accentColor, fontSize: fontSize),
        decoration: InputDecoration(
          disabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black26, style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(20),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red, style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(20),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black26, style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red, style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(20),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black26, style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(20),
          ),
          errorStyle: const TextStyle(color: Colors.red),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.black),
          border: InputBorder.none,
          suffixIcon: suffix,
          prefixIcon: prefixIcon,
          prefixIconColor: Colors.grey,
        ),
      ),
    );
  }
}
