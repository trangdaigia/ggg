// import 'package:velocity_x/velocity_x.dart';

import '../flavors.dart';
import '../services/local_storage.service.dart';
import 'app_strings.dart';

class Api {
  static String get baseUrl {
    switch (F.appFlavor) {
      case Flavor.sod_delivery:
        return LocalStorageService.prefs!.getString(AppStrings.apiUrlKey) ??"https://sod.di4l.vn/api";
      case Flavor.sob_express_admin:
        return "https://cms.goeco.vn/api";
      case Flavor.suc365_driver:
        return "https://suc365cms.di4l.vn/api";
      case Flavor.g47_driver:
        return "https://g47cms.di4l.vn/api";
      case Flavor.appvietsob_delivery:
        return "https://cms.appviet.com.vn/api";
      case Flavor.fasthub_delivery:
        return "https://cms.fasthub.vn/api";
      case Flavor.vasone_driver:
        return "https://cms.vasone.us/api";
      case Flavor.goingship_driver:
        return "https://cms.goingship.vn/api";
      case Flavor.grabxanh_driver:
        return "https://cms.ecoship247.com/api";
      case Flavor.inux_driver:
        return "https://cms.inux.vn/api";
      default:
        return "https://sod.di4l.vn/api";
    }
  }

  static set baseUrl(String value) {
    LocalStorageService.prefs!.setString(AppStrings.apiUrlKey, value);
  }

  static const appSettings = "/app/settings";
  static const appOnboardings = "/app/onboarding?type=driver";
  static const faqs = "/app/faqs?type=driver";

  static const accountDelete = "/account/delete";
  static const tokenSync = "/device/token/sync";
  static const login = "/login";
  static const newAccount = "/driver/register";
  static const qrlogin = "/login/qrcode";
  static const logout = "/logout";
  static const forgotPassword = "/password/reset/init";
  static const verifyPhoneAccount = "/verify/phone";
  static const updateProfile = "/profile/update";
  static const updatePassword = "/profile/password/update";
  static const myProfile = "/my/profile";
  static const vendorTypes = "/vendor/types";
  static const reviewed = "/driver/reviewed";
  static const myReview = "/driver/my-review";
  //
  static const sendOtp = "/otp/send";
  static const verifyOtp = "/otp/verify";
  static const verifyFirebaseOtp = "/otp/firebase/verify";

  //
  static const verifyEmailAccount = "/mail/verify";
  static const sendEmailOtp = "/mail/send-otp";
  static const verifyEmailOtp = "/mail/check-otp";
  static const forgotEmailPassword = "/password/reset/email";




  static const orders = "/orders";
  static const orderStopVerification = "/package/order/stop/verify";
  static const chat = "/chat/notification";

  //
  static const earning = "/earning/user";
  //
  //wallet
  static const walletBalance = "/wallet/balance";
  static const walletTopUp = "/wallet/topup";
  static const walletTransactions = "/wallet/transactions";
  static const transferWalletBalance = "/wallet/transfer";

  //Payment accounts
  static const paymentAccount = "/payment/accounts";
  static const payoutRequest = "/payouts/request";

  //Taxi booking
  static const currentTaxiBooking = "/taxi/current/order";
  static const cancelTaxiBooking = "/taxi/order/cancel";
  static const switchOnOff = "/driver/type/switchOnOff";
  static const rejectTaxiBookingAssignment = "/taxi/order/asignment/reject";
  static const acceptTaxiBookingAssignment = "/taxi/order/asignment/accept";
  static const rating = "/rating";
  static const vehicleTypes = "/partner/vehicle/types";
  static const carMakes = "/partner/car/makes";
  static const carModels = "/partner/car/models";

  //driver type
  static const driverTypeSwitch = "/driver/type/switch";
  static const driverVehicleRegister =
      "/driver/vehicle/register"; // "/rental/vehicle";
  static const vehicles =
      "/driver/vehicles"; //"/driver/vehicles";"/rental/vehicle"
  static const activateVehicle = "/driver/vehicle/{id}/activate";
  static const deactivateVehicle = "/driver/vehicle/{id}/deactivate";

  //
  static const documentSubmission = "/driver/document/request/submission";

  static const receiveBehalfOrderSummary = "/receive_behalf/order/summary";
  static const users = "/users";
  static const deliveryAddresses = "/delivery/addresses";
  static const box = "/box";

  // Other pages
  static String get privacyPolicy {
    final policyLinkPath = "/page/chinh-sach-bao-mat";
    switch (F.appFlavor) {
      case Flavor.sob_express_admin:
        return "https://sobexpress.com${policyLinkPath}";
      case Flavor.g47_driver:
        return "https://g47.vn${policyLinkPath}";
      default:
        final webUrl = baseUrl.replaceAll('/api', '');
        return "$webUrl/privacy/policy";
    }
  }

  static String get terms {
    final webUrl = baseUrl.replaceAll('/api', '');
    return "$webUrl/pages/terms";
  }

  //
  static String get register {
    final webUrl = baseUrl.replaceAll('/api', '');
    return "$webUrl/register#driver";
  }

  static String get contactUs {
    final webUrl = baseUrl.replaceAll('/api', '');
    return "$webUrl/pages/contact";
  }

  static String get inappSupport {
    final webUrl = baseUrl.replaceAll('/api', '');
    return "$webUrl/support/chat";
  }

  //flash sales
  static const flashSales = "/flash/sales";
  static const externalRedirect = "/external/redirect";

  //map
  static const geocoderForward = "/geocoder/forward";
  static const geocoderReserve = "/geocoder/2/reserve";
  static const geocoderPlaceDetails = "/geocoder/place/details";

  // countries
  static const countries = "/countries";
  static String stateByCountry(String countryId) => "/states?country_id=$countryId";
  static String cityByState(String stateId) => "/cities?state_id=$stateId";
}
