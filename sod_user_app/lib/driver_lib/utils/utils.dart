import 'dart:async';
import 'dart:ui' as ui;

import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/driver_lib/constants/app_colors.dart';
import 'package:sod_user/services/http.service.dart';
import 'package:jiffy/jiffy.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import "package:intl/intl.dart" as intl;

class Utils {
  //
  static bool get isArabic => translator.activeLocale.languageCode == "ar";

  static TextDirection get textDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;
  //
  static bool get currencyLeftSided {
    final uiConfig = AppStrings.uiConfig;
    if (uiConfig != null && uiConfig["currency"] != null) {
      final currencylOCATION = uiConfig["currency"]["location"] ?? 'left';
      return currencylOCATION.toLowerCase() == "left";
    } else {
      return true;
    }
  }

  static bool isDark(Color color) {
    return ColorUtils.calculateRelativeLuminance(
            color.red, color.green, color.blue) <
        0.5;
  }

  static bool isPrimaryColorDark([Color? mColor]) {
    final color = mColor ?? AppColor.primaryColor;
    return ColorUtils.calculateRelativeLuminance(
            color.red, color.green, color.blue) <
        0.5;
  }

  static Color textColorByTheme() {
    return isPrimaryColorDark() ? Colors.white : Colors.black;
  }

  static Color textColorByColor(Color color) {
    return isPrimaryColorDark(color) ? Colors.white : Colors.black;
  }

  ///
  Future<Uint8List> getBytesFromCanvas(int width, int height, urlAsset) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final ByteData datai = await rootBundle.load(urlAsset);
    var imaged = await loadImage(new Uint8List.view(datai.buffer));
    canvas.drawImageRect(
      imaged,
      Rect.fromLTRB(
          0.0, 0.0, imaged.width.toDouble(), imaged.height.toDouble()),
      Rect.fromLTRB(0.0, 0.0, width.toDouble(), height.toDouble()),
      new Paint(),
    );

    final img = await pictureRecorder.endRecording().toImage(width, height);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data?.buffer.asUint8List() ?? Uint8List(0);
  }

  Future<ui.Image> loadImage(Uint8List img) async {
    final Completer<ui.Image> completer = new Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  static setJiffyLocale() async {
    String cLocale = translator.activeLocale.languageCode;
    List<String> supportedLocales = Jiffy.getAllAvailableLocales();
    if (supportedLocales.contains(cLocale)) {
      await Jiffy.locale(translator.activeLocale.languageCode);
    } else {
      await Jiffy.locale("en");
    }
  }

  //get country code
  static Future<String> getCurrentCountryCode() async {
    String countryCode = "US";
    try {
      //make request to get country code
      final response = await HttpService().dio?.get(
            "http://ip-api.com/json/?fields=countryCode",
          );
      //get the country code
      countryCode = response?.data["countryCode"];
    } catch (e) {
      countryCode = AppStrings.defaultCountryCode;
    }

    return countryCode.toUpperCase();
  }

  static String formatCurrencyVND(double amount) {
    String formattedAmount =
        intl.NumberFormat("#,##0.", "vi_VN").format(amount);
    return "$formattedAmount đ".replaceAll(",", "");
  }

  //Chuyển từ map sang string
  static String toQueryString(Map<String, dynamic> params,
      {List<dynamic>? exclude}) {
    try {
      if (exclude != null) exclude.forEach((element) => params.remove(element));
      return params.entries
          .map((entry) =>
              '${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(entry.value.toString())}')
          .join('&');
    } catch (e) {
      debugPrint("Error when format string");
      return "";
    }
  }
}
