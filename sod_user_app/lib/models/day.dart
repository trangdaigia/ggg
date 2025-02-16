class Day {
  int? id;
  String? name;
  Pivot? pivot;

  Day({this.id, this.name, this.pivot});

  factory Day.fromJson(Map<String, dynamic> json) {
    return Day(
      id: json['id'],
      name: json['name'],
      pivot: Pivot.fromJson(json['pivot']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "pivot": pivot?.toJson(),
    };
  }
}

class Pivot {
  int? vendorId;
  int? dayId;
  int? id;
  String? open;
  String? close;

  Pivot({this.vendorId, this.dayId, this.id, this.open, this.close});

  factory Pivot.fromJson(Map<String, dynamic> json) {
    return Pivot(
      vendorId: json['vendor_id'],
      dayId: json['day_id'],
      open: json['open'],
      close: json['close'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "vendor_id": vendorId,
      "day_id": dayId,
      "open": open,
      "close": close,
    };
  }
}
