class Distance {
  String? text;
  int? value;

  Distance({
    required this.text,
    required this.value,
  });

  factory Distance.fromJson(Map<String, dynamic> json) {
    return Distance(
      text: json['text'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'value': value,
    };
  }
}
