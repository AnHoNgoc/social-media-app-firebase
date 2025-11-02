import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  final String chatRoomId;
  final List<String> users;
  final String lastMessage;
  final String lastSenderId;
  final Timestamp lastTimestamp;

  ChatRoom({
    required this.chatRoomId,
    required this.users,
    required this.lastMessage,
    required this.lastSenderId,
    required this.lastTimestamp,
  });
}