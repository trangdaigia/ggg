class DistanceMatrixVietMap {
  List<List<int>>? durations;
  List<List<double>>? distances;

  DistanceMatrixVietMap({
    this.durations,
    this.distances,
  });

  factory DistanceMatrixVietMap.fromJson(Map<String, dynamic> json) {
    return DistanceMatrixVietMap(
      durations: (json['durations'] as List)
          .map((list) => List<int>.from(list))
          .toList(),
      distances: (json['distances'] as List)
          .map((list) => List<double>.from(list))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'durations': durations?.map((list) => list).toList(),
      'distances': distances?.map((list) => list).toList(),
    };
  }
}
