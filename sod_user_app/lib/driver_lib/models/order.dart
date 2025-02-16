// To parse this JSON data, do
//
//     final order = orderFromJson(jsonString);

import 'dart:convert';
import 'package:sod_user/driver_lib/constants/app_strings.dart';
import 'package:sod_user/driver_lib/models/box.dart';
import 'package:sod_user/driver_lib/models/delivery_address.dart';
import 'package:sod_user/driver_lib/models/order_attachment.dart';
import 'package:sod_user/driver_lib/models/order_fee.dart';
import 'package:sod_user/driver_lib/models/order_service.dart';
import 'package:sod_user/driver_lib/models/order_stop.dart';
import 'package:sod_user/driver_lib/models/package_type.dart';
import 'package:sod_user/driver_lib/models/taxi_order.dart';
import 'package:sod_user/driver_lib/models/taxi_ship_package.dart';
import 'package:sod_user/driver_lib/models/vendor.dart';
import 'package:sod_user/driver_lib/models/order_product.dart';
import 'package:sod_user/driver_lib/models/payment_method.dart';
import 'package:sod_user/driver_lib/models/user.dart';
import 'package:jiffy/jiffy.dart';

Order orderFromJson(String str) => Order.fromJson(json.decode(str));

String orderToJson(Order data) => json.encode(data.toJson());

class Order {
  Order({
    required this.id,
    required this.canRate,
    required this.rateDriver,
    required this.code,
    required this.verificationCode,
    required this.note,
    required this.type,
    required this.status,
    required this.paymentStatus,
    this.subTotal,
    this.discount,
    this.deliveryFee,
    this.comission,
    this.tax,
    this.taxRate,
    this.tip,
    this.total,
    required this.deliveryAddressId,
    required this.paymentMethodId,
    required this.vendorId,
    required this.userId,
    required this.driverId,
    required this.createdAt,
    required this.updatedAt,
    required this.formattedDate,
    required this.paymentLink,
    required this.orderProducts,
    required this.orderStops,
    required this.user,
    required this.driver,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.vendor,
    required this.orderService,
    required this.taxiOrder,
    //
    required this.packageType,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.pickupDate,
    required this.pickupTime,
    this.recipientName,
    this.recipientPhone,
    required this.width,
    required this.height,
    required this.length,
    required this.weight,
    required this.payer,
    required this.photo,
    required this.attachments,
    required this.fees,
    this.receiveBehalfOrder,
  });

  int id;
  bool canRate;
  bool rateDriver;
  String code;
  String verificationCode;
  String note;
  String type;
  String status;
  String paymentStatus;
  double? subTotal;
  double? discount;
  double? deliveryFee;
  double? comission;
  double? tax;
  double? taxRate;
  double? tip;
  double? total;
  int? deliveryAddressId;
  int? paymentMethodId;
  int? vendorId;
  int userId;
  int? driverId;
  String? pickupDate;
  String? pickupTime;
  DateTime createdAt;
  DateTime updatedAt;
  String formattedDate;
  String paymentLink;
  List<OrderProduct>? orderProducts;
  List<OrderStop>? orderStops;
  User user;
  User? driver;
  DeliveryAddress? deliveryAddress;
  PaymentMethod? paymentMethod;
  Vendor? vendor;
  OrderService? orderService;
  TaxiOrder? taxiOrder;
  //Package related
  PackageType? packageType;
  DeliveryAddress? pickupLocation;
  DeliveryAddress? dropoffLocation;
  String? weight;
  String? length;
  String? height;
  String? width;
  String? payer;
  String? recipientName;
  String? recipientPhone;
  String? photo;
  List<OrderAttachment>? attachments;
  List<OrderFee>? fees;
  ReceiveBehalfOrder? receiveBehalfOrder;

  factory Order.fromJson(dynamic json) {
    //parse fees
    dynamic fees = json["fees"];
    if (fees.runtimeType == String) {
      try {
        fees = jsonDecode(jsonDecode(fees));
      } catch (e) {
        fees = jsonDecode(fees);
      }
    }

    return Order(
      id: json["id"] == null ? null : json["id"],
      canRate: json["can_rate"] == null ? null : json["can_rate"],
      rateDriver:
          json["can_rate_driver"] == null ? false : json["can_rate_driver"],
      code: json["code"] == null ? null : json["code"],
      verificationCode:
          json["verification_code"] == null ? "" : json["verification_code"],
      note: json["note"] == null ? "--" : json["note"],
      type: json["type"] == null ? null : json["type"],
      status: json["status"] == null ? null : json["status"],
      paymentStatus:
          json["payment_status"] == null ? null : json["payment_status"],
      subTotal: json["sub_total"] == null
          ? null
          : double.parse(json["sub_total"].toString()),
      discount: json["discount"] == null
          ? null
          : double.parse(json["discount"].toString()),
      deliveryFee: json["delivery_fee"] == null
          ? null
          : double.parse(json["delivery_fee"].toString()),
      comission: json["comission"] == null
          ? null
          : double.parse(json["comission"].toString()),
      //
      tax: json["tax"] == null ? null : double.parse(json["tax"].toString()),
      taxRate: json["tax_rate"] == null
          ? null
          : double.parse(json["tax_rate"].toString()),
      tip: json["tip"] == null ? 0.00 : double.parse(json["tip"].toString()),
      total:
          json["total"] == null ? null : double.parse(json["total"].toString()),
      deliveryAddressId: json["delivery_address_id"] == null
          ? null
          : int.parse(json["delivery_address_id"].toString()),
      //
      paymentMethodId: json["payment_method_id"] == null
          ? null
          : int.parse(json["payment_method_id"].toString()),
      vendorId: json["vendor_id"] == null
          ? null
          : int.parse(json["vendor_id"].toString()),
      userId: int.parse(json["user_id"].toString()),
      driverId: json["driver_id"] == null
          ? null
          : int.parse(json["driver_id"].toString()),
      createdAt: DateTime.parse(json["created_at"]),
      updatedAt: DateTime.parse(json["updated_at"]),
      formattedDate:
          json["formatted_date"] == null ? null : json["formatted_date"],
      paymentLink: json["payment_link"] == null ? "" : json["payment_link"],
      //
      orderProducts: json["products"] == null
          ? []
          : List<OrderProduct>.from(
              json["products"].map((x) => OrderProduct.fromJson(x))),
      orderStops: json["stops"] == null
          ? []
          : List<OrderStop>.from(
              json["stops"].map((x) => OrderStop.fromJson(x))),
      user: User.fromJson(json["user"]),
      driver: json["driver"] == null ? null : User.fromJson(json["driver"]),
      deliveryAddress: json["delivery_address"] == null
          ? null
          : DeliveryAddress.fromJson(json["delivery_address"]),
      paymentMethod: json["payment_method"] == null
          ? null
          : PaymentMethod.fromJson(json["payment_method"]),
      vendor: json["vendor"] == null ? null : Vendor.fromJson(json["vendor"]),
      orderService: json["order_service"] == null
          ? null
          : OrderService.fromJson(
              json["order_service"],
            ),
      taxiOrder: json["taxi_order"] == null
          ? null
          : TaxiOrder.fromJson(
              json["taxi_order"],
            ),

      //package related data
      packageType: json["package_type"] == null
          ? null
          : PackageType.fromJson(json["package_type"]),
      pickupLocation: json["pickup_location"] == null
          ? null
          : DeliveryAddress.fromJson(json["pickup_location"]),
      dropoffLocation: json["dropoff_location"] == null
          ? null
          : DeliveryAddress.fromJson(json["dropoff_location"]),
      recipientName: json["recipient_name"],
      recipientPhone: json["recipient_phone"],
      pickupDate: json["pickup_date"] != null
          ? Jiffy(json["pickup_date"]).format("dd MMM, yyyy")
          : "",
      pickupTime: "${json["pickup_date"]} ${json["pickup_time"]}",
      // Jiffy("${json["pickup_date"]} ${json["pickup_time"]}","yyyy-MM-dd hh:mm:ss").format("hh:mm a"),
      weight: json["weight"].toString(),
      length: json["length"].toString(),
      height: json["height"].toString(),
      width: json["width"].toString(),
      payer: json["payer"].toString(),
      fees: json["fees"] == null
          ? []
          : List<OrderFee>.from(
              (fees as List).map(
                (x) => OrderFee.fromJson(x),
              ),
            ),
      //attachments
      attachments: json["attachments"] == null
          ? []
          : List<OrderAttachment>.from(
              json["attachments"].map(
                (x) => OrderAttachment.fromJson(x),
              ),
            ),
      photo: json["photo"],
      receiveBehalfOrder: json['receive_behalf_order'] != null
          ? ReceiveBehalfOrder.fromJson(json['receive_behalf_order'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "code": code,
        "verification_code": verificationCode,
        "note": note,
        "type": type,
        "status": status,
        "payment_status": paymentStatus,
        "sub_total": subTotal,
        "discount": discount,
        "delivery_fee": deliveryFee,
        "comission": comission,
        "tax": tax,
        "tax_rate": taxRate,
        "total": total,
        "tip": tip,
        "delivery_address_id": deliveryAddressId,
        "payment_method_id": paymentMethodId,
        "vendor_id": vendorId,
        "user_id": userId,
        "driver_id": driverId,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "formatted_date": formattedDate,
        "payment_link": paymentLink,
        "products": List<dynamic>.from(
          (orderProducts ?? []).map((x) => x.toJson()),
        ),
        "stops": List<dynamic>.from((orderStops ?? []).map((x) => x.toJson())),
        "user": user.toJson(),
        "driver": driver?.toJson(),
        "delivery_address": deliveryAddress?.toJson(),
        "payment_method": paymentMethod?.toJson(),
        "vendor": vendor?.toJson(),
        "order_service": orderService?.toJson(),
        "taxi_order": taxiOrder?.toJson(),
        "fees": List<dynamic>.from((fees ?? []).map((x) => x.toJson())),
        "attachments": List<dynamic>.from(
          (attachments ?? []).map((x) => x.toJson()),
        ),
      };

  //getters

  //
  get isPaymentPending => paymentStatus == "pending";
  get isPackageDelivery => vendor?.vendorType?.slug == "parcel";

  //status => 'pending','preparing','enroute','failed','cancelled','delivered'
  get canChatVendor {
    if (!AppStrings.enableChat) {
      return false;
    }
    return ["pending", "preparing", "enroute"].contains(status);
  }

  get canChatCustomer {
    if (!AppStrings.enableChat) {
      return false;
    }
    return !["failed", "delivered", "cancelled"].contains(status);
  }

  get canChatDriver => ["enroute"].contains(status);
  String get taxiStatus {
    return status.contains("deliver") ? "completed" : status;
  }

  //
  bool get isUnpaid {
    return ['pending', 'request', 'review'].contains(paymentStatus) &&
        !["wallet", "cash"].contains([paymentMethod?.slug]);
  }

  get duration {
    return this.updatedAt.difference(this.createdAt).inMinutes;
  }
}

class ReceiveBehalfOrder {
  int? id;
  int? serviceFee;
  int? orderValue;
  int? paymentFee;
  Box? box;
  List<String>? photos;
  String? complaint;

  ReceiveBehalfOrder(
      {this.id,
      this.serviceFee,
      this.orderValue,
      this.paymentFee,
      this.box,
      this.photos,
      this.complaint});

  factory ReceiveBehalfOrder.fromJson(dynamic json) {
    return ReceiveBehalfOrder(
      id: json['id'],
      paymentFee: json['payment_fee'],
      orderValue: json['order_value'],
      serviceFee: json['service_fee'],
      box: json['box'] == null ? null : Box.fromJson(json['box']),
      photos: json["photos"] == null
          ? []
          : List<String>.from(json["photos"].map((x) => x)),
      complaint: json['complaint'],
    );
  }
}
