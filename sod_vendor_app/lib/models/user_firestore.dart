import 'package:cloud_firestore/cloud_firestore.dart';

class UserFirestore {
  final int id;
  final String name;
  final String? profileImage;
  final DateTime? lastActive;
  final bool isOnline;
  final String? pushToken;

  UserFirestore({
    required this.id,
    required this.name,
    this.profileImage,
    this.lastActive,
    this.isOnline = false,
    this.pushToken,
  });

  // Convert from Firestore document
  factory UserFirestore.fromJson(Map<String, dynamic> json) {
    return UserFirestore(
      id: json['id'] as int,
      name: json['name'] as String,
      profileImage: json['profileImage'] as String?,
      lastActive: (json['lastActive'] as Timestamp?)?.toDate(),
      isOnline: json['isOnline'] as bool? ?? false,
      pushToken: json['pushToken'] as String?,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profileImage': profileImage,
      'lastActive': lastActive,
      'isOnline': isOnline,
      'pushToken': pushToken,
    };
  }
}
