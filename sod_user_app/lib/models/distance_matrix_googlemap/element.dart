import 'package:sod_user/models/distance_matrix_googlemap/distance.dart';

class Element {
  Distance? distance;
  Distance? duration;

  Element({
    required this.distance,
    required this.duration,
  });

  factory Element.fromJson(Map<String, dynamic> json) {
    return Element(
      distance: Distance.fromJson(json['distance']),
      duration: Distance.fromJson(json['duration']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'distance': distance?.toJson(),
      'duration': duration?.toJson(),
    };
  }
}
