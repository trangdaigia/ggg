import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VNDTextEditingController extends TextEditingController {
  @override
  set text(String newText) {
    super.text = _formatNumeric(newText);
  }

  String get originalText => super.text.replaceAll(RegExp(r'\D'), '');

  String _formatNumeric(String value) {
    final amount = value.replaceAll(RegExp(r'\D'), '');
    final formattedValue = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '',
      decimalDigits: 0,
    ).format(amount);
    final updatedValue = formattedValue.trim();
    return updatedValue;
  }


}
