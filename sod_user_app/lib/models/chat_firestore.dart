import 'package:cloud_firestore/cloud_firestore.dart';

class ChatFirestore {
  final String id;
  final List<int> userIds;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final String lastMessageType;

  ChatFirestore({
    required this.id,
    required this.userIds,
    required this.lastMessage,
    this.lastMessageTime,
    required this.lastMessageType,
  });

  // Convert from Firestore document
  factory ChatFirestore.fromJson(Map<String, dynamic> json) {
    return ChatFirestore(
      id: json['id'] as String,
      userIds: List<int>.from(json['userIds'] as List<dynamic>),
      lastMessage: json['lastMessage'] as String,
      lastMessageTime: (json['lastMessageTime'] as Timestamp?)?.toDate(),
      lastMessageType: json['lastMessageType'] as String,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userIds': userIds,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'lastMessageType': lastMessageType,
    };
  }
}
