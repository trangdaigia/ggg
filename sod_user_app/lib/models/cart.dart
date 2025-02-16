import 'dart:convert';
import 'package:sod_user/models/option.dart';
import 'package:sod_user/models/product.dart';

Cart cartFromJson(String str) => Cart.fromJson(json.decode(str));

String cartToJson(Cart data) => json.encode(data.toJson());

class Cart {
  Cart({
    this.price,
    this.product,
    this.options,
    this.optionsIds,
    this.selectedQty,
  });

  //
  int? selectedQty;
  double? price;
  Product? product;
  List<Option>? options;
  List<int>? optionsIds;

  //

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      selectedQty: json["selected_qty"] == null ? 1 : json["selected_qty"],
      price:
          json["price"] == null ? 0.00 : double.parse(json["price"].toString()),
      product: Product.fromJson(json["product"]),
      options: json["options"] == null
          ? null
          : List<Option>.from(
              json["options"].map((x) => Option.fromJson(x)),
            ),
      optionsIds: json["options_ids"] == null
          ? null
          : List<int>.from(json["options_ids"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "selected_qty": selectedQty,
        "price": price,
        "product": product?.toJson(),
        "options": options == null
            ? null
            : List<dynamic>.from(options!.map((x) => x.toJson())),
        "options_ids": optionsIds == null ? null : optionsIds,
        "options_flatten": optionsSentence,
      };

  //to toCheckout
  Map toCheckout() {
    return {
      "selected_qty": selectedQty,
      "price": price,
      "product": product?.toCheckout(),
      "options": options == null
          ? null
          : List<dynamic>.from(options!.map((x) => x.toJson())),
      "options_ids": optionsIds == null ? null : optionsIds,
      "options_flatten": optionsSentence,
    };
  }

  //
  String get optionsSentence {
    var optionsSelected = "";
    final optionsLength = options?.length ?? 0;
    options?.asMap().forEach((index, option) {
      optionsSelected += option.name;
      if (optionsLength > (index) + 1) {
        optionsSelected += ", ";
      }
    });
    return optionsSelected;
  }
}
