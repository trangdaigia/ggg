// To parse this JSON data, do

//
//     final carRentalDetailModel = carRentalDetailModelFromJson(jsonString);

import 'dart:convert';

import 'package:sod_user/models/vehicle_type.dart';

CarRentalDetailModel carRentalDetailModelFromJson(String str) =>
    CarRentalDetailModel.fromJson(json.decode(str));

String carRentalDetailModelToJson(CarRentalDetailModel data) =>
    json.encode(data.toJson());

class CarRentalDetailModel {
  int? id;
  int? carModelId;
  int? driverId;
  int? vehicleTypeId;
  String? regNo;
  String? color;
  int? isActive;
  bool? verified;
  dynamic yearMade;
  int? rentStatus;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? tenantId;
  String? longitude;
  String? latitude;
  String? utilities;
  String? requirementsForRent;
  String? formattedDateTime;
  String? formattedDate;
  String? formattedUpdatedDate;
  List<dynamic>? photo;
  CarModel? carModel;
  VehicleType? vehicleType;
  VehicleRentPrice? vehicleRentPrice;

  CarRentalDetailModel({
    this.id,
    this.carModelId,
    this.driverId,
    this.vehicleTypeId,
    this.regNo,
    this.color,
    this.isActive,
    this.verified,
    this.yearMade,
    this.rentStatus,
    this.createdAt,
    this.updatedAt,
    this.tenantId,
    this.longitude,
    this.latitude,
    this.utilities,
    this.requirementsForRent,
    this.formattedDateTime,
    this.formattedDate,
    this.formattedUpdatedDate,
    this.photo,
    this.carModel,
    this.vehicleType,
    this.vehicleRentPrice,
  });

  factory CarRentalDetailModel.fromJson(Map<String, dynamic> json) =>
      CarRentalDetailModel(
        id: json["id"],
        carModelId: json["car_model_id"],
        driverId: json["driver_id"],
        vehicleTypeId: json["vehicle_type_id"],
        regNo: json["reg_no"],
        color: json["color"],
        isActive: json["is_active"],
        verified: json["verified"],
        yearMade: json["year_made"],
        rentStatus: json["rent_status"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        tenantId: json["tenant_id"],
        longitude: json["longitude"],
        latitude: json["latitude"],
        utilities: json["utilities"],
        requirementsForRent: json["requirements_for_rent"],
        formattedDateTime: json["formatted_date_time"],
        formattedDate: json["formatted_date"],
        formattedUpdatedDate: json["formatted_updated_date"],
        photo: json["photo"] == null
            ? []
            : List<dynamic>.from(json["photo"]!.map((x) => x)),
        carModel: json["car_model"] == null
            ? null
            : CarModel.fromJson(json["car_model"]),
        vehicleType: json["vehicle_type"] == null
            ? null
            : VehicleType.fromJson(json["vehicle_type"]),
        vehicleRentPrice: json["vehicle_rent_price"] == null
            ? null
            : VehicleRentPrice.fromJson(json["vehicle_rent_price"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "car_model_id": carModelId,
        "driver_id": driverId,
        "vehicle_type_id": vehicleTypeId,
        "reg_no": regNo,
        "color": color,
        "is_active": isActive,
        "verified": verified,
        "year_made": yearMade,
        "rent_status": rentStatus,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "tenant_id": tenantId,
        "longitude": longitude,
        "latitude": latitude,
        "utilities": utilities,
        "requirements_for_rent": requirementsForRent,
        "formatted_date_time": formattedDateTime,
        "formatted_date": formattedDate,
        "formatted_updated_date": formattedUpdatedDate,
        "photo": photo == null ? [] : List<dynamic>.from(photo!.map((x) => x)),
        "car_model": carModel?.toJson(),
        "vehicle_type": vehicleType?.toJson(),
        "vehicle_rent_price": vehicleRentPrice?.toJson(),
      };
}

class VehicleRentPrice {
  int? id;
  int? vehicleId;
  int? priceMondayFriday;
  int? priceSaturdaySunday;
  DateTime? createdAt;
  DateTime? updatedAt;

  VehicleRentPrice({
    this.id,
    this.vehicleId,
    this.priceMondayFriday,
    this.priceSaturdaySunday,
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
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "vehicle_id": vehicleId,
        "price_monday_friday": priceMondayFriday,
        "price_saturday_sunday": priceSaturdaySunday,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
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

