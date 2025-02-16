// To parse this JSON data, do
//
//     final vehicle = vehicleFromJson(jsonString);

import 'dart:convert';
import 'package:sod_user/driver_lib/models/trip.dart';
import 'package:sod_user/driver_lib/models/user.dart';
import 'package:sod_user/driver_lib/models/vendor_type.dart';
import 'package:sod_user/models/vehicle_type.dart';
import 'package:supercharged/supercharged.dart';

Vehicle vehicleFromJson(String str) => Vehicle.fromJson(json.decode(str));

String vehicleToJson(Vehicle data) => json.encode(data.toJson());

class Vehicle {
  String? describe;
  int? deliveryDistance;
  int? deliveryFee;
  int? deliveryFree;
  bool? mortgageExemption;
  bool? deliveryToHome;
  bool? fastBooking;
  int? id;
  int? carModelId;
  int? driverId;
  int? vehicleTypeId;
  String? regNo;
  String? color;
  int? isActive;
  bool? verified;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? yearMade;
  int? rentStatus;
  VendorType? service;
  String? formattedDateTime;
  String? formattedDate;
  String? formattedUpdatedDate;
  List<String>? utilites;
  List<String>? requirementsForRent;
  String? latitude;
  String? longitude;
  int? distance;
  List<String>? photo;
  CarModel? carModel;
  VehicleType? vehicleType;
  VehicleRentPrice? vehicleRentPrice;
  List<User>? favouriteUsers;
  double? rating;
  int? totalTrip;
  User? owner;
  bool like;
  List<Trip>? requests;
  Vehicle({
    this.id,
    this.carModelId,
    this.driverId,
    this.vehicleTypeId,
    this.regNo,
    this.color,
    this.isActive,
    this.verified,
    this.createdAt,
    this.updatedAt,
    this.yearMade,
    this.rentStatus,
    this.formattedDateTime,
    this.formattedDate,
    this.formattedUpdatedDate,
    this.utilites,
    this.requirementsForRent,
    this.latitude,
    this.longitude,
    this.distance,
    this.photo,
    this.carModel,
    this.vehicleType,
    this.vehicleRentPrice,
    this.favouriteUsers,
    this.rating,
    this.totalTrip,
    this.owner,
    this.like = false,
    this.fastBooking,
    this.deliveryToHome = false,
    this.mortgageExemption = true,
    this.deliveryDistance = 5,
    this.deliveryFee = 0,
    this.deliveryFree = 0,
    this.requests,
    this.describe,
    this.service,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    print("Vehicle data: $json");
    return Vehicle(
      id: json["id"],
      carModelId: json["car_model_id"],
      driverId: json["driver_id"],
      vehicleTypeId: json["vehicle_type_id"],
      regNo: json["reg_no"],
      color: json["color"],
      isActive: json["is_active"],
      verified: json["verified"],
      createdAt: json["created_at"] == null
          ? null
          : DateTime.parse(json["created_at"]),
      updatedAt: json["updated_at"] == null
          ? null
          : DateTime.parse(json["updated_at"]),
      yearMade: json["year_made"] == null ? null : json["year_made"],
      rentStatus: json["rent_status"],
      // formattedDateTime: json["formatted_date_time"],
      // formattedDate: json["formatted_date"],
      // formattedUpdatedDate: json["formatted_updated_date"],
      // // utilites: json["utilites"] == null
      // //     ? []
      // //     : List<String>.from(json["utilites"]!.map((x) => x)),
      // // requirementsForRent: json["requirements_for_rent"] == null
      // //     ? []
      // //     : List<String>.from(json["requirements_for_rent"]!.map((x) => x)),
      // latitude: json["latitude"] ?? '0',
      // longitude: json["longitude"] ?? '0',
      // distance: json["distance"],
      // // photo: json["photo"] == null
      // //     ? []
      // //     : List<String>.from(json["photo"]!.map((x) => x)),
      carModel: json["car_model"] == null
          ? null
          : CarModel.fromJson(json["car_model"]),
      vehicleType: VehicleType.fromJson(json["vehicle_type"]),
      service: json["vendor_type"] == null
          ? null
          : VendorType.fromJson(json["vendor_type"]),
      // // vehicleRentPrice: json["vehicle_rent_price"] == null
      // //     ? null
      // //     : VehicleRentPrice.fromJson(json["vehicle_rent_price"]),
      // owner: json["owner"] == null ? null : User.fromJson(json['owner']),
      // favouriteUsers: json["favorite_users"] == null
      //     ? null
      //     : List<User>.from(
      //         json["favorite_users"]!.map((x) => User.fromJson(x))),
      // totalTrip: json["total_trip"],
      // rating: json["rating"] == null
      //     ? 0.0
      //     : double.parse(json["rating"].toString()),
      // fastBooking: json["fast_booking"] == 1 ? true : false,
      // deliveryToHome: json["delivery_to_home"] == 1 ? true : false,
      // mortgageExemption: json["mortgage_exemption"] == 1 ? true : false,
      // requests: json["requests"] == null
      //     ? null
      //     : List<Trip>.from(json["requests"]!.map((x) => Trip.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "car_model_id": carModelId,
        "driver_id": driverId,
        "vehicle_type_id": vehicleTypeId,
        "reg_no": regNo,
        "color": color,
        "is_active": isActive,
        "verified": verified,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "year_made": yearMade,
        "rent_status": rentStatus,
        "formatted_date_time": formattedDateTime,
        "formatted_date": formattedDate,
        "formatted_updated_date": formattedUpdatedDate,
        "utilites":
            utilites == null ? [] : List<dynamic>.from(utilites!.map((x) => x)),
        "requirements_for_rent": requirementsForRent == null
            ? []
            : List<dynamic>.from(requirementsForRent!.map((x) => x)),
        "latitude": latitude,
        "longitude": longitude,
        "distance": distance,
        "photo": photo == null ? [] : List<dynamic>.from(photo!.map((x) => x)),
        "car_model": carModel?.toJson(),
        "vehicle_type": vehicleType?.toJson(),
        "vehicle_rent_price": vehicleRentPrice?.toJson(),
      };
      String get vehicleInfo {
    return "$color ${carModel?.carMake ?? ""} ${carModel?.name ?? ""}";
  }
}

class VehicleRentPrice {
  int? id;
  int? vehicleId;
  int? priceMondayFriday;
  int? priceSaturdaySunday;
  int? discountThreeDays;
  int? discountSevenDays;
  DateTime? createdAt;
  DateTime? updatedAt;

  VehicleRentPrice({
    this.id,
    this.vehicleId,
    this.priceMondayFriday,
    this.priceSaturdaySunday,
    this.discountSevenDays,
    this.discountThreeDays,
    this.createdAt,
    this.updatedAt,
  });

  factory VehicleRentPrice.fromJson(Map<String, dynamic> json) =>
      VehicleRentPrice(
        id: json["id"],
        vehicleId: json["vehicle_id"],
        priceMondayFriday: json["price_monday_friday"],
        priceSaturdaySunday: json["price_saturday_sunday"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        discountThreeDays: json["discount_three_days"] == null
            ? null
            : json["discount_three_days"],
        discountSevenDays: json["discount_seven_days"] == null
            ? null
            : json["discount_seven_days"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "vehicle_id": vehicleId,
        "price_monday_friday": priceMondayFriday,
        "price_saturday_sunday": priceSaturdaySunday,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "discount_three_days": discountThreeDays,
        "discount_seven_days": discountSevenDays,
      };
}

class CarModel {
  CarModel({
    required this.id,
    required this.name,
    required this.carMakeId,
    required this.carMake,
  });

  int id;
  String name;
  int carMakeId;
  CarMake? carMake;

  factory CarModel.fromJson(Map<String, dynamic> json) => CarModel(
        id: json["id"],
        name: json["name"],
        carMakeId: json["car_make_id"],
        carMake: json["car_make"] != null
            ? CarMake.fromJson(json["car_make"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "car_make_id": carMakeId,
        "car_make": carMake?.toJson(),
      };
}

class CarMake {
  CarMake({
    required this.id,
    required this.name,
  });

  int id;
  String name;

  factory CarMake.fromJson(Map<String, dynamic> json) => CarMake(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}