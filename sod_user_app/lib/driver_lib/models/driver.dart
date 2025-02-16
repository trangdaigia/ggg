import 'package:sod_user/driver_lib/models/user.dart';
import 'package:sod_user/driver_lib/models/vehicle.dart';

class Driver extends User {
  Vehicle? vehicle;
  // double? rating;

  Driver({
    required int id,
    String? code,
    required String name,
    required String email,
    required String phone,
    String? rawPhone,
    required String countryCode,
    required String photo,
    required String role,
    required String walletAddress,
    this.vehicle,
    required String rating,
  }) : super(
          id: id,
          name: name,
          email: email,
          phone: phone,
          rawPhone: rawPhone,
          photo: photo,
          role: role,
          rating: double.parse(rating),
          vendorId: -1,
          isOnline: false,
          isTaxiDriver: false,
        );

  //create fatory method to convert json to object
  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'],
      code: json['code'] ?? "",
      name: json['name'],
      email: json['email'] ?? "",
      phone: json['phone'] ?? "",
      countryCode: json['country_code'] ?? "",
      photo: json['photo'] ?? "",
      role: json['role_name'] ?? "driver",
      // rating: double.tryParse(json['rating'].toString()) ?? 3,
      vehicle:
          json['vehicle'] != null ? Vehicle.fromJson(json['vehicle']) : null,
      //
      rawPhone: json['raw_phone'],
      walletAddress: json['wallet_address'] ?? "",
      rating: json['rating'] ?? "0",
    );
  }
}
