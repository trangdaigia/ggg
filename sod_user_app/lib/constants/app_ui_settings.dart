import 'package:sod_user/constants/app_strings.dart';

class AppUISettings extends AppStrings {
  static bool get showVendorPhone {
    if (AppStrings.env('ui') == null ||
        AppStrings.env('ui')["showVendorPhone"] == null) {
      return true;
    }
    return AppStrings.env('ui')['showVendorPhone'] == "1";
  }

  //CHAT UI
  static bool get canVendorChat {
    if (AppStrings.env('ui') == null || AppStrings.env('ui')["chat"] == null) {
      return true;
    }
    return AppStrings.env('ui')['chat']["canVendorChat"] == "1";
  }

  static bool get canCustomerChat {
    if (AppStrings.env('ui') == null || AppStrings.env('ui')["chat"] == null) {
      return true;
    }
    return AppStrings.env('ui')['chat']["canCustomerChat"] == "1";
  }

  static bool get canCustomerChatSupportMedia {
    if (AppStrings.env('ui') == null || AppStrings.env('ui')["chat"] == null) {
      return true;
    }
    try {
      dynamic isSupportMedia =
          AppStrings.env('ui')['chat']["canCustomerChatSupportMedia"] ?? false;
      return (isSupportMedia is bool
          ? isSupportMedia
          : int.parse("$isSupportMedia") == 1);
    } catch (e) {
      return false;
    }
  }

  static bool get canDriverChat {
    if (AppStrings.env('ui') == null || AppStrings.env('ui')["chat"] == null) {
      return true;
    }
    return AppStrings.env('ui')['chat']["canDriverChat"] == "1";
  }

  static bool get allowWalletTransfer {
    if (AppStrings.env('finance') == null ||
        AppStrings.env('finance')["allowWalletTransfer"] == null) {
      return true;
    }
    return (AppStrings.env('finance')['allowWalletTransfer'] ?? "0") == "1";
  }

  static bool get allowWallet {
    if (AppStrings.env('finance') == null ||
        AppStrings.env('finance')["allowWallet"] == null) {
      return true;
    }
    return (AppStrings.env('finance')['allowWallet'] ?? "0") == "1";
  }

  //show cart
  static bool get showCart {
    if (AppStrings.env('show_cart') == null) {
      return true;
    }
    return AppStrings.env('show_cart');
  }

  //call settings
  static bool get canCallVendor {
    if (AppStrings.env('ui') == null || AppStrings.env('ui')["call"] == null) {
      return true;
    }
    return [1, "1"]
        .contains(AppStrings.env('ui')['call']["canCustomerVendorCall"]);
  }

  static bool get canCallDriver {
    if (AppStrings.env('ui') == null || AppStrings.env('ui')["call"] == null) {
      return true;
    }
    return [1, "1"]
        .contains(AppStrings.env('ui')['call']["canCustomerDriverCall"]);
  }
}
