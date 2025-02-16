// To parse this JSON data, do
//
//     final carBrandModel = carBrandModelFromJson(jsonString);

import 'dart:convert';

List<CarBrandModel> carBrandModelFromJson(String str) =>
    List<CarBrandModel>.from(
        json.decode(str).map((x) => CarBrandModel.fromJson(x)));

String carBrandModelToJson(List<CarBrandModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CarBrandModel {
  int? id;
  String? name;
  dynamic createdAt;
  dynamic updatedAt;

  CarBrandModel({
    this.id,
    this.name,
    this.createdAt,
    this.updatedAt,
  });

  factory CarBrandModel.fromJson(Map<String, dynamic> json) => CarBrandModel(
        id: json["id"],
        name: json["name"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}
