import '../flavors.dart';

String getAppLogoPath() {
  switch (F.title) {
    case "SOD Vendor":
      return "assets/images/app_icons/sod_vendor/icon.png";
    case "SOB Express Vendor":
      return "assets/images/app_icons/sob_express_vendor/icon.jpg";
    case "SUC365 Vendor":
      return "assets/images/app_icons/suc365_vendor/icon.jpg";
    case "G47 Vendor":
      return "assets/images/app_icons/g47_vendor/icon.jpg";
    case "Áp Việt Admin":
      return "assets/images/app_icons/appvietsob_vendor/icon.jpg";
    default:
      return "assets/images/app_icon.png";
  }
}

class AppImages {
  static final appLogo = getAppLogoPath();
  static const user = "assets/images/user.png";
  static const auth = "assets/images/auth.png";
  static const forgotPasswordImage = "assets/images/forgot_pasword.png";
  static const loginImage = "assets/images/login_intro.png";
  static const registerImage = "assets/images/register_intro.jpg";

  //
  static const onboarding1 = "assets/images/1.png";
  static const onboarding2 = "assets/images/2.png";
  static const onboarding3 = "assets/images/3.png";

  //
  static const error = "assets/images/error.png";
  static const vendor = "assets/images/vendor.png";
  static const noProduct = "assets/images/no_product.png";
  static const product = "assets/images/product.png";
  static const emptyCart = "assets/images/no_cart.png";
  static const addressPin = "assets/images/delivery_address.png";
  static const deliveryParcel = "assets/images/delivery_parcel.png";
  static const deliveryVendor = "assets/images/delivery_vendor.png";
  static const pickupLocation = "assets/images/pickup_location.png";
  static const dropoffLocation = "assets/images/dropoff_location.png";
  static const pendingDocument = "assets/images/pending-document.png";
  static const overflowPermission = "assets/images/overflow_permission.png";
  static const locationGif = "assets/images/location.gif";
  //
  static const newOrderAlert = "assets/images/new_order.gif";
}
