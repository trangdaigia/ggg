import 'package:sod_user/models/document_request.dart';
import 'package:sod_user/models/role.dart';

class User {
  int id;
  String name;
  String? code;
  String email;
  String phone;
  String? rawPhone;
  String? countryCode;
  String photo;
  String role;
  String walletAddress;
  String? rating;
  String? trip;
  String? responseRate;
  String? rateOfAgreement;
  String? feedbackIn;
  bool documentRequested;
  bool pendingDocumentApproval;
  DocumentRequest? documentRequest;
  List<Role> roles;
  DateTime? createdAt;
  User({
    required this.id,
    this.code,
    required this.name,
    required this.email,
    required this.phone,
    this.rawPhone,
    required this.countryCode,
    required this.photo,
    required this.role,
    required this.walletAddress,
    required this.roles,
    required this.documentRequested,
    required this.pendingDocumentApproval,
    this.rating,
    this.documentRequest,
    this.trip = '0',
    this.responseRate = '100%',
    this.rateOfAgreement = "100%",
    this.feedbackIn = '10',
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    print("User data: $json");
    return User(
      id: json['id'],
      code: json['code'] ?? "",
      name: json['name'],
      email: json['email'] ?? "",
      roles: (json['roles'] as List).map((e) => Role.fromJson(e)).toList(),
      phone: json['phone'] ?? "",
      documentRequested: json["document_requested"],
      pendingDocumentApproval: json['pending_document_approval'],
      documentRequest: json['document_request'] == null
          ? null
          : DocumentRequest.fromJson(json['document_request']),
      rawPhone: json['raw_phone'],
      walletAddress: json['wallet_address'] ?? "",
      countryCode: json['country_code'],
      photo: json['photo'] ?? "",
      role: json['role_name'] ?? "client",
      rating: json['rating'] ?? "0",
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'email': email,
      'phone': phone,
      'raw_phone': rawPhone,
      'country_code': countryCode,
      'photo': photo,
      'role_name': role,
      'wallet_address': walletAddress,
      'rating': rating,
      'trip': trip,
      'response_rate': responseRate,
      'rate_of_agreement': rateOfAgreement,
      'feedback_in': feedbackIn,
      'document_requested': documentRequested,
      'pending_document_approval': pendingDocumentApproval,
      'document_request': documentRequest?.toJson(),
      'roles': roles.map((role) => role.toJson()).toList(),
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
