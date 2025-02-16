// To parse this JSON data, do
//
//     final vendor = vendorFromJson(jsonString);

import 'dart:convert';

import 'package:sod_user/extensions/dynamic.dart';
import 'package:sod_user/models/category.dart';
import 'package:sod_user/models/day.dart';
import 'package:sod_user/models/delivery_address.dart';
import 'package:sod_user/models/delivery_slot.dart';
import 'package:sod_user/models/fee.dart';
import 'package:sod_user/models/menu.dart';
import 'package:sod_user/models/package_type_pricing.dart';
import 'package:sod_user/models/vendor_type.dart';
import 'package:sod_user/utils/utils.dart';

class Vendor {
  Vendor({
    required this.id,
    required this.vendorTypeId,
    required this.vendorType,
    required this.name,
    required this.description,
    required this.baseDeliveryFee,
    required this.deliveryFee,
    required this.deliveryRange,
    required this.distance,
    required this.tax,
    required this.phone,
    required this.email,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.comission,
    required this.pickup,
    required this.delivery,
    required this.rating,
    required this.reviews_count,
    required this.chargePerKm,
    required this.isOpen,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.formattedDate,
    required this.logo,
    required this.featureImage,
    required this.menus,
    required this.categories,
    required this.packageTypesPricing,
    required this.fees,
    required this.cities,
    required this.states,
    required this.countries,
    required this.deliverySlots,
    required this.canRate,
    required this.allowScheduleOrder,
    required this.hasSubcategories,
    //
    required this.minOrder,
    required this.maxOrder,
    required this.prepareTime,
    required this.deliveryTime,
    this.days,
  }) {
    this.heroTag = dynamic.randomAlphaNumeric(25) + "$id";
  }

  int id;
  int vendorTypeId;
  VendorType vendorType;
  String? heroTag;
  String name;
  String description;
  double baseDeliveryFee;
  double deliveryFee;
  double deliveryRange;
  double? distance;
  String tax;
  String phone;
  String email;
  String address;
  String latitude;
  String longitude;
  double? comission;
  double? minOrder;
  double? maxOrder;
  int pickup;
  int delivery;
  int rating;
  int reviews_count;
  int chargePerKm;
  bool isOpen;
  int isActive;
  DateTime createdAt;
  DateTime updatedAt;
  String formattedDate;
  String logo;
  String featureImage;
  List<Menu> menus;
  List<Category> categories;
  List<PackageTypePricing> packageTypesPricing;
  List<DeliverySlot> deliverySlots;
  List<Fee> fees;
  List<String> cities;
  List<String> states;
  List<String> countries;
  bool canRate;
  bool allowScheduleOrder;
  bool hasSubcategories;
  String? prepareTime;
  String? deliveryTime;
  List<Day>? days;

  factory Vendor.fromRawJson(String str) => Vendor.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Vendor.fromJson(Map<String, dynamic> json) {
    Vendor vendor = Vendor(
      id: json["id"] == null ? null : json["id"],
      vendorTypeId: json["vendor_type_id"],
      vendorType:
          // json["vendor_type"] == null ? VendorType( id: 0, name: 'name',description: 'description',slug: 'slug',color: 'color',isActive: 0,logo: 'logo',hasBanners: false) :
          VendorType.fromJson(json["vendor_type"]),
      name: json["name"] == null ? null : json["name"],
      description: json["description"] == null ? "" : json["description"],
      baseDeliveryFee: json["base_delivery_fee"] == null
          ? 0.00
          : double.parse(json["base_delivery_fee"].toString()),
      deliveryFee: json["delivery_fee"] == null
          ? 0.00
          : double.parse(json["delivery_fee"].toString()),
      deliveryRange: json["delivery_range"] == null
          ? 0
          : double.parse(json["delivery_range"].toString()),
      distance: double.tryParse(json["distance"].toString()),
      tax: json["tax"] == null ? null : json["tax"],
      phone: json["phone"] == null ? null : json["phone"],
      email: json["email"] == null ? null : json["email"],
      address: json["address"] == null ? "" : json["address"],
      latitude: json["latitude"] == null ? "0.00" : json["latitude"],
      longitude: json["longitude"] == null ? "0.00" : json["longitude"],
      comission: json["comission"] == null
          ? 0
          : double.parse(json["comission"].toString()),
      pickup: json["pickup"] == null ? 0 : int.parse(json["pickup"].toString()),
      delivery:
          json["delivery"] == null ? 0 : int.parse(json["delivery"].toString()),
      rating: json["rating"] == null ? 5 : int.parse(json["rating"].toString()),
      reviews_count: json["reviews_count"],
      chargePerKm: json["charge_per_km"] == null
          ? 0
          : int.parse(json["charge_per_km"].toString()),
      isOpen: json["is_open"] == null ? true : json["is_open"],
      isActive: json["is_active"] == null
          ? 0
          : int.parse(json["is_active"].toString()),
      createdAt: DateTime.parse(json["created_at"]),
      updatedAt: DateTime.parse(json["updated_at"]),
      formattedDate:
          json["formatted_date"] == null ? null : json["formatted_date"],
      logo: json["logo"] == null ? null : json["logo"],
      featureImage:
          json["feature_image"] == null ? null : json["feature_image"],
      menus: json["menus"] == null
          ? []
          : List<Menu>.from(json["menus"].map((x) => Menu.fromJson(x))),
      categories: json["categories"] == null
          ? []
          : List<Category>.from(
              json["categories"].map((x) => Category.fromJson(x))),
      packageTypesPricing: json["package_types_pricing"] == null
          ? []
          : List<PackageTypePricing>.from(json["package_types_pricing"]
              .map((x) => PackageTypePricing.fromJson(x))),
      //cities
      cities: json["cities"] == null
          ? []
          : List<String>.from(json["cities"].map((e) => e["name"])),
      states: json["states"] == null
          ? []
          : List<String>.from(json["states"].map((e) => e["name"])),
      countries: json["cities"] == null
          ? []
          : List<String>.from(json["countries"].map((e) => e["name"])),
      //
      deliverySlots: json["slots"] == null
          ? []
          : List<DeliverySlot>.from(
              json["slots"].map((x) => DeliverySlot.fromJson(x))),
      fees: json["fees"] == null
          ? []
          : List<Fee>.from(json["fees"].map((x) => Fee.fromJson(x))),

      //
      canRate: json["can_rate"] == null ? null : json["can_rate"],
      hasSubcategories: json["has_sub_categories"] == null
          ? false
          : json["has_sub_categories"],
      allowScheduleOrder: json["allow_schedule_order"] == null
          ? false
          : json["allow_schedule_order"],

      //
      minOrder:
          (json["min_order"] == null || json["min_order"].toString().isEmpty)
              ? null
              : (double.parse(json["min_order"].toString())),
      maxOrder:
          (json["max_order"] == null || json["max_order"].toString().isEmpty)
              ? null
              : (double.parse(json["max_order"].toString())),
      //
      prepareTime:
          json["prepare_time"] != null ? json["prepare_time"].toString() : null,
      deliveryTime: json["delivery_time"] != null
          ? json["delivery_time"].toString()
          : null,
      days: json["days"] != null
          ? List<Day>.from(json["days"].map((x) => Day.fromJson(x)))
          : [],
    );

    //check if distance is null, then call utils to calculate distance
    if (vendor.distance == null) {
      vendor.distance = Utils.vendorDistance(vendor);
    }
    //
    return vendor;
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "vendor_type_id": vendorTypeId,
        "vendor_type": vendorType.toJson(),
        "name": name,
        "description": description,
        "base_delivery_fee": baseDeliveryFee,
        "delivery_fee": deliveryFee,
        "delivery_range": deliveryRange,
        "distance": distance,
        "tax": tax,
        "phone": phone,
        "email": email,
        "address": address,
        "latitude": latitude,
        "longitude": longitude,
        "comission": comission != null ? comission : null,
        "min_order": minOrder != null ? minOrder : null,
        "max_order": maxOrder != null ? maxOrder : null,
        "pickup": pickup,
        "delivery": delivery,
        "rating": rating,
        "reviews_count": reviews_count,
        "charge_per_km": chargePerKm,
        "is_open": isOpen,
        "is_active": isActive,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "formatted_date": formattedDate,
        "logo": logo,
        "feature_image": featureImage,
        "can_rate": canRate,
        "allow_schedule_order": allowScheduleOrder,
        "menus": List<dynamic>.from(menus.map((x) => x.toJson())),
        "categories": List<dynamic>.from(categories.map((x) => x.toJson())),
        "package_types_pricing":
            List<dynamic>.from(packageTypesPricing.map((x) => x.toJson())),
        "slots": List<dynamic>.from(deliverySlots.map((x) => x.toJson())),
        "fees": List<dynamic>.from(fees.map((x) => x.toJson())),
        //
        "prepare_time": prepareTime,
        "delivery_time": deliveryTime,
      };

  //categorize type and allowance of schedule order
  bool get allowOnlyDelivery => delivery == 1 && pickup == 0;
  bool get allowOnlyPickup => delivery == 0 && pickup == 1;
  bool get isServiceType => vendorType.slug == "service";
  bool get isPharmacyType => vendorType.slug == "pharmacy";

  //find location
  bool canServiceLocation(DeliveryAddress deliveryaddress) {
    String findCountry = "${deliveryaddress.country}".toLowerCase();
    String findState = "${deliveryaddress.state}".toLowerCase();
    String findCity = "${deliveryaddress.city}".toLowerCase();

    //countries, states and cities

    //countries
    if (this.countries.isNotEmpty) {
      final foundCountry = this.countries.firstWhere(
            (element) => element.toLowerCase() == findCountry,
            orElse: () => "",
          );

      //
      if (foundCountry != findCountry) {
        print("Country found");
        return true;
      }
    }

    //states
    if (this.states.isNotEmpty) {
      final foundState = this.states.firstWhere(
            (element) =>
                element.toLowerCase() ==
                "${deliveryaddress.state}".toLowerCase(),
            orElse: () => "",
          );

      //
      if (foundState != findState) {
        print("state found");
        return true;
      }
    }

    //cities
    if (this.cities.isNotEmpty) {
      final foundCity = this.cities.firstWhere(
        (element) {
          return element.toLowerCase() == findCity;
        },
        orElse: () => "",
      );

      //
      if (foundCity != findCity) {
        print("city found");
        return true;
      }
    }
    return false;
  }
}
