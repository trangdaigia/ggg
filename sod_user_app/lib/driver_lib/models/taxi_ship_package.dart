// To parse this JSON data, do
//
//     final taxiShipPackage = taxiShipPackageFromJson(jsonString);

import 'dart:convert';
TaxiShipPackage taxiShipPackageFromJson(String str) => TaxiShipPackage.fromJson(json.decode(str));

String taxiShipPackageToJson(TaxiShipPackage data) => json.encode(data.toJson());

class TaxiShipPackage {
  TaxiShipPackage({
    required this.id,
    required this.taxiOrderId,
    required this.shipPackageType,
    required this.weight,
    required this.contactName,
    required this.contactNumber,
    this.floorNumberOrBuildingNumber,
    this.photo,
    this.noteForDrier,
    this.createdAt,
    this.updatedAt,
  });

  int id;
  int taxiOrderId;
  String shipPackageType;
  int weight;
  String contactName;
  String contactNumber;
  String? floorNumberOrBuildingNumber;
  String? noteForDrier;
  String? photo;
  DateTime? createdAt;
  DateTime? updatedAt;

  factory TaxiShipPackage.fromJson(Map<String, dynamic> json) => TaxiShipPackage(
        id: int.parse(json["id"].toString()),
        taxiOrderId: int.parse(json["taxi_order_id"].toString()),
        shipPackageType: json["ship_package_type"].toString(),
        weight: json["weight"],
        contactName: json["contact_name"],
        contactNumber: json["contact_number"],
        floorNumberOrBuildingNumber: json["floor_number_or_building_number"],
        noteForDrier: json["note_for_driver"],
        photo: json["photo"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "taxi_order_id": taxiOrderId,
        "ship_package_type_iD": shipPackageType,
        "weight": weight,
        "contact_name": contactName,
        "contact_number": contactNumber,
        "floor_number_or_building_number": floorNumberOrBuildingNumber,
        "note_for_drier": noteForDrier,
      };
}
