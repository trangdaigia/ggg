import 'dart:convert';

RealEstatePrice realEstatePriceFromJson(String str) =>
    RealEstatePrice.fromJson(json.decode(str));

String realEstatePriceToJson(RealEstatePrice data) =>
    json.encode(data.toJson());

class RealEstatePrice {
  RealEstatePrice({
    required this.realEstateId,
    required this.price,
    required this.priceDate,
    this.formattedDate,
  });

  final int realEstateId;
  final double price;
  final DateTime priceDate;
  final String? formattedDate;
  factory RealEstatePrice.fromJson(Map<String, dynamic> json) {
    return RealEstatePrice(
      realEstateId: json['real_estate_id'],
      price: (json['price'] as num).toDouble(), // Ensure price is double
      priceDate: DateTime.parse(json['price_date']),
      formattedDate: json['formatted_date'].toString().substring(0, 6)
    );
  }

  Map<String, dynamic> toJson() => {
        "real_estate_id": realEstateId,
        "price": price,
        "price_date": priceDate.toIso8601String(),
      };
}
