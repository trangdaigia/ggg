import 'package:sod_user/models/user.dart';
import 'package:sod_user/models/vehicle.dart';
import 'package:sod_user/services/auth.service.dart';

class Driver {
  Vehicle? vehicle;
  List<Vehicle> vehicles = [];
  int id;
  int assignedOrders;
  bool? hasMultipleVendors;
  int? vendorId;
  String rating;
  bool isOnline = false;
  bool isActive = false;
  bool isTaxiDriver = false;
  User user;

  Driver({
    required this.id,
    required this.assignedOrders,
    required this.isOnline,
    required this.isActive,
    required this.rating,
    required this.user,
    this.hasMultipleVendors,
    this.vehicles = const [], // Default to empty list if not provided
    this.vendorId,
    this.vehicle,
  });

  // Factory method to convert JSON to Driver object
  factory Driver.fromJson(Map<String, dynamic> json, {bool withUser = true}) {
    print('Driver data: $json');

    return Driver(
      id: json['id'],
      isOnline: json['is_online'] == 1,
      isActive: json['is_active'] == 1,
      assignedOrders: json['assigned_orders'] ?? 0,
      hasMultipleVendors: json['has_multiple_vendors'],
      user: withUser
          ? User.fromJson(json)
          : AuthServices
              .currentUser!, // Ensure currentUser is used when `withUser` is false
      vehicle:
          json['vehicle'] != null ? Vehicle.fromJson(json['vehicle']) : null,
      vehicles: json['vehicles'] != null
          ? (json['vehicles'] as List).map((e) => Vehicle.fromJson(e)).toList()
          : [],
      rating: json['rating'] ?? "0",
    );
  }

  // Method to convert Driver object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': this.id,
      'is_active': this.isActive ? 1 : 0,
      'is_online': this.isOnline ? 1 : 0,
      'vendor_id': this.vendorId,
      'has_multiple_vendors': this.hasMultipleVendors,
      'vehicle': this.vehicle?.toJson(),
      'vehicles': this.vehicles.map((e) => e.toJson()).toList(),
      'rating': this.rating,
      ...this.user.toJson(),
    };
  }
}
