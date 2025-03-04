import '../flavors.dart';

String getAppLogoPath() {
  switch (F.title) {
    case "SOD User":
      return "assets/images/app_icons/sod_user/icon.png";
    case "SOB Express":
      return "assets/images/app_icons/sob_express/icon.png";
    case "SUC365 User":
      return "assets/images/app_icons/suc365_user/icon.png";
    case "G47 User":
      return "assets/images/app_icons/g47_user/icon.jpg";
    case "Áp Việt":
      return "assets/images/app_icons/appvietsob_user/icon.jpg";
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
  static const otpImage = "assets/images/otp.png";

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
  static const emptySearch = "assets/images/empty_search.png";
  static const noReview = "assets/images/no_review.png";
  static const addressPin = "assets/images/delivery_address.png";
  static const deliveryParcel = "assets/images/delivery_parcel.png";
  static const deliveryVendor = "assets/images/delivery_vendor.png";

  //
  static const deliveryBoy = "assets/images/delivery_boy.png";
  static const pickupLocation = "assets/images/pickup_location.png";
  static const dropoffLocation = "assets/images/dropoff_location.png";
  static const driverCar = "assets/images/driver_car.png";
  static const refer = "assets/images/refer.png";

  //
  static const locationGif = "assets/images/location.gif";
  static const noImage = "assets/images/no_image.png";
  static const emptyLoyaltyPoints = "assets/images/no_loyalty_points.png";
  static const emptyParcelOrder = "assets/images/no_parcel_order.png";

  //
  static const noVehicle = "assets/images/no-vehicle.png";

  static const voucher = "assets/images/voucher.png";
}
