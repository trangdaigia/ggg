import 'dart:convert';

import 'package:sod_user/models/category.dart';

RealEstateCategory RealEstateCategoryFromJson(String str) =>
    RealEstateCategory.fromJson(json.decode(str));

String realEstateCatagoryToJson(RealEstateCategory data) =>
    json.encode(data.toJson());

class RealEstateCategory {
  RealEstateCategory({required this.totalQuantity, required this.category});
  final int totalQuantity;
  final Category category;

  factory RealEstateCategory.fromJson(Map<String, dynamic> json) {
    return RealEstateCategory(
        totalQuantity: json['total_quantity'],
        category: Category.fromJson(json));
  }

  Map<String, dynamic> toJson() => {
        ...category.toJson(),
        "total_quantity": totalQuantity,
      };
}
