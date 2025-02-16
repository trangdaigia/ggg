// import 'package:velocity_x/velocity_x.dart';

import '../flavors.dart';
import '../services/local_storage.service.dart';
import '../constants/app_strings.dart';

class Api {
  static String get baseUrl {
    switch (F.appFlavor) {
      case Flavor.sod_user:
        return LocalStorageService.prefs!.getString(AppStrings.apiUrlKey) ??
            "https://sod.di4l.vn/api";
      case Flavor.sob_express:
        return "https://cms.goeco.vn/api";
      case Flavor.suc365_user:
        return "https://suc365cms.di4l.vn/api";
      case Flavor.g47_user:
        return "https://g47cms.di4l.vn/api";
      case Flavor.appvietsob_user:
        return "https://cms.appviet.com.vn/api";
      case Flavor.fasthub_user:
        return "https://cms.fasthub.vn/api";
      case Flavor.vasone:
        return "https://cms.vasone.us/api";
      case Flavor.goingship:
        return "https://cms.goingship.vn/api";
      case Flavor.grabxanh:
        return "https://cms.ecoship247.com/api";
      case Flavor.inux:
        return "https://cms.inux.vn/api";
      default:
        return "https://sod.di4l.vn/api";
    }
  }

  static set baseUrl(String value) {
    LocalStorageService.prefs!.setString(AppStrings.apiUrlKey, value);
  }

  static const appSettings = "/app/settings";
  static const appForbiddenWords = "/app/banned-keywords";
  static const appOnboardings = "/app/onboarding?type=customer";
  static const faqs = "/app/faqs?type=customer";

  static const accountDelete = "/account/delete";
  static const tokenSync = "/device/token/sync";
  static const login = "/login";
  static const switchOnOff = "/driver/type/switchOnOff";

  static const qrlogin = "/login/qrcode";
  static const register = "/register";
  static const logout = "/logout";
  static const forgotPassword = "/password/reset/init";
  static const verifyPhoneAccount = "/verify/phone";
  static const updateProfile = "/profile/update";
  static const updatePassword = "/profile/password/update";
  static const reviewed = "/user/reviewed";
  static const myReview = "/user/my-review";
  //
  static const sendOtp = "/otp/send";
  static const verifyOtp = "/otp/verify";
  static const verifyFirebaseOtp = "/otp/firebase/verify";
  static const socialLogin = "/social/login";
  static const documentSubmission = "/driver/document/request/submission";

  //
  static const verifyEmailAccount = "/mail/verify";
  static const sendEmailOtp = "/mail/send-otp";
  static const verifyEmailOtp = "/mail/check-otp";
  static const forgotEmailPassword = "/password/reset/email";

  //
  static const banners = "/banners";
  static const categories = "/categories";
  static const products = "/products";
  static const services = "/services";
  static const bestProducts = "/products?type=best";
  static const forYouProducts = "/products?type=you";
  static const realEstate = "/realestates";
  static const realEstateCategory = "/realestate/categories";
  static const vendorTypes = "/vendor/types";
  static const vendors = "/vendors";
  static const vendorReviews = "/vendor/reviews";
  static const topVendors = "/vendors?type=top";
  static const bestVendors = "/vendors?type=best";
  // jobs
  static const jobsCategory = "/adscategories";
  static const jobsList = "/adsadvertises";

  static const myProfile = "/my/profile";

  static const search = "/search";
  static const tags = "/tags";
  static const searchData = "/search/data";
  static const favourites = "/favourites";

  //cart & checkout
  static const coupons = "/coupons";
  static const deliveryAddresses = "/delivery/addresses";
  static const paymentMethods = "/payment/methods";
  static const orders = "/orders";
  static const uploadOrderConfirmImages = "/upload/order/confirm/images";
  static const trackOrder = "/track/order";
  static const packageOrders = "/package/orders";
  static const packageOrderSummary = "/package/order/summary";
  static const generalOrderDeliveryFeeSummary =
      "/general/order/delivery/fee/summary";
  static const generalOrderSummary = "/general/order/summary";
  static const serviceOrderSummary = "/service/order/summary";
  static const chat = "/chat/notification";
  static const rating = "/rating";

  //packages
  static const packageTypes = "/package/types";
  static const packageVendors = "/package/order/vendors";

  //Taxi booking
  static const taxiShipPackageTypes = "/taxi/package/types";
  static const vehicleTypes = "/vehicle/types";
  static const vehicleTypePricing = "/vehicle/types/pricing";
  static const newTaxiBooking = "/taxi/book/order";
  static const currentTaxiBooking = "/taxi/current/order";
  static const cancelTaxiBooking = "/taxi/order/cancel";
  static const taxiDriverInfo = "/taxi/driver/info";
  static const taxiLocationAvailable = "/taxi/location/available";
  static const taxiTripLocationHistory = "/taxi/location/history";

  //wallet
  static const walletBalance = "/wallet/balance";
  static const walletTopUp = "/wallet/topup";
  static const walletTransactions = "/wallet/transactions";
  static const myWalletAddress = "/wallet/my/address";
  static const walletAddressesSearch = "/wallet/address/search";
  static const walletTransfer = "/wallet/address/transfer";

  //loyaltypoints
  static const myLoyaltyPoints = "/loyalty/point/my";
  static const loyaltyPointsWithdraw = "/loyalty/point/my/withdraw";
  static const loyaltyPointsReport = "/loyalty/point/my/report";

  //map
  static const geocoderForward = "/geocoder/forward";
  static const geocoderReserve = "/geocoder/2/reserve";
  static const geocoderPlaceDetails = "/geocoder/place/details";

  //reviews
  static const productReviewSummary = "/product/review/summary";
  static const productReviews = "/product/reviews";
  static const productBoughtFrequent = "/product/frequent";

  //flash sales
  static const flashSales = "/flash/sales";
  static const externalRedirect = "/external/redirect";

  // shared ride
  static const sharedRides = "/sharedride";
  static const cancelSharedRide = "/sharedride/cancel";
  static const updateOrderSharedRide = "/sharedride/updateOrder";

  // car rental
  static const getCarRental = "/rental/vehicle";
  static const getCarBrand = "/partner/car/makes";
  static const getCarModel = "/partner/car/models";
  static const addCarRental = "/rental/vehicle";
  static const deleteCarRental = "/rental/vehicle";
  static const changeStatusCarRental = "/rental/vehicle";
  static const getVehicleType = "/vehicle/types";
  static const addRentalRequest = "/rental/request";
  static const changeFavourite = "/favorite/vehicle";
  static const getRentalRequest = "/rental/request";
  static const getOwnerVehicle = "/owner/vehicle";
  //
  static const cancellationReasons = "/cancellation/reasons";
  static const receiveBehalf = "/receive/behalf";

  //payment account
  static const paymentAccount = "/payment/accounts";
  static const payoutRequest = "/payouts/request";

  //
  static const getEarning = "/earning/user";
  static const getEarningTransactions = "/earnings/user/history";
  static const changeBalanceToServiceWallet = "/earning/user/transfer";

  // Other pages
  static String get privacyPolicy {
    final webUrl = baseUrl.replaceAll('/api', '');
    return "$webUrl/privacy/policy";
  }

  static String get terms {
    final webUrl = baseUrl.replaceAll('/api', '');
    return "$webUrl/pages/terms";
  }

  static String get contactUs {
    final webUrl = baseUrl.replaceAll('/api', '');
    return "$webUrl/pages/contact";
  }

  static String get inappSupport {
    final webUrl = baseUrl.replaceAll('/api', '');
    return "$webUrl/support/chat";
  }

  static String get appShareLink {
    final webUrl = baseUrl.replaceAll('/api', '');
    return "$webUrl/preview/share";
  }
}
