import 'package:sod_user/driver_lib/models/building.dart';

class Box {
  Box({
    this.id,
    this.name,
    this.description,
    this.building,
  });

  int? id;
  String? name;
  String? description;
  Building? building;

  factory Box.fromJson(Map<String, dynamic> json) => Box(
        id: json["id"],
        name: json["name"],
        description: json["description"] == null ? '' : json["description"],
        building: json['building'] == null
            ? null
            : Building.fromJson(json['building']),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "building": building!.toJson(),
      };
}
