import 'package:sod_user/driver_lib/models/delivery_address.dart';
import 'package:sod_user/driver_lib/models/order_attachment.dart';

class OrderStop {
  OrderStop({
    required this.id,
    this.orderId,
    this.stopId,
    this.name,
    this.phone,
    this.note,
    this.createdAt,
    this.updatedAt,
    this.formattedDate,
    this.deliveryAddress,
    this.attachments,
    this.verified = false,
  });

  int id;
  bool verified;
  int? orderId;
  int? stopId;
  String? name;
  String? phone;
  String? note;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? formattedDate;
  DeliveryAddress? deliveryAddress;
  List<OrderAttachment>? attachments;

  factory OrderStop.fromJson(Map<String, dynamic> json) {
    return OrderStop(
      id: json["id"] == null ? null : json["id"],
      orderId: json["order_id"] == null
          ? null
          : int.parse(json["order_id"].toString()),
      stopId: json["stop_id"] == null
          ? null
          : int.parse(json["stop_id"].toString()),
      name: json["name"] == null ? "" : json["name"],
      phone: json["phone"] == null ? "" : json["phone"],
      note: json["note"] == null ? "" : json["note"],
      verified: json["verified"] == null
          ? false
          : (int.parse(json["verified"].toString()) == 1),
      createdAt: json["created_at"] == null
          ? null
          : DateTime.parse(json["created_at"]),
      updatedAt: json["updated_at"] == null
          ? null
          : DateTime.parse(json["updated_at"]),
      formattedDate:
          json["formatted_date"] == null ? null : json["formatted_date"],
      deliveryAddress: json["delivery_address"] == null
          ? null
          : DeliveryAddress.fromJson(json["delivery_address"]),
      //attachments
      attachments: json["attachments"] == null
          ? []
          : List<OrderAttachment>.from(
              json["attachments"].map((x) => OrderAttachment.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "order_id": orderId,
        "stop_id": stopId == null && deliveryAddress != null
            ? deliveryAddress?.id
            : stopId,
        "name": name,
        "phone": phone,
        "note": note,
        "verified": verified ? 1 : 0,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "formatted_date": formattedDate == null ? null : formattedDate,
        "delivery_address": deliveryAddress?.toJson(),
        "attachments": attachments != null
            ? List<dynamic>.from(attachments!.map((x) => x.toJson()))
            : [],
      };
}
