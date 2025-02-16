import 'dart:convert';

TaxiShipPackageType taxiShipPackageTypeFromJson(String str) =>
    TaxiShipPackageType.fromJson(json.decode(str));

String taxiShipPackageTypeToJson(TaxiShipPackageType data) => json.encode(data.toJson());

class TaxiShipPackageType {
  TaxiShipPackageType({
    required this.id,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  int id;
  String name;
  DateTime? createdAt;
  DateTime? updatedAt;

  factory TaxiShipPackageType.fromJson(dynamic json) => TaxiShipPackageType(
        id: json["id"] ,
        name: json["name"],
    );

  Map<String, dynamic> toJson() => {
        "id": id.toString(),
        "name": name,
      };
}
