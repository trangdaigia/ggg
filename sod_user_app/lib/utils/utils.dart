import 'dart:io';

import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/models/vendor.dart';
import 'package:sod_user/services/http.service.dart';
import 'package:sod_user/services/location.service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jiffy/jiffy.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:intl/intl.dart' as intl;
import 'package:http/http.dart' as http;

class Utils {
  static bool get isArabic => translator.activeLocale.languageCode == "ar";

  static TextDirection get textDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;

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

  static Color textColorByTheme([bool reversed = false]) {
    if (reversed) {
      return !isPrimaryColorDark() ? Colors.white : Colors.black;
    }
    return isPrimaryColorDark() ? Colors.white : Colors.black;
  }

  static Color textColorByBrightness(BuildContext context,
      [bool reversed = false]) {
    if (reversed) {
      return !context.isDarkMode ? Colors.white : Colors.black;
    }
    return context.isDarkMode ? Colors.white : Colors.black;
  }

  static Color textColorByColor(Color color) {
    return isPrimaryColorDark(color) ? Colors.white : Colors.black;
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

  static Future<File?> compressFile({
    required File file,
    String? targetPath,
    int quality = 40,
    CompressFormat format = CompressFormat.jpeg,
  }) async {
    if (targetPath == null) {
      targetPath =
          "${file.parent.path}/compressed_${file.path.split('/').last}";
    }

    if (kDebugMode) {
      print("file path ==> $targetPath");
    }

    FlutterImageCompress.validator.ignoreCheckExtName = true;
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: quality,
      format: format,
    );
    if (kDebugMode) {
      print("unCompress file size ==> ${file.lengthSync()}");
      if (result != null) {
        print("Compress file size ==> ${result.lengthSync()}");
      } else {
        print("compress failed");
      }
    }

    return result;
  }

  static bool isDefaultImg(String? url) {
    return url == null ||
        url.isEmpty ||
        url == "default.png" ||
        url == "default.jpg" ||
        url == "default.jpeg" ||
        url.contains("default.png");
  }

  //get vendor distance to current location
  static double vendorDistance(Vendor vendor) {
    if (vendor.latitude.isEmptyOrNull || vendor.longitude.isEmptyOrNull) {
      return 0;
    }

    //if location service current location is not available
    if (LocationService.currenctAddress == null) {
      return 0;
    }

    //get distance
    double distance = Geolocator.distanceBetween(
      LocationService.currenctAddress?.coordinates?.latitude ?? 0,
      LocationService.currenctAddress?.coordinates?.longitude ?? 0,
      double.parse(vendor.latitude),
      double.parse(vendor.longitude),
    );

    //convert distance to km
    distance = distance / 1000;
    return distance;
  }

  //
  //get country code
  static Future<String> getCurrentCountryCode() async {
    String countryCode = "US";
    try {
      //make request to get country code
      final response = await HttpService()
          .dio!
          .get("http://ip-api.com/json/?fields=countryCode");
      //get the country code
      countryCode = response.data["countryCode"];
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

  static String? checkForbiddenWordsInMap(Map<String, dynamic> map) {
    final forbiddenWords = AppStrings.forbiddenWords;
    for (var value in map.values) {
      if (value is String) {
        for (var word in forbiddenWords) {
          if (value.toLowerCase().contains(word.toLowerCase())) {
            return word;
          }
        }
      } else if (value is List) {
        for (var item in value) {
          if (item is String) {
            for (var word in forbiddenWords) {
              if (item.toLowerCase().contains(word.toLowerCase())) {
                return word;
              }
            }
          }
        }
      }
    }
    return null;
  }

  static String? checkForbiddenWordsInString(String string) {
    final forbiddenWords = AppStrings.forbiddenWords;
    for (var word in forbiddenWords) {
      if (string.toLowerCase().contains(word.toLowerCase())) {
        return word;
      }
    }
    return null;
  }

  static String timeDifference(DateTime date) {
    final now = DateTime.now();
    final diffInMs = now.difference(date).inMilliseconds;

    final units = [
      {'label': 'year', 'ms': 365 * 24 * 60 * 60 * 1000},
      {'label': 'month', 'ms': 30 * 24 * 60 * 60 * 1000},
      {'label': 'day', 'ms': 24 * 60 * 60 * 1000},
      {'label': 'hour', 'ms': 60 * 60 * 1000},
      {'label': 'minute', 'ms': 60 * 1000},
      {'label': 'second', 'ms': 1000},
    ];

    for (var unit in units) {
      final value = (diffInMs / (unit['ms'] as int)).floor();
      if (value > 0) {
        return 'Created $value ${unit['label']}${value > 1 ? 's' : ''} ago';
      }
    }

    return 'just now';
  }

  // Kiểm tra hình ảnh sản phẩm có hợp lệ hay không
  static Future<bool> checkImageUrl(String photoToCheck) async {
    final response = await http.head(Uri.parse(photoToCheck));
    if (response.statusCode == 200) return true;
    return false;
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
