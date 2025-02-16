import 'package:sod_user/models/area.dart';

class Building {
  Building({
    this.id,
    this.name,
    this.address,
    this.longitude,
    this.latitude,
    this.area,
  });

  int? id;
  String? name;
  String? address;
  String? longitude;
  String? latitude;
  Area? area;

  factory Building.fromJson(Map<String, dynamic> json) => Building(
        id: json["id"],
        name: json["name"],
        address: json["address"],
        longitude: json["longitude"],
        latitude: json["latitude"],
        area: json['area'] == null ? null : Area.fromJson(json['area']),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "address": address,
        "latitude": latitude,
        "longitude": longitude,
        "area": area!.toJson(),
      };
}
