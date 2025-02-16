import 'package:sod_user/flavors.dart';

class TranslateUtils {
  static Map<String, String> get flavorLang {
    switch (F.appFlavor) {
      case Flavor.sod_user:
        return flavorLangSod;
      case Flavor.sob_express:
        return flavorLangSobExpress;
      case Flavor.suc365_user:
        return flavorLangSuc365;
      case Flavor.g47_user:
        return flavorLangG47;
      case Flavor.appvietsob_user:
        return flavorLangAppViet;
      case Flavor.fasthub_user:
        return flavorLangFasthub;
      case Flavor.vasone:
        return flavorLangVasone;
      default:
        return flavorLangSod;
    }
  }

  static String getTranslateForFlavor(String key) {
    return flavorLang[key] ?? flavorLangSod[key]!;
  }

  static final Map<String, String> flavorLangSod = {
    "Chat with driver": "Chat with driver"
  };

  static final Map<String, String> flavorLangSobExpress = {
    "Chat with driver": "Chat"
  };

  static final Map<String, String> flavorLangSuc365 = {};

  static final Map<String, String> flavorLangG47 = {};

  static final Map<String, String> flavorLangAppViet = {};

  static final Map<String, String> flavorLangFasthub = {};

  static final Map<String, String> flavorLangVasone = {};
}
