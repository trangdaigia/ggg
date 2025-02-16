// To parse this JSON data, do
//
//     final earning = earningFromJson(jsonString);

import 'dart:convert';

import 'package:dartx/dartx.dart';

Earning earningFromJson(String str) => Earning.fromJson(json.decode(str));

String earningToJson(Earning data) => json.encode(data.toJson());

class Earning {
  Earning({
    required this.id,
    required this.amount,
    this.userId,
    this.vendorId,
    required this.createdAt,
    required this.updatedAt,
    required this.formattedDate,
    required this.formattedUpdatedDate,
  });

  int id;
  double amount;
  int? userId;
  int? vendorId;
  DateTime createdAt;
  DateTime updatedAt;
  String formattedDate;
  String formattedUpdatedDate;

  factory Earning.fromJson(Map<String, dynamic> json) => Earning(
        id: json["id"].toString().toInt(),
        amount: double.tryParse(json["amount"].toString()) ?? 0.0,
        userId: json["user_id"],
        vendorId: json["vendor_id"],
        createdAt: json["created_at"] == null
            ? DateTime.now()
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? DateTime.now()
            : DateTime.parse(json["updated_at"]),
        formattedDate:
            json["formatted_date"] == null ? null : json["formatted_date"],
        formattedUpdatedDate: json["formatted_updated_date"] == null
            ? null
            : json["formatted_updated_date"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "amount": amount,
        "user_id": userId,
        "vendor_id": vendorId,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "formatted_date": formattedDate,
        "formatted_updated_date": formattedUpdatedDate,
      };
}
