class Area {
  Area({
    this.id,
    this.name,
    this.description,
  });

  int? id;
  String? name;
  String? description;

  factory Area.fromJson(Map<String, dynamic> json) => Area(
        id: json["id"],
        name: json["name"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
      };
}
