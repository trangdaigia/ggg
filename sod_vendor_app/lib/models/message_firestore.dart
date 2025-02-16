import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageTypes { text, image, location, unknown }

class MessageFirestore {
  final String chatId;
  final int fromId;
  final int toId;
  final String message;
  final MessageTypes type;
  final DateTime? sentAt;
  final bool read;

  MessageFirestore({
    required this.chatId,
    required this.fromId,
    required this.toId,
    required this.message,
    required this.type,
    this.sentAt,
    this.read = false,
  });

  // Convert from Firestore document
  factory MessageFirestore.fromJson(Map<String, dynamic> json) {
    return MessageFirestore(
      chatId: json['chatId'] as String,
      fromId: json['fromId'] as int,
      toId: json['toId'] as int,
      message: json['message'] as String,
      type: MessageTypes.values
          .firstWhere((t) => t.name == json['type'] as String),
      sentAt: (json['sentAt'] as Timestamp?)?.toDate(),
      read: json['read'] as bool? ?? false,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'fromId': fromId,
      'toId': toId,
      'message': message,
      'type': type.name,
      'sentAt': sentAt,
      'read': read,
    };
  }
}
