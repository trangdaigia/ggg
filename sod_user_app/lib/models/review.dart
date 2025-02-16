import 'dart:convert';

import 'package:sod_user/models/driver.dart';
import 'package:sod_user/models/user.dart';
import 'package:sod_user/models/vendor.dart';

Review reviewFromJson(String str) => Review.fromJson(json.decode(str));

String reviewToJson(Review data) => json.encode(data.toJson());

class Review {
  Review({
    required this.id,
    required this.rating,
    required this.review,
    required this.userId,
    required this.vendorId,
    required this.driverId,
    required this.orderId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.formattedDate,
    required this.formattedUpdatedDate,
    required this.photo,
    required this.vendor,
    required this.user,
    required this.driver,
  });

  int id;
  int rating;
  String review;
  int? userId;
  int? vendorId;
  int? driverId;
  int? orderId;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;
  String formattedDate;
  String formattedUpdatedDate;
  String photo;
  Vendor? vendor;
  User? user;
  Driver? driver;

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json["id"],
        rating: json["rating"],
        review: json["review"] ?? '',
        userId: json["user_id"],
        vendorId: json["vendor_id"],
        driverId: json["driver_id"],
        orderId: json["order_id"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
        formattedDate: json["formatted_date"] ?? '',
        formattedUpdatedDate: json["formatted_updated_date"] ?? '',
        photo: json["photo"] ?? '',
        vendor: json["vendor"] != null ? Vendor.fromJson(json["vendor"]) : null,
        user: json["user"] != null ? User.fromJson(json["user"]) : null,
        driver: json["driver"] != null ? Driver.fromJson(json["driver"]) : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "rating": rating,
        "review": review,
        "user_id": userId,
        "vendor_id": vendorId,
        "driver_id": driverId,
        "order_id": orderId,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "deleted_at": deletedAt,
        "formatted_date": formattedDate,
        "formatted_updated_date": formattedUpdatedDate,
        "photo": photo,
        "vendor": vendor?.toJson(),
        "user": user?.toJson(),
        "driver": driver?.toJson(),
      };
}
