import 'dart:convert';
import 'package:sod_user/extensions/dynamic.dart';
import 'package:sod_user/models/category.dart';
import 'package:sod_user/models/vendor.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import 'service_option.dart';
import 'service_option_group.dart';

Service ServiceFromJson(String str) => Service.fromJson(json.decode(str));

String ServiceToJson(Service data) => json.encode(data.toJson());

class Service {
  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.discountPrice,
    required this.duration,
    required this.isActive,
    required this.vendorId,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    required this.formattedDate,
    required this.vendor,
    required this.category,
    required this.photos,
    this.selectedQty,
    required this.location,
    this.optionGroups,
    this.token,
    this.ageRestricted = false,
  }) {
    this.heroTag = dynamic.randomAlphaNumeric(15) + "$id";
  }

  int id;
  String? heroTag;
  String name;
  String description;
  double price;
  double? discountPrice;
  String duration;
  int isActive;
  int vendorId;
  int? categoryId;
  DateTime createdAt;
  DateTime updatedAt;
  String formattedDate;
  Vendor vendor;
  Category? category;
  List<String>? photos;
  int? selectedQty;
  bool location;
  List<ServiceOptionGroup>? optionGroups;
  String? token;
  bool ageRestricted;

  //add varibale to hold the selected options
  List<ServiceOption> selectedOptions = [];

  factory Service.fromJson(Map<String, dynamic> json) {
    //print('List hình là: ${json["photos"]}');
    return Service(
      id: json["id"] == null ? null : json["id"],
      name: json["name"] == null ? null : json["name"],
      description: json["description"] == null ? "" : json["description"],
      price: double.parse(json["price"].toString()),
      discountPrice: json["discount_price"] == null
          ? null
          : double.parse(json["discount_price"].toString()),
      duration: json["duration"],
      isActive: json["is_active"] == null
          ? 0
          : int.parse(json["is_active"].toString()),
      vendorId: int.parse(json["vendor_id"].toString()),
      categoryId: json["category_id"] == null ? null : json["category_id"],
      createdAt: DateTime.parse(json["created_at"]),
      updatedAt: DateTime.parse(json["updated_at"]),
      formattedDate:
          json["formatted_date"] == null ? null : json["formatted_date"],
      vendor: Vendor.fromJson(json["vendor"]),
      category:
          json["category"] == null ? null : Category.fromJson(json["category"]),

      // photos
      photos: json["photos"] == null
          ? []
          : List<String>.from(
              json["photos"].map((x) => x),
            ),
      location: json["location"] ?? true,

      //
      optionGroups: json["option_groups"] == null
          ? []
          : List<ServiceOptionGroup>.from(
              json["option_groups"].map(
                (x) => ServiceOptionGroup.fromJson(x),
              ),
            ),

      //
      token: json["token"],
      ageRestricted: json["age_restricted"] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "price": price,
        "discount_price": discountPrice == null ? null : discountPrice,
        "duration": duration,
        "location": location,
        "is_active": isActive,
        "vendor_id": vendorId,
        "category_id": categoryId == null ? null : categoryId,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "formatted_date": formattedDate,
        "vendor": vendor.toJson(),
        "category": category?.toJson(),
        "option_groups": optionGroups == null
            ? null
            : List<dynamic>.from(optionGroups!.map((x) => x.toJson())),
        "token": token,
        "age_restricted": ageRestricted,
      };

  //getters
  bool get showDiscount =>
      discountPrice != null &&
      (discountPrice! > 0.00) &&
      (discountPrice! < price);
  bool get isPerHour => duration == "hour";
  bool get isFixed => duration == "fixed";
  double get sellPrice {
    try {
      return showDiscount ? discountPrice! : price;
    } catch (e) {
      return price;
    }
  }

  int get discountPercentage {
    if (discountPrice == null) {
      return 0;
    }
    if (discountPrice! < price) {
      // return 100 - (100 * ((price - discountPrice) / price) ?? 0).floor();
      return 100 - (100 * (discountPrice! / price)).floor();
    } else {
      return 0;
    }
  }

  String get durationText {
    return "${isFixed ? '' : '/${duration.tr()}'}";
  }

  //
  bool get hasOptions {
    return optionGroups != null && optionGroups!.length > 0;
  }
}
