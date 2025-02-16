import 'dart:io';

import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:sod_vendor/constants/app_colors.dart';
import 'package:sod_vendor/constants/app_strings.dart';
import 'package:sod_vendor/models/vendor.dart';
import 'package:sod_vendor/services/http.service.dart';
import 'package:sod_vendor/views/pages/package_types/package_type_pricing.page.dart';
import 'package:sod_vendor/views/pages/product/products.page.dart';
import 'package:sod_vendor/views/pages/service/service.page.dart';

import 'package:html/parser.dart';
import 'package:jiffy/jiffy.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class Utils {
  //
  static bool get isArabic => translator.activeLocale.languageCode == "ar";

  static TextDirection get textDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;
  //
  static IconData vendorIconIndicator(Vendor? vendor) {
    return Icons.save;
    // return ((vendor == null || (!vendor.isPackageType && !vendor.isServiceType))
    //     ? FlutterIcons.archive_fea
    //     : vendor.isServiceType
    //         ? FlutterIcons.rss_fea
    //         : FlutterIcons.money_faw);
  }

  //
  static String vendorTypeIndicator(Vendor? vendor) {
    return ((vendor == null || (!vendor.isPackageType && !vendor.isServiceType))
        ? 'Products'
        : vendor.isServiceType
            ? "Services"
            : 'Pricing');
  }

  static Widget vendorSectionPage(Vendor? vendor) {
    return ((vendor == null || (!vendor.isPackageType && !vendor.isServiceType))
        ? ProductsPage()
        : vendor.isServiceType
            ? ServicePage()
            : PackagePricingPage());
  }

  static bool get currencyLeftSided {
    final uiConfig = AppStrings.uiConfig;
    if (uiConfig != null && uiConfig["currency"] != null) {
      final currencylOCATION = uiConfig["currency"]["location"] ?? 'left';
      return currencylOCATION.toLowerCase() == "left";
    } else {
      return true;
    }
  }

  static String removeHTMLTag(String str) {
    var document = parse(str);
    return parse(document.body?.text).documentElement?.text ?? str;
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

  static setJiffyLocale() async {
    String cLocale = translator.activeLocale.languageCode;
    List<String> supportedLocales = Jiffy.getAllAvailableLocales();
    if (supportedLocales.contains(cLocale)) {
      await Jiffy.locale(translator.activeLocale.languageCode);
    } else {
      await Jiffy.locale("en");
    }
  }

  //
  static bool isDefaultImg(String? url) {
    return url == null ||
        url.isEmpty ||
        url == "default.png" ||
        url == "default.jpg" ||
        url == "default.jpeg" ||
        url.contains("default.png");
  }

  //
  //
  //get country code
  static Future<String> getCurrentCountryCode() async {
    String countryCode = "US";
    try {
      //make request to get country code
      final response = await HttpService().dio.get(
            "http://ip-api.com/json/?fields=countryCode",
          );
      //get the country code
      countryCode = response.data["countryCode"];
    } catch (e) {
      try {
        countryCode = AppStrings.countryCode
            .toUpperCase()
            .replaceAll("AUTO", "")
            .replaceAll("INTERNATIONAL", "")
            .split(",")[0];
      } catch (e) {
        countryCode = "us";
      }
    }

    return countryCode.toUpperCase();
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
