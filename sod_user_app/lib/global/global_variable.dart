import 'package:sod_user/models/trip.dart';
import 'package:sod_user/models/user.dart';
import 'package:sod_user/view_models/car_management.view_model.dart';

class GlobalVariable {
  static var showHomePage = true;
  static int bookRideId = 0;
  static int sharedRideId = 0;
  static User? userBookedRide = null;
  static bool checkTypeNotification = false;
  static void updateOrderBookedRideId(int newValue) {
    bookRideId = newValue;
  }

  static Trip? request;
  static CarManagementViewModel? carManagementViewModel;
  static bool refreshCache = false;
  static bool activeSecondIndex = false;
  static String? rentalVehicleId;
  static String? totalPrice;
  static String vehicleName = " ";
  static void resetActiveSecondIndex() {
    activeSecondIndex = false;
  }
}
