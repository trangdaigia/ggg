import 'package:supercharged/supercharged.dart';
class User {
  int id;
  String name;
  String? email;
  String? phone;
  String photo;
  String role;
  int? vendorId;
  double rating;
  bool isOnline = false;
  bool isTaxiDriver = false;
  bool documentRequested;
  bool pendingDocumentApproval;

  String? gender;
  String? rawPhone;
  String? countryId;
  String? stateId;
  String? cityId;
  User(
      {required this.id,
      required this.name,
      required this.email,
      required this.phone,
      required this.photo,
      required this.role,
      required this.vendorId,
      required this.rating,
      required this.isOnline,
      required this.isTaxiDriver,
      required this.rawPhone,
      this.documentRequested = false,
      this.pendingDocumentApproval = false,
      this.gender,
      this.countryId,
      this.stateId,
      this.cityId,
      });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      photo: json['photo'] ?? "",
      role: json['role_name'] ?? "client",
      vendorId: json['vendor_id'],
      rating: json['rating'].toString().toDouble() ?? 5.00,
      isOnline: (json['is_online'].toString().toInt() ?? 0) == 1,
      isTaxiDriver: (json['is_taxi_driver'].toString().toInt() ?? 0) == 1,
      documentRequested: json["document_requested"] == null ? false : json["document_requested"],
      pendingDocumentApproval: json["pending_document_approval"] == null ? false : json["pending_document_approval"],
      gender: json["gender"] != null ? json["gender"] : "male",
      rawPhone: json['raw_phone'],
      countryId: json['country_id'].toString(),
      stateId: json['state_id'].toString(),
      cityId: json['city_id'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'photo': photo,
      'role_name': role,
      'vendor_id': vendorId,
      'rating': rating,
      'is_online': isOnline ? 1 : 0,
      'is_taxi_driver': isTaxiDriver ? 1 : 0,
      'document_requested': documentRequested,
      'pending_document_approval': pendingDocumentApproval,
      'gender': gender,
      
      'country_id': countryId,
      'state_id': stateId,
      'city_id': cityId,
    };
  }
}
