// To parse this JSON data, do
//
//     final carRentalModel = carRentalModelFromJson(jsonString);

import 'dart:convert';

import 'package:sod_user/models/trip.dart';
import 'package:sod_user/models/user.dart';
import 'package:sod_user/models/vehicle_type.dart';

CarRentalModel carRentalModelFromJson(String str) =>
    CarRentalModel.fromJson(json.decode(str));

String carRentalModelToJson(CarRentalModel data) => json.encode(data.toJson());

class CarRentalModel {
  List<CarRental>? data;

  CarRentalModel({
    this.data,
  });

  factory CarRentalModel.fromJson(Map<String, dynamic> json) => CarRentalModel(
        data: json["data"] == null
            ? []
            : List<CarRental>.from(
                json["data"]!.map((x) => CarRental.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

VehicleRentPrice priceNull = VehicleRentPrice(
    priceMondayFriday: 0,
    priceSaturdaySunday: 0,
    discountSevenDays: 0,
    discountThreeDays: 0);

class CarRental {
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
  String? formattedDateTime;
  String? formattedDate;
  String? formattedUpdatedDate;
  List<String>? utilites;
  List<String>? requirementsForRent;
  String? latitude;
  String? longitude;
  double? distance;
  List<String>? photo;
  List<String>? newCarParrotPhotos;
  List<String>? newRegistrationPhotos;
  List<String>? newCivilLiabilityInsurancePhotos;
  List<String>? newVehicleBodyInsurancePhotos;
  CarModel? carModel;
  VehicleType? vehicleType;
  VehicleRentPrice? vehicleRentPrice = priceNull;
  List<User>? favouriteUsers;
  double? rating;
  int? totalTrip;
  User? owner;
  bool like;
  List<Trip>? requests;
  String? location;
  int? rental_options;
  String? rangeOfVehicle;
  CarRental({
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
    this.latitude = "10.706355",
    this.longitude = "106.568326",
    this.distance,
    this.photo,
    this.newCarParrotPhotos,
    this.newRegistrationPhotos,
    this.newCivilLiabilityInsurancePhotos,
    this.newVehicleBodyInsurancePhotos,
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
    this.deliveryFee = 12000,
    this.deliveryFree = 0,
    this.requests,
    this.describe,
    this.location,
    this.rental_options,
    this.rangeOfVehicle,
  });

  factory CarRental.fromJson(Map<String, dynamic> json) {
    return CarRental(
      location: json["location"] ?? '',
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
      yearMade: json["year_made"] ?? '',
      rentStatus: json["rent_status"],
      formattedDateTime: json["formatted_date_time"],
      formattedDate: json["formatted_date"],
      formattedUpdatedDate: json["formatted_updated_date"],
      utilites: (json["utilites"] as List?)?.map((e) => e.toString()).toList() ?? [],
      requirementsForRent: json["requirements_for_rent"] == null
          ? []
          : List<String>.from(json["requirements_for_rent"]!.map((x) => x)),
      latitude: json["latitude"],
      longitude: json["longitude"],
      distance: json["distance"] == null
          ? 0
          : double.parse(json["distance"].toString()),
      photo: json["photo"] == null
          ? []
          : List<String>.from(json["photo"]!.map((x) => x)),
      newCarParrotPhotos: json["new_car_parrot_photos"] == null
          ? []
          : List<String>.from(json["new_car_parrot_photos"]!.map((x) => x)),
      newRegistrationPhotos: json["new_registration_photos"] == null
          ? []
          : List<String>.from(json["new_registration_photos"]!.map((x) => x)),
      newCivilLiabilityInsurancePhotos:
          json["new_civil_liability_insurance_photos"] == null
              ? []
              : List<String>.from(
                  json["new_civil_liability_insurance_photos"]!.map((x) => x)),
      newVehicleBodyInsurancePhotos:
          json["new_vehicle_body_insurance_photos"] == null
              ? []
              : List<String>.from(
                  json["new_vehicle_body_insurance_photos"]!.map((x) => x)),
      carModel: json["car_model"] == null
          ? null
          : CarModel.fromJson(json["car_model"]),
      vehicleType: json["vehicle_type"] == null
          ? null
          : VehicleType.fromJson(json["vehicle_type"]),
      vehicleRentPrice: json["vehicle_rent_price"] == null
          ? priceNull
          : VehicleRentPrice.fromJson(json["vehicle_rent_price"]),
      owner: json["owner"] == null ? null : User.fromJson(json['owner']),
      favouriteUsers: json["favorite_users"] == null
          ? []
          : List<User>.from(json["favorite_users"]!
              .map((x) => User.fromJson(x["user_id"] != null ? x["user"] : x))),
      totalTrip: json["total_trip"] ?? 0,
      rating: json["rating"] == null
          ? 0.0
          : double.parse(json["rating"].toString()),
      fastBooking: json["fast_booking"] == 1 ? true : false,
      deliveryToHome: json["delivery_to_home"] == 1 ? true : false,
      mortgageExemption: json["mortgage_exemption"] == 1 ? true : false,
      requests: json["requests"] == null
          ? []
          : List<Trip>.from(json["requests"]!.map((x) => Trip.fromJson(x))),
      deliveryDistance: json["delivery_distance"],
      deliveryFee: json["delivery_fee"],
      deliveryFree: json["delivery_free"],
      describe: json["describe"] == null ? '' : json["describe"],
      rental_options:
          json["rental_options"] == null ? 0 : json["rental_options"],
      rangeOfVehicle:
          json['range_of_vehicle'] == null ? '' : json['range_of_vehicle'],
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
}

class CarModel {
  int? id;
  String? name;
  int? carMakeId;
  dynamic createdAt;
  dynamic updatedAt;
  int? tenantId;
  CarMake? carMake;

  CarModel({
    this.id,
    this.name,
    this.carMakeId,
    this.createdAt,
    this.updatedAt,
    this.tenantId,
    this.carMake,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) => CarModel(
        id: json["id"],
        name: json["name"],
        carMakeId: json["car_make_id"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        tenantId: json["tenant_id"],
        carMake: json["car_make"] == null
            ? null
            : CarMake.fromJson(json["car_make"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "car_make_id": carMakeId,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "tenant_id": tenantId,
        "car_make": carMake?.toJson(),
      };
}

class CarMake {
  int? id;
  String? name;
  dynamic createdAt;
  dynamic updatedAt;
  int? tenantId;

  CarMake({
    this.id,
    this.name,
    this.createdAt,
    this.updatedAt,
    this.tenantId,
  });

  factory CarMake.fromJson(Map<String, dynamic> json) => CarMake(
        id: json["id"],
        name: json["name"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        tenantId: json["tenant_id"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "tenant_id": tenantId,
      };
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
  int? priceMondayFridayWithDriver;
  int? priceSaturdaySundayWithDriver;
  int? drivingFee;
  int? priceOneKm;
  VehicleRentPrice({
    this.id,
    this.vehicleId,
    this.priceMondayFriday,
    this.priceSaturdaySunday,
    this.discountSevenDays,
    this.discountThreeDays,
    this.createdAt,
    this.updatedAt,
    this.priceMondayFridayWithDriver,
    this.priceSaturdaySundayWithDriver,
    this.drivingFee,
    this.priceOneKm,
  });

  factory VehicleRentPrice.fromJson(Map<String, dynamic> json) =>
      VehicleRentPrice(
        id: json["id"],
        vehicleId: json["vehicle_id"],
        priceMondayFriday: json["price_monday_friday"],
        priceSaturdaySunday: json["price_saturday_sunday"],
        priceMondayFridayWithDriver: json["price_monday_friday_with_driver"],
        priceSaturdaySundayWithDriver:
            json["price_saturday_sunday_with_driver"],
        drivingFee: json["driving_fee"],
        priceOneKm: json["price_one_km"],
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
