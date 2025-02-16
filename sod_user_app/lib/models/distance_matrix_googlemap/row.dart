import 'package:sod_user/models/distance_matrix_googlemap/element.dart';

class Row {
  List<Element> elements;

  Row({
    required this.elements,
  });

  factory Row.fromJson(Map<String, dynamic> json) {
    return Row(
      elements: List<Element>.from(
          json['elements'].map((element) => Element.fromJson(element))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'elements': elements.map((element) => element.toJson()).toList(),
    };
  }
}
