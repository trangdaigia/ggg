// To parse this JSON data, do
//
//     final taxiOrder = taxiOrderFromJson(jsonString);

import 'dart:convert';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/models/currency.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sod_user/models/taxi_ship_package.dart';

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
    this.request_driver_gender,
    this.shipPackage,
    this.currency,
    this.base_fare,
    this.distance_fare,
    this.time_fare,
    this.trip_distance,
    this.trip_time,
  });

  int id;
  int orderId;
  String type;
  String? request_driver_gender;
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
  String? base_fare;
  String? distance_fare;
  String? time_fare;
  String? trip_distance;
  String? trip_time;
  TaxiShipPackage? shipPackage;

  factory TaxiOrder.fromJson(Map<String, dynamic> json) => TaxiOrder(
        id: int.parse(json["id"].toString()),
        type: json["type"].toString(),
        orderId: int.parse(json["order_id"].toString()),
        vehicleTypeId: int.parse(json["vehicle_type_id"].toString()),
        pickupLatitude: json["pickup_latitude"],
        pickupLongitude: json["pickup_longitude"],
        pickupAddress: json["pickup_address"],
        dropoffLatitude: json["dropoff_latitude"],
        dropoffLongitude: json["dropoff_longitude"],
        dropoffAddress: json["dropoff_address"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        currency: json['currency'] != null
            ? Currency.fromJSON(json['currency'])
            : null,
        //Breakdown
        base_fare: json['base_fare'],
        distance_fare: json['distance_fare'],
        time_fare: json['time_fare'],
        trip_distance: json['trip_distance'],
        trip_time: json['trip_time'],
        request_driver_gender: json['request_driver_gender'] != null ? json["request_driver_gender"] : null,
        shipPackage: json['ship_package'] != null ? TaxiShipPackage.fromJson(json['ship_package']) : null
      );

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
        "currency": currency != null ? currency!.toJson() : null,
        //Breakdown
        "base_fare": base_fare,
        "distance_fare": distance_fare,
        "time_fare": time_fare,
        "trip_distance": trip_distance,
        "trip_time": trip_time,
      };

  LatLng get pickupLatLng => LatLng(
        double.parse(pickupLatitude.toString()),
        double.parse(pickupLongitude.toString()),
      );
  LatLng get dropoffLatLng => LatLng(
        double.parse(dropoffLatitude.toString()),
        double.parse(dropoffLongitude.toString()),
      );

  //
  String get currencySymbol {
    return currency != null ? currency!.symbol : AppStrings.currencySymbol;
  }
}
