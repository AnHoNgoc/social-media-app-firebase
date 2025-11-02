import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ChatRepo {
  Stream<List<Map<String, dynamic>>> getUsersStream();
  Future<void> sendMessage(String receiverId, String message);
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId);
  Stream<QuerySnapshot> getChatRooms();
  Future<DocumentSnapshot> getChatRoom(String chatRoomId);
}