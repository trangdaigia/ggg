import 'package:sod_user/driver_lib/constants/app_strings.dart';

class AppPageSettings extends AppStrings {
  //
  static int get maxDriverDocumentCount {
    try {
      if (AppStrings.env('page') == null ||
          AppStrings.env('page')["settings"] == null) {
        return 2;
      }
      return int.parse(
          AppStrings.env('page')['settings']["driverDocumentCount"].toString());
    } catch (error) {
      return 2;
    }
  }

  static String get driverDocumentInstructions {
    final page = AppStrings.env('page'); // Get the 'page' map
    print("AppString: $page"); // Log the value for debugging

    // Ensure `page` is a valid Map
    if (page is Map<String, dynamic>) {
      final settings = page['settings'];

      // Ensure `settings` is also a Map
      if (settings is Map<String, dynamic>) {
        return settings['driverDocumentInstructions'] as String? ?? "";
      }
    }

    // Fallback for invalid structure
    return "";
  }
}
