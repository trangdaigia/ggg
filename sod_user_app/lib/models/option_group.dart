// To parse this JSON data, do
//
//     final optionGroup = optionGroupFromJson(jsonString);

import 'dart:convert';

import 'package:sod_user/models/option.dart';

OptionGroup optionGroupFromJson(String str) =>
    OptionGroup.fromJson(json.decode(str));

String optionGroupToJson(OptionGroup data) => json.encode(data.toJson());

class OptionGroup {
  OptionGroup({
    required this.id,
    required this.name,
    required this.multiple,
    required this.required,
    this.maxOptions,
    required this.isActive,
    required this.photo,
    required this.options,
  });

  int id;
  String name;
  int multiple;
  int required;
  int? maxOptions;
  int isActive;
  String photo;
  List<Option> options;

  factory OptionGroup.fromJson(Map<String, dynamic> json) => OptionGroup(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        multiple: json["multiple"] == null
            ? 0
            : int.parse(json["multiple"].toString()),
        required: json["required"] == null
            ? 0
            : int.parse(json["required"].toString()),
        isActive: json["is_active"] == null
            ? 0
            : int.parse(json["is_active"].toString()),
        photo: json["photo"] == null ? null : json["photo"],
        options: json["options"] == null
            ? []
            : List<Option>.from(json["options"].map((x) => Option.fromJson(x))),
        maxOptions: json["max_options"] ?? null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "multiple": multiple,
        "required": required,
        "max_options": maxOptions,
        "is_active": isActive,
        "photo": photo,
        "options": List<dynamic>.from(options.map((x) => x.toJson())),
      };
}
