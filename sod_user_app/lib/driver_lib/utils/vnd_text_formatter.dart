import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class VNTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final amount = int.parse(newValue.text.replaceAll(RegExp(r'\D'), ''));
    final formattedValue = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '',
      decimalDigits: 0,
    ).format(amount);

    final updatedValue = formattedValue.trim();

    return TextEditingValue(
      text: updatedValue,
      selection: TextSelection.collapsed(offset: updatedValue.length),
    );
  }
}
