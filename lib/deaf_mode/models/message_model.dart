import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String messageId;
  final String senderId;
  final String text;
  final DateTime? timestamp;
  final Map<String, String> reactions; // userId -> emoji
  final String status; // sent | delivered | read

  MessageModel({
    required this.messageId,
    required this.senderId,
    required this.text,
    this.timestamp,
    this.reactions = const {},
    this.status = 'sent',
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : FieldValue.serverTimestamp(),
      'reactions': reactions,
      'status': status,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      messageId: id,
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate(),
      reactions: Map<String, String>.from(map['reactions'] ?? {}),
      status: map['status'] ?? 'sent',
    );
  }
}
