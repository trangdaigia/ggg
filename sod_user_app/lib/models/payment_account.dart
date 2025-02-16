// To parse this JSON data, do
//
//     final paymentAccount = paymentAccountFromJson(jsonString);

import 'dart:convert';

PaymentAccount paymentAccountFromJson(String str) =>
    PaymentAccount.fromJson(json.decode(str));

String paymentAccountToJson(PaymentAccount data) => json.encode(data.toJson());

class PaymentAccount {
  PaymentAccount({
    required this.bankName,
    required this.name,
    required this.number,
    required this.id,
    required this.instructions,
    required this.isActive,
  });

  String bankName;
  String name;
  String number;
  int id;
  String instructions;
  bool isActive;
 

  factory PaymentAccount.fromJson(Map<String, dynamic> json) => PaymentAccount(
        bankName: json["bank_name"] == null ? '' : json["bank_name"],
        name: json["name"],
        number: json["number"],
        id: json["id"],
        instructions: json["instructions"] == null ? '' : json["instructions"],
        isActive: json["is_active"] == 1 ? true : false,
      );

  Map<String, dynamic> toJson() => {
        "bank_name": bankName,
        "name": name,
        "id": id,
        "number": number,
        "instructions": instructions,
        "is_active": isActive ? "1" : "0",
      };
  @override
  String toString() {
    return 'PaymentAccount{bankName: $bankName, name: $name, number: $number, id: $id, instructions: $instructions, isActive: $isActive}';
  }
}
