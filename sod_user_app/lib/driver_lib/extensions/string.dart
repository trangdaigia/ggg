import 'package:intl/intl.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

extension StringParsing on dynamic {
  //

  String telFormat() {
    return this.replaceAll(new RegExp(r'^0+(?=.)'), '');
  }

  String formatTextFieldInputNumber(String s) =>
      NumberFormat.decimalPattern(translator.activeLanguageCode).format(int.parse(s));

  String cleanTextFieldInputNumber(String s) => s.replaceAll(RegExp(r'\D'), '');
}
