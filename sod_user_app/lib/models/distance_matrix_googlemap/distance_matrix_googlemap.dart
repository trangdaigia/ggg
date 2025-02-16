import 'package:sod_user/models/distance_matrix_googlemap/row.dart';

class DistanceMatrixGoogleMap {
  List<String>? destinationAddresses;
  List<String>? originAddresses;
  List<Row>? rows;

  DistanceMatrixGoogleMap({
    required this.destinationAddresses,
    required this.originAddresses,
    required this.rows,
  });

  factory DistanceMatrixGoogleMap.fromJson(Map<String, dynamic> json) {
    return DistanceMatrixGoogleMap(
      destinationAddresses: List<String>.from(json['destination_addresses']),
      originAddresses: List<String>.from(json['origin_addresses']),
      rows: List<Row>.from(json['rows'].map((row) => Row.fromJson(row))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'destination_addresses': destinationAddresses,
      'origin_addresses': originAddresses,
      'rows': rows?.map((row) => row.toJson()).toList(),
    };
  }
}
