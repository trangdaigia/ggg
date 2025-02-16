// To parse this JSON data, do
//
//     final taxiOrder = taxiOrderFromJson(jsonString);

import 'dart:convert';
import 'package:sod_user/driver_lib/models/currency.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:sod_user/driver_lib/models/taxi_ship_package.dart';
import 'package:supercharged/supercharged.dart';

TaxiOrder taxiOrderFromJson(String str) => TaxiOrder.fromJson(json.decode(str));

String taxiOrderToJson(TaxiOrder data) => json.encode(data.toJson());

class TaxiOrder {
  TaxiOrder({
    required this.id,
    required this.type,
    required this.orderId,
    required this.vehicleTypeId,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.pickupAddress,
    required this.dropoffLatitude,
    required this.dropoffLongitude,
    required this.dropoffAddress,
    required this.createdAt,
    required this.updatedAt,
    this.currency,
    this.shipPackage,
    this.request_driver_gender,
  });

  int id;

  int orderId;
  String type;
  int vehicleTypeId;
  String pickupLatitude;
  String pickupLongitude;
  String pickupAddress;
  String dropoffLatitude;
  String dropoffLongitude;
  String dropoffAddress;
  DateTime createdAt;
  DateTime updatedAt;
  Currency? currency;
  String? request_driver_gender;
  TaxiShipPackage? shipPackage;

  factory TaxiOrder.fromJson(Map<String, dynamic> json) => TaxiOrder(
      id: json["id"].toString().toInt()!,
      type: json["type"].toString(),
      orderId: json["order_id"].toString().toInt()!,
      vehicleTypeId: json["vehicle_type_id"].toString().toInt()!,
      pickupLatitude: json["pickup_latitude"],
      pickupLongitude: json["pickup_longitude"],
      pickupAddress: json["pickup_address"],
      dropoffLatitude: json["dropoff_latitude"],
      dropoffLongitude: json["dropoff_longitude"],
      dropoffAddress: json["dropoff_address"],
      createdAt: DateTime.parse(json["created_at"]),
      updatedAt: DateTime.parse(json["updated_at"]),
      currency:
          json["currency"] != null ? Currency.fromJSON(json["currency"]) : null,
      request_driver_gender: json['request_driver_gender'] != null
          ? json["request_driver_gender"]
          : null,
      shipPackage: json['ship_package'] != null
          ? TaxiShipPackage.fromJson(json['ship_package'])
          : null);

  Map<String, dynamic> toJson() => {
        "id": id,
        "order_id": orderId,
        "vehicle_type_id": vehicleTypeId,
        "pickup_latitude": pickupLatitude,
        "pickup_longitude": pickupLongitude,
        "pickup_address": pickupAddress,
        "dropoff_latitude": dropoffLatitude,
        "dropoff_longitude": dropoffLongitude,
        "dropoff_address": dropoffAddress,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "currency": currency != null ? currency?.toJson() : null,
      };

  LatLng get pickupLatLng {
    return LatLng(
      pickupLatitude.toDouble()!,
      pickupLongitude.toDouble()!,
    );
  }

  LatLng get dropoffLatLng {
    return LatLng(
      dropoffLatitude.toDouble()!,
      dropoffLongitude.toDouble()!,
    );
  }

  get startTime {
    return DateFormat("h:m a").format(this.createdAt);
  }

  get endTime {
    return DateFormat("h:m a").format(this.updatedAt);
  }
}
