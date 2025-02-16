import '../flavors.dart';

class AppImages {
  static String get appLogo {
    switch (F.appFlavor) {
      case Flavor.sod_delivery:
        return "assets/images/app_icons/sod_delivery/icon.png";
      case Flavor.sob_express_admin:
        return "assets/images/app_icons/sob_express_admin/icon.png";
      case Flavor.suc365_driver:
        return "assets/images/app_icons/suc365_driver/icon.png";
      case Flavor.g47_driver:
        return "assets/images/app_icons/g47_driver/icon.jpg";
      case Flavor.appvietsob_delivery:
        return "assets/images/app_icons/appvietsob_delivery/icon.png";
      case Flavor.vasone_driver:
        return "assets/images/app_icons/vasone_driver/icon.png";
      case Flavor.fasthub_delivery:
        return "assets/images/app_icons/fasthub_delivery/icon.png";
      default:
        return "assets/images/app_icon.png";
    }
  }

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
  static const paymentAccount = "assets/images/payment_account.png";

  //taxi
  static const pickupLocation = "assets/images/pickup_location.png";
  static const dropoffLocation = "assets/images/dropoff_location.png";
  static const driverCar = "assets/images/driver_car.png";
  static const noLocation = "assets/images/no_location.png";
  //
  static const noNotification = "assets/images/no-notification.png";
  static const noVehicle = "assets/images/no-vehicle.png";
  static const pendingDocument = "assets/images/pending-document.png";
}
