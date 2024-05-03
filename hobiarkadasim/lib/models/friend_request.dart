import 'package:cloud_firestore/cloud_firestore.dart';

class FriendRequest {
  final String senderId;
  final String receiverId;
  final String status;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  FriendRequest({
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FriendRequest.fromMap(Map<String, dynamic> map) {
    return FriendRequest(
      senderId: map['sender_id'],
      receiverId: map['receiver_id'],
      status: map['status'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sender_id': senderId,
      'receiver_id': receiverId,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}