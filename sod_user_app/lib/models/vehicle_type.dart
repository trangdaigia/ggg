// To parse this JSON data, do
//
//     final vehicleType = vehicleTypeFromJson(jsonString);

import 'dart:convert';
import 'package:dartx/dartx.dart';
import 'package:sod_user/models/currency.dart';

VehicleType vehicleTypeFromJson(String str) =>
    VehicleType.fromJson(json.decode(str));

String vehicleTypeToJson(VehicleType data) => json.encode(data.toJson());

class VehicleType {
  VehicleType({
    required this.id,
    required this.name,
    required this.slug,
    required this.baseFare,
    required this.distanceFare,
    required this.timeFare,
    required this.minFare,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.formattedDate,
    required this.photo,
    required this.total,
    required this.encrypted,
    required this.currency,
    required this.vendorTypeId,
    this.onSelect = false,
  });

  int id;
  String name;
  int vendorTypeId;
  String slug;
  double baseFare;
  double distanceFare;
  double timeFare;
  double total;
  double minFare;
  int isActive;
  DateTime? createdAt;
  DateTime? updatedAt;
  String formattedDate;
  bool onSelect = false;
  String photo;
  String? encrypted;
  Currency? currency;

  factory VehicleType.fromJson(Map<String, dynamic> json) {
    return VehicleType(
      id: json["id"],
      name: json["name"],
      vendorTypeId: json["vendor_type_id"] ?? 0,
      slug: json["slug"],
      baseFare: json["base_fare"].toString().toDouble(),
      distanceFare: json["distance_fare"].toString().toDouble(),
      timeFare: json["time_fare"].toString().toDouble(),
      minFare: json["min_fare"].toString().toDouble(),
      total: json["total"] == null ? 0.0 : json["total"].toString().toDouble(),
      isActive: json["is_active"],
      createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
      updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
      formattedDate: json["formatted_date"],
      photo: json["photo"],
      encrypted: json["encrypted"],
      currency:
          json["currency"] != null ? Currency.fromJSON(json["currency"]) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "vendor_type_id": vendorTypeId,
        "slug": slug,
        "base_fare": baseFare,
        "distance_fare": distanceFare,
        "time_fare": timeFare,
        "min_fare": minFare,
        "total": total,
        "is_active": isActive,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "formatted_date": formattedDate,
        "photo": photo,
        "encrypted": encrypted,
        "currency": currency != null ? currency?.toJson() : null,
      };
}
