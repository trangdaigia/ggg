import 'package:sod_vendor/services/auth.service.dart';

import '../flavors.dart';
import '../services/local_storage.service.dart';
import '../constants/app_strings.dart';

class Api {
  static String get baseUrl {
    switch (F.appFlavor) {
      case Flavor.sod_vendor:
        return LocalStorageService.prefs!.getString(AppStrings.apiUrlKey) ??
            "https://sod.di4l.vn/api";
      case Flavor.sob_express_vendor:
        return "https://cms.goeco.vn/api";
      case Flavor.suc365_vendor:
        return "https://suc365cms.di4l.vn/api";
      case Flavor.g47_vendor:
        return "https://g47cms.di4l.vn/api";
      case Flavor.appvietsob_vendor:
        return "https://cms.appviet.com.vn/api";
      case Flavor.fasthub_vendor:
        return "https://cms.fasthub.vn/api";
      case Flavor.vasone_vendor:
        return "https://cms.vasone.us/api";
      case Flavor.goingship_vendor:
        return "https://cms.goingship.vn/api";
      case Flavor.grabxanh_vendor:
        return "https://cms.ecoship247.com/api";
      default:
        return "https://sod.di4l.vn/api";
    }
  }

  static set baseUrl(String value) {
    LocalStorageService.prefs!.setString(AppStrings.apiUrlKey, value);
  }

  static const appSettings = "/app/settings";
  static const appForbiddenWords = "/app/banned-keywords";
  static const appOnboardings = "/app/onboarding?type=vendor";
  static const faqs = "/app/faqs?type=vendor";

  static const accountDelete = "/account/delete";
  static const login = "/login";
  static const newAccount = "/vendor/register";
  static const qrlogin = "/login/qrcode";
  static const logout = "/logout";
  static const forgotPassword = "/password/reset/init";
  static const verifyPhoneAccount = "/verify/phone";
  static const updateProfile = "/profile/update";
  static const updatePassword = "/profile/password/update";
  //
  static const sendOtp = "/otp/send";
  static const verifyOtp = "/otp/verify";

  //
  static const verifyEmailAccount = "/mail/verify";
  static const sendEmailOtp = "/mail/send-otp";
  static const verifyEmailOtp = "/mail/check-otp";
  static const verifyFirebaseOtp = "/otp/firebase/verify";
  static const forgotEmailPassword = "/password/reset/email";

  static const orders = "/orders";
  static const chat = "/chat/notification";
  static const users = "/users";
  static const products = "/products";
  static const productCategories = "/categories";
  static const packagePricing = "/vendor/package/pricing";
  static const packageTypes = "/package/types";
  static const services = "/my/services";
  static const serviceDurations = "/service/durations";
  static const vendorTypes = "/vendor/types";

  //Payment accounts
  static const paymentAccount = "/payment/accounts";
  static const payoutRequest = "/payouts/request";

  //
  static const vendorDetails = "/vendor/id/details";
  static const vendorAvailability = "/availability/vendor/id";
  static const documentSubmission = "/my/vendor/document/request/submission";

  //manage vendors
  static const myVendors = "/my/vendors";
  static const switchVendor = "/switch/vendor";

  //map
  static const geocoderForward = "/geocoder/forward";
  static const geocoderReserve = "/geocoder/2/reserve";
  static const geocoderPlaceDetails = "/geocoder/place/details";

  //misc
  static const externalRedirect = "/external/redirect";

  static String get webUrl {
    return baseUrl.replaceAll('/api', '');
  }

  //
  static String get subscription {
    return "$webUrl/subscription/my/subscribe";
  }

  // Other pages
  static String get privacyPolicy {
    final policyLinkPath = "/page/chinh-sach-bao-mat";
    switch (F.appFlavor) {
      case Flavor.sob_express_vendor:
        return "https://sobexpress.com${policyLinkPath}";
      case Flavor.g47_vendor:
        return "https://g47.vn${policyLinkPath}";
      default:
        return "$webUrl/privacy/policy";
    }
  }

  static String get terms {
    return "$webUrl/pages/terms";
  }

  //
  static String get register {
    return "$webUrl/register#vendor";
  }

  static String get contactUs {
    return "$webUrl/pages/contact";
  }

  static String get inappSupport {
    return "$webUrl/support/chat";
  }

  static String get backendUrl {
    return "$webUrl/";
  }

  static Future<String> redirectAuth(String url) async {
    final userToken = await AuthServices.getAuthBearerToken();
    return "$webUrl/auth/redirect?token=$userToken&url=$url";
  }
}
