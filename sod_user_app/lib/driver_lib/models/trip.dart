import 'package:sod_user/driver_lib/models/user.dart';
import 'package:sod_user/driver_lib/models/vehicle.dart';

class Trip {
  int? id;
  String? totalDays;
  String? debutDate;
  String? expireDate;
  String? contactPhone;
  String? status;
  User? user;
  Vehicle? vehicle;
  int? totalPrice;
  Trip({
    this.id,
    this.totalDays,
    this.debutDate,
    this.expireDate,
    this.contactPhone,
    this.status,
    this.user,
    this.vehicle,
    this.totalPrice,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'],
      totalDays: json['total_days'],
      debutDate: json['debut_date'],
      expireDate: json['expire_date'],
      contactPhone: json['contact_phone'],
      status: json['status'],
      user: User.fromJson(json['user']),
      vehicle:
          json['vehicle'] == null ? null : Vehicle.fromJson(json['vehicle']),
      totalPrice: json["total_price"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'total_days': totalDays,
      'debut_date': debutDate,
      'expire_date': expireDate,
      'contact_phone': contactPhone,
      'status': status,
      'user': user?.toJson(),
      'vehicle': vehicle?.toJson(),
    };
  }
}
