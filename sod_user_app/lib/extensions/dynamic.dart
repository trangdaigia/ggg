import 'dart:math';
import 'package:sod_user/constants/app_strings.dart';
import 'package:currency_formatter/currency_formatter.dart';
import 'package:supercharged/supercharged.dart';

extension DynamicParsing on dynamic {
  double toDouble() {
    return double.parse(this);
  }

  //
  String fill(List values) {
    //
    String data = this.toString();
    for (var value in values) {
      data = data.replaceFirst("%s", value.toString());
    }
    return data;
  }

  //randomAlphaNumeric(length)
  String randomAlphaNumeric(int length) {
    final String chars =
        "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    final Random rnd = Random(DateTime.now().millisecondsSinceEpoch);
    final String result = String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
      ),
    );
    return result;
  }

  String currencyFormat() {
    final uiConfig = AppStrings.uiConfig;
    if (uiConfig != null && uiConfig["currency"] != null) {
      //
      final thousandSeparator = uiConfig["currency"]["format"] ?? ",";
      final decimalSeparator = uiConfig["currency"]["decimal_format"] ?? ".";
      final decimals = uiConfig["currency"]["decimals"];
      final currencylOCATION = uiConfig["currency"]["location"] ?? 'left';
      final decimalsValue = "".padLeft(decimals.toString().toInt() ?? 0, "0");

      //
      //
      final values =
          this.toString().split(" ").join("").split(AppStrings.currencySymbol);

      //
      CurrencyFormatterSettings currencySettings = CurrencyFormatterSettings(
        symbol: AppStrings.currencySymbol,
        symbolSide: currencylOCATION.toLowerCase() == "left"
            ? SymbolSide.left
            : SymbolSide.right,
        thousandSeparator: thousandSeparator,
        decimalSeparator: decimalSeparator,
      );

      return CurrencyFormatter.format(
        values[1],
        currencySettings,
        decimal: decimalsValue.length,
        enforceDecimals: true,
      );
    } else {
      return this.toString();
    }
  }

  String currencyValueFormat() {
    final uiConfig = AppStrings.uiConfig;
    if (uiConfig != null && uiConfig["currency"] != null) {
      final thousandSeparator = uiConfig["currency"]["format"] ?? ",";
      final decimalSeparator = uiConfig["currency"]["decimal_format"] ?? ".";
      final decimals = uiConfig["currency"]["decimals"];
      final decimalsValue = "".padLeft(decimals.toString().toInt() ?? 0, "0");
      final values = this.toString().split(" ").join("");

      //
      CurrencyFormatterSettings currencySettings = CurrencyFormatterSettings(
        symbol: "",
        symbolSide: SymbolSide.right,
        thousandSeparator: thousandSeparator,
        decimalSeparator: decimalSeparator,
      );
      return CurrencyFormatter.format(
        values,
        currencySettings,
        decimal: decimalsValue.length,
        enforceDecimals: true,
      );
    } else {
      return this.toString();
    }
  }
}
