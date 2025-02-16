import 'package:sod_user/constants/app_strings.dart';

class AppLanguages {
  static const Map<String, String> _allLanguages = {
    "en": "English",
    "vi": "Tiếng Việt",
    // Uncomment the following lines to enable other languages in app
    // "ar": "العربية",
    // "fr": "Français",
    // "es": "Español",
    // "ko": "한국어",
    // "de": "Deutsch",
    // "pt": "Português",
    // "hi": "हिन्दी",
    // "tr": "Türkçe",
    // "ru": "Русский",
    // "my": "မြန်မာ",
    // "zh": "中文",
    // "ja": "日本語",
  };

  static const Map<String, String> _countryFlags = {
    "en": "GB",
    "vi": "VN",
    "ar": "SA",
    "fr": "FR",
    "es": "ES",
    "ko": "KR",
    "de": "DE",
    "pt": "PT",
    "hi": "IN",
    "tr": "TR",
    "ru": "RU",
    "my": "MM",
    "zh": "CN",
    "ja": "JP",
  };

  // Get the list of available languages in remote settings
  static List<String> get _availableLanguageCodes {
    final enabledLanguages =
        AppStrings.appSettingsObject?["enabledLanguage"] as List<dynamic>?;
    if (enabledLanguages == null || enabledLanguages.isEmpty) {
      return _allLanguages.keys.toList();
    }
    return enabledLanguages.map((e) => e["code"] as String).toList();
  }

  static List<String> get codes => _availableLanguageCodes;

  static List<String> get names => _availableLanguageCodes
      .map((code) => _allLanguages[code] ?? "Unknown")
      .toList();

  static List<String> get flags => _availableLanguageCodes
      .map((code) => _countryFlags[code] ?? "GB")
      .toList();

  static bool get canChangeLanguage => _availableLanguageCodes.length > 1;
  static String get defaultLanguage => _availableLanguageCodes.first;
  static List<String> get allLanguageCodes => _allLanguages.keys.toList();
}
