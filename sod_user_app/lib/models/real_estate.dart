import 'dart:convert';

import 'package:sod_user/extensions/dynamic.dart';
import 'package:sod_user/models/category.dart';
import 'package:sod_user/models/real_estate_price.dart';
import 'package:sod_user/models/vendor.dart';

RealEstate realEstateFromJson(String str) =>
    RealEstate.fromJson(json.decode(str));

String realEstateToJson(RealEstate data) => json.encode(data.toJson());

class RealEstate {
  RealEstate(
      {required this.id,
      required this.name,
      required this.description,
      required this.shortDescription,
      required this.area,
      required this.price,
      required this.areaUnit,
      this.availableQty,
      required this.isActive,
      required this.photo,
      this.photos,
      required this.vendor,
      this.categories = const [],
      required this.status,
      required this.direction,
      required this.bedroom,
      required this.sellingType,
      required this.longtitude,
      required this.latitude,
      required this.vendorId,
      this.discountPrice,
      this.createdAt,
      this.rating,
      this.reviewsCount,
      this.prices,
      this.address}) {
    this.heroTag = dynamic.randomAlphaNumeric(15) + "$id";
  }

  int id;
  String name;
  String description;
  double area;
  double price;
  int? availableQty;
  bool isActive;
  String photo;
  List<String>? photos;
  Vendor? vendor;
  int vendorId;
  List<Category> categories; // IDs of related categories
  String status;
  String shortDescription;
  String direction;
  double longtitude;
  double latitude;
  int bedroom;
  String sellingType;
  List<RealEstatePrice>? prices;
  double? discountPrice;
  double? rating;
  int? reviewsCount;
  String areaUnit;
  DateTime? createdAt;
  String? heroTag;
  String? address;
  factory RealEstate.fromJson(Map<String, dynamic> json) {
    return RealEstate(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        shortDescription: json["short_description"],
        area: double.parse(json["area"].toString()),
        price: double.parse(json["price"].toString()),
        availableQty: json["available_qty"] == null
            ? null
            : int.parse(json["available_qty"].toString()),
        isActive: json["is_active"] == 1,
        photo: json["photo"],
        photos: json["photos"] == null
            ? []
            : List<String>.from(json["photos"].map((x) => x)),
        vendorId: json['vendor_id'],
        vendor: json['vendor'] == null ? null : Vendor.fromJson(json['vendor']),
        latitude: json['latitude'],
        longtitude: json['longtitude'],
        categories: json["categories"] == null
            ? []
            : List<Category>.from(
              json["categories"].map((x) => Category.fromJson(x)),
            ),
        status: json["status"] == null ? "Unknown" : json["status"].toString(),
        direction: json["direction"],
        prices: json['prices'] == null
            ? null
            : List<RealEstatePrice>.from(
              json["prices"].map((x) => RealEstatePrice.fromJson(x)),
            ),
        bedroom:
            json["bedroom"] == null ? 0 : int.parse(json["bedroom"].toString()),
        sellingType: json["selling_type"],
        discountPrice: json["discount_price"] == null
            ? null
            : double.parse(json["discount_price"].toString()),
        areaUnit: json["area_unit"] ?? "m2",
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        rating: json["rating"] == null
            ? null
            : double.parse(json["rating"].toString()),
        reviewsCount: json["reviews_count"] == null
            ? null
            : int.parse(json["reviews_count"].toString()),
        address: json['address']);
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "short_description": shortDescription,
        "area": area,
        "price": price,
        "available_qty": availableQty,
        "is_active": isActive ? 1 : 0,
        "photo": photo,
        "vendor_id": vendorId,
        "categories": categories.isEmpty
            ? null
            : List<dynamic>.from(categories.map((x) => x.toJson())),
        "status": status,
        "direction": direction,
        "bedroom": bedroom,
        "selling_type": sellingType,
        "discount_price": discountPrice,
        "address": address
      };

  // Getters for specific business logic
  bool get hasStock => availableQty == null || availableQty! > 0;
  bool get hasDiscount =>
      discountPrice != null && discountPrice! > 0 && discountPrice! < price;
  double get sellPrice => hasDiscount ? discountPrice! : price;
  double get priceByArea => (sellPrice / area).roundToDouble();
  int get discountPercentage {
    if (hasDiscount) {
      try {
        return 100 - (100 * (discountPrice! / price)).floor();
      } catch (e) {
        return 0;
      }
    }
    return 0;
  }
}
